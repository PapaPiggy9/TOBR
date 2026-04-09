# Tower of Brainrot — Project Specs

## Overview
A Roblox obby/tower game inspired by **Tower of Hell**, themed around internet "brainrot" culture and meme characters. Core loop is the same — climb a randomly-generated tower of obstacle sections before the timer runs out — but with heavy monetization, brainrot skin cosmetics, and character figures to drive spending.

---

## Core Gameplay (Tower of Hell Foundation)
- Randomly assembled tower from a pool of obstacle sections each round
- No checkpoints (same as Tower of Hell)
- Round timer (~8 minutes default)
- Players race to reach the top; winners get coins/XP
- Lobby between rounds with social hangout area

---

## Brainrot Theme
The entire visual identity is built around popular internet brainrot characters and memes. Examples of characters/figures to include:

- Tralalelo Tralala (shark)
- Bombardiro Crocodilo
- Tung Tung Tung Sahur
- Ballerina Cappuccina
- Brr Brr Patapim
- Bobr Kurwa (beaver)
- Glorbo / Skibidi Toilet variants
- Ohio-themed obstacle sections
- Sigma / Rizz themed UI elements

Characters can appear as:
- Equippable player skins/morphs
- NPC decorations in lobby and tower sections
- Animated idle figures in the hangout area

---

## Monetization — Gamepasses

### Quality of Life
| Gamepass | Description | Suggested Price (Robux) |
|---|---|---|
| VIP | 2x coins per round, gold name tag, exclusive lobby area | 299 |
| Infinite Attempts | Rejoin tower mid-round without waiting for next round | 499 |
| Speed Boost | Permanent +10% walk/run speed | 349 |
| Anti-Gravity | Lower gravity toggle | 399 |
| Ghost Mode | Walk through other players (no player collision) | 249 |

### Cosmetic Packs
| Gamepass | Description | Suggested Price (Robux) |
|---|---|---|
| Brainrot Starter Pack | Unlocks 5 base brainrot character skins | 199 |
| Shark Pack (Tralalelo) | Shark skin + shark-themed trail + music | 299 |
| Croc Pack (Bombardiro) | Croc skin + explosion particle effect | 299 |
| Sigma Bundle | All "sigma" themed skins + UI reskin | 499 |
| Full Brainrot Bundle | All character skins (best value) | 999 |

### Gameplay Modifiers
| Gamepass | Description | Suggested Price (Robux) |
|---|---|---|
| Section Skip | Skip one obstacle section per round | 599 |
| Double Jump | Permanent double jump ability | 449 |
| Section Reveal | See the full tower layout before the round starts | 349 |
| Extra Time | Add 60 seconds to your personal timer per round | 399 |

### Social / Flex
| Gamepass | Description | Suggested Price (Robux) |
|---|---|---|
| Custom Chat Tags | Colored/custom tag above name | 199 |
| Emote Pack | Brainrot-themed emotes (dances, reactions) | 299 |
| Pet Companion | Small brainrot character follows you up the tower | 349 |
| Boom Box | Play music in lobby | 149 |

---

## Developer Products (One-Time Purchases)
- Coin Packs (100 / 500 / 1000 coins for Robux)
- Tower Skip Token — skip current round, jump to next
- Revive Token — respawn mid-tower once (single use)

---

## Tower Sections
Obstacle sections should have brainrot-themed names and aesthetics:
- "Ohio Zone" — surreal/weird obstacles
- "Sigma Grindset" — moving platforms with motivational meme text
- "Skibidi Bathroom" — toilet-themed section
- "Italian Brainrot" — Tralalelo / Bombardiro themed section
- "Rizz Corridor" — neon, flashy aesthetic
- Standard difficulty tiers: Easy / Medium / Hard / Insane / Brainrot (extreme)

---

## Tech Stack
- **Engine:** Roblox Studio (Luau scripting)
- **Game Structure:** ServerScriptService, ReplicatedStorage, StarterGui, StarterCharacterScripts
- **Monetization:** MarketplaceService for gamepasses and developer products
- **Data Persistence:** DataStoreService for coins, owned passes, and stats
- **Randomization:** Server-side tower assembly from section ModuleScripts

---

## Folder Structure (Planned)
```
Tower Of Brainrot/
  src/
    server/          -- ServerScriptService scripts
    client/          -- LocalScripts (StarterPlayerScripts)
    shared/          -- ReplicatedStorage ModuleScripts
      sections/      -- Obstacle section definitions
      characters/    -- Brainrot character skin data
      gamepasses/    -- Gamepass ID configs and effects
  assets/            -- Exported models, textures, sounds
  docs/              -- Design notes, section ideas
```

---

## Next Steps
- [ ] Set up Roblox Studio project and folder structure
- [ ] Build 5–10 starter obstacle sections
- [ ] Implement tower assembly and round loop (ServerScript)
- [ ] Implement DataStore for coins and gamepass ownership
- [ ] Build lobby area with brainrot NPC decorations
- [ ] Add first batch of character skins (Tralalelo, Bombardiro, Skibidi)
- [ ] Wire up MarketplaceService for all gamepasses
- [ ] Playtest and tune difficulty/timer

---

## Development Workflow

### Module Structure
Each feature is developed as an isolated module. Every module lives under `@Claude/` with its own directory.

**Naming Convention:** Module directories use all-caps with a `MODULE` suffix and spaces, e.g. `LAYOUT MODULE`, `GAMEPASSES MODULE`, `ROUND LOOP MODULE`.

Each module contains:
- `spec.md` — full design spec (written and finalized by Spec Agent)
- `memory.md` — pipeline status, decisions log, and tickets
- `requests/` — drop files here when other modules need something from this module

```
Tower Of Brainrot/@Claude/
  CLAUDE.md                          -- project-level spec (this file)
  LAYOUT MODULE/
    spec.md
    memory.md
    requests/
  ROUND LOOP MODULE/
    spec.md
    memory.md
    requests/
  TOWER ASSEMBLY MODULE/
    spec.md
    memory.md
    requests/
  PLAYER MODULE/
    spec.md
    memory.md
    requests/
  GAMEPASSES MODULE/
    spec.md
    memory.md
    requests/
  CHARACTER SKINS MODULE/
    spec.md
    memory.md
    requests/
```

### Module Directory Map
| Name | Path |
|---|---|
| Layout | `@Claude/LAYOUT MODULE/` |
| Round Loop | `@Claude/ROUND LOOP MODULE/` |
| Tower Assembly | `@Claude/TOWER ASSEMBLY MODULE/` |
| Player | `@Claude/PLAYER MODULE/` |
| Gamepasses | `@Claude/GAMEPASSES MODULE/` |
| Character Skins | `@Claude/CHARACTER SKINS MODULE/` |

- `spec.md` — full design spec for the module
- `memory.md` — running context, decisions, and ticket history for the module

### Agent Pipeline
Each module flows through a 4-agent pipeline in sequence:

1. **Spec Agent** — takes a feature idea, writes a full design spec into the module's `spec.md`
2. **Ticket Agent** — reads the spec, breaks it into discrete, actionable dev tickets stored in `memory.md`
3. **Code Writer Agent** — implements Luau code based on the tickets
4. **QA Agent** — reviews the code against the spec and tickets, flags issues or approves

Each agent reads only its module's directory as context to keep features isolated.

### Open Questions (to resolve before first module)
- [ ] Should Code Writer output directly into the Roblox Studio project folder or a staging `src/` under the module dir?
- [ ] Should QA do static code review only, or also write test scripts where applicable?
- [ ] Which module to tackle first?
