# CHARACTER SKINS MODULE — Spec

**Status:** Pending
**Pipeline Stage:** Not Started
**Last Updated:** 2026-04-04

---

## Purpose
Manage all brainrot character skins — equipping, previewing, and applying player morphs/appearances. Also handles lobby NPC decorations.

---

## Responsibilities
- Registry of all available skins and their unlock requirements (gamepass or coins)
- Apply equipped skin to player character on spawn
- Skin selection UI in lobby
- Lobby NPC placement — idle animated brainrot figures
- Pet companion spawning for GAMEPASSES MODULE

---

## Skin Registry (Initial)
| Skin Key | Character | Unlock |
|---|---|---|
| default | Base Roblox character | Free |
| tralalelo | Tralalelo Tralala (shark) | Shark Pack gamepass |
| bombardiro | Bombardiro Crocodilo | Croc Pack gamepass |
| skibidi | Skibidi Toilet | Brainrot Starter Pack |
| sigma | Sigma character | Sigma Bundle gamepass |
| tung | Tung Tung Tung Sahur | Brainrot Starter Pack |

---

## Morph System
- Skins applied via character model swap on spawn
- Skin data stored as Models in ReplicatedStorage/Skins
- Player's equipped skin persisted via PLAYER MODULE

---

## Dependencies
- **PLAYER MODULE** — reads/writes equippedSkin field
- **GAMEPASSES MODULE** — checks ownership before allowing skin equip
- **LAYOUT MODULE** — NPC placement positions in lobby

---

## Open Questions
- [ ] Are skin models being custom made or sourced from the Roblox marketplace?
- [ ] Should there be a free skin rotation to incentivize daily play?
