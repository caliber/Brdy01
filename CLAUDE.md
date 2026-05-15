# BRDY.01 — Project Guide

## What This Is

Flutter strokeplay golf shot tracking app. Three screens: Setup (handicap + course load), Shot Capture (outcome buttons, putts, fairway/GIR, GPS pins, voice), Round Review (scorecard + stats + WHS differential). Local-only, no accounts. Wear OS companion for score buttons on the wrist.

## GSD Workflow

This project uses the GSD (Get Shit Done) workflow. All planning artifacts are in `.planning/`.

### Key Commands

```
/gsd:discuss-phase <N>   — gather context before planning a phase
/gsd:plan-phase <N>      — create detailed plan for a phase
/gsd:execute-phase <N>   — execute all plans in a phase
/gsd:progress            — check current status
/gsd:verify-work         — verify phase goal was achieved
```

### Current State

See `.planning/STATE.md` for current phase and progress.
See `.planning/ROADMAP.md` for the full 5-phase plan.

## Tech Stack

- **Framework:** Flutter / Dart
- **State:** Riverpod 2.x with code generation (`@riverpod` annotations)
- **Local DB:** Drift (SQLite) — write-through, all round data
- **Prefs/Cache:** Hive — handicap index, course cache only (not round data)
- **Navigation:** go_router — `context.go()` not `context.push()` for main screens
- **API:** Dio + Retrofit — Golf Course API (`golfcourseapi.com`)
- **Maps:** flutter_map (OpenStreetMap) + flutter_map_tile_caching
- **GPS:** geolocator — on-demand, not continuous streaming
- **Voice:** speech_to_text — fixed vocabulary, tap-to-speak
- **Wear OS:** wear_plus — Android only, score buttons companion

### API Key

Pass via `--dart-define=GOLF_API_KEY=<value>` at build time. Never hardcode or commit. Validated at startup — empty key = clear error state.

## Architecture

Clean Architecture layers: `lib/features/` → `lib/domain/` → `lib/data/` → `lib/infrastructure/` → `lib/services/`

### Provider keepAlive Rules

These providers MUST be `@Riverpod(keepAlive: true)` — they hold state across screen transitions:
- `appDatabaseProvider`, `hivePlayerPrefsProvider`, `hiveCourseBoxProvider`
- `dioProvider`, `golfCourseApiProvider`
- All repository providers
- `activeRoundIdProvider`, `activeHoleIndexProvider`

Screen-level providers use `@riverpod` (auto-dispose).

### Navigation Model

The 3-screen flow uses `context.go()` to replace the stack — no back-button to Setup from Shot Capture:
- `context.go('/setup')` — start/reset
- `context.go('/shot-capture/$roundId')` — round in progress
- `context.go('/round-review/$roundId')` — round finished

Hole navigation within Shot Capture is internal state (`activeHoleIndexProvider.state = index`), not route pushes. This avoids an 18-level back-stack.

### Drift Schema Rules

- Every `Table` class change MUST bump `schemaVersion` and add an `onUpgrade` migration case
- Run `dart run build_runner build --delete-conflicting-outputs` after every schema change
- Commit `drift_schemas/` JSON for every schema version
- Round data only in Drift — not Hive (Hive is not transactional)

### WHS Differential Formula

```
Course Handicap = round(handicapIndex × (slope / 113) + (courseRating − par))
Adjusted Gross Score = sum of min(hole_score, par + 2 + handicap_strokes_on_hole) per hole
Differential = (AGS − courseRating) × 113 ÷ slope
```

Pickup holes scored at net double bogey = `par + 2 + handicap_strokes_received_on_hole`. Requires Stroke Index per hole from the API.

## Design System

Brutalist monospace aesthetic. All decisions are locked — do not introduce alternative styles.

- **Accent:** `#E8520A` (orange)
- **Background:** Black / off-white — no white-on-white surfaces
- **Numerics:** JetBrains Mono (scores, stats, distances)
- **Labels/Buttons:** Barlow Condensed
- **Contrast:** 7:1+ for all on-course text (WCAG AAA target)
- **Tap targets:** 64×80dp minimum for score buttons (golf gloves, wet hands)

### Scorecard Colour Coding (standard golf convention — do not invent alternatives)

- Eagle: Gold / `#FFD700`
- Birdie: Orange / `#E8520A`
- Par: Plain (no highlight)
- Bogey: Single underline
- Double+: Red / double underline

## Critical Don'ts

- **Don't** hold round state in memory without writing to Drift — OS will kill the app mid-round
- **Don't** use continuous GPS streaming — use on-demand `getCurrentPosition()` at pin-tap time
- **Don't** use `context.push()` for main screen transitions — creates invalid back-stacks
- **Don't** start GPS/map loading before the score buttons appear on screen — score entry speed is paramount
- **Don't** add any feature not in REQUIREMENTS.md without a requirements update
- **Don't** use always-on voice listening — tap-to-speak only (battery + outdoor false positives)
- **Don't** display WHS differential without all 18 holes recorded (or clearly label it "Indicative")
- **Don't** build any backend, auth system, or cloud service — local-only is a core constraint

## Before Any GPS or Voice Feature Work

Add to `ios/Runner/Info.plist` (all three — do it in one pass):
- `NSLocationWhenInUseUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`

Add to `android/app/src/main/AndroidManifest.xml`:
- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`

## Before Any Distribution (iOS or Android)

Generate a release keystore and update `android/app/build.gradle`. The current scaffold uses debug signing for release — Play Console rejects this and it blocks Wear OS Data Layer pairing. See `.planning/research/PITFALLS.md` — Pitfall 24.

## Planning Artifacts

| File | Purpose |
|------|---------|
| `.planning/PROJECT.md` | Vision, requirements, decisions |
| `.planning/ROADMAP.md` | 5-phase plan with success criteria |
| `.planning/REQUIREMENTS.md` | 33 v1 requirements with REQ-IDs |
| `.planning/STATE.md` | Current phase and progress |
| `.planning/research/` | Stack, features, architecture, pitfalls, summary |
| `.planning/codebase/` | Stack, architecture, structure, conventions, concerns |
| `.planning/config.json` | GSD workflow settings |
