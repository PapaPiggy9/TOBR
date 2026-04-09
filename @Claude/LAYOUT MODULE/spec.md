# Layout Module — Spec

**Status:** Finalized
**Pipeline Stage:** Spec → Ready for Ticket Agent
**Last Updated:** 2026-04-04

---

## Purpose
Define the physical layout of the Tower of Brainrot game world inside Roblox Studio. This covers the lobby, the tower structure, section stacking, kill plane, finish platform, and the exact naming conventions scripts depend on.

---

## Decisions (All Resolved)

| Decision | Value | Source |
|---|---|---|
| Max players per server | 15 | Developer |
| Sections per round | 10–12 (match Tower of Hell) | Developer |
| Section orientation | Fixed — always face the same direction, no rotation | Developer |
| Tower visibility | Fully visible from lobby, no fog obscuring it | Developer |
| Lobby theme | Brainrot-themed from day one | Developer |
| Section footprint | 50 × 50 studs | Spec default — matches clean stacking math |
| Section height | 50 studs | Spec default — consistent with ToH-style sections |
| Kill plane depth | –200 studs (Y) below lobby floor | Spec default — deep enough to catch all falls |
| Lobby floor size | 300 × 300 studs | Spec default — comfortable for 15 players with decorations |
| Tower base position | Center of map, X=0, Z=0, Y=0 | Spec default — easy to reference in scripts |

---

## Areas

### 1. Lobby
- Spawn point for all players between rounds
- Brainrot NPC decorations (idle animated figures) placed around the perimeter and near the tower entrance
- Leaderboard display showing top players and coin totals
- Gamepass shop access point (UI trigger — a glowing sign or kiosk model)
- VIP-only lounge area gated by a door that checks VIP gamepass ownership
- Round countdown timer display visible from spawn
- Portal/entry point that opens when a round starts and closes once the tower assembles

### 2. Tower
- Vertical structure assembled from stacked section Models each round
- Base plate at Y=0, finish platform at top of the last section
- Sections snap together — each section's bottom face sits exactly on the top face of the section below
- Tower rebuilds every round with a randomized section order drawn from the section pool
- Difficulty tiers for the section pool: Easy → Medium → Hard → Insane → Brainrot
- The full tower height is visible from the lobby (no fog, open sky)

### 3. Section Design Rules
- Each section is a self-contained Model stored in ReplicatedStorage > Sections
- Standard footprint: 50 × 50 studs (width × depth)
- Standard height: 50 studs
- Entry point at bottom-center, exit point at top-center (use invisible part named "Entry" and "Exit" inside the model)
- No section should be completable in under ~10 seconds (minimum challenge)
- Sections do not rotate — they always face the same direction (positive Z = forward/into tower)
- Maximum tower height for 12 sections: 600 studs above lobby floor

### 4. Kill Plane / Fall Detection
- A single large BasePart named "KillPlane" positioned at Y = –200
- Size: 2000 × 4 × 2000 studs (wide enough to catch any fall anywhere on the map)
- CanCollide = false, Transparency = 1, Anchored = true
- A server Script inside it kills any Character that touches it and respawns them to lobby spawn
- No fall damage — death is instant on touch

### 5. Finish Platform
- A BasePart named "FinishPlatform" placed at the top of the assembled tower each round
- Size: 50 × 4 × 50 studs (matches section footprint)
- Colored bright gold (BrickColor: "Bright yellow") to stand out
- A server Script detects touch, triggers win condition, plays fireworks + brainrot character animation
- Only the first player to touch wins the round (others get a "close!" consolation message)

---

## Spatial Layout (Top-Down)

```
[ VIP Lounge ]     [ Leaderboard ]     [ Shop Kiosk ]
[               Lobby Spawn Area (300x300)            ]
[        Brainrot NPCs around perimeter               ]
[        Round Timer Display (near tower base)        ]
                       |
                [ Tower Portal ]
                       |
                 [ Tower Base ]   <-- Y=0, X=0, Z=0
                       |
                 [ Section 1 ]    <-- Y=0 to Y=50
                 [ Section 2 ]    <-- Y=50 to Y=100
                      ...
                 [ Section N ]    <-- up to Y=600
                       |
               [ Finish Platform ]
```

