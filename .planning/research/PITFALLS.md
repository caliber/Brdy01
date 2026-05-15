# Pitfalls Research

> Confidence: HIGH on infrastructure/platform issues (confirmed by codebase analysis); MEDIUM on runtime behaviour; LOW on third-party API specifics. Training data cutoff Aug 2025.

## GPS & Location (Battery, Permissions, Accuracy)

### Pitfall 1: Missing Android Permission Declarations — App Crashes or Returns No Location

**Confidence:** HIGH (confirmed in CONCERNS.md)

**What goes wrong:** `AndroidManifest.xml` does not declare GPS permissions. `geolocator` requires `ACCESS_FINE_LOCATION` for GPS precision — without it, the plugin returns `LocationPermission.denied` permanently. On Android 12+, the OS enforces a two-step prompt — foreground first, then background from Settings — requesting both in one call silently discards the background request.

**Warning signs:** `geolocator.checkPermission()` always returns `denied`; no location events fire; background location never granted on Android 12+.

**Prevention:**
- Add to `AndroidManifest.xml` before `<application>`: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- Handle `LocationPermission.deniedForever` by directing user to Settings

**Phase:** Shot Capture GPS implementation. Add permission declarations before writing a single GPS line.

---

### Pitfall 2: Missing iOS Info.plist Privacy Strings — App Crashes on First Launch

**Confidence:** HIGH (confirmed in CONCERNS.md)

**What goes wrong:** iOS throws a runtime exception the moment `geolocator` calls `requestPermission()` if `NSLocationWhenInUseUsageDescription` is absent. App Store review also rejects builds missing these strings.

**Prevention:** Add to `ios/Runner/Info.plist` in one pass:
- `NSLocationWhenInUseUsageDescription` — "BRDY uses your location to pin shot positions on the course map."
- `NSMicrophoneUsageDescription` — "BRDY uses the microphone to record score commands."
- `NSSpeechRecognitionUsageDescription` — "BRDY uses speech recognition to record your score by voice command."

Do NOT request `NSLocationAlwaysAndWhenInUseUsageDescription` — no legitimate need for background location.

**Phase:** First iOS physical device test. All three strings are a prerequisite — add together before any GPS or voice work.

---

### Pitfall 3: Continuous GPS Streaming Drains Battery Over a 4-Hour Round

**Confidence:** MEDIUM

**What goes wrong:** `LocationAccuracy.best` keeps the full GPS radio active. Over 4 hours this drains battery significantly. Continuous streaming also causes the position dot to jitter (±5–15m normal for consumer GPS), making placed shot pins appear to drift.

**Prevention:**
- Use on-demand `getCurrentPosition()` at pin-tap time, not a continuous stream
- Use `LocationAccuracy.high` (not `best`) — irrelevant difference at 150m but meaningful battery difference
- Warm GPS on round start with one silent background call
- Set a 10–15 second timeout with clear error state — never wait indefinitely

**Phase:** Shot Capture screen GPS implementation. On-demand vs streaming is an architecture decision, not retrofittable.

---

## Voice Recognition (Outdoor Reliability)

### Pitfall 4: Android Speech Recognition Requires Network on Most Devices

**Confidence:** MEDIUM

**What goes wrong:** On most Android devices, `speech_to_text` delegates to Google's cloud Speech Recognition. Golf courses frequently have poor cellular coverage. When network is absent, the recogniser fires `SpeechStatus.done` with an empty result — the golfer says "birdie" and nothing happens, no error, no feedback. iOS uses on-device `SFSpeechRecognizer` by default (iOS 13+), making it significantly more reliable offline.

**Prevention:**
- Show a clear "Voice unavailable" state when `speech_to_text.initialize()` fails or network is absent — not just a greyed-out mic button
- Outcome buttons must always be the primary path. Voice is a convenience layer — never the only path to score entry
- Test with airplane mode on a non-Pixel Android device before shipping voice

**Phase:** Shot Capture screen — voice implementation. Network fallback UX must be designed alongside the feature.

