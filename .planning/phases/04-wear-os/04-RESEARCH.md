# Phase 4: Wear OS Companion — Research

**Researched:** 2026-05-20
**Domain:** Flutter / Wear OS companion app — Data Layer messaging, offline queuing, circular UI
**Confidence:** MEDIUM (core architecture verified via official Android docs and pub.dev; some implementation details from community sources)

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| WEAR-01 | Wear OS companion displays current hole number, par, and score buttons (EAGLE/BIRDIE/PAR/BOGEY/DOUBLE/PICKUP) on the watch | WatchShape + AmbientMode from wear_plus; circular 3×2 grid with 64dp minimum tap targets |
| WEAR-02 | Score entry on the watch syncs the outcome to the phone's active round (Drift write on phone) | DataClient putDataItem path=/brdy/score; phone-side DataLayerListenerService writes to Drift |
| WEAR-03 | Watch handles "phone not connected" state gracefully (queues locally, syncs on reconnect; shows connection status indicator) | DataClient automatic offline buffering + urgent sync on reconnect; SharedPreferences queue on watch for belt-and-suspenders |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

- **Package name:** `com.brdy.brdy01` — watch app MUST use the same `applicationId`
- **State management:** Riverpod 2.x with `@riverpod` — phone side only; watch app is standalone Flutter with no Riverpod dependency
- **Persistence:** Drift is the authoritative store on the **phone**. Watch queues locally in SharedPreferences only as a temporary offline buffer
- **minSdk:** Phone is currently `minSdk = 24`. Watch must set `minSdk = 30` (Wear OS 3 minimum recommended for Galaxy Watch 4 target)
- **Flutter version:** 3.24.5 / Dart 3.5.4 — watch app must target the same SDK constraints
- **Signing:** Phone currently uses debug keystore. Data Layer pairing requires both apps to share the same signing key. Release keystore MUST be configured before Wear OS work begins (Pitfall 13 from existing research)
- **Design system:** Brutalist monospace, accent `#E8520A`, minimum 64×80dp tap targets for score buttons
- **No backend / no cloud:** Local-only. Watch-to-phone is the only sync path; no server relay
- **Scope:** Score buttons and hole/par display only. No voice, no GPS, no putts/fairway/GIR on watch (explicitly out of scope in REQUIREMENTS.md)
- **Don't add features not in REQUIREMENTS.md** — no stats, no round review, no history on watch

---

## Summary

Flutter Wear OS development uses a **separate Flutter project** for the watch app (not an embedded module), configured with the same `applicationId` (`com.brdy.brdy01`) and the same release signing key. The watch app is a standalone Flutter app compiled to a Wear OS APK — from Flutter's perspective it is just another Android app with specific manifest metadata and minSdk constraints.

`wear_plus` (already in pubspec) provides only two things: `WatchShape` (round vs square detection) and `AmbientMode` (ambient/active mode switching). It has **no messaging channel**. Phone-watch communication requires the Android **Wearable Data Layer API** (`MessageClient` for fire-and-forget, `DataClient` for persistent/offline-capable sync), accessed via a Kotlin `MethodChannel` bridge in `MainActivity.kt` on both apps.

For WEAR-03 offline queuing, `DataClient.putDataItem()` is the right primitive: it buffers data locally when the phone is not reachable and syncs automatically on reconnect. `MessageClient.sendMessage()` is best-effort with no retry — not suitable for offline queuing without hand-rolled retry logic. The watch should use `DataClient` for score submissions.

The Wear OS emulator is sufficient for UI development and basic connectivity testing against a phone emulator, but it cannot reproduce Bluetooth connection instability or battery-dependent ambient mode transitions. No physical watch is available, so the emulator is the only test path.

