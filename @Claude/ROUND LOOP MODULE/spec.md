# ROUND LOOP MODULE — Spec

**Status:** Finalized
**Pipeline Stage:** Spec → Ready for Ticket Agent
**Last Updated:** 2026-04-04

---

## Purpose
Manage the full lifecycle of a game round — intermission countdown, round start, active play timer, win/loss detection, round end, and lobby reset. This is the central orchestrator of the game; every other module reacts to events this module fires.

---

## Responsibilities
- Intermission countdown displayed in the lobby before each round
- Signal the Tower Assembly Module to build the tower during intermission
- Open the tower portal when the round begins
- Run the server-side round timer (8 minutes)
- Detect when a player touches the FinishPlatform (win condition)
- Detect when the timer expires with no winner (round over, no winner)
- Announce results to all players
- Teleport all players back to LobbySpawn
- Signal Tower Assembly to tear down and reset the tower
- Begin next intermission

---

## Decisions (All Resolved)

| Decision | Value | Reasoning |
|---|---|---|
| Intermission duration | 20 seconds | Matches Tower of Hell pacing; enough time for players to read results from the previous round before the next build starts |
| Minimum players to start | 1 | Solo play is supported for testing; no lobby-fill gate needed at this stage |
| Round duration | 8 minutes | Standard Tower of Hell duration; tunable later |
| Who gets rewarded | All players get a small participation coin reward; first player to touch FinishPlatform gets a larger winner reward | Keeps casual players engaged, rewards skill without making non-winners feel the round was pointless |
| Exact coin amounts | TBD — delegated to Player Module | Round Loop fires a win/participate event with a result type; Player Module decides the coin value |
| What happens if no one wins | Round ends at timer expiry, no winner announced, all players get participation reward only | Clean fallback; no edge-case handling needed |
| Portal behavior | TowerPortal opens at round start, closes at round end | Prevents late joiners from entering mid-round; consistent with Tower of Hell |
| Mid-round respawn | Players who fall are killed by KillPlane and respawned to LobbySpawn; they cannot re-enter the tower unless they own the "Infinite Attempts" gamepass | Gamepass check is delegated to the Gamepasses Module |
| Round state storage | Stored in a single server-side ModuleScript (`RoundState`) — not in DataStore | Round state is ephemeral; only persistent data (coins, etc.) lives in DataStore |
| TimerTick frequency | Every 1 second | Sufficient for a countdown display; low server overhead |

---

## Round Phases

### Phase 1 — Intermission
**Duration:** 20 seconds

**What happens:**
1. `RoundManager` script sets state to `"Intermission"`
2. Fires `RoundStateChanged` BindableEvent with value `"Intermission"` — UI clients update the timer display
3. `TimerTick` RemoteEvent fires every second to all clients with the remaining countdown (20 → 0)
4. `workspace.TimerDisplay.TimerBoard` SurfaceGui is updated server-side each tick
5. `TowerPortal.PortalTrigger` is made non-collidable and visually "closed" (transparency set to 0.8) — players cannot enter
6. Fires `BuildTower` BindableEvent → Tower Assembly Module assembles the tower during these 20 seconds
7. At 0 seconds, transitions to Round Start

**Objects involved:**
- `workspace.TimerDisplay.TimerBoard` (SurfaceGui)
- `workspace.TowerPortal.PortalTrigger` (BasePart)
- `BindableEvent: BuildTower` (ServerScriptService)
- `RemoteEvent: TimerTick` (ReplicatedStorage)
- `RemoteEvent: RoundStateChanged` (ReplicatedStorage)

---

### Phase 2 — Round Start
**Duration:** Instant (single frame transition)

**What happens:**
1. `RoundManager` sets state to `"RoundStart"`
2. Fires `RoundStateChanged` RemoteEvent with value `"RoundStart"` to all clients
3. Opens `TowerPortal.PortalTrigger` — sets CanCollide = true, transparency = 0 (fully visible/open)
4. Fires `RoundStart` RemoteEvent to all clients — client UI shows "GO!" splash or equivalent
5. Starts the 8-minute round timer (480 ticks)
6. Transitions immediately to Active Round