---

### Pitfall 5: Wind and Ambient Noise Cause False Positives or Silent Misses

**Confidence:** MEDIUM

**What goes wrong:** Wind, other players, and equipment sounds cause ambient noise. False positives (unintended score entries from background sounds) and silent misses (recogniser returns garbled token, no match, nothing happens) both occur.

**Prevention:**
- Require explicit activation: hold-to-speak mic button opening a 3–5 second window. Auto-cancel after the window. No always-on listening.
- After a token is recognised and matched, show a 1-second toast: "BOGEY recorded — Hole 7 [UNDO]" with a 4-second undo window
- Normalise recognised text before matching: lowercase, strip punctuation, trim whitespace. `"Birdie."` → `"birdie"`

**Phase:** Shot Capture screen — voice implementation. The confirm/undo toast is non-optional for outdoor reliability.

---

### Pitfall 6: iOS Requires Microphone AND Speech Recognition Permissions Separately

**Confidence:** HIGH

**What goes wrong:** A common mistake is adding only `NSMicrophoneUsageDescription` and omitting `NSSpeechRecognitionUsageDescription`. If either is absent or denied, `speech_to_text.initialize()` returns `false` with no user-facing explanation.

**Prevention:** Both strings in `Info.plist` (see Pitfall 2). Handle `initialize() == false` explicitly — disable mic button, show "Voice entry unavailable on this device."

**Phase:** Same Info.plist pass as GPS privacy strings.

---

## State Persistence (App Lifecycle)

### Pitfall 7: In-Memory Riverpod State Lost When OS Kills the App Mid-Round

**Confidence:** HIGH (canonical Flutter/Riverpod lifecycle problem)

**What goes wrong:** When the OS kills the app (low memory on Android, extended backgrounding on iOS), all provider state resets. When the golfer relaunches, the round is gone. This is the most damaging UX failure possible for a scoring app. The scaffold has Drift but zero implemented tables — if round state accumulates in a Riverpod Notifier without flushing to Drift after each mutation, this failure is guaranteed on any low-RAM Android device.

**Warning signs:** Round state survives switching apps and returning (false positive — hot restart preserves in-memory state). Failure only reproduces after 5+ minutes backgrounded on low-RAM Android or using "Force Stop."

**Prevention:**
- **Write-through persistence:** every score entry writes to Drift immediately, in the same operation as the provider update. Never batch writes.
- On app start, read the active round from Drift and rehydrate the Riverpod provider. Navigate to the correct hole if a round is in progress.
- Use Drift (SQLite, transactional, crash-safe) for round data. Never use Hive for round state — Hive is not transactional.

**Phase:** Drift schema and repository phase — before any UI state is built. Write-through is an architecture decision, not a retrofit.

---

### Pitfall 8: Cold Restart Drops Golfer on Setup Screen Mid-Round

**Confidence:** MEDIUM

**What goes wrong:** After an OS kill-and-relaunch, `go_router` starts at `/setup` regardless of where the golfer was. Even if round state is correctly rehydrated from Drift, the golfer lands on Setup — feels like data loss even when no data was lost.

**Prevention:**
- On app start, before `go_router` settles on the initial route, check Drift for an active incomplete round. If found, redirect to `/shot-capture/$roundId`.
- Implement this as a `redirect` callback in the `GoRouter` constructor — it fires on every navigation event including cold start.

**Phase:** Same phase as Drift round schema — navigation restoration and state rehydration are coupled.

---

## Drift Migrations

### Pitfall 9: Incrementing schemaVersion Without a Migration Crashes All Existing Installs

