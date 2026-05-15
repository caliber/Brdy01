# Architecture Research

> Confidence: HIGH for Riverpod 2.x, Drift 2.x, go_router, flutter_map (versions from pubspec.yaml); MEDIUM for wear_plus (API patterns inferred).

## Provider Graph (Riverpod providers and relationships)

### Design principle

Use `riverpod_generator` (`@riverpod` / `@Riverpod(keepAlive: true)`) throughout. Never hand-write `Provider(...)` boilerplate. All providers that depend on another receive it via `ref.watch()`.

### Provider taxonomy for the 3-screen flow

```
Infrastructure providers (keepAlive: true — live for the whole app)
├── appDatabaseProvider         — Drift AppDatabase singleton
├── hivePlayerPrefsProvider     — Hive Box<dynamic> 'player_prefs'
├── hiveCourseBoxProvider       — Hive Box<dynamic> 'course_cache'
├── dioProvider                 — configured Dio instance
└── golfCourseApiProvider       — Retrofit client (depends on dioProvider)

Repository providers (keepAlive: true)
├── roundRepositoryProvider     — RoundRepository impl (depends on appDatabaseProvider)
├── courseRepositoryProvider    — CourseRepository impl (depends on golfCourseApiProvider + hiveCourseBoxProvider)
└── playerPrefsRepositoryProvider — PlayerPrefsRepository impl (depends on hivePlayerPrefsProvider)

Setup screen providers (auto-dispose)
├── handicapIndexProvider       — StateProvider<double?> (persists to Hive on change)
├── courseSearchQueryProvider   — StateProvider<String>
├── courseSearchResultsProvider — FutureProvider<List<Course>> (depends on courseSearchQueryProvider + courseRepositoryProvider)
├── selectedCourseProvider      — StateProvider<Course?>
└── roundSetupNotifierProvider  — AsyncNotifier<void> — creates Round in Drift, navigates on success

Active round providers (keepAlive: true — must survive screen transitions)
├── activeRoundIdProvider       — StateProvider<int?> (set when round is created; null = no active round)
├── activeRoundProvider         — StreamProvider<Round?> (Drift stream on Round row)
├── activeHoleIndexProvider     — StateProvider<int> (0-based, 0–17; survives back-nav)
├── holeScoresProvider          — StreamProvider<List<HoleScore>> (all HoleScore rows for active round)
└── currentHoleScoreProvider    — Provider<HoleScore?> (derives from holeScoresProvider + activeHoleIndexProvider)

Shot Capture screen providers (auto-dispose)
├── shotCaptureNotifierProvider — AsyncNotifier — handles upsert of HoleScore row
├── gpsLocationProvider         — StreamProvider<Position?> (geolocator stream)
├── shotPinsProvider            — StreamProvider<List<ShotPin>> (Drift stream for current hole)
├── addShotPinNotifierProvider  — AsyncNotifier<void> — inserts ShotPin row
└── voiceCommandNotifierProvider — AsyncNotifier<String?> (speech_to_text; emits recognised token)

Round Review providers (auto-dispose)
├── roundSummaryProvider        — FutureProvider<RoundSummary> (computed from round + hole scores)
└── whsDifferentialProvider     — Provider<double?> (pure computation from roundSummaryProvider)
```

### Key relationships

```
appDatabaseProvider
  └── roundRepositoryProvider
        ├── activeRoundProvider (stream)
        ├── holeScoresProvider (stream)
        ├── shotPinsProvider (stream)
        ├── roundSetupNotifierProvider (write)
        └── shotCaptureNotifierProvider (write)

golfCourseApiProvider + hiveCourseBoxProvider
  └── courseRepositoryProvider
        ├── courseSearchResultsProvider (read-through cache)
        └── selectedCourseProvider (write on selection)

activeRoundIdProvider (set by roundSetupNotifierProvider)
  └── activeRoundProvider
        └── roundSummaryProvider
              └── whsDifferentialProvider
```

### Active round providers MUST be keepAlive

`activeRoundIdProvider`, `activeHoleIndexProvider`, and anything driving shot capture state must be `@Riverpod(keepAlive: true)`. Auto-dispose would reset hole index and round ID on screen navigation.

## Drift Schema Design

### Table definitions

