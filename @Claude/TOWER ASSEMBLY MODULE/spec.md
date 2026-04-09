# TOWER ASSEMBLY MODULE — Spec

**Status:** Finalized
**Pipeline Stage:** Spec Complete → Ready for Code Writer
**Last Updated:** 2026-04-04

---

## Purpose

Randomly assemble the tower each round by cloning obstacle section Models from ReplicatedStorage, stacking them vertically above TowerBase, and placing FinishPlatform on top. Tear everything down cleanly when the round resets.

---

## Decisions (All Resolved)

| Decision | Value | Reason |
|---|---|---|
| Sections per round | 10–12 (random per round) | Matches Tower of Hell pacing; matches Layout Module spec |
| Section pool at launch | 2 sections (OhioZone, SigmaGrindset) | These are the only two built so far; more added later |
| Selection method | Random shuffle of available sections, repeated to fill 10–12 count | Simple to implement; no weighted difficulty logic needed at launch |
| Consecutive duplicate rule | Skipped for now | Only 2 sections at launch; will add once pool grows |
| Section orientation | No rotation applied | All sections face the same direction per Layout Module spec |
| FinishPlatform ownership | Tower Assembly places and removes it | Round Loop reads it; Tower Assembly owns its position |
| Cloned section naming | `Tower_Section_1`, `Tower_Section_2`, ... `Tower_Section_N` | Predictable names; easy to find and destroy later |
| Where clones are parented | `workspace.Map.Tower` | Keeps tower objects grouped and separate from lobby objects |
| Stacking math anchor | TowerBase top face at Y=4 (center Y=2, height=4, so top = 2 + 2 = 4) | Derived from TowerBase: Position Y=2, Size Y=4 |
| Section height | 50 studs | Defined in Layout Module |
| FinishPlatform size | 50 × 4 × 50 studs | Defined in Layout Module |
| WaitForChild usage | Required for all workspace and ReplicatedStorage lookups | LayoutBuilder runs every Play; objects may not exist instantly |

---

## How This Module Connects to Round Loop

The Round Loop Module fires two BindableEvents that Tower Assembly must listen to. Both events live at:

```
ServerScriptService > BindableEvents > BuildTower    (BindableEvent)
ServerScriptService > BindableEvents > DestroyTower  (BindableEvent)
```

**BuildTower** fires at the start of Intermission (20 seconds before the round begins). Tower Assembly must complete the full build within this window. Server-side Part cloning is fast — 10–12 sections will finish in well under 1 second.

**DestroyTower** fires during the Reset phase (after Round End). Tower Assembly must destroy all cloned sections and remove FinishPlatform from the world.

---

## Section Pool

Sections live in:
```
ReplicatedStorage > Sections > OhioZone       (Model, has Entry and Exit parts)
ReplicatedStorage > Sections > SigmaGrindset  (Model, has Entry and Exit parts)
```

Each Model has two invisible marker parts inside it:
- `Entry` — BasePart at the bottom-center of the section (marks where the section floor is)
- `Exit` — BasePart at the top-center of the section (marks where the section ceiling is)

These markers are used to calculate the section's internal Y offset so stacking is always accurate regardless of where the Model's origin sits.

---

## Section Selection Logic

Each round, the assembly script builds a shuffled list of 10–12 section names drawn from the pool. Since the pool currently has only 2 sections, sections are repeated — the pool is tiled until the target count is reached, then shuffled.

Pseudocode:
```
local POOL = {"OhioZone", "SigmaGrindset"}
local TARGET = math.random(10, 12)

-- Tile the pool to fill TARGET slots
local sectionNames = {}
while #sectionNames < TARGET do
    for _, name in ipairs(POOL) do
        table.insert(sectionNames, name)
        if #sectionNames >= TARGET then break end
    end
end

-- Shuffle using Fisher-Yates
for i = #sectionNames, 2, -1 do
    local j = math.random(1, i)
    sectionNames[i], sectionNames[j] = sectionNames[j], sectionNames[i]
end
```

This approach scales automatically when new section names are added to POOL — no other code changes needed.

---

## Stacking Math

### TowerBase Reference Values
- Position: X=0, Y=2, Z=0
- Size: 54 × 4 × 54 (height = 4 studs)
- Top face Y = Position.Y + (Size.Y / 2) = 2 + 2 = **Y = 4**

### Section Positions
Each cloned section is positioned so its **Entry marker** aligns with the stacking Y for that slot.

The Entry marker inside each section Model tells the script where the section's floor is relative to the Model's CFrame origin. Use this to compute the correct CFrame offset.

```
Section 1 bottom (Entry) Y = 4
Section 2 bottom (Entry) Y = 4 + 50 = 54
Section 3 bottom (Entry) Y = 4 + 100 = 104
Section N bottom (Entry) Y = 4 + (N-1 × 50)
```

General formula:
```
sectionBottomY = 4 + (sectionIndex - 1) * 50
```

To place the section Model at the correct world position:
```lua
local entryLocalY = sectionModel.Entry.Position.Y  -- Y of Entry relative to model origin
local targetWorldY = 4 + (sectionIndex - 1) * 50
local yOffset = targetWorldY - entryLocalY
clone:SetPrimaryPartCFrame(CFrame.new(0, yOffset, 0))
```

X and Z are always 0 (centered on tower). Sections do not rotate.

