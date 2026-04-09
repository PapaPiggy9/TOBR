# ROUND LOOP MODULE — Memory

## Pipeline Status
- [x] Spec — complete
- [x] Tickets — complete
- [x] Code — complete
- [x] QA — complete 2026-04-04 (timer confirmed working in-game)

---

## Decisions Log
| Date | Decision | Reason |
|---|---|---|
| 2026-04-04 | Intermission duration: 20 seconds | Matches Tower of Hell pacing; enough time for players to read previous round results before the next build starts |
| 2026-04-04 | Minimum players to start: 1 | Solo play supported for testing; no lobby-fill gate needed at this stage |
| 2026-04-04 | Round duration: 8 minutes (480 seconds) | Standard Tower of Hell duration; tunable later |
| 2026-04-04 | Round end display hold: 5 seconds | Time for players to see results before lobby reset |
| 2026-04-04 | Reset yield: 2 seconds | Enough time for tower teardown to begin before next intermission starts |
| 2026-04-04 | RoundState stored in ModuleScript, not DataStore | Round state is ephemeral — only persistent data (coins, etc.) lives in DataStore |
| 2026-04-04 | TimerTick fires every 1 second | Sufficient for countdown display; low server overhead |
| 2026-04-04 | Coin amounts delegated to Player Module | Round Loop fires event with result type; Player Module decides values |
| 2026-04-04 | Infinite Attempts gamepass check delegated to Gamepasses Module | Gamepasses Module listens on PortalTrigger independently; Round Loop has no gamepass awareness |

---

## Tickets

### Ticket 1 — Create RemoteEvents Folder and Events in ReplicatedStorage
**Type:** Studio

**Description:**
Open Roblox Studio. In the Explorer panel, find `ReplicatedStorage`. Right-click it and insert a **Folder**. Rename the folder to `RemoteEvents` (exact spelling, capital R and E).

Inside the `RemoteEvents` folder, insert five **RemoteEvent** instances. Rename them exactly as listed:
- `RoundStateChanged`
- `RoundStart`
- `RoundEnd`
- `TimerTick`
- `PlayerWon`

To insert a RemoteEvent: right-click the `RemoteEvents` folder → Insert Object → search "RemoteEvent" → click it.

After this ticket, your `ReplicatedStorage` hierarchy should look like:
```
ReplicatedStorage
├── Sections          (already exists from Layout Module)
├── Characters        (already exists from Layout Module)
└── RemoteEvents      (NEW)
    ├── RoundStateChanged
    ├── RoundStart
    ├── RoundEnd
    ├── TimerTick
    └── PlayerWon
```

**Acceptance Criteria:**
- A folder named `RemoteEvents` exists directly inside `ReplicatedStorage`
- All five RemoteEvent instances exist inside it with exact names (case-sensitive)
- No typos — scripts will break silently if names are wrong

**Dependencies:** Layout Module Studio setup must be complete (Sections and Characters folders must exist)

---

### Ticket 2 — Create BindableEvents Folder and Events in ServerScriptService
**Type:** Studio

**Description:**
In the Explorer panel, find `ServerScriptService`. Right-click it and insert a **Folder**. Rename the folder to `BindableEvents` (exact spelling).

Inside the `BindableEvents` folder, insert four **BindableEvent** instances. Rename them exactly:
- `BuildTower`
- `DestroyTower`
- `AwardWinner`
- `AwardParticipants`

To insert a BindableEvent: right-click the folder → Insert Object → search "BindableEvent" → click it.

After this ticket, your `ServerScriptService` hierarchy should look like:
```
ServerScriptService
├── Scripts           (already exists from Layout Module)
└── BindableEvents    (NEW)
    ├── BuildTower
    ├── DestroyTower
    ├── AwardWinner
    └── AwardParticipants
```

**Acceptance Criteria:**
- A folder named `BindableEvents` exists directly inside `ServerScriptService`
- All four BindableEvent instances exist inside it with exact names
- The existing `Scripts` folder is untouched

**Dependencies:** Ticket 1

---

### Ticket 3 — Create Script and ModuleScript Shells in ServerScriptService
**Type:** Studio

