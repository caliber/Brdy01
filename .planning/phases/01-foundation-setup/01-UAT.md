---
status: partial
phase: 01-foundation-setup
source: [01-01-SUMMARY.md, 01-02-SUMMARY.md, 01-03-SUMMARY.md, 01-04-SUMMARY.md, 01-05-SUMMARY.md]
started: 2026-05-17
updated: 2026-05-17
---

## Current Test

number: complete
name: Awaiting device verification
expected: |
  All 12 tests require a physical Android/iOS device and a real golfcourseapi.com API key.
  Device tests deferred until Android Studio is installed.
awaiting: device available

## Summary

12 tests defined. 0 pass (device required). 0 issues. 12 deferred.

All tests require:
- Physical Android or iOS device (Drift FFI incompatible with web/dart2js)
- Real golfcourseapi.com API key (`--dart-define=GOLF_API_KEY=<key>`)
- Android Studio (for Android emulator/device deployment)

Code-reviewed items confirmed clean:
- `flutter analyze --no-fatal-warnings` → No issues
- `flutter test` → 1 passing (BrdyApp smoke test)
- All 5 plan human-verify checkpoints approved via architecture review

## Tests

### 1. App boots to splash then Setup (no Setup flash)
expected: Cold launch shows BRDY.01 splash briefly, then Setup. No Setup flash before splash.
result: deferred
reason: Requires physical device

### 2. Handicap index persists across restarts (SETUP-01)
expected: Type 14.3 → kill → relaunch → field pre-populates with 14.3
result: deferred
reason: Requires physical device

### 3. Course search triggers after 400ms, not on first char (SETUP-02)
expected: 1 char → no spinner. 2 chars → spinner after ~400ms → results list.
result: deferred
reason: Requires device + API key

### 4. Course detail loads and CourseCard renders (SETUP-03)
expected: Tap result → CourseCard with accent border, orange course name, RATING/SLOPE, light haptic.
result: deferred
reason: Requires device + API key

### 5. Last-used course pre-populates on reopen (SETUP-04)
expected: Load course → kill → relaunch → CourseCard pre-populated from cache (airplane mode).
result: deferred
reason: Requires physical device

### 6. API key missing → full-screen error (FOUND-04)
expected: Empty GOLF_API_KEY → type 2+ chars → full-screen 'API KEY NOT CONFIGURED'.
result: deferred
reason: Requires device

### 7. START ROUND inserts Drift row + navigates (FOUND-01)
expected: Tap START ROUND → spinner → Shot Capture 'ROUND N' + 'active provider: N'.
result: deferred
reason: Requires device

### 8. Crash recovery → Shot Capture (FOUND-02 + FOUND-03)
expected: Force-kill from Shot Capture → cold relaunch → same round id, ZERO Setup frames.
result: deferred
reason: Requires device (CRITICAL test — most important to verify)

### 9. Back button from Shot Capture exits app (FOUND-03)
expected: Back press from Shot Capture → app exits. Setup never shown.
result: deferred
reason: Requires Android device

### 10. Missing rating banner + manual entry (SETUP-05)
expected: Null CR/Slope course → banner → ENTER MANUALLY → form → SAVE → banner gone.
result: deferred
reason: Requires device + API key

### 11. Tile pre-cache progress bar appears (FOUND-05)
expected: GPS-enabled course → 'DOWNLOADING MAP TILES… N%' appears within 2 seconds.
result: deferred
reason: Requires device + API key

### 12. START ROUND not blocked by tile download (D-10)
expected: Tile progress active → tap START ROUND → navigates immediately.
result: deferred
reason: Requires device
