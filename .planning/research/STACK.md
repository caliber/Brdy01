# Stack Research

> Note: Written from training knowledge (cutoff Aug 2025). Verify package versions against pub.dev before execution.

## Package Versions (current recommended)

| Package | Version in pubspec | Notes |
|---|---|---|
| `flutter_riverpod` | check pubspec | Use 2.x with code generation (`@riverpod` annotation). Avoid 1.x legacy providers. |
| `drift` | 2.x | Requires `drift_dev` and `build_runner` as dev deps. Use typed DAOs. |
| `hive_flutter` | 2.x | Use `Hive.initFlutter()`. TypeAdapters required for non-primitive types. |
| `go_router` | 13.x | Shell routes for persistent navigation shell. Named routes for deep linking. |
| `dio` | 5.x | Use `BaseOptions` for timeout config. |
| `retrofit` | 4.x | Requires `retrofit_generator` and `build_runner`. Annotation-driven. |
| `flutter_map` | 6.x | OSM tiles via `TileLayer`. Marker layers for shot pins. |
| `geolocator` | 12.x | `LocationSettings` replaces old `LocationAccuracy`. |
| `speech_to_text` | 6.x | `SpeechToText` singleton. Call `initialize()` once at app start. |
| `wear_plus` | 3.x | Separate `FlutterWear` widget for watch UI. Uses Wear OS message API. |

## Riverpod Patterns (2025 best practices)

**Use code generation** (`@riverpod` annotations). Avoids manual `ref.watch` type errors.

```dart
// Prefer this:
@riverpod
class ActiveRound extends _$ActiveRound {
  @override
  Round? build() => null;

  void startRound(Course course, int handicapIndex) { ... }
  void recordHoleOutcome(int hole, HoleOutcome outcome) { ... }
}

// Avoid: StateNotifier (legacy), ChangeNotifier, global mutable state
```

**Provider scoping for BRDY.01**:
- `courseSearchProvider` — searches API, returns `AsyncValue<List<Course>>`
- `selectedCourseProvider` — holds loaded course
- `activeRoundProvider` — the live round being played (18 hole states)
- `currentHoleIndexProvider` — which hole the user is on (0–17)
- `roundStatsProvider` — derived stats computed from activeRound (birdie count, total putts, etc.)

**Key rule**: Derive stats with `Provider` (not `StateProvider`) — they update automatically when `activeRound` changes.

## Drift Schema Design for Golf Data

```dart
// Three tables needed:

class Rounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get courseName => text()();
  RealColumn get courseRating => real()();
  IntColumn get courseSlope => integer()();
  IntColumn get handicapIndex => integer()();  // × 10 for decimal storage
  DateTimeColumn get startedAt => dateTime()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

class HoleScores extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  IntColumn get holeNumber => integer()();  // 1–18
  IntColumn get par => integer()();
  TextColumn get outcome => textEnum<HoleOutcome>()();  // BIRDIE, PAR, BOGEY, DOUBLE, PICKUP
  IntColumn get putts => integer().nullable()();
  BoolColumn get fairwayHit => boolean().nullable()();  // null = par 3
  BoolColumn get greenInRegulation => boolean().nullable()();
}

class ShotPins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get holeScoreId => integer().references(HoleScores, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get shotNumber => integer()();
}
```

**DAO pattern**: One `RoundDao` with `insertRound`, `upsertHoleScore`, `getActiveRound`, `insertShotPin`. Keep queries in DAOs, not providers.

## Retrofit + Dio Gotchas

**Critical**: `retrofit_generator` version must match `retrofit` version exactly. Mismatches cause silent code gen failures. Check changelog before updating either.

**Common mistakes**:
- Forgetting `part 'golf_api.g.dart';` in API interface file
- Not running `flutter pub run build_runner build --delete-conflicting-outputs` after changes
- Missing `@JsonSerializable()` on response DTOs
- Dio `connectTimeout` and `receiveTimeout` use `Duration` in Dio 5.x, not milliseconds int