**Description:**
In the Explorer panel, find `ServerScriptService > Scripts` (the Scripts folder created by the Layout Module).

Right-click `Scripts` and insert a **Script**. Rename it `RoundManager`. Leave the default contents for now — the Code Writer will fill it in.

Right-click `Scripts` again and insert a **ModuleScript**. Rename it `RoundState`. Leave the default contents for now.

After this ticket:
```
ServerScriptService
├── Scripts
│   ├── RoundManager    (Script)       -- NEW
│   └── RoundState      (ModuleScript) -- NEW
└── BindableEvents      (from Ticket 2)
```

**Acceptance Criteria:**
- `RoundManager` Script exists inside `ServerScriptService > Scripts`
- `RoundState` ModuleScript exists inside `ServerScriptService > Scripts`
- Both are empty/default — no code yet

**Dependencies:** Ticket 2

---

### Ticket 4 — Create RoundClient LocalScript Shell in StarterPlayerScripts
**Type:** Studio

**Description:**
In the Explorer panel, find `StarterPlayer > StarterPlayerScripts > ClientScripts` (the ClientScripts folder created by the Layout Module).

Right-click `ClientScripts` and insert a **LocalScript**. Rename it `RoundClient`. Leave the default contents for now.

After this ticket:
```
StarterPlayer
└── StarterPlayerScripts
    └── ClientScripts
        └── RoundClient    (LocalScript) -- NEW
```

**Acceptance Criteria:**
- `RoundClient` LocalScript exists inside `StarterPlayerScripts > ClientScripts`
- It is a LocalScript (not a Script or ModuleScript)
- Default/empty contents

**Dependencies:** Ticket 3

---

### Ticket 5 — Write the RoundState ModuleScript
**Type:** Script

**Description:**
Open `ServerScriptService > Scripts > RoundState` in the Script Editor (double-click it in the Explorer).

Replace all default contents with the following Luau code. This module holds the current state of the round. `RoundManager` will write to it; other scripts can read from it.

```lua
-- RoundState
-- Holds ephemeral (in-memory only) state for the current round.
-- RoundManager is the only script that writes to these values.
-- Other server scripts may read them.

local RoundState = {}

RoundState.currentPhase = "Intermission"   -- Current phase name (string)
RoundState.winner = nil                     -- Display name of winner, or nil if no winner yet
RoundState.winnerUserId = nil               -- UserId of winner, or nil
RoundState.roundTimeRemaining = 20          -- Seconds remaining in the current phase timer
RoundState.roundActive = false              -- True while the Active phase is running

return RoundState
```

**Acceptance Criteria:**
- `RoundState` ModuleScript contains valid Luau that returns a table
- The table has all five fields: `currentPhase`, `winner`, `winnerUserId`, `roundTimeRemaining`, `roundActive`
- Pasting the script into Studio does not show any red error underlines
- Clicking Play in Studio does not produce a script error in the Output window related to RoundState

**Dependencies:** Ticket 3

---

### Ticket 6 — Write the RoundManager Script (Intermission Phase)
**Type:** Script

**Description:**
This ticket implements Phase 1 only (Intermission). You will write the top of the `RoundManager` script — the references, helper function, and the Intermission phase logic.

Open `ServerScriptService > Scripts > RoundManager` in the Script Editor. Replace all default contents with the code below.

**What this code does:**
- Gets references to all the Studio objects and events the script needs
- Defines a helper function `setPortal(open)` to open or close the portal
- Defines a helper function `runTimer(seconds, label)` that counts down and fires `TimerTick` each second
- Runs the Intermission phase: sets state, closes the portal, fires `BuildTower`, counts down 20 seconds