```dart
class Rounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get courseId => text()();
  TextColumn get courseName => text()();
  RealColumn get courseRating => real()();
  IntColumn get slope => integer()();
  RealColumn get handicapIndex => real()();
  IntColumn get startedAt => integer()();         // Unix ms
  IntColumn get completedAt => integer().nullable()();
  // JSON-encoded List of ints: '[3,4,4,5,...]' (18 par values)
  TextColumn get holeParsJson => text()();
  // JSON-encoded List of ints: stroke index per hole (SI 1–18)
  TextColumn get holeStrokeIndexJson => text()();
}

class HoleScores extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  IntColumn get holeIndex => integer()();         // 0-based (0–17)
  IntColumn get outcome => integer().nullable()(); // HoleOutcome ordinal
  IntColumn get putts => integer().nullable()();
  BoolColumn get fairwayHit => boolean().nullable()(); // null on par 3
  BoolColumn get gir => boolean().nullable()();
  IntColumn get recordedAt => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [{roundId, holeIndex}];
}

class ShotPins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  IntColumn get holeIndex => integer()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  IntColumn get recordedAt => integer()();
}
```

### HoleOutcome enum

```dart
enum HoleOutcome {
  eagle,   // 0
  birdie,  // 1
  par,     // 2
  bogey,   // 3
  double_, // 4  (double bogey)
  pickup,  // 5
}
```

Store as `int` ordinal in Drift. Convert in DAO mapper. Note: eagle is included (see FEATURES.md open question — 6-button model recommended).

### DAO design

```dart
@DriftAccessor(tables: [Rounds, HoleScores, ShotPins])
class RoundsDao extends DatabaseAccessor<AppDatabase> {

  Future<int> createRound(RoundsCompanion companion) =>
      into(rounds).insert(companion);

  Stream<Round?> watchRound(int roundId) =>
      (select(rounds)..where((r) => r.id.equals(roundId)))
          .watchSingleOrNull();

  Future<void> upsertHoleScore(HoleScoresCompanion companion) =>
      into(holeScores).insertOnConflictUpdate(companion);

  Stream<List<HoleScore>> watchHoleScores(int roundId) =>
      (select(holeScores)..where((h) => h.roundId.equals(roundId))).watch();

  Future<void> insertPin(ShotPinsCompanion companion) =>
      into(shotPins).insert(companion);

  Stream<List<ShotPin>> watchPins(int roundId, int holeIndex) =>
      (select(shotPins)
            ..where((p) => p.roundId.equals(roundId) & p.holeIndex.equals(holeIndex)))
          .watch();

  Future<Round?> findIncompleteRound() =>
      (select(rounds)
        ..where((r) => r.completedAt.isNull())
        ..orderBy([(r) => OrderingTerm.desc(r.startedAt)])
        ..limit(1))
          .getSingleOrNull();
}
```

### Schema notes

- `holeParsJson` and `holeStrokeIndexJson` store 18 values as JSON strings on the Round row — avoids a fourth table for immutable-per-round data. Parse once in the domain mapper.
- `uniqueKeys` on `HoleScores` enables clean upsert via `insertOnConflictUpdate`.
- `completedAt` is null until the golfer finishes Round Review — the in-progress-round signal for crash recovery.
- No separate `courses` Drift table. `courseRating`, `slope` duplicated on Round row keeps it self-contained for WHS calculation.

## Active Round State Flow

### Full lifecycle

```
main() → ProviderScope starts
         activeRoundIdProvider = null  (keepAlive)
         activeHoleIndexProvider = 0   (keepAlive)
         appStartupProvider → checks for incomplete round in Drift

SetupScreen
  user picks course + enters HI
  → roundSetupNotifierProvider.createRound(...)
      → repo.createRound(...) → roundId (int)
      → activeRoundIdProvider.state = roundId
      → context.go('/shot-capture/$roundId')

ShotCaptureScreen
  → activeRoundProvider = watchRound(roundId) → Stream<Round?>
  → holeScoresProvider = watchHoleScores(roundId)
  → currentHoleScoreProvider = holeScores[activeHoleIndex]
  user taps BIRDIE
  → shotCaptureNotifierProvider.recordOutcome(HoleOutcome.birdie)
      → repo.upsertHoleScore(roundId, holeIndex, outcome: birdie)
      → Drift stream emits → holeScoresProvider rebuilds → UI rebuilds
  user taps NEXT HOLE (or auto-advance)
  → activeHoleIndexProvider.state++
  user taps FINISH ROUND
  → context.go('/round-review/$roundId')

RoundReviewScreen
  → roundSummaryProvider reads from already-live streams
  → whsDifferentialProvider computes synchronously
  user taps NEW ROUND
  → repo.markRoundComplete(roundId)  (sets completedAt)
  → activeRoundIdProvider.state = null
  → activeHoleIndexProvider.state = 0
  → context.go('/setup')
```

### Back navigation within Shot Capture (hole correction)

Hole navigation is internal state — not route-based back navigation. Shot Capture is a single route; hole navigation is a state change:

```dart
// Navigate to a previous hole to correct it
ref.read(activeHoleIndexProvider.notifier).state = targetHoleIndex;
// currentHoleScoreProvider re-derives; existing data already in holeScoresProvider stream
```

This avoids an 18-level back-stack entirely.

### Crash recovery in appStartupProvider