---

## Studio Setup

These are the exact parts and models to create inside Roblox Studio before any scripting begins. Build these manually in the workspace.

### Workspace Objects to Create

| Object | Type | Position | Size | Notes |
|---|---|---|---|---|
| LobbyFloor | BasePart (Anchored) | X=0, Y=-2, Z=150 | 300 × 4 × 300 | The lobby platform. Offset from tower on Z so tower base is at Z=0 |
| TowerBase | BasePart (Anchored) | X=0, Y=0, Z=0 | 50 × 4 × 50 | Marks the bottom of the tower; sections stack above this |
| KillPlane | BasePart (Anchored) | X=0, Y=-200, Z=0 | 2000 × 4 × 2000 | Invisible, CanCollide=false |
| LobbySpawn | SpawnLocation | X=0, Y=2, Z=200 | Default | Where players appear between rounds |
| VIPDoor | Model | X=-120, Y=2, Z=100 | — | See naming conventions below |
| LeaderboardSign | Model | X=100, Y=10, Z=100 | — | Visual display for top players |
| ShopKiosk | Model | X=-80, Y=2, Z=180 | — | Triggers shop UI on touch/proximity |
| TowerPortal | Model | X=0, Y=2, Z=20 | — | Entry portal; opens when round starts |
| NPCGroup | Folder (in Workspace) | — | — | Contains all lobby NPC models |
| TimerDisplay | Model | X=0, Y=8, Z=50 | — | Visible countdown sign near tower entrance |
| FinishPlatform | BasePart (Anchored) | Placed by server script each round | 50 × 4 × 50 | Gold color |

### ReplicatedStorage Objects to Create

| Object | Type | Notes |
|---|---|---|
| Sections | Folder | Parent of all section Models |
| Sections > [SectionName] | Model | One Model per obstacle section |
| Sections > [SectionName] > Entry | BasePart | Invisible marker at section bottom-center |
| Sections > [SectionName] > Exit | BasePart | Invisible marker at section top-center |
| Characters | Folder | Brainrot NPC/skin models |

### ServerScriptService Objects to Create

| Object | Type | Notes |
|---|---|---|
| Scripts | Folder | All server scripts live here |

### StarterPlayerScripts Objects to Create

| Object | Type | Notes |
|---|---|---|
| ClientScripts | Folder | All LocalScripts live here |

---

## Roblox Studio Naming Conventions

Scripts reference every object by exact name. Use these names precisely — do not rename after scripts are written.

### Workspace Instance Hierarchy

```
Workspace
├── LobbyFloor                  (BasePart)
├── TowerBase                   (BasePart)
├── KillPlane                   (BasePart)
├── LobbySpawn                  (SpawnLocation)
├── FinishPlatform              (BasePart)  -- moved each round by server
├── TowerPortal                 (Model)
│   ├── PortalFrame             (BasePart)
│   └── PortalTrigger           (BasePart)  -- touch = enter tower
├── VIPDoor                     (Model)
│   ├── DoorFrame               (BasePart)
│   ├── DoorBlock               (BasePart)  -- removed for VIP players
│   └── VIPSign                 (BasePart / SurfaceGui on it)
├── LeaderboardSign             (Model)
│   └── DisplayBoard            (BasePart / SurfaceGui on it)
├── ShopKiosk                   (Model)
│   └── KioskFront              (BasePart)  -- proximity prompt on this
├── TimerDisplay                (Model)
│   └── TimerBoard              (BasePart / SurfaceGui on it)
└── NPCGroup                    (Folder)
    ├── NPC_Tralalelo           (Model)
    ├── NPC_Bombardiro          (Model)
    ├── NPC_TungTung            (Model)
    ├── NPC_Ballerina           (Model)
    └── NPC_Skibidi             (Model)
```

### ReplicatedStorage Instance Hierarchy

```
ReplicatedStorage
├── Sections                    (Folder)
│   ├── OhioZone                (Model)
│   │   ├── Entry               (BasePart)
│   │   └── Exit                (BasePart)
│   ├── SigmaGrindset           (Model)
│   │   ├── Entry               (BasePart)
│   │   └── Exit                (BasePart)
│   └── [more sections...]
└── Characters                  (Folder)
    └── [brainrot skin models]
```

