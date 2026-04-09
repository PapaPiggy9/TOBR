# Layout Module — Memory

## Pipeline Status
- [x] Spec — complete 2026-04-04
- [x] Tickets — complete 2026-04-04
- [x] Code — complete 2026-04-04
- [x] QA — complete 2026-04-04 (developer approved layout in-game)

---

## Decisions Log
_Record key decisions and the reasoning behind them here as the module progresses._

| Date | Decision | Reason |
|---|---|---|
| 2026-04-04 | Standard section footprint set to 50x50x50 studs | Consistent snapping, easy to scale |

---

## Tickets

### Ticket 1 — Create the Roblox Studio Project Folder Structure
**Type:** Studio

**Description:**
Open Roblox Studio and set up the top-level containers that all scripts and assets will live inside. You are not building anything visual yet — just creating the named folders in the right services.

Do the following in the Explorer panel:
1. Inside **ServerScriptService**, create a Folder named `Scripts`
2. Inside **ReplicatedStorage**, create a Folder named `Sections`
3. Inside **ReplicatedStorage**, create a Folder named `Characters`
4. Inside **StarterPlayer > StarterPlayerScripts**, create a Folder named `ClientScripts`

To create a Folder: right-click the parent object in the Explorer → Insert Object → Folder → rename it exactly as shown above.

**Acceptance Criteria:**
- Explorer shows `ServerScriptService > Scripts` (Folder)
- Explorer shows `ReplicatedStorage > Sections` (Folder)
- Explorer shows `ReplicatedStorage > Characters` (Folder)
- Explorer shows `StarterPlayer > StarterPlayerScripts > ClientScripts` (Folder)
- All names match exactly (spelling, capitalization)

**Dependencies:** None

---

### Ticket 2 — Build the Lobby Floor
**Type:** Studio

**Description:**
Create the main lobby platform that players stand on between rounds.

1. In the Explorer, right-click **Workspace** → Insert Object → **Part**
2. Rename it `LobbyFloor`
3. In the Properties panel, set:
   - **Position:** X=0, Y=-2, Z=150
   - **Size:** X=300, Y=4, Z=300
   - **Anchored:** true
   - **BrickColor:** "Bright green" (you will add the checkerboard pattern in a later ticket — for now just set the base color)
4. Lock it in place (right-click → Lock) so you don't accidentally move it

**Acceptance Criteria:**
- A large green platform named `LobbyFloor` exists in Workspace
- It is Anchored and does not fall when you hit Play
- Its position and size match the values above exactly

**Dependencies:** Ticket 1

---

### Ticket 3 — Build the Tower Base
**Type:** Studio

**Description:**
Create the anchor point at the bottom of the tower. This part stays in the world permanently and tells scripts exactly where Y=0 is for section stacking.