```lua
-- RoundManager
-- Main server-side game loop. Runs phases in sequence: Intermission → RoundStart → Active → RoundEnd → Reset → repeat.

local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players             = game:GetService("Players")

-- State module
local RoundState = require(ServerScriptService.Scripts.RoundState)

-- RemoteEvents (server → all clients)
local RemoteEvents     = ReplicatedStorage.RemoteEvents
local RoundStateChanged = RemoteEvents.RoundStateChanged
local RoundStartEvent   = RemoteEvents.RoundStart
local RoundEndEvent     = RemoteEvents.RoundEnd
local TimerTickEvent    = RemoteEvents.TimerTick
local PlayerWonEvent    = RemoteEvents.PlayerWon

-- BindableEvents (server → other server modules)
local BindableEvents      = ServerScriptService.BindableEvents
local BuildTowerEvent     = BindableEvents.BuildTower
local DestroyTowerEvent   = BindableEvents.DestroyTower
local AwardWinnerEvent    = BindableEvents.AwardWinner
local AwardParticipantsEvent = BindableEvents.AwardParticipants

-- Workspace objects
local TowerPortal    = workspace.TowerPortal
local PortalTrigger  = TowerPortal.PortalTrigger
local FinishPlatform = workspace.FinishPlatform
local LobbySpawn     = workspace.LobbySpawn
local TimerBoard     = workspace.TimerDisplay.TimerBoard

-- -------------------------------------------------------
-- Helper: open or close the tower portal
-- open = true  → CanCollide on, fully visible
-- open = false → CanCollide off, semi-transparent (closed)
-- -------------------------------------------------------
local function setPortal(open)
	if open then
		PortalTrigger.CanCollide   = true
		PortalTrigger.Transparency = 0
	else
		PortalTrigger.CanCollide   = false
		PortalTrigger.Transparency = 0.8
	end
end

-- -------------------------------------------------------
-- Helper: count down `seconds` ticks, firing TimerTick
-- each second and updating the TimerBoard SurfaceGui.
-- -------------------------------------------------------
local function runTimer(seconds)
	for remaining = seconds, 0, -1 do
		RoundState.roundTimeRemaining = remaining

		-- Update the SurfaceGui text on the in-world timer sign
		local surfaceGui = TimerBoard:FindFirstChildWhichIsA("SurfaceGui")
		if surfaceGui then
			local label = surfaceGui:FindFirstChildWhichIsA("TextLabel")
			if label then
				label.Text = tostring(remaining)
			end
		end

		-- Tell all clients the current remaining time
		TimerTickEvent:FireAllClients(remaining)

		if remaining > 0 then
			task.wait(1)
		end
	end
end

-- -------------------------------------------------------
-- PHASE 1: INTERMISSION
-- -------------------------------------------------------
local function runIntermission()
	RoundState.currentPhase = "Intermission"
	RoundState.roundActive   = false
	RoundState.winner        = nil
	RoundState.winnerUserId  = nil

	RoundStateChanged:FireAllClients("Intermission")
	setPortal(false)

	-- Signal Tower Assembly to build the tower during these 20 seconds
	-- TODO: Tower Assembly Module must connect a handler to BuildTowerEvent.Event
	BuildTowerEvent:Fire()

	runTimer(20)
end

-- -------------------------------------------------------
-- MAIN LOOP ENTRY POINT
-- Phases are added in subsequent tickets.
-- -------------------------------------------------------
while true do
	runIntermission()
	-- TODO: call runRoundStart(), runActive(), runRoundEnd(), runReset() — added in later tickets
	task.wait(1) -- temporary pause to prevent an infinite tight loop while other phases are stubbed out
end
```

**Acceptance Criteria:**
- Script saves without Studio syntax errors (no red underlines)
- Clicking Play, then watching the Output window shows no errors
- During Play, the `TimerBoard` SurfaceGui counts down from 20 to 0 (you may need to add a TextLabel inside the SurfaceGui on `TimerBoard` in Studio first — see note below)
- `BuildTowerEvent` fires once at the start of Intermission (you can confirm by temporarily adding a Script that prints when BuildTowerEvent.Event fires)

**Note for beginner:** The `TimerBoard` part needs a SurfaceGui with a TextLabel inside it for the countdown text to display. If you have not set that up yet in Studio, add a SurfaceGui to `workspace.TimerDisplay.TimerBoard`, then add a TextLabel inside the SurfaceGui. The script will find it automatically.

**Dependencies:** Tickets 4 and 5

---

### Ticket 7 — Add RoundStart and Active Phases to RoundManager
**Type:** Script

**Description:**
Open `RoundManager`. You will add two new phase functions below the `runIntermission()` function and before the main loop.