**Recommended Dio setup for Golf Course API**:
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.golfcourseapi.com/v1/',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  headers: {'Authorization': 'Key $apiKey'},
));
```

**Error handling**: Wrap Retrofit calls with `DioException` catch. Golf Course API may return 404 for missing courses — handle gracefully in the repository, not in UI.

## flutter_map + geolocator (Outdoor GPS)

**flutter_map setup for shot pinning**:
```dart
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(holeLat, holeLng),
    initialZoom: 17,  // Good zoom for a single hole
    onTap: (tapPosition, latlng) => ref.read(...).addShotPin(latlng),
  ),
  children: [
    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
    MarkerLayer(markers: shotPins.map(...).toList()),
  ],
)
```

**Tile caching**: `flutter_map_tile_caching` is already in pubspec. Use it — OSM tiles without caching = blank map on course (no signal). Pre-cache hole tiles when course is loaded.

**geolocator battery + accuracy**:
- Use `LocationAccuracy.high` for shot pinning, `LocationAccuracy.low` for background position
- On Android: request `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` in manifest
- On iOS: add `NSLocationWhenInUseUsageDescription` to Info.plist — required or app crashes
- Stream position updates only when map is visible; cancel stream when navigating away
- `Geolocator.getPositionStream(locationSettings: LocationSettings(accuracy: high, distanceFilter: 5))`

**Permission flow**: Check `await Geolocator.checkPermission()` before requesting. Handle `LocationPermission.deniedForever` — direct to app settings, not re-request.

## speech_to_text (Outdoor Reliability)

**Known outdoor issues**:
- Wind noise causes high false-positive rate on "birdie" vs "bogey" (similar phonemes)
- iOS uses on-device recognition when offline; Android may require network on some devices
- `SpeechToText` needs `initialize()` called once; subsequent `listen()` calls are cheap

**Recommended pattern**:
```dart
// Fixed vocabulary confirmation — don't trust raw result
final validOutcomes = {'birdie', 'par', 'bogey', 'double', 'pickup'};
void onSpeechResult(SpeechRecognitionResult result) {
  final word = result.recognizedWords.toLowerCase().trim();
  if (validOutcomes.contains(word) && result.finalResult) {
    // Only act on final results, not interim
    recordOutcome(word);
  }
}
```

**UI pattern**: Hold-to-speak button (not always-on listening). Always-on listening drains battery and produces false positives. Show recognized word before confirming — gives user chance to correct.

**Confidence threshold**: Only accept results with `result.confidence > 0.75`. Below that, ask user to retry.

**Permissions**: Microphone permission required. `speech_to_text` handles the request but add `NSMicrophoneUsageDescription` to iOS Info.plist manually.

## wear_plus Integration (Flutter ↔ Wear OS)

**Architecture**: Phone app is the data master. Watch app is a thin client that sends score events to the phone.

**Communication pattern** (wear_plus 3.x):
```dart
// Phone: listen for messages from watch
Wearable.messageClient.messages.listen((message) {
  if (message.path == '/score') {
    final outcome = HoleOutcome.values.byName(String.fromCharCodes(message.data));
    ref.read(activeRoundProvider.notifier).recordHoleOutcome(currentHole, outcome);
  }
});

// Watch: send score button tap
await Wearable.messageClient.sendMessage(
  nodeId,          // peer phone node ID
  '/score',
  utf8.encode(outcome.name),
);
```

**Wear OS entry point**: Separate `main()` in `lib/main_wear.dart`. Use `WearApp` widget from `wear_plus`. Detect platform at startup.

**Watch UI constraints**:
- Round screens only (no rectangular layouts assumed)
- 5 buttons (BIRDIE/PAR/BOGEY/DOUBLE/PICKUP) need careful layout — use `GridView` or `WearButton`
- Current hole number must be prominent (large JetBrains Mono)
- No scroll — everything above the fold

**Known pitfall**: Node connectivity is not guaranteed. Watch must handle "phone not connected" gracefully — queue the score locally and sync when reconnected.

## Confidence Levels

| Area | Confidence | Notes |
|---|---|---|
| Riverpod code gen patterns | HIGH | Stable API in 2.x |
| Drift schema design | HIGH | Stable since 2.0 |
| Retrofit + Dio Dio 5.x | HIGH | Duration API change is well-documented |
| geolocator permissions | MEDIUM | Platform behavior changes frequently — verify against current geolocator changelog |
| speech_to_text outdoor | MEDIUM | Based on community reports; test on-device early |
| wear_plus 3.x API | MEDIUM | API surface has shifted between major versions — verify against current docs |
| flutter_map tile caching | MEDIUM | `flutter_map_tile_caching` integration pattern may have changed |