**Objects involved:**
- `workspace.TowerPortal.PortalTrigger` (BasePart)
- `RemoteEvent: RoundStart` (ReplicatedStorage)
- `RemoteEvent: RoundStateChanged` (ReplicatedStorage)

---

### Phase 3 — Active Round
**Duration:** Up to 8 minutes (480 seconds)

**What happens:**
1. `RoundManager` sets state to `"Active"`
2. `TimerTick` RemoteEvent fires every second to all clients with remaining time
3. `workspace.TimerDisplay.TimerBoard` updates each tick
4. `FinishPlatform` touch detection is active — a `.Touched` connection on `workspace.FinishPlatform` checks for a humanoid
5. If a player touches `FinishPlatform`:
   - Record winner's UserId and username in `RoundState`
   - Fires `PlayerWon` RemoteEvent to all clients with winner's name
   - Fires `AwardWinner` BindableEvent → Player Module grants winner coins
   - Transitions to Round End immediately
6. If timer reaches 0 with no winner:
   - Transitions to Round End with no winner

**Objects involved:**
- `workspace.FinishPlatform` (BasePart — `.Touched` connection)
- `workspace.TimerDisplay.TimerBoard` (SurfaceGui)
- `RemoteEvent: TimerTick` (ReplicatedStorage)
- `RemoteEvent: PlayerWon` (ReplicatedStorage)
- `BindableEvent: AwardWinner` (ServerScriptService)

---

### Phase 4 — Round End
**Duration:** 5 seconds (results display before reset)

**What happens:**
1. `RoundManager` sets state to `"RoundEnd"`
2. Fires `RoundEnd` RemoteEvent to all clients with result data: `{ winner = "PlayerName" | nil, timedOut = true | false }`
3. Client UI displays results screen (winner announcement or "nobody won" message) — handled by client script, not this module
4. Fires `AwardParticipants` BindableEvent → Player Module grants participation coins to all players currently in the server
5. Closes `TowerPortal.PortalTrigger` (CanCollide = false, transparency = 0.8) — no new entries
6. After 5 seconds, transitions to Reset

**Objects involved:**
- `workspace.TowerPortal.PortalTrigger` (BasePart)
- `RemoteEvent: RoundEnd` (ReplicatedStorage)
- `BindableEvent: AwardParticipants` (ServerScriptService)

---

### Phase 5 — Reset
**Duration:** ~2 seconds (cleanup, then loops to Intermission)

**What happens:**
1. `RoundManager` sets state to `"Reset"`
2. Teleports all players to `workspace.LobbySpawn` (CFrame them to the spawn position)
3. Fires `DestroyTower` BindableEvent → Tower Assembly Module destroys all cloned section Parts and repositions `FinishPlatform` out of the way (or sets it invisible)
4. Clears `RoundState` (winner, timer value reset to 20)
5. After cleanup confirms (or after a 2-second yield), loops back to Intermission

**Objects involved:**
- `workspace.LobbySpawn` (SpawnLocation — used for CFrame target)
- `BindableEvent: DestroyTower` (ServerScriptService)
- `RoundState` ModuleScript (internal state reset)

---

## Server Script Architecture

All scripts live in `ServerScriptService > Scripts` (the Scripts Folder defined in the Layout Module).

### Scripts to Write

#### `RoundManager` (Script)
- Location: `ServerScriptService > Scripts > RoundManager`
- Type: Regular Script (server-only)
- Responsibility: The main loop. Runs the phase sequence: Intermission → RoundStart → Active → RoundEnd → Reset → repeat. Owns the `RoundState` values. Connects `.Touched` on `FinishPlatform`. Fires all RemoteEvents and BindableEvents.
- Contains an infinite `while true do` loop that advances through phases using `task.wait()`