**Phase 2 — RoundStart:** Sets state, opens the portal, fires `RoundStart` event to all clients. Instant transition.

**Phase 3 — Active:** Sets state, runs the 480-second (8-minute) timer, and listens for a `FinishPlatform` touch to detect a winner.

Add the following code block. Insert it after the closing `end` of `runIntermission()` and before the `while true do` line:

```lua
-- -------------------------------------------------------
-- PHASE 2: ROUND START
-- -------------------------------------------------------
local function runRoundStart()
	RoundState.currentPhase = "RoundStart"

	RoundStateChanged:FireAllClients("RoundStart")
	setPortal(true)
	RoundStartEvent:FireAllClients()
end

-- -------------------------------------------------------
-- PHASE 3: ACTIVE ROUND
-- -------------------------------------------------------
local function runActive()
	RoundState.currentPhase = "Active"
	RoundState.roundActive   = true

	RoundStateChanged:FireAllClients("Active")

	-- Connect FinishPlatform touch detection
	-- Only the first touch that includes a humanoid counts as a win
	local winnerDetected = false
	local touchConnection

	touchConnection = FinishPlatform.Touched:Connect(function(hit)
		if winnerDetected then return end

		local character = hit.Parent
		local humanoid  = character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then return end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		winnerDetected = true
		touchConnection:Disconnect()

		-- Record winner in RoundState
		RoundState.winner       = player.DisplayName
		RoundState.winnerUserId = player.UserId

		-- Tell all clients who won
		PlayerWonEvent:FireAllClients(player.DisplayName)

		-- Signal Player Module to award winner coins
		-- TODO: Player Module must connect a handler to AwardWinnerEvent.Event
		AwardWinnerEvent:Fire(player.UserId)
	end)

	-- Run the 8-minute (480 second) round timer
	-- The timer runs to completion regardless of whether a winner was found.
	-- If a winner was found early, the main loop will call runRoundEnd() immediately after.
	runTimer(480)

	-- Clean up the touch connection if timer expired with no winner
	if touchConnection.Connected then
		touchConnection:Disconnect()
	end
end
```

Then update the `while true do` main loop at the bottom of the script to call the new phases:

```lua
while true do
	runIntermission()
	runRoundStart()
	runActive()
	-- TODO: call runRoundEnd() and runReset() — added in the next ticket
	task.wait(1) -- temporary stub; remove when all phases are wired
end
```

**Acceptance Criteria:**
- No syntax errors in Studio
- During Play: after the 20-second intermission, the portal opens (CanCollide = true, Transparency = 0)
- During Play: `RoundStart` fires to clients (confirm by printing in RoundClient or a test Script)
- During Play: the timer counts down from 480 on the TimerBoard
- During Play: touching `FinishPlatform` prints a winner message to the Output window (add a temporary `print(RoundState.winner)` after `AwardWinnerEvent:Fire()` to verify)

**Dependencies:** Ticket 6

---

### Ticket 8 — Add RoundEnd and Reset Phases to RoundManager
**Type:** Script

**Description:**
Open `RoundManager`. Add the final two phase functions — RoundEnd and Reset — then wire them into the main loop.

Insert the following code block after the closing `end` of `runActive()` and before the `while true do` line:

```lua
-- -------------------------------------------------------
-- PHASE 4: ROUND END
-- -------------------------------------------------------
local function runRoundEnd()
	RoundState.currentPhase = "RoundEnd"
	RoundState.roundActive   = false

	-- Build result payload for clients
	local resultData = {
		winner   = RoundState.winner,     -- display name string or nil
		timedOut = (RoundState.winner == nil)
	}

	RoundEndEvent:FireAllClients(resultData)
	setPortal(false)

	-- Signal Player Module to award participation coins to everyone
	-- TODO: Player Module must connect a handler to AwardParticipantsEvent.Event
	AwardParticipantsEvent:Fire()

	-- Hold the results screen for 5 seconds
	task.wait(5)
end

-- -------------------------------------------------------
-- PHASE 5: RESET
-- -------------------------------------------------------
local function runReset()
	RoundState.currentPhase = "Reset"

	-- Teleport all players back to LobbySpawn
	local spawnCFrame = LobbySpawn.CFrame + Vector3.new(0, 3, 0)
	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = spawnCFrame
			end
		end
	end

	-- Signal Tower Assembly to tear down the tower
	-- TODO: Tower Assembly Module must connect a handler to DestroyTowerEvent.Event
	DestroyTowerEvent:Fire()

	-- Clear winner from state (timer and phase reset at the top of runIntermission)
	RoundState.winner       = nil
	RoundState.winnerUserId = nil

	-- Wait for teardown to complete before starting next intermission
	task.wait(2)
end
```