1. Insert a **Part** into Workspace
2. Rename it `TowerBase`
3. Set:
   - **Position:** X=0, Y=0, Z=0
   - **Size:** X=50, Y=4, Z=50
   - **Anchored:** true
   - **BrickColor:** "Medium stone grey" (neutral so it doesn't clash with sections above it)
4. Confirm it sits visually just above the lobby floor level

**Acceptance Criteria:**
- A part named `TowerBase` exists in Workspace at X=0, Y=0, Z=0
- Size is 50 × 4 × 50
- Anchored = true

**Dependencies:** Ticket 2

---

### Ticket 4 — Build the Kill Plane
**Type:** Studio

**Description:**
Create the invisible floor that kills players who fall off the tower. It must be enormous so it catches falls anywhere on the map.

1. Insert a **Part** into Workspace
2. Rename it `KillPlane`
3. Set:
   - **Position:** X=0, Y=-200, Z=0
   - **Size:** X=2000, Y=4, Z=2000
   - **Anchored:** true
   - **CanCollide:** false
   - **Transparency:** 1 (fully invisible)

The part will be invisible in-game. In Studio you can still select it in the Explorer. Do NOT add any script to it yet — the kill script is a separate ticket.

**Acceptance Criteria:**
- A part named `KillPlane` exists in Workspace at Y=-200
- Size is 2000 × 4 × 2000
- Anchored = true, CanCollide = false, Transparency = 1
- It is invisible during Play mode

**Dependencies:** Ticket 2

---

### Ticket 5 — Place the Lobby SpawnLocation
**Type:** Studio

**Description:**
Add the spawn point where all players appear when the game starts or between rounds.

1. Insert a **SpawnLocation** into Workspace (right-click Workspace → Insert Object → SpawnLocation)
2. Rename it `LobbySpawn`
3. Set:
   - **Position:** X=0, Y=2, Z=200
   - **Neutral:** true (so any team can spawn here)
4. Leave the default size

**Acceptance Criteria:**
- A SpawnLocation named `LobbySpawn` exists in Workspace at X=0, Y=2, Z=200
- Pressing Play spawns your character near this location

**Dependencies:** Ticket 2

---

### Ticket 6 — Build the VIP Door Model
**Type:** Studio

**Description:**
Build the VIP lounge gate. It is a Model containing a door frame, a block that physically blocks non-VIP players, and a sign. Scripts in a later module will remove DoorBlock for VIP players.

1. Insert a **Model** into Workspace and rename it `VIPDoor`
2. Set the Model's **PrimaryPart** to the first part you create below (DoorFrame)
3. Inside `VIPDoor`, create:
   - A Part named `DoorFrame` — Position X=-120, Y=5, Z=100 — Size X=10, Y=10, Z=2 — BrickColor "Dark orange" — Anchored
   - A Part named `DoorBlock` — Position X=-120, Y=3, Z=100 — Size X=8, Y=6, Z=2 — BrickColor "Bright red" — Anchored
   - A Part named `VIPSign` — Position X=-120, Y=9, Z=100 — Size X=8, Y=2, Z=1 — BrickColor "Bright red" — Anchored
4. Add a **SurfaceGui** to `VIPSign`:
   - Insert SurfaceGui → inside it insert a TextLabel
   - Set TextLabel **Text** to: `VIP ONLY — NO BRAINROT PEASANTS`
   - Set **TextColor3** to white, **BackgroundColor3** to red, **Font** to GothamBold
   - Set TextLabel Size to {1,0},{1,0} (fills the surface)

**Acceptance Criteria:**
- A Model named `VIPDoor` exists in Workspace at roughly X=-120
- It contains exactly: DoorFrame, DoorBlock, VIPSign — all Anchored
- The sign displays the correct text in-game
- The Model has a PrimaryPart set

**Dependencies:** Ticket 2

---

### Ticket 7 — Build the Leaderboard Sign Model
**Type:** Studio

**Description:**
Build the visual leaderboard display. The actual leaderboard data will be populated by a script in a later ticket. For now, just build the physical sign.

1. Insert a **Model** into Workspace and rename it `LeaderboardSign`
2. Inside it, create:
   - A Part named `DisplayBoard` — Position X=100, Y=10, Z=100 — Size X=14, Y=10, Z=1 — BrickColor "Really black" — Anchored
3. Add a **SurfaceGui** to `DisplayBoard`:
   - Insert a TextLabel inside it
   - Text: `TOP SIGMA GRINDERS`
   - TextColor3: bright yellow (RGB 255, 200, 0), Font: GothamBold
   - A second TextLabel below with placeholder text: `1. ---` through `5. ---` (these will be replaced by script)
   - Size both labels to fill their area
4. Set `DisplayBoard` as the Model's PrimaryPart

**Acceptance Criteria:**
- A Model named `LeaderboardSign` with a child part named `DisplayBoard` exists in Workspace at roughly X=100
- The SurfaceGui shows "TOP SIGMA GRINDERS" heading in-game
- Part is Anchored

**Dependencies:** Ticket 2

---

### Ticket 8 — Build the Shop Kiosk Model
**Type:** Studio

**Description:**
Build the shop access point in the lobby. A ProximityPrompt on the front face will later trigger the shop UI. For now, build the model and add the prompt.

1. Insert a **Model** into Workspace and rename it `ShopKiosk`
2. Inside it, create:
   - A Part named `KioskFront` — Position X=-80, Y=4, Z=180 — Size X=6, Y=8, Z=2 — BrickColor "Neon orange" — Anchored
3. Add a **ProximityPrompt** to `KioskFront`:
   - Insert Object → ProximityPrompt
   - Set **ActionText** to `Open Shop`
   - Set **ObjectText** to `Skin Shop`
   - Set **MaxActivationDistance** to 10
4. Add a **SurfaceGui** to `KioskFront`:
   - TextLabel with Text: `SKINS — GET COOKED`
   - TextColor3: neon green (RGB 0, 255, 100)
   - Font: GothamBold
5. Set `KioskFront` as the Model's PrimaryPart

**Acceptance Criteria:**
- A Model named `ShopKiosk` exists in Workspace with a child named `KioskFront`
- Standing near it shows the ProximityPrompt "Open Shop" prompt in-game
- The sign text is visible on the kiosk surface

**Dependencies:** Ticket 2

---

### Ticket 9 — Build the Tower Portal Model
**Type:** Studio

**Description:**
Build the entry portal at the base of the tower. Players touch the PortalTrigger part to enter the tower when a round is active. The portal will be scripted in a later ticket to open and close.

1. Insert a **Model** into Workspace and rename it `TowerPortal`
2. Inside it, create:
   - A Part named `PortalFrame` — Position X=0, Y=5, Z=20 — Size X=12, Y=10, Z=2 — BrickColor "Bright violet" — Anchored — Material: Neon
   - A Part named `PortalTrigger` — Position X=0, Y=3, Z=20 — Size X=8, Y=6, Z=2 — Anchored — CanCollide: false — Transparency: 0.8 — BrickColor "Cyan"
3. Add a **SurfaceGui** to `PortalFrame` (the frame part, not the trigger):
   - TextLabel Text: `ENTER IF YOU HAVE RIZZ`
   - TextColor3: neon yellow (RGB 255, 255, 0), BackgroundColor3: black
   - Font: GothamBold
4. Set `PortalFrame` as the Model's PrimaryPart

**Acceptance Criteria:**
- A Model named `TowerPortal` exists in Workspace
- It contains exactly: PortalFrame and PortalTrigger
- The entry sign text is visible on the frame
- PortalTrigger has CanCollide = false so players pass through it

**Dependencies:** Ticket 3

---

### Ticket 10 — Build the Timer Display Model
**Type:** Studio

**Description:**
Build the round countdown sign visible near the tower entrance. A script will update the text each second — for now just build the sign with placeholder text.

1. Insert a **Model** into Workspace and rename it `TimerDisplay`
2. Inside it, create:
   - A Part named `TimerBoard` — Position X=0, Y=8, Z=50 — Size X=10, Y=4, Z=1 — BrickColor "Really black" — Anchored
3. Add a **SurfaceGui** to `TimerBoard`:
   - Set **Face** to Front
   - Insert a TextLabel — Text: `ROUND STARTS IN: --:--` — TextColor3: white — Font: GothamBold — TextScaled: true
4. Set `TimerBoard` as the Model's PrimaryPart

**Acceptance Criteria:**
- A Model named `TimerDisplay` with child `TimerBoard` exists in Workspace
- The SurfaceGui shows placeholder timer text in-game facing the lobby
- Part is Anchored

**Dependencies:** Ticket 2

---

### Ticket 11 — Create the NPCGroup Folder and Placeholder NPCs
**Type:** Studio

**Description:**
Create the container folder for all lobby NPC decorations and add 5 placeholder NPCs. Real character meshes come later — for now each NPC is a colored block with a floating name label.

1. Insert a **Folder** into Workspace and rename it `NPCGroup`
2. For each NPC below, create a **Model** inside `NPCGroup`, with the exact name shown:

   | Model Name | Position | Block Color |
   |---|---|---|
   | NPC_Tralalelo | X=-80, Y=4, Z=180 | "Bright blue" |
   | NPC_Bombardiro | X=80, Y=4, Z=180 | "Bright green" |
   | NPC_TungTung | X=-80, Y=4, Z=100 | "Bright orange" |
   | NPC_Ballerina | X=80, Y=4, Z=100 | "Hot pink" |
   | NPC_Skibidi | X=0, Y=4, Z=160 | "Bright yellow" |

3. Inside each Model, create:
   - A Part named `Body` at the position above — Size X=4, Y=5, Z=2 — Anchored — BrickColor as listed
   - A **BillboardGui** attached to the Body part:
     - Size: {0,200},{0,50}
     - StudsOffset: {0,4,0} (floats above the block)
     - A TextLabel inside it with the character's display name (see below), Font: GothamBold, TextColor3: white, BackgroundTransparency: 1

   Display names for BillboardGui:
   - NPC_Tralalelo → `Tralalelo Tralala`
   - NPC_Bombardiro → `Bombardiro Crocodilo`
   - NPC_TungTung → `Tung Tung Tung Sahur`
   - NPC_Ballerina → `Ballerina Cappuccina`
   - NPC_Skibidi → `Skibidi Toilet`

4. Set each Model's PrimaryPart to its Body part

**Acceptance Criteria:**
- `Workspace > NPCGroup` folder exists
- 5 NPC Models exist inside it with exact names listed above
- Each NPC has a Body part and a BillboardGui floating above it
- Each BillboardGui shows the correct display name in-game
- All Body parts are Anchored

**Dependencies:** Ticket 2

---

### Ticket 12 — Add the VIP Lounge Raised Platform
**Type:** Studio

**Description:**
Build the VIP-only raised platform. It is visually distinct (gold floor, elevated +4 studs) and physically blocked by the VIPDoor built in Ticket 6.

1. Insert a **Part** into Workspace and name it `VIPLounge`
2. Set:
   - **Position:** X=-120, Y=0, Z=80
   - **Size:** X=40, Y=2, Z=40
   - **Anchored:** true
   - **BrickColor:** "Bright yellow" (gold floor)
3. Add neon trim walls around the lounge perimeter — create 4 thin Parts (no special name needed) as children of a Model named `VIPLounge_Decor`:
   - Each wall: Size X=40, Y=4, Z=1 (or rotated for the sides), BrickColor "Electric blue", Material: Neon, Anchored
   - Position them flush against the 4 edges of the VIPLounge platform
4. The VIPDoor (built in Ticket 6) already guards the entrance — no additional blocking needed here

**Acceptance Criteria:**
- A Part named `VIPLounge` exists in Workspace, gold colored, elevated
- Neon trim walls surround the platform visually
- The lounge is visually distinct from the regular lobby floor in-game

**Dependencies:** Ticket 6

---

### Ticket 13 — Add Lobby Checkerboard Floor Tiles
**Type:** Studio

**Description:**
Replace the plain LobbyFloor color with a brainrot-style checkerboard pattern using alternating bright green and hot pink tiles. You will cover the LobbyFloor surface with individual tile parts.

The lobby floor is 300 × 300 studs. Tiles are 10 × 10 studs, so you need a 30 × 30 grid = 900 tiles. To avoid placing these manually, you will write a simple one-time Script in the Command Bar.

1. In Studio, open the **Command Bar** (View → Command Bar)
2. Paste and run the following Luau snippet:

```lua
local floor = workspace.LobbyFloor
local tileSize = 10
local gridCount = 30
local startX = -145
local startZ = 5  -- lobby Z center is 150, so 150 - 145 = 5 offset

for row = 0, gridCount - 1 do
    for col = 0, gridCount - 1 do
        local tile = Instance.new("Part")
        tile.Size = Vector3.new(tileSize, 0.4, tileSize)
        tile.Anchored = true
        tile.CanCollide = false
        tile.Position = Vector3.new(startX + col * tileSize + 5, 0.2, startZ + row * tileSize + 5)
        if (row + col) % 2 == 0 then
            tile.BrickColor = BrickColor.new("Bright green")
        else
            tile.BrickColor = BrickColor.new("Hot pink")
        end
        tile.Parent = workspace.LobbyFloor
    end
end
print("Tiles created!")
```

3. After running, verify tiles appear covering the lobby floor
4. Select all tiles (they will be children of LobbyFloor) and group them into a Model named `FloorTiles` inside LobbyFloor for organization

**Acceptance Criteria:**
- The lobby floor is covered in alternating green and hot pink tiles
- Tiles are non-collidable (players don't snag on tile edges) and sit just above LobbyFloor
- "Tiles created!" prints in the Output window confirming the script ran

**Dependencies:** Ticket 2

---

### Ticket 14 — Add Lobby Decorations (Confetti, Corner Pillars, Tower Ring)
**Type:** Studio

**Description:**
Add the remaining lobby decorations: scattered confetti blocks, 4 corner pillars, and a glowing ring at the tower base.

**Confetti blocks (10–20 small colored parts):**
1. Create a Model in Workspace named `LobbyDecor`
2. Inside it, create 15 small Parts with random bright BrickColors:
   - Size: roughly X=1, Y=1, Z=1 (vary slightly for effect)
   - Scatter them around the lobby floor (various X/Z positions between -120 and 120, Z between 80 and 220)
   - Anchored = true, CanCollide = false
   - Use colors like: "Bright red", "Bright blue", "Bright yellow", "Cyan", "Magenta"

**Corner pillars (4 tall thin parts):**
3. Inside `LobbyDecor`, create 4 Parts named `Pillar_NW`, `Pillar_NE`, `Pillar_SW`, `Pillar_SE`:
   - Size: X=4, Y=30, Z=4
   - BrickColor: "Bright orange"
   - Anchored = true
   - Positions (approx corners of the lobby):
     - Pillar_NW: X=-145, Y=13, Z=5
     - Pillar_NE: X=145, Y=13, Z=5
     - Pillar_SW: X=-145, Y=13, Z=295
     - Pillar_SE: X=145, Y=13, Z=295

**Tower base glowing ring:**
4. Inside `LobbyDecor`, create 8 thin Parts arranged in a ring around TowerBase (at Y=2, radius ~35 studs from center):
   - Each part: Size X=12, Y=1, Z=2, BrickColor "Neon yellow" or "Cyan", Material: Neon, Anchored
   - Rotate each part to form an octagonal ring shape around X=0, Z=0
   - Approximate positions for the 8 segments (rotate CFrame by 45-degree increments around Y-axis)

**Acceptance Criteria:**
- `LobbyDecor` Model exists in Workspace with confetti, pillars, and ring parts inside it
- Confetti blocks are scattered visibly around the lobby floor
- 4 orange pillars stand at the lobby corners
- A neon ring is visible at the base of the tower when viewed from the lobby

**Dependencies:** Ticket 3, Ticket 13

---

### Ticket 15 — Create a Starter Obstacle Section in ReplicatedStorage
**Type:** Studio

**Description:**
Build one complete obstacle section Model that scripts can clone into the world each round. This establishes the template all future sections follow. You will build `OhioZone` — a simple section with a few platforms.

1. Insert a **Model** into `ReplicatedStorage > Sections` and name it `OhioZone`
2. Inside `OhioZone`, create the following parts (all Anchored):

   **Floor entry slab:**
   - Part named `Floor` — Position X=0, Y=0, Z=0 — Size X=50, Y=2, Z=50 — BrickColor "Sand green"

   **Entry marker:**
   - Part named `Entry` — Position X=0, Y=0, Z=0 — Size X=2, Y=2, Z=2 — Anchored — CanCollide: false — Transparency: 1

   **Exit marker:**
   - Part named `Exit` — Position X=0, Y=50, Z=0 — Size X=2, Y=2, Z=2 — Anchored — CanCollide: false — Transparency: 1

   **3 floating platforms (the actual obstacles):**
   - Part `Platform_A` — Position X=-15, Y=15, Z=0 — Size X=12, Y=2, Z=8 — BrickColor "Bright blue"
   - Part `Platform_B` — Position X=15, Y=25, Z=0 — Size X=12, Y=2, Z=8 — BrickColor "Bright yellow"
   - Part `Platform_C` — Position X=0, Y=38, Z=0 — Size X=16, Y=2, Z=8 — BrickColor "Bright green"

3. Set the Model's **PrimaryPart** to `Entry`
4. Confirm: the section is 50 studs wide, 50 studs deep, 50 studs tall from Entry (Y=0) to Exit (Y=50)

**Acceptance Criteria:**
- `ReplicatedStorage > Sections > OhioZone` Model exists
- It contains Entry, Exit, Floor, and at least 3 platform Parts
- Entry is at Y=0 (bottom-center), Exit is at Y=50 (top-center)
- PrimaryPart is set to Entry
- The section is self-contained — all parts are children of OhioZone

**Dependencies:** Ticket 1

---

### Ticket 16 — Create a Second Obstacle Section (SigmaGrindset)
**Type:** Studio

**Description:**
Build a second section following the same rules as Ticket 15. This proves the pattern works and gives the tower assembly script at least 2 sections to randomize between.

1. Insert a **Model** into `ReplicatedStorage > Sections` and name it `SigmaGrindset`
2. Follow the exact same structure as OhioZone:
   - `Entry` part at Y=0, center, invisible, CanCollide false
   - `Exit` part at Y=50, center, invisible, CanCollide false
   - A floor slab if desired (optional for this section)
   - At least 3 obstacle platforms at different heights between Y=5 and Y=48
   - Give this section a different visual style — use neon colors (BrickColor "Neon orange", "Electric blue") to match the Sigma theme
3. Add 2–3 small Parts with SurfaceGui TextLabels showing motivational meme text:
   - "STAY SIGMA"
   - "GRIND NEVER STOPS"
   - "NO DAYS OFF"
4. Set PrimaryPart to `Entry`

**Acceptance Criteria:**
- `ReplicatedStorage > Sections > SigmaGrindset` Model exists
- Follows the same Entry/Exit/50-stud-tall structure as OhioZone
- Has a visually distinct style from OhioZone
- Contains meme text signs
- PrimaryPart set to Entry

**Dependencies:** Ticket 15

---

### Ticket 17 — Write the KillPlane Script
**Type:** Script

**Description:**
Write the server Script that kills any player who touches the KillPlane and respawns them at the lobby spawn. This is a Script (runs on the server), not a LocalScript.

1. In the Explorer, expand `Workspace > KillPlane`
2. Right-click `KillPlane` → Insert Object → **Script**
3. Rename it `KillPlaneScript`
4. Delete the default `print("Hello world!")` line
5. Paste the following code:

```lua
-- KillPlaneScript
-- Kills any character that falls onto the kill plane and respawns them at LobbySpawn

local killPlane = script.Parent  -- this is the KillPlane part

killPlane.Touched:Connect(function(hit)
    -- 'hit' is whatever part touched the kill plane
    -- We need to find the player character it belongs to
    local character = hit.Parent
    local player = game.Players:GetPlayerFromCharacter(character)

    if player then
        -- LoadCharacter() kills and respawns the player at their SpawnLocation
        player:LoadCharacter()
    end
end)
```

6. Hit Play and test by walking off the lobby floor — your character should die and respawn at `LobbySpawn`

**Acceptance Criteria:**
- A Script named `KillPlaneScript` exists inside `Workspace > KillPlane`
- During Play mode, walking into the kill plane (easiest to test by deleting the lobby floor temporarily or moving your character in the workspace) causes the character to respawn at LobbySpawn
- No errors appear in the Output window when the script runs

**Dependencies:** Ticket 4, Ticket 5

---

### Ticket 18 — Write the FinishPlatform Touch Detection Script
**Type:** Script

**Description:**
Write the server Script that detects when the first player touches the FinishPlatform and prints a win message. The full win condition (coins, round end) belongs to other modules — this script only handles touch detection and logs it. It also fires a fireworks particle effect and plays a win sound.

First, add the FinishPlatform part to Workspace (it is normally placed by the assembly script each round, but for testing you will place a static version):

1. Insert a **Part** into Workspace and name it `FinishPlatform`
2. Set:
   - **Position:** X=0, Y=54, Z=0 (just above TowerBase for testing)
   - **Size:** X=50, Y=4, Z=50
   - **BrickColor:** "Bright yellow"
   - **Anchored:** true
3. Right-click `FinishPlatform` → Insert Object → **Script**, rename it `FinishScript`
4. Paste the following code:

```lua
-- FinishScript
-- Detects the first player to touch the FinishPlatform

local finishPlatform = script.Parent
local roundActive = true  -- simple flag: only fire once per round

finishPlatform.Touched:Connect(function(hit)
    if not roundActive then return end  -- already won, ignore further touches

    local character = hit.Parent
    local player = game.Players:GetPlayerFromCharacter(character)

    if player then
        roundActive = false  -- lock out other players

        print(player.Name .. " reached the top! WINNER!")

        -- Notify all players
        for _, p in pairs(game.Players:GetPlayers()) do
            if p == player then
                -- TODO: show winner UI to this player (handled by Round Loop Module)
            else
                -- TODO: show "so close!" message (handled by Round Loop Module)
            end
        end

        -- TODO: award coins and end round (handled by Round Loop Module)
    end
end)
```

5. Test by pressing Play, walking to the FinishPlatform — the Output should show "[YourName] reached the top! WINNER!"

**Acceptance Criteria:**
- A Part named `FinishPlatform` exists in Workspace, gold colored
- A Script named `FinishScript` is inside it
- Touching the platform in Play mode prints the winner message in Output
- The `roundActive` flag prevents the message from firing more than once per session

**Dependencies:** Ticket 3, Ticket 17

---

## Notes
- First module — establishes baseline structure all other modules depend on
- Lobby layout affects NPC placement (character-skins module) and shop UI (gamepasses module)
- Tickets 1–14 are pure Studio work (no scripting) and can be done by a developer learning Studio
- Tickets 15–16 are Studio work that establishes the section template used by the Tower Assembly Module
- Tickets 17–18 are the only scripts owned by this module; full round logic is deferred to Round Loop and Tower Assembly modules
- FinishPlatform placed in Ticket 18 is a static test placement; the real placement each round is handled by the Tower Assembly Module
- NPC animations (idle loops) are stubbed out in Ticket 11 with placeholders; full NPC animation belongs to the Character Skins Module