```dart
@Riverpod(keepAlive: true)
Future<void> appStartup(AppStartupRef ref) async {
  final db = ref.read(appDatabaseProvider);
  final inProgress = await db.roundsDao.findIncompleteRound();
  if (inProgress != null) {
    ref.read(activeRoundIdProvider.notifier).state = inProgress.id;
    final scores = await db.roundsDao.getHoleScores(inProgress.id);
    final lastScoredHole = scores
        .where((s) => s.outcome != null)
        .fold(-1, (max, s) => s.holeIndex > max ? s.holeIndex : max);
    ref.read(activeHoleIndexProvider.notifier).state =
        (lastScoredHole + 1).clamp(0, 17);
  }
}
```

The router redirect uses this to send the user back to Shot Capture on restart.

## go_router Route Structure

```dart
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/setup',
    redirect: (context, state) {
      final roundId = ref.read(activeRoundIdProvider);
      if (roundId != null && state.uri.path == '/setup') {
        return '/shot-capture/$roundId';
      }
      if (roundId == null &&
          (state.uri.path.startsWith('/shot-capture') ||
           state.uri.path.startsWith('/round-review'))) {
        return '/setup';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/setup', name: 'setup',
          builder: (_, __) => const SetupScreen()),
      GoRoute(
        path: '/shot-capture/:roundId',
        name: 'shotCapture',
        builder: (_, state) => ShotCaptureScreen(
          roundId: int.parse(state.pathParameters['roundId']!)),
      ),
      GoRoute(
        path: '/round-review/:roundId',
        name: 'roundReview',
        builder: (_, state) => RoundReviewScreen(
          roundId: int.parse(state.pathParameters['roundId']!)),
      ),
    ],
  );
}
```

### Navigation model

| User action | Mechanism |
|---|---|
| Start Round (Setup → Shot Capture) | `context.go('/shot-capture/$id')` — replaces stack |
| Finish Round (Shot Capture → Review) | `context.go('/round-review/$id')` — replaces stack |
| New Round (Review → Setup) | `context.go('/setup')` — replaces stack |
| Navigate to previous hole | `activeHoleIndexProvider.state = targetIndex` — no route change |
| Android back on Shot Capture | `PopScope` intercepted — "abandon round?" confirmation |

Use `context.go()` not `context.push()` everywhere — pushing creates a back-stack that allows invalid mid-round back-navigation.

## API Integration Pattern

### Layer stack

```
golfcourseapi.com HTTP
  → GolfCourseApiClient (Retrofit)          lib/data/remote/api/
  → CourseDto (json_serializable + Freezed)  lib/data/remote/dto/
  → CourseRepositoryImpl.toDomain()          lib/infrastructure/repositories/
  → Course (Freezed domain model)            lib/domain/models/
  → courseRepositoryProvider
  → courseSearchResultsProvider → SetupScreen
```

### Retrofit client

```dart
@RestApi()
abstract class GolfCourseApiClient {
  factory GolfCourseApiClient(Dio dio, {String baseUrl}) = _GolfCourseApiClient;

  @GET('/courses/search')
  Future<CourseSearchResponseDto> searchCourses(
    @Query('name') String name,
    @Header('x-api-key') String apiKey,
  );

  @GET('/courses/{id}')
  Future<CourseDetailDto> getCourseDetail(
    @Path('id') String courseId,
    @Header('x-api-key') String apiKey,
  );
}
```

Pass API key per-request from `AppConstants.golfApiKey` rather than a Dio interceptor — keeps client stateless and testable.

### Repository implementation

```dart
class CourseRepositoryImpl implements CourseRepository {
  @override
  Future<List<Course>> searchCourses(String query) async {
    try {
      final dto = await _api.searchCourses(query, AppConstants.golfApiKey);
      _cacheBox.putSearchResults(query, dto.toJson());
      return dto.courses.map(_toDomain).toList();
    } on DioException {
      final cached = _cacheBox.getSearchResults(query);
      if (cached != null) return _parseCachedSearch(cached);
      rethrow;
    }
  }
}
```

## Course Caching (Hive)

### Box structure

```
course_cache box:
  'course_{courseId}'     → Map<String, dynamic>  (CourseDetailDto JSON)
  'search_{query}'        → Map<String, dynamic>  (CourseSearchResponseDto JSON)
  'last_used_course_id'   → String

player_prefs box:
  'handicap_index'        → double
  'last_course_id'        → String
```

### Cache strategy

- **Network-first with Hive fallback** for both search and detail.
- **Cache-on-load:** Full course detail written to `course_{id}` immediately when user loads a course — the offline-first guarantee for on-course use.
- **No TTL.** Golf courses do not change. No expiry logic.
- **Last-used restore:** Pre-populate course selection on Setup open using `last_used_course_id`.
- **Raw JSON in Hive** (not typed adapters) — reuses the same DTO `json_serializable` encoding, one format to maintain.