**Confidence:** HIGH (Drift's #1 reported migration mistake)

**What goes wrong:** When `schemaVersion` is bumped (e.g. 1 → 2) but no `MigrationStrategy.onUpgrade` handles the case, Drift throws `MigrationException` at startup for every user with a prior install. New installs work fine — making this invisible in development but catastrophic on update.

**Prevention:**
```dart
MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from < 2) await m.addColumn(rounds, rounds.weatherCondition);
    if (from < 3) await m.createTable(holeStats);
  },
)
```
- Never skip version numbers
- Write a migration test for every bump using Drift's `SchemaVerifier`
- Commit `drift_schemas/` with generated schema JSON for each version

**Phase:** Drift schema definition. Set up `MigrationStrategy` boilerplate and `drift_schemas/` from version 1 — do not wait until version 2.

---

### Pitfall 10: Changing Table Definition Without Bumping schemaVersion — Silent Data Corruption

**Confidence:** HIGH

**What goes wrong:** Adding a Dart column without incrementing `schemaVersion` means generated code expects the column but the on-disk database doesn't have it. SQLite will not auto-add columns. May return `null` silently (nullable columns) or throw `SqliteException: no such column` on writes (non-nullable).

**Prevention:** Team convention: any `Table` class change requires a schema version bump and migration in the same commit. Hard rule, not a guideline.

---

### Pitfall 11: Stale Generated Code After Schema Changes

**Confidence:** HIGH

**What goes wrong:** Editing a `Table` class without running `dart run build_runner build` leaves `.g.dart` files stale. The app compiles but runtime behaviour reflects the old schema. "I added the column but it's not working" — the DAO doesn't know about it yet.

**Prevention:**
- Run `dart run build_runner build --delete-conflicting-outputs` after every schema change
- Commit generated `*.g.dart` files to git
- Consider a `Makefile` target wrapping the command

**Phase:** Drift setup phase. Establish the workflow before any schema definition.

---

## Wear OS Integration Failures

### Pitfall 12: wear_plus Version Lags Flutter Updates; Message Delivery Is Best-Effort

**Confidence:** MEDIUM (confirmed thinness in CONCERNS.md)

**What goes wrong:**
1. `wear_plus` historically lags major Flutter version bumps by weeks to months — plugin may fail to compile after a Flutter upgrade
2. Data Layer message delivery is best-effort: scores entered on the watch while phone is in the bag may arrive out of order or be dropped silently
3. No reliable synchronous API to check watch connectivity before sending — sending to a disconnected watch silently discards on some firmware versions

**Prevention:**
- Treat watch score entry as additive — phone is always authoritative. If a watch score is lost, golfer uses phone buttons
- Use idempotent message handling: each message carries `hole_id` + `outcome`. Applying the same message twice is safe
- Show connection status in phone UI: "Watch connected" / "Watch not found"
- Pin `wear_plus` to a specific tested version. Upgrade deliberately
- Test on physical Wear OS hardware — emulator misrepresents Bluetooth connectivity

**Phase:** Dedicated Wear OS phase, implemented after core phone functionality is complete and stable. Wear OS is the highest-risk integration — implement it last.

---

### Pitfall 13: Signing Mismatch Breaks Wear OS Data Layer Pairing

**Confidence:** MEDIUM

**What goes wrong:** The Wearable Data Layer routes messages only between apps sharing the same package name and signing key. If phone uses debug keystore (current state per CONCERNS.md) and watch companion is signed differently, the Data Layer rejects connections between them.

**Prevention:** Release signing must be configured before Wear OS implementation begins. Use the same release keystore for both phone and watch companion from the start.

**Phase:** Release signing (Pitfall 24) must be resolved before Wear OS work begins.

---

## flutter_map Performance

### Pitfall 14: Map Tiles Never Cached — Grey Maps On-Course

**Confidence:** HIGH (confirmed in CONCERNS.md: `flutter_map_tile_caching` declared but never imported or initialised)

**What goes wrong:** `flutter_map` fetches OSM tiles from the network on every map load. On a golf course with poor connectivity, tiles fail to load — grey grid, golfer can place pins but cannot see the course layout. The scaffold has `flutter_map_tile_caching` in pubspec but it is a dead dependency — never used anywhere.

**Prevention:**
- Initialise `flutter_map_tile_caching` in `main()` before `runApp()`
- Pre-fetch tiles for the loaded course's bounding box at round setup (before driving to the course)
- Set a tile cache size limit (~200MB) and TTL (~30 days)
- OSM's tile usage policy requests caching — required to be a good citizen

**Phase:** Shot Capture / map overlay phase. Tile caching must be implemented alongside the map display.

---

### Pitfall 15: Accumulated GPS Markers Cause Rendering Jank on Low-End Android

**Confidence:** MEDIUM

**What goes wrong:** 70–100 shot pins across 18 holes are all rendered as `Marker` widgets on every frame. On low-end Android devices this causes frame drops and jank when panning or zooming.

**Prevention:**
- Only render markers for the current hole during active shot capture. Show all markers on the summary map in Round Review only
- Use simple icon markers, not complex widget trees per marker
- `distanceFilter: 3` on the GPS stream prevents MarkerLayer rebuilds from GPS jitter

**Phase:** Shot Capture map overlay phase. Define which markers to render per hole before building pin placement.

---

## Golf Course API Reliability

### Pitfall 16: Course Rating and Slope Missing or Zero — WHS Differential Breaks

**Confidence:** MEDIUM (data quality varies; NZ market specifically)

**What goes wrong:** If the API returns `null`, `0`, or empty for Course Rating or Slope, the WHS differential formula produces nonsense (division by zero for Slope=0, `NaN`/`Infinity` displayed). Especially likely for courses in smaller markets — given the developer's location (New Zealand), NZ Golf is R&A-affiliated but individual course submission to third-party APIs is inconsistent.

**Prevention:**
- Validate both fields on course load. If either is missing or zero: show a warning, allow manual entry of Rating and Slope, cache the manual values in Hive
- Guard the differential calculation: if either field is invalid, display "N/A" with an explanation. Never divide without checking `slope != 0`
- Always allow the round to proceed even without Rating/Slope — scoring works independently of differential

**Phase:** Course setup phase (API client implementation). Missing-data UX must be designed before the first integration test.

---

### Pitfall 17: Silent API Key Failure Returns 401 With No User Feedback

**Confidence:** HIGH (confirmed in CONCERNS.md)

**What goes wrong:** If `--dart-define=GOLF_API_KEY=<value>` is omitted at build time, the key defaults to empty string. All API calls return 401/403 silently. In a CI/CD pipeline that doesn't inject the secret, the released app ships non-functional.

**Prevention:**
- Add a startup assertion: `assert(golfApiKey.isNotEmpty, 'GOLF_API_KEY must be provided via --dart-define')` — throws in debug
- In release, check key at API client initialisation and surface a clear error state if absent
- Document the `--dart-define` requirement in the README

**Phase:** API client implementation phase. Add the guard before the first API call.

---

## On-Course UX Failures

### Pitfall 18: Slow UI Response Makes the App Unusable Between Shots

**Confidence:** HIGH

**What goes wrong:** A golfer has ~30–60 seconds walking to the next tee to record a score. If score entry takes more than 1–2 seconds — due to a blocking Drift write, synchronous GPS fix, or map tile load blocking the main thread — the golfer misses the window. On-course context switching means delayed entries get forgotten or mis-entered.

**Prevention:**
- All Drift writes must be async and must not block the UI. Use optimistic UI updates: update the provider immediately on tap, write to Drift asynchronously
- Load the map overlay and GPS after the scoring UI appears — never await them before showing the score buttons
- Target: tap → confirmed score visual in under 100ms

**Phase:** Shot Capture screen. Performance must be a design constraint from the start.

---

### Pitfall 19: Low Contrast and Small Targets — App Unreadable in Direct Sunlight

**Confidence:** HIGH

**What goes wrong:** Standard Material Design surfaces (white backgrounds, thin text, grey-on-grey) are nearly unreadable in direct sunlight. The PROJECT.md design system is well-suited — but only if implemented consistently. A single off-spec label breaks the whole outdoor experience.

**Prevention:**
- Minimum contrast ratio for all text: WCAG AA (4.5:1). For critical on-course info (hole number, score buttons): WCAG AAA (7:1)
- Score button tap targets: minimum 48×48dp; prefer 64×80dp
- Test the UI in direct outdoor sunlight on a physical device before shipping any phase

**Phase:** Design system implementation — before any screen UI. Establish the theme on physical hardware outdoors.

---

### Pitfall 20: No Undo After Score Entry — Wrong Score Requires Multi-Step Correction

**Confidence:** HIGH (consistent across golf app reviews)

**What goes wrong:** Golfer taps BOGEY when they meant PAR. Without undo, recovery requires navigating back to the previous hole — multiple taps while already walking. Confirmation dialogs are worse: mandatory extra tap on every score, universally panned in golf app reviews.

**Prevention:** "Commit immediately, undo briefly" pattern:
- Record the score immediately on tap (optimistic UI + instant Drift write)
- Show auto-dismissing toast: "BOGEY — Hole 7 [UNDO]" for 4 seconds
- UNDO reverts to previous state (store "previous score" in the Riverpod notifier)
- After 4 seconds, toast dismisses; golfer can still navigate back to correct

**Phase:** Shot Capture screen. The undo pattern affects the Riverpod state model — design it before implementing score entry.

---

## WHS Calculation Mistakes

### Pitfall 21: Pickup Score Applied Without Handicap Strokes — Differential Miscalculated

**Confidence:** HIGH (WHS rules precisely specified post-2020)

**What goes wrong:** WHS defines unfinished holes as **net double bogey**: `par + 2 + handicap strokes the player is entitled to on that hole`. The common mistake is treating a pickup as simply `par + 2` (gross double bogey) without applying handicap stroke allocation. For Course Handicap 18 on a par-4 hole, a pickup is 4+2+1=7, not 6.

This requires knowing each hole's **Stroke Index (SI)** — which must come from the course API. If golfcourseapi.com does not provide SI per hole, the formula must be approximated or the limitation disclosed.

**Prevention:**
```dart
// Post-2020 WHS Course Handicap formula (note: + courseRating - par term)
courseHandicap = round(handicapIndex × (slope / 113) + (courseRating − par))

// Pickup score per hole
pickupScore = holePar + 2 + floor(courseHandicap / 18)
            + (1 if holeSI <= courseHandicap % 18 else 0)
```
Write unit tests covering: all pars, pickup on SI 1, pickup on SI 18, all pickups, high and low handicaps.

**Phase:** Domain model phase. Define `calculateCourseHandicap()` and `calculateDifferential()` as domain functions with full unit test coverage before any UI is built.

---

### Pitfall 22: Course Handicap vs Handicap Index Confusion

**Confidence:** HIGH

**What goes wrong:** **Handicap Index** is the golfer's portable number (stored in Hive). **Course Handicap** is derived for a specific course. Many implementations conflate these — using Course Handicap in the differential formula where Handicap Index is required (over-adjusts), or using Handicap Index for stroke allocation where Course Handicap is required (under-adjusts).

**Prevention:** Define two distinct typed functions in the domain layer — `calculateCourseHandicap(handicapIndex, slope, courseRating, par)` and `calculateDifferential(adjustedGrossScore, courseRating, slope)`. Use named parameters or strong types to make the distinction explicit.

**Phase:** Domain model phase.

---

### Pitfall 23: Differential Displayed for Incomplete Rounds

**Confidence:** MEDIUM

**What goes wrong:** If the differential formula runs on partial data (golfer stops at hole 9 due to weather), the result is mathematically wrong — 9 holes of strokes against a full 18-hole Course Rating.

**Prevention:** Only display the differential when all 18 holes have a recorded outcome (score or pickup). When fewer than 18 are complete and golfer triggers "Finish Round," either block with an explanation or auto-fill remaining holes as pickups.

**Phase:** Round Review phase. Validate hole completion before computing the differential.

---

## Release & Distribution Blockers

### Pitfall 24: Debug Keystore in Release Builds — Blocks Play Console and TestFlight

**Confidence:** HIGH (confirmed in CONCERNS.md — two TODOs visible in build.gradle)

**What goes wrong:** `android/app/build.gradle` configures release builds with the debug keystore. Consequences:
- Google Play Console rejects debug-signed APKs/AABs immediately
- A debug-signed install cannot be updated by a properly signed release (signing key mismatch)
- Wear OS Data Layer requires matching signing keys — debug keys make this fragile in production
- Debug key lives on one developer's machine; if lost, updates to debug-signed installs are impossible

**Prevention (step-by-step):**
1. `keytool -genkey -v -keystore brdy01.keystore -alias brdy01 -keyalg RSA -keysize 2048 -validity 10000`
2. Store keystore **outside** the git repository — in a password manager or secure vault. Never commit the `.keystore` file
3. Store keystore password/alias/key-password in env vars or gitignored `key.properties`
4. Update `build.gradle` to reference the keystore via `key.properties`
5. Document keystore location and recovery procedure in a secure accessible location

**Phase:** Immediately — prerequisite gate for Wear OS (Pitfall 13) and any distribution attempt.

---

### Pitfall 25: No iOS Podfile — iOS Build Is Not Reproducible Across Machines

**Confidence:** HIGH (confirmed in CONCERNS.md)

**What goes wrong:** Without a committed `ios/Podfile`, running `pod install` on a different machine or at a different time may resolve different CocoaPod versions. `geolocator`, `speech_to_text`, and `wear_plus` all have native iOS layers. The first TestFlight build may differ from the development build.

**Prevention:**
- Run `flutter pub get` then `cd ios && pod install` on a clean clone
- Commit both `ios/Podfile` and `ios/Podfile.lock` to git
- Never run `pod update` without understanding the implications

**Phase:** Project setup / first iOS build. One-time task; must be done before any iOS-specific feature work.

---

## Phase-Specific Warnings Summary

| Phase Topic | Most Likely Pitfall | Mitigation |
|---|---|---|
| Project setup | Missing Podfile → unreproducible iOS build | Commit Podfile.lock before any iOS feature work |
| Release signing | Debug keystore blocks Play Console, TestFlight, Wear OS | Generate release keystore before first distribution attempt |
| Drift schema | No migration boilerplate at v1; stale generated code | Set up MigrationStrategy + drift_schemas/ + build_runner workflow from day one |
| Course API client | Empty API key silent failure; missing Rating/Slope | Guard key at initialisation; validate course data on load |
| GPS shot pins | Missing AndroidManifest + Info.plist permissions → crash | Add all permission strings before first GPS call |
| Voice commands | Android network dependency; iOS dual-permission; wind false positives | Design offline fallback and confirm-and-undo toast alongside the feature |
| Shot Capture screen | Blocking writes cause UI lag; no undo | Async writes, optimistic UI, 4-second undo toast |
| WHS differential | Wrong pickup formula; Course vs Index confusion | Unit test domain functions before any UI |
| Round Review | Differential shown for incomplete rounds | Validate all 18 holes recorded before computing |
| flutter_map | Tiles never cached → grey maps on-course | Initialise flutter_map_tile_caching at app startup |
| Wear OS | Signing mismatch; message loss; version lag | Release signing first; implement last |

## Gaps Requiring External Verification

1. **golfcourseapi.com Stroke Index (SI) per hole** — required for correct pickup calculation. Verify with a live API test before implementing pickup scoring.
2. **golfcourseapi.com rate limits** — not publicly documented in training data. Verify before implementing the search UI.
3. **flutter_map_tile_caching current initialisation API** — package API may have changed. Verify against current pub.dev docs before implementing.
4. **wear_plus version compatibility with current Flutter** — check pub.dev before beginning Wear OS implementation. Pin the tested version.
5. **Android offline speech recognition device matrix** — test with airplane mode on non-Pixel Android hardware before committing to voice as a first-class feature.