#### `RoundState` (ModuleScript)
- Location: `ServerScriptService > Scripts > RoundState`
- Type: ModuleScript
- Responsibility: Holds current round state values so other server scripts can read them without coupling to `RoundManager`. Values: `currentPhase`, `winner`, `roundTimeRemaining`, `roundActive`.
- `RoundManager` is the only script that writes to this module. Other scripts read it.

#### `RoundClient` (LocalScript)
- Location: `StarterPlayerScripts > ClientScripts > RoundClient`
- Type: LocalScript (runs on each player's client)
- Responsibility: Listens to RemoteEvents (`RoundStateChanged`, `RoundStart`, `RoundEnd`, `TimerTick`, `PlayerWon`). Updates the `TimerDisplay` SurfaceGui text and triggers client-side UI (results screen, "GO!" splash). Does not make any game logic decisions — display only.

### Communication

| From | To | Method | Event Name | Payload |
|---|---|---|---|---|
| RoundManager (server) | All clients | RemoteEvent | `RoundStateChanged` | `string` — phase name |
| RoundManager (server) | All clients | RemoteEvent | `RoundStart` | none |
| RoundManager (server) | All clients | RemoteEvent | `RoundEnd` | `{ winner: string\|nil, timedOut: bool }` |
| RoundManager (server) | All clients | RemoteEvent | `TimerTick` | `number` — seconds remaining |
| RoundManager (server) | All clients | RemoteEvent | `PlayerWon` | `string` — winner's display name |
| RoundManager (server) | Tower Assembly | BindableEvent | `BuildTower` | none |
| RoundManager (server) | Tower Assembly | BindableEvent | `DestroyTower` | none |
| RoundManager (server) | Player Module | BindableEvent | `AwardWinner` | `number` — winner's UserId |
| RoundManager (server) | Player Module | BindableEvent | `AwardParticipants` | none |

---

## Roblox Studio Objects Required

These objects do not exist from the Layout Module and must be created before scripting begins.

### ReplicatedStorage — New RemoteEvents

Create a Folder named `RemoteEvents` inside `ReplicatedStorage`, then add these RemoteEvent instances inside it:

| Object | Type | Location |
|---|---|---|
| `RoundStateChanged` | RemoteEvent | `ReplicatedStorage > RemoteEvents` |
| `RoundStart` | RemoteEvent | `ReplicatedStorage > RemoteEvents` |
| `RoundEnd` | RemoteEvent | `ReplicatedStorage > RemoteEvents` |
| `TimerTick` | RemoteEvent | `ReplicatedStorage > RemoteEvents` |
| `PlayerWon` | RemoteEvent | `ReplicatedStorage > RemoteEvents` |

### ServerScriptService — New BindableEvents

Create a Folder named `BindableEvents` inside `ServerScriptService`, then add these BindableEvent instances inside it:

| Object | Type | Location |
|---|---|---|
| `BuildTower` | BindableEvent | `ServerScriptService > BindableEvents` |
| `DestroyTower` | BindableEvent | `ServerScriptService > BindableEvents` |
| `AwardWinner` | BindableEvent | `ServerScriptService > BindableEvents` |
| `AwardParticipants` | BindableEvent | `ServerScriptService > BindableEvents` |

### ServerScriptService — New Scripts Folder Entries

| Object | Type | Location |
|---|---|---|
| `RoundManager` | Script | `ServerScriptService > Scripts` |
| `RoundState` | ModuleScript | `ServerScriptService > Scripts` |

### StarterPlayerScripts — New Client Script

| Object | Type | Location |
|---|---|---|
| `RoundClient` | LocalScript | `StarterPlayerScripts > ClientScripts` |

### Full Updated ReplicatedStorage Hierarchy

```
ReplicatedStorage
├── Sections                    (Folder) -- from Layout Module
│   └── [section models...]
├── Characters                  (Folder) -- from Layout Module
│   └── [skin models...]
└── RemoteEvents                (Folder) -- NEW
    ├── RoundStateChanged       (RemoteEvent)
    ├── RoundStart              (RemoteEvent)
    ├── RoundEnd                (RemoteEvent)
    ├── TimerTick               (RemoteEvent)
    └── PlayerWon               (RemoteEvent)
```

### Full Updated ServerScriptService Hierarchy

```
ServerScriptService
├── Scripts                     (Folder) -- from Layout Module
│   ├── RoundManager            (Script)       -- NEW
│   └── RoundState              (ModuleScript) -- NEW
└── BindableEvents              (Folder) -- NEW
    ├── BuildTower              (BindableEvent)
    ├── DestroyTower            (BindableEvent)
    ├── AwardWinner             (BindableEvent)
    └── AwardParticipants       (BindableEvent)
```

---

## Connections to Other Modules

### Layout Module
The Round Loop Module reads Layout Module objects directly by name. It does not fire any events to it — the Layout Module's objects are static world geometry.

| Object Used | How It Is Used |
|---|---|
| `workspace.TowerPortal.PortalTrigger` | CanCollide and Transparency toggled at Round Start and Round End |
| `workspace.FinishPlatform` | `.Touched` connection to detect the win condition |
| `workspace.LobbySpawn` | CFrame target for teleporting all players back to lobby at Reset |
| `workspace.TimerDisplay.TimerBoard` | SurfaceGui Text property updated each TimerTick |

### Tower Assembly Module
The Round Loop Module fires BindableEvents that Tower Assembly listens to. Round Loop does not care how the tower is built — it only signals when to start and stop.

| Event Fired | When | What Tower Assembly Must Do |
|---|---|---|
| `BuildTower` | Start of Intermission phase | Assemble the tower (clone sections, stack them, place FinishPlatform) |
| `DestroyTower` | During Reset phase | Destroy all cloned section instances, reposition or hide FinishPlatform |

**Assumption:** Tower Assembly completes its build within 20 seconds (the intermission window). If it needs more time, the intermission duration can be increased — but 20 seconds is sufficient for server-side Part cloning.

### Player Module
The Round Loop Module fires BindableEvents that the Player Module listens to. Round Loop never reads player coin/XP data — it only signals what happened.

| Event Fired | When | Payload | What Player Module Must Do |
|---|---|---|---|
| `AwardWinner` | Immediately on FinishPlatform touch | Winner's UserId (`number`) | Grant winner coin reward (amount TBD by Player Module) |
| `AwardParticipants` | At Round End, before Reset | none | Grant all players in server a participation coin reward (amount TBD by Player Module) |

**Note:** VIP 2x coin multiplier is handled inside the Player Module when processing these events — Round Loop does not know about gamepasses.

### Gamepasses Module
The Round Loop Module fires no events to the Gamepasses Module. The only gamepass that touches Round Loop logic is "Infinite Attempts" (mid-round rejoin). That check is handled by the Gamepasses Module listening on the `TowerPortal.PortalTrigger` touch event independently — Round Loop does not need to change for it.

---

## Key Naming Reference (for Code Writer Agent)

| Reference | Path |
|---|---|
| Portal trigger | `workspace.TowerPortal.PortalTrigger` |
| Finish platform | `workspace.FinishPlatform` |
| Lobby spawn | `workspace.LobbySpawn` |
| Timer display surface | `workspace.TimerDisplay.TimerBoard` |
| RemoteEvents folder | `game.ReplicatedStorage.RemoteEvents` |
| BindableEvents folder | `game.ServerScriptService.BindableEvents` |
| Round state module | `game.ServerScriptService.Scripts.RoundState` |

---

## What This Module Does NOT Cover
- Tower section assembly and teardown logic → Tower Assembly Module
- Coin/XP amounts and DataStore writes → Player Module
- Gamepass ownership checks (Infinite Attempts mid-round rejoin) → Gamepasses Module
- Client results screen UI design → handled by RoundClient LocalScript (visual only, no logic)
- Character skin application → Character Skins Module
- KillPlane respawn logic → defined in Layout Module (script inside KillPlane part)