## Wear OS Sync Pattern

**Confidence: MEDIUM.** Verify exact `wear_plus` method signatures against current package docs before implementation.

### Message protocol

```
Phone → Watch: '/brdy/hole-state'
Payload: { "holeIndex": 4, "holeNumber": 5, "par": 4, "currentOutcome": "birdie" }

Watch → Phone: '/brdy/score-entry'
Payload: { "outcome": "birdie" }
```

### Integration approach

Phone holds all state. Watch is a thin client that sends score events. `wearSyncWatcher` provider (keepAlive) reacts to `activeHoleIndexProvider` changes and pushes the current hole state to the watch. Watch score entries are received as a stream and routed to `shotCaptureNotifierProvider.recordOutcome()`.

**Platform guard:** All `wear_plus` calls wrapped in `if (Platform.isAndroid)` — library throws on iOS.

**Physical hardware required for testing.** Wear OS emulator pairing with Android emulator is unreliable.

## flutter_map + Riverpod Integration

### Three marker types on the overlay

1. **Hole GPS marker** — static, from `Course.holes[holeIndex]`, loaded at round start
2. **Shot pins** — user-placed, streamed via `shotPinsProvider` (Drift)
3. **Player location** — continuous stream from `gpsLocationProvider`

### GPS location stream

```dart
@riverpod
Stream<Position> gpsLocation(GpsLocationRef ref) {
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,  // only emit on 3m+ movement — prevents marker thrashing
    ),
  );
}
```

`distanceFilter: 3` is the key to preventing the MarkerLayer from re-rendering on every GPS tick.

### Tile pre-caching (flutter_map_tile_caching)

Pre-cache tiles for the course region during Setup when the course is loaded — not at first map open. Show a progress indicator in Setup. Without pre-caching the map is blank mid-round without signal.

Cache zoom levels 14–17 (covers hole-level detail without excessive storage).

## Build Order

### Phase 1: Foundation (no UI)

1. Domain models (Freezed): `Round`, `HoleScore`, `ShotPin`, `Course`, `HoleLayout`, `HoleOutcome`, `RoundSummary`
2. Domain repository interfaces: `RoundRepository`, `CourseRepository`, `PlayerPrefsRepository`
3. Drift tables + AppDatabase + `RoundsDao`
4. `appDatabaseProvider` (keepAlive)
5. Hive wrappers: `CourseCacheBox`, `PlayerPrefsBox`
6. Retrofit client + DTOs: `GolfCourseApiClient`, `CourseSearchResponseDto`, `CourseDetailDto`
7. Repository implementations
8. Infrastructure providers: `dioProvider`, `golfCourseApiProvider`, `roundRepositoryProvider`, `courseRepositoryProvider`
9. go_router wired as `appRouterProvider`
10. `appStartupProvider`: in-progress round recovery + router redirect

### Phase 2: Setup screen

1. Search + HI input providers
2. `roundSetupNotifierProvider`
3. Setup screen UI + tile pre-caching trigger

### Phase 3: Shot Capture screen

1. Active round providers + `shotCaptureNotifierProvider`
2. Shot Capture UI + hole navigation
3. GPS, shot pins, `HoleMapOverlay`
4. Voice command notifier + `speech_to_text`

### Phase 4: Round Review screen

1. `roundSummaryProvider`, `whsDifferentialProvider`
2. Scorecard + stat cards UI
3. Share/export (`share_plus` + `screenshot`)
4. New round reset flow

### Phase 5: Wear OS

1. `WearSyncService` + message protocol
2. `wearSyncWatcher` provider (phone side)
3. Watch-side Flutter entry point + score button UI
4. Physical hardware end-to-end test

### Phase 6: Polish

1. Offline detection gate in Setup
2. FMTC download progress UX
3. Error states on all `AsyncValue` providers
4. Haptic feedback + micro-animations

## Cross-cutting Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Provider keepAlive scope | `activeRoundId`, `activeHoleIndex`, infra + repos = keepAlive; screen providers = auto-dispose | Round state must survive navigation |
| Hole navigation within Shot Capture | Internal state change, not route pushes | Avoids 18-level back-stack |
| Course data in Hive vs Drift | Hive for course cache; rating/slope duplicated on Round row | Courses are immutable reference data |
| `holeParsJson` as JSON string | Denormalised on Round row | Avoids a 4th Drift table |
| GPS distanceFilter: 3m | `LocationSettings(distanceFilter: 3)` | Prevents GPS jitter thrashing MarkerLayer |
| Tile caching trigger | On course load in Setup | Tiles available before golfer reaches the course |
| `completedAt` null = in-progress | Drift Round column | Simple crash-recovery signal |
