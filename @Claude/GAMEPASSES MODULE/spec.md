# GAMEPASSES MODULE — Spec

**Status:** Pending
**Pipeline Stage:** Not Started
**Last Updated:** 2026-04-04

---

## Purpose
Wire up all Roblox gamepasses and developer products via MarketplaceService. Apply purchased perks to players at runtime.

---

## Responsibilities
- Central config of all gamepass IDs and their effects
- Check ownership on player join and apply active perks
- Handle `ProcessReceipt` for developer products (coin packs, tokens)
- Expose `PlayerHasPass(player, passName)` utility to other modules
- Trigger perk application when a pass is purchased mid-session

---

## Gamepass Registry (from main spec)
| Key | Gamepass | Effect |
|---|---|---|
| VIP | VIP | 2x coins, gold tag, VIP lounge access |
| InfiniteAttempts | Infinite Attempts | Rejoin tower mid-round |
| SpeedBoost | Speed Boost | +10% WalkSpeed |
| AntiGravity | Anti-Gravity | Reduced gravity toggle |
| GhostMode | Ghost Mode | No player collision |
| SectionSkip | Section Skip | Skip one section per round |
| DoubleJump | Double Jump | Double jump ability |
| SectionReveal | Section Reveal | See full tower before round |
| ExtraTime | Extra Time | +60s personal timer |
| PetCompanion | Pet Companion | Brainrot pet follows player |

---

## Dependencies
- **PLAYER MODULE** — stores owned passes, exposes ownership checks
- **ROUND LOOP MODULE** — ExtraTime and SectionReveal hook into round events
- **LAYOUT MODULE** — VIP lounge gating
- **CHARACTER SKINS MODULE** — Pet Companion spawning

---

## Open Questions
- [ ] Are Roblox gamepass IDs assigned yet? (need live game to get IDs)
- [ ] Should effects stack if a player buys multiple related passes?