### Key Name Rules for Scripts
- Tower base anchor: `workspace.TowerBase`
- Kill plane: `workspace.KillPlane`
- Finish platform: `workspace.FinishPlatform`
- Lobby spawn: `workspace.LobbySpawn`
- Section pool folder: `game.ReplicatedStorage.Sections`
- NPC group folder: `workspace.NPCGroup`
- VIP door block: `workspace.VIPDoor.DoorBlock`
- Portal trigger: `workspace.TowerPortal.PortalTrigger`
- Timer display board: `workspace.TimerDisplay.TimerBoard`

---

## Brainrot Lobby Theme

The lobby must look unmistakably brainrot from the moment a player spawns. It should feel chaotic, colorful, and meme-saturated — not a blank gray baseplate.

### Visual Style
- Floor color: Bright lime green or hot pink checkerboard tile pattern (BrickColor "Bright green" / "Hot pink" alternating tiles, 10 × 10 studs each)
- Sky: Bright blue, no fog — the full tower is visible reaching into the sky
- Ambient lighting: Bright and saturated — no dark/moody atmosphere
- Neon trim on the VIP Lounge walls (electric blue / neon yellow borders)

### NPC Placements
Place 5 starter brainrot NPCs in NPCGroup. Position them around the lobby perimeter so players encounter them immediately on spawn:

| NPC | Position (approx) | Notes |
|---|---|---|
| NPC_Tralalelo | X=-80, Y=2, Z=180 | Near spawn, facing inward |
| NPC_Bombardiro | X=80, Y=2, Z=180 | Near spawn, opposite side |
| NPC_TungTung | X=-80, Y=2, Z=100 | Midway down lobby left side |
| NPC_Ballerina | X=80, Y=2, Z=100 | Midway down lobby right side |
| NPC_Skibidi | X=0, Y=2, Z=160 | Center-back, directly behind spawn |

All NPCs should have an idle loop animation playing. Use a simple R6 or R15 rig with a brainrot character mesh applied. If a custom mesh is not yet ready, use a colored block placeholder with the NPC name on a BillboardGui above it.

### Signs and Text
- Large sign above the tower portal: "ENTER IF YOU HAVE RIZZ" — bold, neon yellow text on a black background SurfaceGui
- Sign near the VIP door: "VIP ONLY — NO BRAINROT PEASANTS" (white text, red background)
- Sign near the shop kiosk: "SKINS — GET COOKED" (neon green text)
- Floating text above the leaderboard: "TOP SIGMA GRINDERS"
- BillboardGui above each NPC showing the character name (e.g., "Tralalelo Tralala")

### Decorations
- Scatter 10–20 small colored Part "confetti" blocks around the lobby floor (non-collidable, anchored, various bright colors)
- Add 4 corner pillars around the lobby (tall thin BaseParts, BrickColor "Bright orange") for visual framing
- The VIP Lounge is a raised platform (+4 studs) with a different floor color (gold / "Bright yellow") to make it visually distinct
- The tower base area should have a glowing ring (a thin torus-style ring of neon parts) to draw the eye upward

---

## Section Assembly Logic (Layout Perspective)

This section is consumed by the Tower Assembly Module — included here for completeness.

- Sections are cloned from ReplicatedStorage.Sections each round
- Each cloned section is parented to Workspace
- Section 1 bottom face sits at Y=4 (top of TowerBase)
- Each subsequent section bottom = previous section top (Y += 50 per section)
- After assembly, FinishPlatform is placed at Y = (section count × 50) + 4
- At round end, all cloned sections and FinishPlatform are destroyed; tower resets for next round
- KillPlane and lobby objects are never destroyed between rounds

---

## What This Module Does NOT Cover
- Round timer logic → Round Loop Module
- Section obstacle scripting → Tower Assembly Module
- Gamepass ownership checks (beyond VIP door concept) → Gamepasses Module
- Player coin/XP tracking → Player Module
- Character skin application → Character Skins Module
