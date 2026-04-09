# TOWER ASSEMBLY MODULE — Memory

## Pipeline Status
- [x] Spec — complete (2026-04-04)
- [x] Tickets — complete (2026-04-04)
- [x] Code — complete (2026-04-04)
- [ ] QA — pending

---

## Decisions Log

| Date | Decision | Reason |
|---|---|---|
| 2026-04-04 | Section count per round: 10–12 (random) | Matches Tower of Hell pacing; Layout Module spec |
| 2026-04-04 | Launch pool: OhioZone + SigmaGrindset only | Only two sections built so far; POOL list is easy to expand |
| 2026-04-04 | Selection: tile pool then Fisher-Yates shuffle | Simple, fair, no bias; scales when more sections are added |
| 2026-04-04 | No consecutive-duplicate rule at launch | Pointless with only 2 sections; add when pool reaches 5+ |
| 2026-04-04 | Clones parented to workspace.Map.Tower | Keeps tower clutter separate from lobby objects |
| 2026-04-04 | Clone naming: Tower_Section_1 … Tower_Section_N | Predictable prefix makes cleanup loop trivial |
| 2026-04-04 | FinishPlatform repositioned, not recreated | Simpler than destroy/recreate; avoids re-wiring .Touched in RoundManager |
| 2026-04-04 | Stacking anchor: Entry marker Y inside each section | Decouples assembly math from Model origin placement |
| 2026-04-04 | All workspace lookups use WaitForChild() | LayoutBuilder runs on Play and objects arrive async |

---

## Tickets

### TICKET-TA-01 — Verify FinishPlatform exists inside workspace.Map.Tower

**Type:** Studio Setup
**Depends on:** Layout Module (LayoutBuilder must be done)
**Estimate:** 5 minutes

**What to do:**
1. Press Play in Roblox Studio.
2. In the Explorer, expand `Workspace > Map > Tower`.
3. Confirm a BasePart named exactly `FinishPlatform` is present.
4. Check its properties: Size = 50, 4, 50 — BrickColor = "Bright yellow" — Anchored = true.
5. If it is missing or misnamed, fix it in the LayoutBuilder script before continuing.

**Done when:** `workspace.Map.Tower.FinishPlatform` exists with the correct size and color every time you press Play.

---

### TICKET-TA-02 — Verify OhioZone and SigmaGrindset sections are correct in ReplicatedStorage

**Type:** Studio Setup
**Depends on:** Nothing (sections are static assets)
**Estimate:** 10 minutes

**What to do:**
1. In the Explorer (without pressing Play), open `ReplicatedStorage > Sections`.
2. Confirm both `OhioZone` and `SigmaGrindset` Models exist there.
3. For each Model:
   - Open it and confirm a BasePart named `Entry` exists inside it.
   - Confirm a BasePart named `Exit` exists inside it.
   - Confirm the Model has a **PrimaryPart** set (click the Model, look for PrimaryPart in Properties — it should point to one of the parts inside the model, ideally a base/floor part).
   - Confirm the Model is approximately 50 studs tall (measure from Entry Y to Exit Y).
4. If Entry or Exit is missing, add them as invisible, anchored BaseParts (Size 2×2×2, Transparency = 1, CanCollide = false) at the bottom-center and top-center of the section respectively.
5. If PrimaryPart is not set, click the Model in Explorer, then in the Workspace viewport right-click the floor part of the section and choose "Set as PrimaryPart".

**Done when:** Both Models have Entry, Exit, and PrimaryPart set correctly.

---

### TICKET-TA-03 — Confirm BindableEvents folder and events exist in ServerScriptService

**Type:** Studio Setup
**Depends on:** Round Loop Module (creates these events)
**Estimate:** 5 minutes

**What to do:**
1. In the Explorer, open `ServerScriptService > BindableEvents`.
2. Confirm `BuildTower` (BindableEvent) is present.
3. Confirm `DestroyTower` (BindableEvent) is present.
4. If the folder or events are missing, create them now:
   - Right-click `ServerScriptService` → Insert Object → Folder → rename to `BindableEvents`
   - Right-click `BindableEvents` → Insert Object → BindableEvent → rename to `BuildTower`
   - Repeat for `DestroyTower`

**Done when:** Both BindableEvents exist at the correct path.

---

### TICKET-TA-04 — Create the TowerAssembler Script in ServerScriptService

**Type:** Studio Setup
**Depends on:** TICKET-TA-01, TICKET-TA-02, TICKET-TA-03
**Estimate:** 2 minutes

**What to do:**
1. In the Explorer, open `ServerScriptService > Scripts`.
2. Right-click `Scripts` → Insert Object → Script.
3. Rename the new Script to exactly `TowerAssembler`.
4. Leave the script body empty for now — code is added in TICKET-TA-05.

**Done when:** `ServerScriptService > Scripts > TowerAssembler` (Script) exists.

