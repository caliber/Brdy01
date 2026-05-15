# Phase 1: Foundation + Setup - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-16
**Phase:** 1-Foundation + Setup
**Areas discussed:** Drift schema scope, Course Hive cache structure, FMTC tile caching setup, go_router + crash recovery

---

## Drift Schema Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Full schema now | Define rounds + holes + shots tables at schemaVersion: 1 | ✓ |
| Rounds only now | Add holes/shots via migrations in Phase 2 | |

**User's choice:** Full schema now

---

| Option | Description | Selected |
|--------|-------------|----------|
| Create 18 hole rows at round creation | createRound() inserts rounds row + 18 hole rows in a transaction | |
| Create hole rows on first score | Phase 2 INSERTs a hole row when the user first scores it | ✓ |

**User's choice:** Create hole rows on first score

---

| Option | Description | Selected |
|--------|-------------|----------|
| Define shots table in Phase 1 | Schema completeness — Phase 5 just inserts rows | |
| Shots table deferred to Phase 5 | Add shots table via migration later | |
| You decide | Claude picks | ✓ |

**User's choice:** Deferred to Claude — see Claude's Discretion section.

---

## Course Hive Cache Structure

| Option | Description | Selected |
|--------|-------------|----------|
| Full SETUP-03 data now | Cache name, par, rating, slope, hole-by-hole par + Stroke Index + GPS per hole | ✓ |
| Flat course only | Cache top-level fields only; defer hole-by-hole data to later phases | |

**User's choice:** Full SETUP-03 data now

---

| Option | Description | Selected |
|--------|-------------|----------|
| JSON string in Hive | Serialize via Freezed toJson(), store as String. No TypeAdapter. | ✓ |
| Hive TypeAdapter | Custom TypeAdapter for type-safe, faster reads | |

**User's choice:** JSON string in Hive

---

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — cache GPS data | Cache GPS coordinates if API returns them | ✓ |
| Nullable fields, cache if present | Same outcome — GPS fields nullable in domain model | |

**User's choice:** Yes — cache GPS data if API returns it (GPS fields nullable)

---

## FMTC Tile Caching Setup

| Option | Description | Selected |
|--------|-------------|----------|
| FMTC in main(), bounding box from GPS data | Derive bbox from min/max lat-lng of hole GPS coordinates | ✓ |
| FMTC in main(), fixed radius | Fixed geographic radius around course primary coordinate | |

**User's choice:** FMTC in main(), bounding box from hole GPS coordinates

---

| Option | Description | Selected |
|--------|-------------|----------|
| Z14–17 | Full course overview through green detail. Standard for golf. | ✓ |
| Z12–18 | Wider range — more tiles, longer cache time | |
| You decide | Claude picks | |

**User's choice:** Z14–17

---

| Option | Description | Selected |
|--------|-------------|----------|
| Allow START ROUND during pre-cache | Non-blocking; show progress bar; player can start immediately | ✓ |
| Block START ROUND until pre-cache finishes | Guarantees full offline availability but delays round start | |

**User's choice:** Allow START ROUND during pre-cache (best-effort, non-blocking)

---

## go_router + Crash Recovery

| Option | Description | Selected |
|--------|-------------|----------|
| Router redirect callback | redirect: reads appStartupProvider AsyncValue; re-evaluates on state change | ✓ |
| Initial location override | Async check completes before router builds; passed as initialLocation: | |

**User's choice:** Router redirect callback

---

| Option | Description | Selected |
|--------|-------------|----------|
| Dedicated /splash route | initialLocation is /splash; redirect keeps user there while loading | ✓ |
| No splash route — redirect returns null | initialLocation is /setup; risk of Setup screen flash | |

**User's choice:** Dedicated /splash route

---

| Option | Description | Selected |
|--------|-------------|----------|
| GoRouter in keepAlive Riverpod provider | routerProvider watches appStartupProvider; redirect auto re-evaluates | ✓ |
| GoRouter constructed in BrdyApp.build() | Manual router.refresh() calls; routing coupled to widget build method | |

**User's choice:** GoRouter in a keepAlive Riverpod provider (routerProvider)

---

## Claude's Discretion

- **Shots table in Phase 1:** User said "you decide." Decision: include shots table at schemaVersion: 1. Keeps the complete data model in one schema version; Phase 5 just inserts rows without a table-creation migration.

## Deferred Ideas

None — discussion stayed within phase scope.
