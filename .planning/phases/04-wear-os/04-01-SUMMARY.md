---
phase: 04-wear-os
plan: 01
subsystem: wear-os-bridge
completed: 2026-05-20
duration_mins: ~60
tasks_completed: 6
tasks_total: 5
files_created: 7
files_modified: 4
tags: [android, wear-os, data-layer, kotlin, flutter-plugin, tdd]
dependency_graph:
  requires: []
  provides: [WEAR-01, WEAR-02, WEAR-03]
  affects: [04-02, 04-03, 04-04]
tech_stack:
  added:
    - com.google.android.gms:play-services-wearable:18.1.0
    - androidx.localbroadcastmanager:localbroadcastmanager:1.1.0
  patterns:
    - FlutterPlugin + MethodCallHandler + EventChannel.StreamHandler
    - DataClient.OnDataChangedListener (foreground)
    - WearableListenerService (background)
    - LocalBroadcastManager bridge between Service and Plugin
    - Conditional release keystore signing (debug fallback with Gradle warning)
key_files:
  created:
    - android/key.properties.example
    - android/app/src/main/res/values/wearable_capabilities.xml
    - android/app/src/main/kotlin/com/brdy/brdy01/WearDataBridgePlugin.kt
    - android/app/src/main/kotlin/com/brdy/brdy01/WearDataBridgeService.kt
    - lib/features/shot_capture/services/wear_bridge_service.dart
    - lib/features/shot_capture/services/wear_score_event.dart
    - test/features/shot_capture/services/wear_bridge_service_test.dart
  modified:
    - android/app/build.gradle
    - android/app/src/main/AndroidManifest.xml
    - android/app/src/main/kotlin/com/brdy/brdy01/MainActivity.kt
    - lib/features/shot_capture/shot_capture_screen.dart
decisions:
  - "DataClient only, no MessageClient — preserves offline queue behavior required by WEAR-03"
  - "LocalBroadcastManager bridge pattern: WearDataBridgeService broadcasts, WearDataBridgePlugin relays to EventChannel sink"
  - "pushHoleState returns bool (not void) — false on PUT_FAILED satisfies T-04-04 non-repudiation requirement"
  - "Conditional Groovy signing config: keystoreProperties loaded only if key.properties exists; Gradle warning printed when missing"
  - "FlutterEngineCache not used — LocalBroadcastManager bridge is sufficient for foreground relay"
---

# Phase 04 Plan 01: Phone-side Wear OS Bridge Summary

**One-liner:** DataClient-based phone-side Wear OS bridge — WearDataBridgePlugin (foreground), WearDataBridgeService (background), and Dart WearBridgeService wired into ShotCaptureScreen.

## What Was Built

### Task 1 — Keystore documentation and signing config

- Created `android/key.properties.example` with `keytool` generation command documented for developers.
- Updated `android/app/build.gradle` with conditional release signing: reads `key.properties` if present, falls back to debug signing with a `println` Gradle warning.
- Added `play-services-wearable:18.1.0` and `localbroadcastmanager:1.1.0` to app dependencies.
- `android/.gitignore` already excluded `key.properties` and `**/*.jks` — verified and left intact.

**Developer keystore setup steps (one-time):**
```
keytool -genkey -v -keystore ~/brdy-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias brdy
cp android/key.properties.example android/key.properties
# Edit key.properties with real values
```

### Task 2 — Wearable capability metadata

- Created `android/app/src/main/res/values/wearable_capabilities.xml` declaring `brdy_phone_peer`.
- Updated `AndroidManifest.xml`: added `google_play_services_version` meta-data and `android_wear_capabilities` resource reference.
- Did NOT add `com.google.android.wearable.beta.app` — that is watch-side only.

### Task 3 — WearDataBridgePlugin (Kotlin, foreground)

`WearDataBridgePlugin.kt` implements:
- `FlutterPlugin` + `MethodCallHandler` + `EventChannel.StreamHandler` + `DataClient.OnDataChangedListener`
- MethodChannel `com.brdy.brdy01/wear` with handlers: `sendHoleState`, `sendScoreAck`, `connectionStatus`
- EventChannel `com.brdy.brdy01/wear/scores` streaming score events to Dart
- `LocalBroadcastManager` receiver that forwards `com.brdy.brdy01.WEAR_SCORE` broadcasts from WearDataBridgeService to the EventChannel sink
- `MainActivity.kt` updated to call `flutterEngine.plugins.add(WearDataBridgePlugin())`

### Task 3a — WearDataBridgeService (background score reception)

`WearDataBridgeService.kt` extends `WearableListenerService`:
- Handles `/brdy/score/` DataItems when the Flutter app is backgrounded
- Forwards to foreground plugin via `LocalBroadcastManager` broadcast
- Registered in `AndroidManifest.xml` with `DATA_CHANGED` intent filter on `/brdy/score/` path

### Task 4 — Dart WearBridgeService (TDD)