---

### TICKET-TA-05 — Write the section selection and shuffle logic

**Type:** Script
**File:** `ServerScriptService > Scripts > TowerAssembler`
**Depends on:** TICKET-TA-04
**Estimate:** 20 minutes

**What to do:**

Open `TowerAssembler` and write the top section of the script. This part defines the section pool and builds a shuffled list of section names for the round.

```lua
-- TowerAssembler
-- Listens to BuildTower and DestroyTower BindableEvents from Round Loop.

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")

-- Section pool — add more section names here as they are built
local SECTION_POOL = {
    "OhioZone",
    "SigmaGrindset",
}

-- How many sections to stack each round (random between 10 and 12)
local MIN_SECTIONS = 10
local MAX_SECTIONS = 12

-- Build a shuffled list of section names for one round
local function buildSectionList()
    local target = math.random(MIN_SECTIONS, MAX_SECTIONS)
    local list = {}

    -- Tile the pool until we have enough entries
    while #list < target do
        for _, name in ipairs(SECTION_POOL) do
            table.insert(list, name)
            if #list >= target then break end
        end
    end

    -- Fisher-Yates shuffle
    for i = #list, 2, -1 do
        local j = math.random(1, i)
        list[i], list[j] = list[j], list[i]
    end

    return list
end
```

**Done when:** The function exists and returns a table of 10–12 shuffled section name strings without errors (you can test by calling `print(#buildSectionList())` temporarily).

---

### TICKET-TA-06 — Write the section stacking (BuildTower) function

**Type:** Script
**File:** `ServerScriptService > Scripts > TowerAssembler`
**Depends on:** TICKET-TA-05
**Estimate:** 30 minutes

**What to do:**

Add the `buildTower` function below the code from TICKET-TA-05. This function:
1. Gets the shuffled section list.
2. For each section name, clones the Model from ReplicatedStorage.
3. Names the clone `Tower_Section_N`.
4. Parents the clone to `workspace.Map.Tower`.
5. Positions the clone using the Entry marker and stacking math.
6. Positions FinishPlatform on top of the last section.

```lua
-- Stacking constants
local TOWER_BASE_TOP_Y = 4    -- TowerBase: Position Y=2, Height=4, so top face = Y=4
local SECTION_HEIGHT   = 50   -- Each section is 50 studs tall
local FINISH_HALF_HEIGHT = 2  -- FinishPlatform Size.Y=4, half = 2

local function buildTower()
    local sectionsFolder = ReplicatedStorage:WaitForChild("Sections")
    local towerFolder    = workspace:WaitForChild("Map"):WaitForChild("Tower")
    local finishPlatform = towerFolder:WaitForChild("FinishPlatform")

    local sectionList = buildSectionList()

    for i, sectionName in ipairs(sectionList) do
        -- Clone the section Model from ReplicatedStorage
        local template = sectionsFolder:WaitForChild(sectionName)
        local clone    = template:Clone()

        -- Name it so we can find and destroy it later
        clone.Name = "Tower_Section_" .. i

        -- Parent to workspace before moving (required for SetPrimaryPartCFrame)
        clone.Parent = towerFolder

        -- Calculate where this section's bottom (Entry) should be in world space
        local sectionBottomY = TOWER_BASE_TOP_Y + (i - 1) * SECTION_HEIGHT

        if clone.PrimaryPart then
            -- Use SetPrimaryPartCFrame — offset so Entry lands at sectionBottomY
            local entryLocalY = clone:WaitForChild("Entry").Position.Y
            local yOffset = sectionBottomY - entryLocalY
            clone:SetPrimaryPartCFrame(CFrame.new(0, yOffset, 0))
        else
            -- Fallback: use Entry part as anchor directly
            local entry = clone:WaitForChild("Entry")
            local offset = sectionBottomY - entry.Position.Y
            for _, part in ipairs(clone:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Position = part.Position + Vector3.new(0, offset, 0)
                end
            end
        end
    end

    -- Place FinishPlatform on top of the last section
    local finishY = TOWER_BASE_TOP_Y + (#sectionList * SECTION_HEIGHT) + FINISH_HALF_HEIGHT
    finishPlatform.CFrame      = CFrame.new(0, finishY, 0)
    finishPlatform.Transparency = 0
    finishPlatform.CanCollide  = true

    print("TowerAssembler: built tower with " .. #sectionList .. " sections. FinishPlatform at Y=" .. finishY)
end
```

**Done when:** When `buildTower()` is called, sections appear stacked above TowerBase in the expected positions and FinishPlatform appears at the top. Verify in Studio by calling it from the command bar or a test run.

---

### TICKET-TA-07 — Write the tower teardown (DestroyTower) function

**Type:** Script
**File:** `ServerScriptService > Scripts > TowerAssembler`
**Depends on:** TICKET-TA-06
**Estimate:** 15 minutes