**Primary recommendation:** Build the watch app as a separate `flutter create` project in `watch/` under the monorepo root. Use `DataClient.putDataItem()` (urgent, via MethodChannel) on the watch to push scores, and a `WearableListenerService` on the phone to receive them and write to Drift.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Display hole number and par | Watch (Flutter UI) | Phone (pushes state via DataClient) | Watch renders; phone is source of truth for which hole is active |
| Score button grid (6 buttons) | Watch (Flutter UI) | — | Pure watch-side UI; no phone involvement at render time |
| Score submission (outcome tap) | Watch (DataClient send) | Phone (DataLayerListenerService receive + Drift write) | Watch initiates; phone persists. Write-through to Drift on phone is mandatory (CLAUDE.md) |
| Offline score queue | Watch (DataClient offline buffer) | — | DataClient buffers automatically; no custom queue needed for happy path |
| Connection status indicator | Watch (CapabilityClient query) | — | Watch polls/subscribes to capability to show connected/disconnected chip |
| Hole state push (hole + par) | Phone (DataClient put) | Watch (OnDataChangedListener) | Phone owns round state; pushes on hole advance. Watch receives and renders |
| Drift write on score receipt | Phone (WearableListenerService) | — | All Drift writes happen on phone per architecture rules |

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `wear_plus` | `^1.2.4` (already in phone pubspec) | `WatchShape` + `AmbientMode` widgets for watch app | Only actively maintained Flutter wear widget package [VERIFIED: pub.dev/packages/wear_plus] |
| Android Data Layer API | Built into `com.google.android.gms:play-services-wearable` | MessageClient, DataClient, CapabilityClient | Official Google Wear OS IPC mechanism [VERIFIED: developer.android.com/training/wearables/data] |
| `shared_preferences` | `^2.3.x` | Watch-side offline queue backup and last-known hole state | Already standard Flutter package; belt-and-suspenders if DataClient buffer is flushed [ASSUMED — verify version on pub.dev] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `wearable_rotary` | `^2.0.4` | Rotary crown/bezel input on Galaxy Watch 4/5 | Only if score selection via rotary input is added; NOT needed for tap-only buttons [VERIFIED: pub.dev/packages/wearable_rotary] |
| `connectivity_plus` | Already in phone pubspec | Already present on phone for connection detection | Not needed on watch — use CapabilityClient instead |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `DataClient` (offline-capable) | `MessageClient` (fire-and-forget) | MessageClient is simpler but requires active connection; drops silently when phone is in bag. DataClient buffers offline — required for WEAR-03 |
| Separate Flutter project | Flutter module (`flutter create --template module`) | Module approach shares Gradle build with phone but adds complexity. Separate project is simpler for a small isolated watch app and easier to `flutter run` independently |
| Custom MethodChannel bridge | `flutter_wear_os_connectivity` package | `flutter_wear_os_connectivity` v1.0.0 published 3 years ago, 197 downloads, appears unmaintained [VERIFIED: pub.dev]. Custom MethodChannel adds ~100 lines of Kotlin but avoids an abandoned dependency |

**Installation (watch app pubspec.yaml):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  wear_plus: ^1.2.4
  shared_preferences: ^2.3.0
```

**Phone app — no new Dart packages needed.** The phone adds a `WearableListenerService` in Kotlin and a MethodChannel in `MainActivity.kt` for pushing hole state. The `play-services-wearable` Gradle dependency is added to `android/app/build.gradle`.

---

## Package Legitimacy Audit

> slopcheck was run but reported SLOP for all packages because it targets PyPI, not pub.dev. These are Dart packages — slopcheck cannot assess them. Manual verification via pub.dev was performed instead.

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| `wear_plus` | pub.dev | ~2 yrs (v1.2.4, 6 mo ago) | Low (17 likes) | github.com/Rexios80/wear_plus | N/A (PyPI tool) | Approved — verified publisher rexios.dev, actively maintained [VERIFIED: pub.dev/packages/wear_plus] |
| `flutter_wear_os_connectivity` | pub.dev | 3 yrs, no updates | 197 downloads | github.com/ssttonn/flutter_wear_os_connectivity | N/A | REMOVED — unmaintained, 197 lifetime downloads, no updates in 3 years [VERIFIED: pub.dev/packages/flutter_wear_os_connectivity] |
| `wearable_rotary` | pub.dev | Active, v2.0.4 | 21 likes | tizen.org (verified publisher) | N/A | Approved but optional — only if rotary input added [VERIFIED: pub.dev/packages/wearable_rotary] |

**Packages removed:** `flutter_wear_os_connectivity` — unmaintained, low adoption. Replace with custom MethodChannel bridge (~100 lines Kotlin).

*slopcheck is a Python/PyPI tool and cannot assess Dart pub.dev packages. All packages above were manually verified on pub.dev.*

---

## Architecture Patterns

### System Architecture Diagram

```
PHONE APP (brdy01)                        WATCH APP (brdy01_wear)
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│  ShotCaptureScreen              │       │  WatchScoreScreen               │
│  (activeHoleIndexProvider)      │       │  (StatefulWidget)               │
│         │                       │       │         │                       │
│         ▼ hole advances         │       │         ▼ button tap            │
│  WearBridge (Dart)              │       │  WearBridge (Dart)              │
│  MethodChannel                  │       │  MethodChannel                  │
│  'com.brdy.brdy01/wear'         │       │  'com.brdy.brdy01/wear'         │
│         │                       │       │         │                       │
│         ▼                       │       │         ▼                       │
│  MainActivity.kt                │       │  MainActivity.kt (watch)        │
│  DataClient.putDataItem()       │       │  DataClient.putDataItem()       │
│  path: /brdy/hole               │       │  path: /brdy/score              │
│  {hole, par, roundId}   ────────┼──────▶│  OFFLINE: buffered until        │
│                                 │       │  phone reconnects               │
│  WearableListenerService ◀──────┼───────│                                 │
│  onDataChanged()                │       │  CapabilityClient               │
│  path: /brdy/score              │       │  detects /brdy/scoring-app      │
│         │                       │       │  → shows connected indicator    │
│         ▼                       │       └─────────────────────────────────┘
│  HoleScoreNotifier              │
│  .recordOutcome(outcome, par)   │
│         │                       │
│         ▼                       │
│  Drift (SQLite)                 │
│  write-through                  │
└─────────────────────────────────┘