**Note:** Each section Model must have a PrimaryPart set for SetPrimaryPartCFrame to work. If no PrimaryPart is set, use the Entry marker as the positioning anchor instead (see script ticket for fallback handling).

### FinishPlatform Position
Placed after all sections are stacked:
```
finishPlatformY = 4 + (sectionCount * 50) + (4 / 2)
               = 4 + (sectionCount * 50) + 2
```

The +2 accounts for the FinishPlatform's own half-height (Size.Y = 4, so center is 2 studs above its bottom face).

Example for 10 sections:
```
finishPlatformY = 4 + (10 * 50) + 2 = 4 + 500 + 2 = 506
```

Example for 12 sections:
```
finishPlatformY = 4 + (12 * 50) + 2 = 4 + 600 + 2 = 606
```

---

## FinishPlatform — Placement and Removal

FinishPlatform is a pre-existing BasePart in the workspace at:
```
workspace.Map.Tower.FinishPlatform
```

It is **not** destroyed and recreated each round. Tower Assembly repositions it each round.

**On BuildTower:**
- Wait for FinishPlatform using `WaitForChild()`
- Set `FinishPlatform.CFrame = CFrame.new(0, finishPlatformY, 0)`
- Set `FinishPlatform.Transparency = 0` (make it visible)
- Set `FinishPlatform.CanCollide = true`

**On DestroyTower:**
- Move FinishPlatform far out of the world: `CFrame.new(0, -500, 0)`
- Set `FinishPlatform.Transparency = 1`
- Set `FinishPlatform.CanCollide = false`

This avoids players accidentally touching it during intermission or reset.

---

## Cloned Section Naming Convention

Each cloned section is renamed immediately after cloning:
```
clone.Name = "Tower_Section_" .. sectionIndex
```

Examples: `Tower_Section_1`, `Tower_Section_2`, ..., `Tower_Section_12`

All clones are parented to `workspace.Map.Tower`.

On DestroyTower, the cleanup loop finds and destroys all children of `workspace.Map.Tower` whose names start with `Tower_Section_`.

---

## DestroyTower Cleanup

```lua
local tower = workspace:WaitForChild("Map"):WaitForChild("Tower")
for _, child in ipairs(tower:GetChildren()) do
    if string.sub(child.Name, 1, 14) == "Tower_Section_" then
        child:Destroy()
    end
end
```

After clearing sections, hide FinishPlatform (see above).

---

## Script Architecture

One server Script handles all Tower Assembly logic:

### `TowerAssembler` (Script)
- **Location:** `ServerScriptService > Scripts > TowerAssembler`
- **Type:** Regular Script (server only)
- **Responsibilities:**
  1. On startup, connect to `BuildTower` and `DestroyTower` BindableEvents
  2. On `BuildTower`: select sections, clone them, stack them, place FinishPlatform
  3. On `DestroyTower`: destroy all `Tower_Section_*` instances, hide FinishPlatform

No ModuleScript or client script is needed for this module. All logic is server-side.

---

## Roblox Studio Objects Required

These must exist before the TowerAssembler script is written:

### Already Exists (from Layout Module and LayoutBuilder)
| Object | Location | Notes |
|---|---|---|
| `Map` | `workspace.Map` | Created by LayoutBuilder each Play |
| `Tower` | `workspace.Map.Tower` | Created by LayoutBuilder each Play |
| `TowerBase` | `workspace.Map.Tower.TowerBase` | Position X=0 Y=2 Z=0, Size 54×4×54 |
| `FinishPlatform` | `workspace.Map.Tower.FinishPlatform` | Size 50×4×50, BrickColor "Bright yellow" |
| `Sections` folder | `ReplicatedStorage.Sections` | Already exists |
| `OhioZone` | `ReplicatedStorage.Sections.OhioZone` | Has Entry and Exit parts |
| `SigmaGrindset` | `ReplicatedStorage.Sections.SigmaGrindset` | Has Entry and Exit parts |

### New Objects to Create
| Object | Type | Location | Notes |
|---|---|---|---|
| `TowerAssembler` | Script | `ServerScriptService > Scripts` | Main assembly script |

The `BuildTower` and `DestroyTower` BindableEvents already exist from the Round Loop Module setup at `ServerScriptService > BindableEvents`.

---

## Key Naming Reference (for Code Writer Agent)

| Reference | Path |
|---|---|
| Tower folder | `workspace:WaitForChild("Map"):WaitForChild("Tower")` |
| TowerBase | `workspace:WaitForChild("Map"):WaitForChild("Tower"):WaitForChild("TowerBase")` |
| FinishPlatform | `workspace:WaitForChild("Map"):WaitForChild("Tower"):WaitForChild("FinishPlatform")` |
| Sections folder | `game.ReplicatedStorage:WaitForChild("Sections")` |
| BuildTower event | `game.ServerScriptService:WaitForChild("BindableEvents"):WaitForChild("BuildTower")` |
| DestroyTower event | `game.ServerScriptService:WaitForChild("BindableEvents"):WaitForChild("DestroyTower")` |
| Cloned section parent | `workspace.Map.Tower` |
| Clone naming pattern | `Tower_Section_1` through `Tower_Section_N` |

---

## What This Module Does NOT Cover
- Round timer and phase management → Round Loop Module
- Player win detection on FinishPlatform touch → Round Loop Module
- Coin/XP awards → Player Module
- Gamepass checks → Gamepasses Module
- KillPlane respawn logic → Layout Module
- Character skins → Character Skins Module