Then replace the `while true do` main loop with the fully wired version:

```lua
-- -------------------------------------------------------
-- MAIN LOOP — runs forever
-- -------------------------------------------------------
while true do
	runIntermission()
	runRoundStart()
	runActive()
	runRoundEnd()
	runReset()
end
```

**Acceptance Criteria:**
- No syntax errors in Studio
- During Play: after the Active phase (or after a winner touches FinishPlatform), `RoundEnd` event fires to clients
- During Play: after Round End, all players are teleported near `LobbySpawn`
- During Play: `DestroyTowerEvent` fires (confirm with a temporary print in a test Script)
- During Play: after 2 seconds, the loop restarts and Intermission begins again (timer resets to 20 on the TimerBoard)
- The `task.wait(1)` temporary stub line is removed from the main loop

**Dependencies:** Ticket 7

---

### Ticket 9 — Write the RoundClient LocalScript
**Type:** Script

**Description:**
Open `StarterPlayerScripts > ClientScripts > RoundClient` in the Script Editor. Replace all default contents with the following code.

This LocalScript runs on every player's device. It listens to RemoteEvents from the server and updates the client's display. It makes no game logic decisions — display only.

```lua
-- RoundClient
-- Listens to round RemoteEvents from the server and updates client-side UI.
-- Display only — no game logic decisions are made here.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local player = Players.LocalPlayer

-- RemoteEvents
local RemoteEvents      = ReplicatedStorage:WaitForChild("RemoteEvents")
local RoundStateChanged = RemoteEvents:WaitForChild("RoundStateChanged")
local RoundStartEvent   = RemoteEvents:WaitForChild("RoundStart")
local RoundEndEvent     = RemoteEvents:WaitForChild("RoundEnd")
local TimerTickEvent    = RemoteEvents:WaitForChild("TimerTick")
local PlayerWonEvent    = RemoteEvents:WaitForChild("PlayerWon")

-- -------------------------------------------------------
-- RoundStateChanged — phase label update
-- -------------------------------------------------------
RoundStateChanged.OnClientEvent:Connect(function(phase)
	-- TODO: update a ScreenGui phase label here when the UI module is built
	print("[RoundClient] Phase changed to:", phase)
end)

-- -------------------------------------------------------
-- RoundStart — show "GO!" feedback to the player
-- -------------------------------------------------------
RoundStartEvent.OnClientEvent:Connect(function()
	-- TODO: show a "GO!" splash ScreenGui element here
	print("[RoundClient] Round started — GO!")
end)

-- -------------------------------------------------------
-- TimerTick — update the client's local timer display
-- The server also updates the in-world SurfaceGui directly,
-- so this handler is for any client-side HUD timer overlay.
-- -------------------------------------------------------
TimerTickEvent.OnClientEvent:Connect(function(remaining)
	-- TODO: update a client HUD timer TextLabel here
	-- print("[RoundClient] Timer:", remaining)  -- commented out to avoid spam; uncomment for debugging
end)

-- -------------------------------------------------------
-- PlayerWon — show winner announcement to all clients
-- -------------------------------------------------------
PlayerWonEvent.OnClientEvent:Connect(function(winnerName)
	-- TODO: show winner splash ScreenGui here
	print("[RoundClient] Winner:", winnerName)
end)

-- -------------------------------------------------------
-- RoundEnd — show results screen
-- payload = { winner = "Name" | nil, timedOut = bool }
-- -------------------------------------------------------
RoundEndEvent.OnClientEvent:Connect(function(data)
	if data.winner then
		-- TODO: show "WINNER: [name]" results screen
		print("[RoundClient] Round ended — Winner:", data.winner)
	else
		-- TODO: show "Nobody won this round" results screen
		print("[RoundClient] Round ended — No winner (timed out:", data.timedOut, ")")
	end
end)
```