Data Layer (Bluetooth / Wi-Fi — managed by Android OS)
┌──────────────────────────────────────────────────────┐
│  DataItem /brdy/hole  →  phone pushes on hole advance │
│  DataItem /brdy/score ←  watch pushes on button tap  │
│  DataItem /brdy/status ← watch polls for connection  │
│  Offline: DataClient buffers, syncs on reconnect     │
└──────────────────────────────────────────────────────┘
```

### Recommended Project Structure

```
brdy01/                        # Phone app (existing)
├── android/
│   └── app/
│       ├── build.gradle        # + play-services-wearable dependency
│       └── src/main/
│           ├── AndroidManifest.xml  # + WearableListenerService registration
│           └── kotlin/com/brdy/brdy01/
│               ├── MainActivity.kt      # + MethodChannel for hole push
│               └── WearDataService.kt   # WearableListenerService for score receive
└── lib/
    └── features/
        └── wear/
            ├── wear_bridge.dart        # Dart MethodChannel wrapper
            └── wear_sync_service.dart  # Called by ShotCaptureScreen on hole advance

watch/                          # NEW: Separate Flutter project
├── android/
│   └── app/
│       ├── build.gradle        # applicationId = com.brdy.brdy01, minSdk=30
│       └── src/main/
│           ├── AndroidManifest.xml  # wear metadata, WearableListenerService
│           └── kotlin/com/brdy/brdy01/
│               ├── MainActivity.kt      # MethodChannel, sends score DataItem
│               └── WearDataService.kt   # Receives /brdy/hole DataItem from phone
└── lib/
    ├── main.dart               # WatchShape + AmbientMode root
    ├── score_screen.dart       # 6-button grid + hole/par header
    ├── wear_bridge.dart        # MethodChannel: sendScore, getConnectionStatus
    └── models/
        └── watch_state.dart    # {holeNumber, par, isConnected, lastOutcome}
```

### Pattern 1: Watch App Root — WatchShape + AmbientMode

**What:** Wrap the watch app root in `WatchShape` then `AmbientMode`. Show a dimmed fallback in ambient mode (OLED battery); show the full score screen in active mode.

**When to use:** Always — required for Wear OS ambient mode compliance and circular screen handling.

**Example:**
```dart
// Source: pub.dev/packages/wear_plus README
import 'package:wear_plus/wear_plus.dart';

class WatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            if (mode == WearMode.ambient) {
              return const AmbientScreen(); // Black bg, white text only
            }
            return const ScoreScreen();
          },
        );
      },
    );
  }
}
```

### Pattern 2: DataClient Score Push (Watch → Phone)

**What:** Watch calls `DataClient.putDataItem()` via MethodChannel when a score button is tapped. DataClient buffers offline and syncs urgently when phone reconnects.

**When to use:** Every score button tap. Use `setUrgent()` to force immediate sync when connected.

**Example (Kotlin, watch MainActivity.kt):**
```kotlin
// Source: developer.android.com/training/wearables/data/data-items
private fun sendScore(outcome: String, holeNumber: Int, roundId: Int) {
    val putDataReq = PutDataMapRequest.create("/brdy/score").run {
        dataMap.putString("outcome", outcome)
        dataMap.putInt("holeNumber", holeNumber)
        dataMap.putInt("roundId", roundId)
        dataMap.putLong("timestamp", System.currentTimeMillis())
        setUrgent()
        asPutDataRequest()
    }
    Wearable.getDataClient(this).putDataItem(putDataReq)
        .addOnSuccessListener { Log.d(TAG, "Score queued: $outcome hole $holeNumber") }
        .addOnFailureListener { Log.e(TAG, "Score queue failed", it) }
}
```

**Example (Dart, watch wear_bridge.dart):**
```dart
// Source: flutter.dev/docs/development/platform-integration/platform-channels
static const _channel = MethodChannel('com.brdy.brdy01/wear');

Future<void> sendScore({
  required String outcome,
  required int holeNumber,
  required int roundId,
}) async {
  await _channel.invokeMethod('sendScore', {
    'outcome': outcome,
    'holeNumber': holeNumber,
    'roundId': roundId,
  });
}
```

### Pattern 3: WearableListenerService (Phone — receives score)

**What:** A `WearableListenerService` on the phone processes `/brdy/score` DataItems and writes to Drift via the HoleScoreNotifier equivalent. Runs as an Android Service — does not require the phone app to be in the foreground.

**When to use:** Mandatory for receiving Data Layer events when the phone app is backgrounded (which it will be when the golfer is using the watch).

**Example (Kotlin, phone WearDataService.kt):**
```kotlin
// Source: developer.android.com/training/wearables/data/events
class WearDataService : WearableListenerService() {
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        dataEvents.forEach { event ->
            if (event.type == DataEvent.TYPE_CHANGED) {
                val item = event.dataItem
                when (item.uri.path) {
                    "/brdy/score" -> {
                        val data = DataMapItem.fromDataItem(item).dataMap
                        val outcome = data.getString("outcome") ?: return@forEach
                        val holeNumber = data.getInt("holeNumber")
                        val roundId = data.getInt("roundId")
                        // Post to main thread for Drift write
                        Handler(Looper.getMainLooper()).post {
                            // Notify Flutter via EventChannel or broadcast
                            broadcastScoreReceived(outcome, holeNumber, roundId)
                        }
                    }
                }
            }
        }
    }
}
```

**AndroidManifest.xml (phone — register the service):**
```xml
<service
    android:name=".WearDataService"
    android:exported="true">
    <intent-filter>
        <action android:name="com.google.android.gms.wearable.DATA_CHANGED" />
        <data android:scheme="wear" android:host="*" android:pathPrefix="/brdy" />
    </intent-filter>
