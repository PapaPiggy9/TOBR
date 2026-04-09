# PLAYER MODULE — Spec

**Status:** Pending
**Pipeline Stage:** Not Started
**Last Updated:** 2026-04-04

---

## Purpose
Manage all per-player state — coins, XP, stats, DataStore persistence, death/respawn handling, and gamepass ownership checks.

---

## Responsibilities
- Load player data from DataStore on join
- Save player data to DataStore on leave and periodically
- Track coins, XP, rounds played, rounds won
- Award coins/XP at round end
- Handle player death — respawn to lobby instantly
- Expose gamepass ownership checks to other modules
- Handle player leaving cleanly (no data loss)

---

## Data Schema
```lua
{
  coins = 0,
  xp = 0,
  roundsPlayed = 0,
  roundsWon = 0,
  ownedGamepasses = {},   -- populated from MarketplaceService
  equippedSkin = "default"
}
```

---

## Dependencies
- **ROUND LOOP MODULE** — listens for RoundEnd/PlayerWon to award coins
- **GAMEPASSES MODULE** — provides gamepass IDs for ownership checks
- **CHARACTER SKINS MODULE** — reads equippedSkin to apply on spawn

---

## Open Questions
- [ ] How many coins awarded for winning vs. participating?
- [ ] Is there an XP leveling system or just a display stat?
- [ ] How often should auto-save run? (every 60 seconds is standard)