**Acceptance Criteria:**
- Script saves without syntax errors
- During Play, the Output window (client side) shows phase change prints as the round progresses
- During Play, touching FinishPlatform causes the winner print to appear in the Output window
- During Play, after Round End the results print appears in the Output window
- No errors appear in the Output window related to WaitForChild timing out (if it waits more than ~5 seconds, the RemoteEvents folder may be missing — go back to Ticket 1)

**Dependencies:** Tickets 1 and 8

---

### Ticket 10 — Integration Test: Full Round Loop End-to-End
**Type:** Studio (manual playtesting in Studio)

**Description:**
This ticket is a manual end-to-end test of the complete round loop. No new code is written. Run through the checklist below in Roblox Studio using the Play button (single player test). Use the Output window to verify each step.

**Test Checklist:**

**Intermission Phase (0–20 seconds):**
- [ ] Output shows: `[RoundClient] Phase changed to: Intermission`
- [ ] `TimerBoard` SurfaceGui counts down from 20 to 0
- [ ] `PortalTrigger` has `CanCollide = false` and `Transparency = 0.8` (check Properties panel while playing)
- [ ] Output shows `BuildTowerEvent` fired (if you have a test listener) OR no error is thrown when it fires with no listener

**Round Start (instant, at 0 seconds):**
- [ ] Output shows: `[RoundClient] Phase changed to: RoundStart`
- [ ] Output shows: `[RoundClient] Round started — GO!`
- [ ] `PortalTrigger` has `CanCollide = true` and `Transparency = 0`

**Active Phase (timer counts from 480):**
- [ ] Output shows: `[RoundClient] Phase changed to: Active`
- [ ] `TimerBoard` counts down from 480
- [ ] Walking your character into `FinishPlatform` prints: `[RoundClient] Winner: [your display name]`
- [ ] Immediately after winner detection, `RoundEnd` phase begins (timer does not keep running)

**Round End (5-second hold):**
- [ ] Output shows: `[RoundClient] Round ended — Winner: [name]` (or "No winner" if you waited it out)
- [ ] `PortalTrigger` has `CanCollide = false` and `Transparency = 0.8`
- [ ] Your character is NOT teleported during this 5-second window

**Reset Phase:**
- [ ] Your character is teleported to near `LobbySpawn`
- [ ] `DestroyTowerEvent` fires (no error thrown)
- [ ] After ~2 seconds, Intermission begins again (Output shows phase change, TimerBoard resets to 20)

**Known Stubs (expected behavior — not bugs):**
- `BuildTower` and `DestroyTower` fire but nothing builds or tears down — Tower Assembly Module not yet written
- `AwardWinner` and `AwardParticipants` fire but no coins are awarded — Player Module not yet written
- All `TODO` comments in `RoundClient` are placeholders — no ScreenGui elements exist yet

**Acceptance Criteria:**
- All checklist items above are checked off
- No unhandled errors in the Output window (warnings about missing connections to BindableEvents are acceptable)
- The loop repeats indefinitely: Intermission → RoundStart → Active → RoundEnd → Reset → Intermission → ...

**Dependencies:** All prior tickets (1–9)

---

## Notes
- Core game loop — all other time-sensitive modules depend on this
- Build after LAYOUT MODULE is complete
- The `TimerBoard` part at `workspace.TimerDisplay.TimerBoard` needs a SurfaceGui with a TextLabel inside it before the timer display works — this is a Layout Module concern but must be confirmed before Ticket 6 testing
- All BindableEvent handlers (`BuildTower`, `DestroyTower`, `AwardWinner`, `AwardParticipants`) are stubbed with TODO comments — those connections are implemented by Tower Assembly Module and Player Module respectively
- `RoundManager` uses `task.wait()` throughout — never use `wait()` (the legacy version); `task.wait()` is the modern Roblox API
- The Active phase timer runs its full 480 seconds even when a winner is detected; the winner is recorded and the transition to RoundEnd happens after the timer naturally completes. If you want early exit on win, that is a future optimization — keep it simple for now