`wear_score_event.dart`:
- `WearScoreEvent` class with `holeIndex`, `outcome`, `timestamp`
- `holeOutcomeFromString()` top-level function mapping all 6 `HoleOutcome` values, throws `ArgumentError` on unknown

`wear_bridge_service.dart`:
- `WearBridgeService` with injectable channels for testing
- `pushHoleState` returns `Future<bool>` — `false` on `PlatformException`, logged via `developer.log`
- `isPhoneConnectedToWatch` via `connectionStatus` MethodChannel call
- `scoreEvents` lazy broadcast stream, skips malformed events
- `wearBridgeServiceProvider` Riverpod `Provider`

`ShotCaptureScreen` wiring:
- `_pushCurrentHoleState()` helper reads course data for current hole
- Called via `WidgetsBinding.instance.addPostFrameCallback` in `initState`
- Called on every `activeHoleIndexProvider` change via `ref.listen`

## MethodChannel + EventChannel Contract

| Direction | Channel | Method / Event | Args |
|-----------|---------|---------------|------|
| Dart → Kotlin | `com.brdy.brdy01/wear` | `sendHoleState` | `{roundId: String, holeIndex: int, par: int, si: int?}` |
| Dart → Kotlin | `com.brdy.brdy01/wear` | `sendScoreAck` | `{holeIndex: int, outcome: String}` |
| Dart → Kotlin | `com.brdy.brdy01/wear` | `connectionStatus` | `{}` → `bool` |
| Kotlin → Dart | `com.brdy.brdy01/wear/scores` | event | `{holeIndex: int, outcome: String, timestamp: int}` |

Plan 04-02 (watch side) mirrors this contract exactly.

## TDD Gate Compliance

| Gate | Commit | Status |
|------|--------|--------|
| RED (failing tests) | `ffa3d2e` | Pass — compilation errors confirmed no implementation |
| GREEN (passing tests) | `688362e` | Pass — all 5 tests pass |

## Deviations from Plan

### Auto-fixed Issues

None.

### Notes

1. **Gradle dependency verification**: `./gradlew :app:dependencies` fails outside Flutter context due to JDK 8 constraint. Verified dependency presence via Gradle cache (`~/.gradle/caches/modules-2/files-2.1/com.google.android.gms/play-services-wearable`) and confirmed `flutter build apk --debug` succeeds — Flutter uses its embedded JDK which satisfies the JVM 11+ requirement.

2. **Test 2 scope**: EventChannel integration testing in the Flutter test framework requires a full binary messenger mock. Test 2 verifies the parsing logic (`WearScoreEvent` constructor + `holeOutcomeFromString`) and confirms `scoreEvents` returns a broadcast stream. Full EventChannel integration is covered by the on-device integration tests in Plan 04-04.

## Known Stubs

None — no stub data flows to UI rendering from this plan's changes.

## Threat Flags

All threats from `<threat_model>` addressed:

| Flag | Status |
|------|--------|
| T-04-01: DataItem tampering | Mitigated — same-key pairing enforced by Wearable Data Layer |
| T-04-02: Rapid putDataItem DOS | Mitigated — `ts` field in `/brdy/hole` path deduplicates writes |
| T-04-03: Keystore in git | Mitigated — `.gitignore` verified to exclude `key.properties` and `*.jks` |
| T-04-04: Silent PUT_FAILED | Mitigated — `pushHoleState` returns `false`, logs via `developer.log` |
| T-04-SC: Gradle dep legitimacy | Verified — `play-services-wearable` is official Google library |

## Commits

| Hash | Task | Description |
|------|------|-------------|
| `8896e19` | Task 1 | Keystore signing config, Wearable + LocalBroadcastManager deps |
| `8acf9f3` | Task 2 | Wearable capability metadata in manifest |
| `468aa04` | Task 3 | WearDataBridgePlugin Kotlin |
| `722d4a0` | Task 3a | WearDataBridgeService background reception |
| `ffa3d2e` | Task 4 RED | Failing tests for WearBridgeService |
| `688362e` | Task 4 GREEN | WearBridgeService Dart + ShotCaptureScreen wiring |

## Self-Check: PASSED

Files verified present:
- `android/key.properties.example` — FOUND
- `android/app/src/main/res/values/wearable_capabilities.xml` — FOUND
- `android/app/src/main/kotlin/com/brdy/brdy01/WearDataBridgePlugin.kt` — FOUND
- `android/app/src/main/kotlin/com/brdy/brdy01/WearDataBridgeService.kt` — FOUND
- `lib/features/shot_capture/services/wear_bridge_service.dart` — FOUND
- `lib/features/shot_capture/services/wear_score_event.dart` — FOUND
- `test/features/shot_capture/services/wear_bridge_service_test.dart` — FOUND

Build verification: `flutter build apk --debug` — PASS
Tests: `flutter test` — 5/5 PASS
MessageClient check: 0 matches — PASS