**What to do:**

Add the `destroyTower` function below the `buildTower` function.

```lua
local function destroyTower()
    local towerFolder    = workspace:WaitForChild("Map"):WaitForChild("Tower")
    local finishPlatform = towerFolder:WaitForChild("FinishPlatform")

    -- Destroy all cloned sections
    for _, child in ipairs(towerFolder:GetChildren()) do
        if string.sub(child.Name, 1, 14) == "Tower_Section_" then
            child:Destroy()
        end
    end

    -- Move FinishPlatform out of the world so no one can touch it between rounds
    finishPlatform.CFrame      = CFrame.new(0, -500, 0)
    finishPlatform.Transparency = 1
    finishPlatform.CanCollide  = false

    print("TowerAssembler: tower destroyed.")
end
```

**Done when:** When `destroyTower()` is called, all `Tower_Section_*` instances are gone from the workspace and FinishPlatform is no longer visible or touchable.

---

### TICKET-TA-08 — Wire up BuildTower and DestroyTower BindableEvents

**Type:** Script
**File:** `ServerScriptService > Scripts > TowerAssembler`
**Depends on:** TICKET-TA-07
**Estimate:** 10 minutes

**What to do:**

Add the event connections at the bottom of `TowerAssembler`. This is the final piece — it makes the script react to signals from RoundManager.

```lua
-- Connect to BindableEvents from Round Loop
local bindableEvents = ServerScriptService:WaitForChild("BindableEvents")
local buildEvent     = bindableEvents:WaitForChild("BuildTower")
local destroyEvent   = bindableEvents:WaitForChild("DestroyTower")

buildEvent.Event:Connect(function()
    print("TowerAssembler: BuildTower event received.")
    buildTower()
end)

destroyEvent.Event:Connect(function()
    print("TowerAssembler: DestroyTower event received.")
    destroyTower()
end)

print("TowerAssembler: ready and listening.")
```

**Done when:** The script runs without errors on Play, prints "ready and listening", and responds to both events being fired.

---

### TICKET-TA-09 — Integration Test: full round cycle

**Type:** Integration Test
**Depends on:** TICKET-TA-08, Round Loop Module (RoundManager script must be written)
**Estimate:** 20 minutes

**What to do:**

Test the full build-and-destroy cycle works correctly when driven by RoundManager.

**Test steps:**

1. Press Play in Roblox Studio.
2. Wait for the Intermission phase to begin (RoundManager fires `BuildTower`).
3. In the Output window, confirm you see:
   - `TowerAssembler: ready and listening.`
   - `TowerAssembler: BuildTower event received.`
   - `TowerAssembler: built tower with N sections. FinishPlatform at Y=...`
4. In the viewport, confirm:
   - Sections are stacked directly above TowerBase with no gaps and no overlaps.
   - FinishPlatform (gold platform) is visible at the very top of the stack.
   - All clones are inside `workspace.Map.Tower` (check Explorer).
   - Clone names are `Tower_Section_1` through `Tower_Section_N`.
5. Wait for the round to end and reach the Reset phase (RoundManager fires `DestroyTower`).
6. Confirm you see in Output:
   - `TowerAssembler: DestroyTower event received.`
   - `TowerAssembler: tower destroyed.`
7. In the viewport, confirm:
   - All `Tower_Section_*` instances are gone from Explorer.
   - FinishPlatform is no longer visible in the world.
8. Wait for the next Intermission — confirm a new tower assembles correctly (different random section order).

**Pass criteria:**
- [ ] Tower builds without errors every round
- [ ] Section count is between 10 and 12 each round
- [ ] No sections visually overlap or have gaps between them
- [ ] FinishPlatform sits flush on top of the last section
- [ ] Tower fully disappears after DestroyTower fires
- [ ] Cycle repeats cleanly for at least 3 consecutive rounds

**If something looks wrong:**
- Sections overlapping → check that Entry marker Y is measured correctly inside the Model
- Sections floating with a gap → same Entry marker issue; also verify TOWER_BASE_TOP_Y = 4 is correct
- FinishPlatform at wrong height → check the finishY formula in TICKET-TA-06
- Script errors on WaitForChild → confirm Map and Tower folders are created by LayoutBuilder before TowerAssembler fires

---

## Notes

- When the section pool grows beyond 5 sections, revisit the consecutive-duplicate rule (no two of the same section back-to-back). Not needed now.
- `SetPrimaryPartCFrame` moves all parts relative to the PrimaryPart. Confirm PrimaryPart is set on every section before the Code Writer runs — failing to set it triggers the slower fallback path.
- The LayoutBuilder runs on Play and creates `workspace.Map.Tower`. TowerAssembler's `WaitForChild` calls handle the timing gap safely.
- Do not add coin or gamepass logic here. That belongs to the Player Module and Gamepasses Module.