</service>
```

### Pattern 4: Connection Status Detection (Watch)

**What:** Query `CapabilityClient` on the watch to detect whether the phone (advertising capability `brdy_scoring`) is reachable. Display a status chip on the score screen.

**When to use:** On watch app start and whenever connectivity changes.

**Example (Kotlin, watch MainActivity.kt):**
```kotlin
// Source: developer.android.com/training/wearables/data/client-types
private fun checkPhoneConnection() {
    Wearable.getCapabilityClient(this)
        .getCapability("brdy_scoring", CapabilityClient.FILTER_REACHABLE)
        .addOnSuccessListener { capabilityInfo ->
            val connected = capabilityInfo.nodes.isNotEmpty()
            channel.invokeMethod("connectionStatusChanged", connected)
        }
}
```

**Phone res/values/wear.xml** (advertise the capability):
```xml
<resources>
    <string-capability name="brdy_scoring"/>
</resources>
```

### Anti-Patterns to Avoid

- **Using `MessageClient` for score submission:** MessageClient drops silently when phone is unreachable. It cannot buffer offline. Score loss is unacceptable — use DataClient.
- **Writing Drift directly from `WearableListenerService`:** The service runs on a background thread. Use an EventChannel or LocalBroadcastManager to hand off to the Flutter engine, which then calls the existing `HoleScoreNotifier.recordOutcome()` path.
- **Putting round business logic in the watch app:** Watch is a dumb terminal. It knows hole number, par, and the 6 outcomes. All scoring logic (putts, fairway, GIR, WHS differential) stays on the phone.
- **Sharing Drift between phone and watch:** Drift is phone-only. Watch has no SQLite. The only watch-side persistence is SharedPreferences for last-known hole state and a small pending-scores queue.
- **Same project as phone app:** Do not add Wear OS targets to the existing Flutter project. A separate project avoids contaminating the phone build with watch-only dependencies and Gradle complexity.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Circular screen clipping | Custom clip widget | `wear_plus` WatchShape + standard Flutter padding 20dp all sides | WatchShape is the standard; hand-rolled clip is fragile across device variants |
| Offline score queue | Custom retry loop with Timer | `DataClient.putDataItem()` with `setUrgent()` | DataClient buffers and syncs automatically — Google manages the retry |
| Phone/watch connectivity status | BLE scan or socket ping | `CapabilityClient.getCapability()` | CapabilityClient is the official Wear OS API; direct BLE scan requires extra permissions |
| Cross-process IPC between WearableListenerService and Flutter | Manual socket or file | `EventChannel` (Dart) + `EventSink` (Kotlin) | Standard Flutter platform channel pattern for streaming events into Dart |
| Watch UI state persistence | Custom SQLite on watch | `shared_preferences` on watch (last hole/par only) | SharedPreferences is sufficient for a few integers; SQLite is overkill for a one-screen watch app |

**Key insight:** The Data Layer API handles everything that would otherwise be a custom sync protocol — buffering, deduplication (DataItems are keyed by path), and reconnection. The implementation surface is actually small: ~100 lines of Kotlin per side plus ~50 lines of Dart bridging.

---

## Wear OS UI Constraints

### Screen Dimensions

| Watch | Size | Resolution | Density | Usable diameter |
|-------|------|------------|---------|-----------------|
| Galaxy Watch 4 (40mm) | 40mm | 396×396 px | 330 dpi | ~280dp safe zone |
| Galaxy Watch 4 (44mm) | 44mm | 450×450 px | 330 dpi | ~320dp safe zone |
| Galaxy Watch 5 (40mm) | 40mm | 396×396 px | 330 dpi | ~280dp safe zone |
| Galaxy Watch 5 (44mm) | 44mm | 450×450 px | 330 dpi | ~320dp safe zone |

[VERIFIED: screensizes.net/watches/samsung-galaxy-watch4]

### Circular Clip Safe Zone

The watch screen is physically circular but the Flutter render surface is square. Content at the corners is clipped. The safe inscribed circle diameter is approximately 70% of the full screen width.

**For 396×396 at 330dpi → ~120dp screen → safe zone ≈ 84dp radius from center.**

In practice: wrap all content in `Padding(padding: EdgeInsets.all(20))` for the Galaxy Watch 4/5 form factor. This keeps the 6-button grid well inside the circular clip boundary.

### 6-Button Score Grid Layout

The 6 scores (EAGLE / BIRDIE / PAR / BOGEY / DOUBLE / PICKUP) should be arranged as a 3-column × 2-row grid. On a 396px screen at 330dpi:

- Screen width in dp: ~120dp
- Safe width after padding (20dp each side): ~80dp
- 3 buttons across 80dp → each button ~26dp wide
- CLAUDE.md requires 64×80dp minimum tap targets for score buttons on the phone

**The 64×80dp phone tap target is NOT achievable on a 120dp watch screen with 6 buttons.** This is a known constraint. Watch tap targets are typically 40–48dp minimum (Wear OS Material guidance [ASSUMED — Material for Wear OS guidelines not directly verified in this session]). On a circular 120dp screen, 6 buttons at 26dp is the realistic maximum — compensate with bold text and clear colour differentiation (the BRDY colour scheme translates well: eagle=gold, birdie=accent orange, etc.).

**Recommended layout — 3×2 grid with abbreviated labels:**
```
┌──────────────────────────────────────┐
│          HOLE 7   PAR 4              │  (header row, ~24dp height)
│  ┌────────┐┌────────┐┌────────┐      │
│  │ EAGLE  ││ BIRDIE ││  PAR   │      │  row 1 (~32dp height)
│  └────────┘└────────┘└────────┘      │
│  ┌────────┐┌────────┐┌────────┐      │
│  │ BOGEY  ││ DOUBLE ││ PICKUP │      │  row 2 (~32dp height)
│  └────────┘└────────┘└────────┘      │
│         ● connected                  │  (status row, ~14dp)
└──────────────────────────────────────┘
```

Font: SometypeMono at 9–10sp for button labels (monospace matches BRDY aesthetic and is readable at small sizes). Use bold for the hole/par header at 14sp.

### Ambient Mode Requirements

When in ambient mode (watch display dims to save OLED battery), show a minimal dark screen: hole number and par in white text on black. No animated elements. No color fills. This is mandatory for Wear OS certification. [CITED: pub.dev/packages/wear_plus]

---

## Common Pitfalls

### Pitfall 1: DataClient Path Must Be Unique Per Score Entry

**What goes wrong:** `DataClient.putDataItem()` uses the path as a key — writing to `/brdy/score` twice replaces the first item. If the golfer taps two buttons quickly, only the second score arrives on the phone.

**Why it happens:** DataItems are a key-value store, not a message queue. Same path = overwrite.

**How to avoid:** Include a unique timestamp or UUID in the path: `/brdy/score/{timestamp}`. The phone processes all paths matching `/brdy/score/*`.

**Warning signs:** Two rapid taps on the watch produce only one Drift write on the phone.

### Pitfall 2: Signing Key Mismatch Blocks Data Layer Pairing

**What goes wrong:** The Data Layer API only connects apps with the same package name AND the same signing certificate. Phone uses debug keystore; watch uses debug keystore from a different machine → different SHA-256 fingerprint → Data Layer refuses to pair.

**Why it happens:** Debug keystores are generated per-machine. CLAUDE.md already flags this (Pitfall 13 in research/PITFALLS.md).

**How to avoid:** Configure a shared release keystore before writing any Data Layer code. Both apps must be signed with the same key. Use the same `keystore.jks` for phone and watch builds.

**Warning signs:** `CapabilityClient.getCapability()` returns empty nodes even when watch and phone are paired in the Wear OS app.

### Pitfall 3: WearableListenerService Not in Manifest → Silent Drop

**What goes wrong:** DataItem changes fire but the phone app never receives them because `WearDataService` is not registered in `AndroidManifest.xml` with the correct intent filter.

**Why it happens:** Easy to omit during a `flutter create` watch project where the manifest is minimal.

**How to avoid:** Register the service with `<action android:name="com.google.android.gms.wearable.DATA_CHANGED" />` and the correct `pathPrefix`. Test by tapping a score button and checking Logcat for `WearDataService.onDataChanged` log lines.

**Warning signs:** No Logcat output from `WearDataService` after a score tap, even though DataClient reports success.

### Pitfall 4: play-services-wearable Version Conflict

**What goes wrong:** `play-services-wearable` has a version dependency on Google Play Services. If the Gradle version differs between phone and watch, or conflicts with another `play-services-*` dependency, the build fails with a cryptic version resolution error.

**Why it happens:** Multiple `play-services-*` libraries in the dependency tree; they must all resolve to the same version.

**How to avoid:** Explicitly pin `com.google.android.gms:play-services-wearable:18.1.0` in both `build.gradle` files [ASSUMED — verify current version on Maven]. Check that `compileSdk = 35` is consistent across both projects.

**Warning signs:** Gradle sync fails with `Duplicate class com.google.android.gms...` or version conflict errors.

### Pitfall 5: Watch App Debug Performance Is Misleading

**What goes wrong:** Flutter in debug mode on a Wear OS emulator is very slow — frame rates drop to 5–10fps. Developers mistake this for a real performance problem and over-engineer the UI.

**Why it happens:** Flutter debug mode includes extensive assertions, hot reload instrumentation, and the service protocol layer. Wear OS emulators are also emulating ARM on x86.

**How to avoid:** Always test UI performance in profile or release mode: `flutter run --release -d <wearDeviceId>`. Debug mode is for logic testing only.

**Warning signs:** Buttons feel laggy and animations stutter in debug. Test in release before making UI simplification decisions.

### Pitfall 6: DataClient Urgent Sync Only Works When Bluetooth Is Active

**What goes wrong:** `setUrgent()` ensures immediate sync when connected, but if the golfer's phone is in the bag with Bluetooth audio active and the watch is 10m away, the connection may be intermittent. Scores are buffered but arrive in bursts when reconnected.

**Why it happens:** Wear OS Bluetooth range is ~10m; golf shots mean walking away from the phone.

**How to avoid:** Design the phone UI to handle a burst of DataItem changes arriving at once (hole 4, 5, 6 scores all arrive simultaneously). The existing Drift write-through pattern handles this safely since each score has a `holeNumber` key. Idempotent upsert logic in `HoleScoreNotifier.recordOutcome()` already handles this correctly.

### Pitfall 7: `applicationId` Must Be Identical on Watch and Phone

**What goes wrong:** Data Layer routing is keyed on `applicationId` (package name). If the watch project is created with a different package name (e.g. `com.brdy.brdy01.wear`), Data Layer messages are silently rejected.

**Why it happens:** `flutter create watch` uses the directory name as the package name by default.

**How to avoid:** Set `applicationId = "com.brdy.brdy01"` in the watch `android/app/build.gradle` explicitly. The watch app is a separate APK but must share the phone's package identity.

---

## Code Examples

### Watch App main.dart (full structure)
```dart
// Pattern: WatchShape → AmbientMode → ScoreScreen
// Source: pub.dev/packages/wear_plus README
import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'score_screen.dart';

void main() => runApp(const BrdyWatchApp());

class BrdyWatchApp extends StatelessWidget {
  const BrdyWatchApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: WatchShape(
        builder: (context, shape, _) => AmbientMode(
          builder: (context, mode, _) => mode == WearMode.ambient
              ? const AmbientFace()
              : const ScoreScreen(),
        ),
      ),
    );
  }
}

class AmbientFace extends StatelessWidget {
  const AmbientFace({super.key});
  @override
  Widget build(BuildContext context) {
    // Ambient: black bg, white text only — OLED safe
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('BRDY', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
```

### Score Screen 3×2 Grid
```dart
// 6 outcomes arranged as 3 columns × 2 rows, constrained to circular safe zone
class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});
  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int _holeNumber = 1;
  int _par = 4;
  bool _connected = false;

  static const _outcomes = [
    ('EAGLE', Color(0xFFFFD700)),
    ('BIRDIE', Color(0xFFE8520A)),
    ('PAR',    Color(0xFFFFFFFF)),
    ('BOGEY',  Color(0xFFCCCCCC)),
    ('DOUBLE', Color(0xFFFF4444)),
    ('PICKUP', Color(0xFF888888)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),  // Circular safe zone
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            Text(
              'HOLE $_holeNumber  PAR $_par',
              style: const TextStyle(
                fontFamily: 'SometypeMono',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // 3×2 button grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
              children: _outcomes.map((entry) {
                final (label, color) = entry;
                return GestureDetector(
                  onTap: () => _onOutcomeTap(label),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      border: Border.all(color: color, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'SometypeMono',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            // Connection status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _connected ? Icons.circle : Icons.circle_outlined,
                  size: 8,
                  color: _connected ? const Color(0xFFE8520A) : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _connected ? 'CONNECTED' : 'OFFLINE',
                  style: const TextStyle(
                    fontFamily: 'SometypeMono',
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onOutcomeTap(String outcome) {
    // Convert display label to HoleOutcome wire format
    final wireOutcome = const {
      'EAGLE': 'eagle',
      'BIRDIE': 'birdie',
      'PAR': 'par',
      'BOGEY': 'bogey',
      'DOUBLE': 'doubleBogey',
      'PICKUP': 'pickup',
    }[outcome]!;
    WearBridge.sendScore(
      outcome: wireOutcome,
      holeNumber: _holeNumber,
      roundId: 0, // Received from phone via /brdy/hole DataItem
    );
  }
}
```

### Phone WearBridge — Push Hole State to Watch
```dart
// Called by ShotCaptureScreen when activeHoleIndexProvider changes
// Source: flutter.dev/docs/development/platform-integration/platform-channels
class WearSyncService {
  static const _channel = MethodChannel('com.brdy.brdy01/wear');

  static Future<void> pushHoleState({
    required int holeNumber,
    required int par,
    required int roundId,
  }) async {
    try {
      await _channel.invokeMethod('pushHoleState', {
        'holeNumber': holeNumber,
        'par': par,
        'roundId': roundId,
      });
    } on PlatformException catch (e) {
      // Non-fatal: watch not paired or not running. Log and continue.
      debugPrint('WearSync: pushHoleState failed: ${e.message}');
    }
  }
}
```

---

## Offline Queue Implementation

`DataClient.putDataItem()` provides automatic offline buffering — items written while the phone is unreachable are persisted on the watch and synced when the connection is re-established. This satisfies WEAR-03 without any custom queue logic.

**Belt-and-suspenders (optional):** Store the last-sent score in `SharedPreferences` on the watch so a UI "pending sync" badge can persist across watch app restarts. Clear it when the corresponding `/brdy/score` DataItem reports delivery (via the `putDataItem` Task completion callback).

**DataItem path uniqueness is critical (Pitfall 1):** Use `/brdy/score/{holeNumber}-{timestamp}` as the path to prevent rapid taps overwriting each other. The phone `WearableListenerService` matches on `/brdy/score/*`.

**Connection status for the UI:** Use `CapabilityClient.getCapability("brdy_scoring", FILTER_REACHABLE)` on the watch at startup and on resume. Subscribe to capability changes via `addListener` for real-time updates. Display a small indicator at the bottom of the score screen (orange dot = connected, grey circle = offline/queued).

---

## Build and Test Setup

### Watch App Build

```bash
# Create the watch project (one-time setup)
flutter create --org com.brdy --project-name brdy01 watch/

# Set applicationId in watch/android/app/build.gradle:
#   applicationId = "com.brdy.brdy01"
#   minSdk = 30
#   targetSdk = 34  (mandatory for new Wear OS apps from Aug 2025)

# Run on Wear OS emulator
flutter devices                          # Find Wear OS device ID
flutter run -d <wearDeviceId> watch/
```

### Emulator Setup (Android Studio)

1. Open **Device Manager** → **Create Virtual Device**
2. Select **Wear OS** category → choose **Wear OS Large Round** (closest to Galaxy Watch 4 44mm)
3. Select system image: **Wear OS 4 (API 33)** or **Wear OS 3 (API 30)** — both require x86_64
4. Use **Wear OS emulator pairing assistant** (Device Manager → pair icon) to connect the Wear emulator to a phone emulator or physical phone
5. Run `flutter run --release -d <wearId>` to test performance (not debug mode — see Pitfall 5)

### Known Emulator Limitations

| Limitation | Impact | Mitigation |
|-----------|--------|------------|
| Bluetooth connectivity not emulated | Cannot test real Bluetooth drop/reconnect | Use emulator virtual Wi-Fi pairing instead; test offline queue logic via ADB `adb -s <wearId> shell svc bluetooth disable` |
| Ambient mode transitions not automatic | Cannot test ambient → active transition timing | Manually trigger via extended controls panel |
| Debug mode performance is extremely slow | UI appears laggy | Always measure in `--release` mode |
| Galaxy Watch 4-specific Tizen quirks not reproduced | Minor — watch runs stock Wear OS 3/4 | Acceptable; core Data Layer behaviour is standard |
| `play-services-wearable` on emulator routes via virtual Wi-Fi | Different latency profile vs Bluetooth | Acceptable for functional testing |

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `wear` package (original, archived) | `wear_plus` (fork, actively maintained) | 2022 | `wear` is no longer maintained; use `wear_plus` exclusively |
| `flutter_wear_os_connectivity` for Data Layer | Custom MethodChannel + native Kotlin | 2022 (package abandoned) | Must write own Kotlin bridge; ~100 lines, well-documented |
| MessageClient for all messaging | DataClient for persistent items, MessageClient for ephemeral RPCs | Best practice since Wear OS 2 | MessageClient has no offline buffer; DataClient is required for offline queuing |
| Module embedding via Gradle `wearApp` | Separate Flutter project with same applicationId | Emerging practice 2023–2025 | Separate project is simpler to `flutter run` and debug; module embedding adds Gradle complexity without benefit for a small companion |

**Deprecated/outdated:**
- `wear` package (pub.dev): Archived, unmaintained since 2022. Use `wear_plus` instead.
- `flutter_wear_os_connectivity` (pub.dev): Last updated 3 years ago, 197 downloads. Do not use.
- `MessageClient.sendMessage()` as primary score delivery: No offline buffer. Use `DataClient.putDataItem()` with `setUrgent()`.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Watch app build | ✓ | 3.24.5 | — |
| Dart SDK | Watch app build | ✓ | 3.5.4 | — |
| Android Studio / AVD Manager | Wear OS emulator | Must verify | — | Manual `avdmanager` CLI |
| Wear OS emulator system image | WEAR-01/02/03 testing | Must install | API 33 or 30 | Physical watch (unavailable) |
| Physical Galaxy Watch 4 | Real Bluetooth testing | ✗ | — | Emulator (covers happy path, not BT edge cases) |
| Release keystore | Data Layer pairing | ✗ (debug only) | — | Cannot complete pairing without this — must create before Wear OS work |
| `play-services-wearable` | Data Layer API | Gradle dep (not yet added) | 18.1.0 | — |

**Missing dependencies with no fallback:**
- **Release keystore** — Data Layer pairing requires matching signing keys. Debug keystores from different machines have different fingerprints. Must create and configure a shared release keystore in `watch/android/app/build.gradle` and `android/app/build.gradle` before any end-to-end Data Layer testing.

**Missing dependencies with fallback:**
- Wear OS emulator system image — must download via Android Studio SDK Manager (no fallback except physical watch)

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `shared_preferences` latest version is `^2.3.x` | Standard Stack | Minor — verify on pub.dev before adding to watch pubspec |
| A2 | Wear OS Material tap target minimum is 40–48dp | UI Constraints | Low — if official guidance is different, button sizing changes but layout stays the same |
| A3 | `play-services-wearable:18.1.0` is the current stable version | Pitfall 4 | Moderate — wrong version causes Gradle build failures; verify on Maven Central before adding |
| A4 | `DataClient` buffers remain intact across watch app process kills | Offline Queue | High — if the OS clears pending DataItems on process kill, the belt-and-suspenders SharedPreferences queue becomes the primary offline path rather than optional |
| A5 | `targetSdk = 34` mandatory from Aug 2025 applies to new Wear OS app submissions | Build Setup | Low — already past Aug 2025; confirm on Android Developers Wear OS release notes before first Play Store submission |

---

## Open Questions (RESOLVED)

1. **Release keystore availability** — RESOLVED
   - No release keystore exists yet. Plan 04-01 Task 1 documents the `keytool` command and creates `android/key.properties.example`. The developer generates the keystore once before executing the phase. Stored outside the git repo.

2. **Round ID communication to watch** — RESOLVED
   - Phone pushes `roundId` inside the `/brdy/hole` DataItem on every hole advance and on screen init. Watch stores the last-seen `roundId` in SharedPreferences and includes it in every `/brdy/score` DataItem. On reconnect, `WearDataBridgeService` (phone) re-pushes current hole state. Plan 04-01 Task 3 and Plan 04-04 Task 1 implement this.

3. **Multi-score arrival ordering** — RESOLVED
   - Each score DataItem path includes a millisecond timestamp: `/brdy/score/{holeNumber}-{timestamp}`. Phone-side `WearDataBridgeService.onDataChanged()` tracks the highest timestamp per `holeNumber` and drops out-of-order arrivals. Plan 04-01 Task 3a implements this dedup window (2 s).

---

## Sources

### Primary (HIGH confidence)
- [developer.android.com/training/wearables/data/data-items](https://developer.android.com/training/wearables/data/data-items) — DataClient putDataItem, offline buffer behaviour, setUrgent
- [developer.android.com/training/wearables/data/client-types](https://developer.android.com/training/wearables/data/client-types#message-client) — MessageClient vs DataClient tradeoffs
- [developer.android.com/training/wearables/data/events](https://developer.android.com/training/wearables/data/events) — WearableListenerService, onDataChanged
- [developer.android.com/training/wearables/get-started/emulator](https://developer.android.com/training/wearables/get-started/emulator) — emulator setup, limitations
- [pub.dev/packages/wear_plus](https://pub.dev/packages/wear_plus) — WatchShape, AmbientMode API, version history
- [pub.dev/packages/wearable_rotary](https://pub.dev/packages/wearable_rotary) — rotary input, version, publisher
- [pub.dev/packages/flutter_wear_os_connectivity](https://pub.dev/packages/flutter_wear_os_connectivity) — confirmed abandoned (3 years, 197 downloads)
- [screensizes.net/watches/samsung-galaxy-watch4](https://screensizes.net/watches/samsung-galaxy-watch4) — Galaxy Watch 4 screen dimensions

### Secondary (MEDIUM confidence)
- [blog.sjain.dev/wear-os-flutter-2/](https://blog.sjain.dev/wear-os-flutter-2/) — AndroidManifest setup, circular UI padding, minSdk guidance
- [blog.sjain.dev/wear-os-flutter-3/](https://blog.sjain.dev/wear-os-flutter-3/) — MethodChannel implementation pattern
- [verygood.ventures/blog/building-wear-os-apps-with-flutter-a-very-good-guide/](https://verygood.ventures/blog/building-wear-os-apps-with-flutter-a-very-good-guide/) — separate project vs module architecture

### Tertiary (LOW confidence)
- Wear OS Material Design tap target minimums (40–48dp) — training knowledge, not verified against official Material for Wear OS guidelines in this session [ASSUMED]

---

## Metadata

**Confidence breakdown:**
- Standard stack (wear_plus, Data Layer): HIGH — verified on pub.dev and official Android docs
- Architecture (separate project, DataClient path): MEDIUM — verified via community sources + official docs, no first-hand build tested
- UI constraints (screen dimensions, safe zone): MEDIUM — dimensions from spec sheets; Flutter safe zone from community sources
- Pitfalls: HIGH for signing/manifest (confirmed by existing project research); MEDIUM for DataClient path uniqueness and performance
- Offline queue via DataClient: HIGH — explicitly documented in official Android docs

**Research date:** 2026-05-20
**Valid until:** 2026-08-20 (stable Wear OS APIs; wear_plus is pinned — check for updates if Flutter SDK is upgraded)
