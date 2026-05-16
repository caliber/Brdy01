# Phase 1: Foundation + Setup — Research

**Researched:** 2026-05-16
**Domain:** Flutter infrastructure stack — Drift, Hive, Riverpod code-gen, go_router, Dio+Retrofit, FMTC
**Confidence:** HIGH (verified against pub.dev, official docs, codebase analysis)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Full Drift schema (rounds + holes + shots) at schemaVersion:1. All three tables together — no table-creation migrations needed in later phases.
- **D-02:** Phase 1 `createRound()` creates the `rounds` row only. Hole rows are created on first score in Phase 2.
- **D-03:** The `shots` table is defined in Phase 1 but shot data is not written until Phase 5.
- **D-04:** Cache the full SETUP-03 dataset in Hive on course load (name, par, Course Rating, Slope, hole-by-hole par, Stroke Index, GPS hole coordinates). Full dataset cached in one API call — no re-fetch needed in later phases.
- **D-05:** Serialize the course object to a JSON string via Freezed `toJson()` and store it as a `String` value in the `course_cache` Hive box. No TypeAdapter needed.
- **D-06:** GPS hole layout fields (tee/green lat-lng per hole) are nullable in the domain model. Cache if returned; skip gracefully if not.
- **D-07:** Initialize `flutter_map_tile_caching` in `main()` before `runApp` with a single named store `'brdy_tiles'`.
- **D-08:** When a course is loaded, derive the tile bounding box from hole GPS coordinates in Hive (min/max lat-lng plus buffer). If no GPS data, skip pre-caching silently.
- **D-09:** Pre-cache zoom levels Z14–17 for the course bounding box.
- **D-10:** Tile pre-caching is best-effort and non-blocking. Show progress bar while downloading. Do not disable START ROUND button.
- **D-11:** GoRouter held in `@Riverpod(keepAlive: true)` provider (`routerProvider`). Lets the router watch `appStartupProvider` so redirect re-evaluates when startup resolves.
- **D-12:** Crash-recovery redirect is a GoRouter `redirect:` callback, not an `initialLocation` override. Reads `appStartupProvider` (AsyncValue): loading → `/splash`; incomplete round found → `/shot-capture/$roundId`; no incomplete round → `/setup`.
- **D-13:** `/splash` is the `initialLocation`. Splash widget: `background` color (#0A0A0A), centered `BRDY.01` wordmark in `labelLarge`. No spinner. User never sees Setup screen flash.

### Claude's Discretion

- **shots table in Phase 1:** Include at `schemaVersion:1` for schema completeness (decided: YES — Phase 5 just inserts rows, no migration needed).

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FOUND-01 | Round data written to Drift immediately on entry — write-through, no batching | Drift async DAO insert + optimistic Riverpod update pattern |
| FOUND-02 | App recovers in-progress round if restarted mid-round | appStartupProvider queries Drift for incomplete round on startup |
| FOUND-03 | App redirects to Shot Capture at correct hole if incomplete round detected | GoRouter redirect callback reads appStartupProvider AsyncValue |
| FOUND-04 | Golf Course API key validated at startup; clear error state if absent or 401 | AppConstants.golfApiKey isEmpty check + DioInterceptor 401 detection |
| FOUND-05 | OSM tiles pre-cached for course bounding box when course is loaded | FMTC FMTCObjectBoxBackend().initialise() + RectangleRegion + startForeground() |
| SETUP-01 | User can enter handicap index (decimal numeric, stored in Hive) | Hive box write on onChanged; TextFormField with numberWithOptions(decimal:true) |
| SETUP-02 | User can search for a golf course by name via golfcourseapi.com | Retrofit @GET('/search') + Riverpod AsyncNotifier with 400ms debounce |
| SETUP-03 | User can load a course (name, CR, slope, par/SI per hole, GPS layout) | getCourseDetail() Retrofit call + Freezed domain model |
| SETUP-04 | Loaded course cached locally in Hive; last-used pre-selected on next open | HiveCourseBox.write(id, course.toJson()); read lastUsedCourseId on startup |
| SETUP-05 | Warning if course missing CR or Slope, with option to enter both manually | Domain model nullable fields; MissingRatingBanner widget; inline form |
</phase_requirements>

---

## Summary

Phase 1 wires the full persistence and infrastructure stack from scratch. The app is a scaffold — Hive boxes are opened, but zero providers, DAOs, routes, or domain models exist. Every architectural layer must be populated in the correct dependency order: domain models first, then data layer implementations, then Riverpod providers, then go_router, then the UI. The Walking Skeleton objective is: user can search for a course, select it, and tap START ROUND — the app navigates to `/shot-capture/$roundId` and the round persists in Drift so a cold-restart returns to the correct screen.

The most critical technical decision already made (D-12/D-13) is the `appStartupProvider` + GoRouter redirect pattern. This is the spine that connects crash recovery (FOUND-02/03) to the splash screen and eliminates the Setup flash problem. All other decisions flow from the locked stack (Drift, Hive, Riverpod code-gen, Retrofit+Dio, FMTC v9).

The single unresolved external dependency is golfcourseapi.com's Stroke Index field. The FEATURES.md research notes "it does in standard golfcourseapi.com response schema" — this is [ASSUMED] and must be verified with a live API call in the first implementation task that touches the API.

**Primary recommendation:** Implement in strict layer order — domain models → Drift schema → Hive wrappers → Retrofit client → Riverpod providers → go_router → UI. Running `build_runner` is required after each layer's generated code changes.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Crash-safe round persistence | Data / Drift | — | SQLite is transactional; OS kill safe |
| Crash-recovery routing | App bootstrap / GoRouter | Riverpod (appStartupProvider) | Router redirect fires before any screen renders |
| Course search + load | Data / Retrofit | Domain / Repository interface | Network IO belongs in data layer |
| Hive prefs (handicap, last course) | Data / Hive | — | Key-value, non-transactional — prefs only |
| App state (active round ID, hole index) | Riverpod (keepAlive) | Drift (persisted copy) | In-memory for speed; Drift as source of truth |
| OSM tile pre-caching | Data / FMTC | — | File IO, background — not UI |
| API key validation | App bootstrap / constants | DioInterceptor | Compile-time inject; runtime intercept 401 |
| Setup screen UI | Presentation / Features | Riverpod providers | UI consumes providers; no direct data access |
| Theme / design system | App / Theme | — | One-time registration in BrdyTheme |

---

## Technical Approach

### 1. Drift Schema — Three Tables at schemaVersion:1

**Chosen approach:** Define `Rounds`, `Holes`, and `Shots` table classes in `lib/data/local/database/tables/`. Generate with `build_runner`. Schema version 1 has no `onUpgrade` path (fresh install only); the boilerplate is set up now so future bumps just add `if (from < 2)` branches.

**Key schema decisions from D-01/02/03:**

```dart
// lib/data/local/database/tables/rounds_table.dart
class Rounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get courseName => text()();
  RealColumn get courseRating => real().nullable()();
  IntColumn get courseSlope => integer().nullable()();
  RealColumn get handicapIndex => real()();   // stored as decimal (14.3, not 143)
  TextColumn get courseJson => text()();       // full Hive-cached course snapshot
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();  // null = in progress
}

class Holes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  IntColumn get holeNumber => integer()();    // 1–18
  IntColumn get par => integer()();
  IntColumn get strokeIndex => integer().nullable()();
  TextColumn get outcome => text().nullable()();  // 'eagle','birdie','par','bogey','double','pickup'
  IntColumn get putts => integer().nullable()();
  BoolColumn get fairwayHit => boolean().nullable()(); // null = par 3
  BoolColumn get greenInRegulation => boolean().nullable()();
  DateTimeColumn get recordedAt => dateTime().nullable()();
}

class Shots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get holeId => integer().references(Holes, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get shotNumber => integer()();
  DateTimeColumn get recordedAt => dateTime()();
}
```

**MigrationStrategy for schemaVersion:1:** [VERIFIED: drift.simonbinder.eu/migrations]

```dart
@override
int get schemaVersion => 1;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async => await m.createAll(),
  onUpgrade: (m, from, to) async {
    // Phase 2+ schema bumps: if (from < 2) await m.addColumn(...)
  },
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
  },
);
```

**`drift_schemas/` directory:** Must exist and contain the exported JSON for version 1. Generate with `dart run drift_dev schema dump lib/data/local/database/app_database.dart drift_schemas/1.json` after the tables are defined. [CITED: drift.simonbinder.eu/migrations]

**Confidence:** HIGH

---

### 2. Hive Course Cache — JSON String, No TypeAdapter

**Chosen approach (D-05):** Store the course as `course_cache.put(courseId, jsonEncode(course.toJson()))`. Read back with `jsonDecode(raw)` and `CourseModel.fromJson()`. No TypeAdapter registration needed because the value is a plain `String`. This avoids the Concerns.md-identified risk of Hive failing at runtime for non-primitive types. [VERIFIED: codebase CONCERNS.md]

**`player_prefs` Hive box keys:**
- `'handicap_index'` → `double`
- `'last_used_course_id'` → `String`

**`course_cache` Hive box keys:**
- `courseId` (String from API) → JSON string of `CourseModel.toJson()`

The `HivePlayerPrefs` and `HiveCourseBox` wrapper classes live in `lib/data/local/preferences/`. They are thin wrappers: typed getters/setters that call `Hive.box(name).get(key)` and `.put(key, value)`. These wrappers are exposed via `@Riverpod(keepAlive: true)` providers. [ASSUMED — standard pattern; matches CONCERNS.md and CONVENTIONS.md observations]

**Confidence:** HIGH

---

### 3. Riverpod 2.x Code Generation

**Chosen approach:** `@riverpod` annotations throughout. Never hand-write Provider boilerplate (established project convention). [VERIFIED: CLAUDE.md, CONVENTIONS.md]

**keepAlive providers (MUST — CLAUDE.md rule):**

```dart
// lib/data/local/database/app_database.provider.dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

// lib/data/local/preferences/hive_player_prefs.provider.dart
@Riverpod(keepAlive: true)
HivePlayerPrefs hivePlayerPrefs(Ref ref) =>
    HivePlayerPrefs(Hive.box(AppConstants.playerPrefsBox));

// lib/data/local/preferences/hive_course_box.provider.dart
@Riverpod(keepAlive: true)
HiveCourseBox hiveCourseBox(Ref ref) =>
    HiveCourseBox(Hive.box(AppConstants.courseCacheBox));

// lib/data/remote/api/golf_course_api.provider.dart
@Riverpod(keepAlive: true)
Dio dio(Ref ref) => Dio(BaseOptions(
  baseUrl: AppConstants.golfApiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  headers: {'Authorization': 'Key ${AppConstants.golfApiKey}'},
));

@Riverpod(keepAlive: true)
GolfCourseApi golfCourseApi(Ref ref) =>
    GolfCourseApi(ref.watch(dioProvider));

// lib/infrastructure/repositories/course_repository.provider.dart
@Riverpod(keepAlive: true)
CourseRepository courseRepository(Ref ref) =>
    CourseRepositoryImpl(ref.watch(golfCourseApiProvider), ref.watch(hiveCourseBoxProvider));

// lib/infrastructure/repositories/round_repository.provider.dart
@Riverpod(keepAlive: true)
RoundRepository roundRepository(Ref ref) =>
    RoundRepositoryImpl(ref.watch(appDatabaseProvider));

// lib/app/router.dart
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => GoRouter(...);

// lib/features/setup/providers/active_round_id.provider.dart
@Riverpod(keepAlive: true)
class ActiveRoundId extends _$ActiveRoundId {
  @override
  int? build() => null;
  void set(int id) => state = id;
  void clear() => state = null;
}

// lib/features/shot_capture/providers/active_hole_index.provider.dart
@Riverpod(keepAlive: true)
class ActiveHoleIndex extends _$ActiveHoleIndex {
  @override
  int build() => 0;
  void set(int index) => state = index;
}
```

**Screen-level providers (auto-dispose):**

```dart
// Course search — auto-dispose: result discarded when setup screen exits
@riverpod
class CourseSearchQuery extends _$CourseSearchQuery { ... }

@riverpod
Future<List<CourseSearchResult>> courseSearchResults(Ref ref) async { ... }

@riverpod
class SelectedCourse extends _$SelectedCourse { ... }

@riverpod
class RoundSetupNotifier extends _$RoundSetupNotifier { ... }

// app startup check — runs once; auto-dispose after routing completes
@riverpod
Future<int?> appStartup(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.roundDao.findIncompleteRoundId();  // returns null or roundId
}
```

**Confidence:** HIGH

---

### 4. go_router Crash-Recovery Redirect

**Chosen approach (D-11/12/13):** GoRouter held in a `@Riverpod(keepAlive:true)` provider. The router uses `refreshListenable` wired to a `ChangeNotifier` that wraps the `appStartupProvider` state changes. The `redirect:` callback reads `appStartupProvider` from the `ref`. [VERIFIED: multiple community sources; ASSUMED for exact syntax of ref access inside redirect callback]

The key architectural challenge: GoRouter's `refreshListenable` only accepts `Listenable` (ChangeNotifier), not Riverpod `AsyncValue`. The standard pattern is a `RouterNotifier` class: [ASSUMED — verified pattern exists, exact code is training knowledge]

```dart
// lib/app/router_notifier.dart
class RouterNotifier extends ChangeNotifier implements AutoDisposeRef<void> {
  // OR simpler pattern:
  // Use ref.listen() inside the router provider to notifyListeners when appStartup resolves
}

// lib/app/router.dart
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // Create a ChangeNotifier that notifyListeners when appStartupProvider changes
  final notifier = _RouterListenable(ref);
  ref.onDispose(notifier.dispose);
  
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) async {
      final startupState = ref.read(appStartupProvider);
      return startupState.when(
        loading: () => '/splash',
        error: (_, __) => '/setup',  // fail open to setup
        data: (incompleteRoundId) {
          if (incompleteRoundId != null) {
            ref.read(activeRoundIdProvider.notifier).set(incompleteRoundId);
            return '/shot-capture/$incompleteRoundId';
          }
          if (state.uri.path == '/splash') return '/setup';
          return null;  // no redirect needed
        },
      );
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/setup', builder: (_, __) => const SetupScreen()),
      GoRoute(
        path: '/shot-capture/:roundId',
        builder: (_, state) => ShotCaptureScreen(
          roundId: int.parse(state.pathParameters['roundId']!),
        ),
      ),
      GoRoute(
        path: '/round-review/:roundId',
        builder: (_, state) => RoundReviewScreen(
          roundId: int.parse(state.pathParameters['roundId']!),
        ),
      ),
    ],
  );
}
```

**`_RouterListenable`** is a simple `ChangeNotifier` that subscribes to `appStartupProvider` via `ref.listen()` inside the router provider and calls `notifyListeners()` when it transitions from loading → data/error.

**IMPORTANT — navigation model:** All main screen transitions use `context.go()`, NOT `context.push()`. Hole navigation within Shot Capture uses `ref.read(activeHoleIndexProvider.notifier).set(index)` — NOT route pushes. [VERIFIED: CLAUDE.md]

**`BrdyApp` update:** Replace `MaterialApp(home: SetupScreen())` with:
```dart
MaterialApp.router(routerConfig: ref.watch(routerProvider))
```

**Confidence:** HIGH (pattern), MEDIUM (exact `ref` access syntax in redirect — verify against go_router 14.x API)

---

### 5. Dio + Retrofit — Golf Course API Client

**Chosen approach:** `@RestApi` Retrofit interface + Freezed DTOs + Dio 5.x with `Duration`-based timeouts. [VERIFIED: STACK.md research; pubspec versions confirmed]

**API Key validation (FOUND-04):**

```dart
// lib/data/remote/api/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConstants.golfApiKey.isEmpty) {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        message: 'API_KEY_MISSING',
      ));
      return;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Surface as typed exception for UI to detect
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: DioExceptionType.badResponse,
        message: 'API_KEY_INVALID',
      ));
      return;
    }
    handler.next(err);
  }
}
```

**Retrofit interface:**

```dart
// lib/data/remote/api/golf_course_api.dart
part 'golf_course_api.g.dart';

@RestApi(baseUrl: AppConstants.golfApiBaseUrl)
abstract class GolfCourseApi {
  factory GolfCourseApi(Dio dio) = _GolfCourseApi;

  @GET('/search')
  Future<CourseSearchResponseDto> searchCourses(@Query('search_query') String query);

  @GET('/courses/{id}')
  Future<CourseDetailResponseDto> getCourseDetail(@Path('id') String id);
}
```

**Endpoint assumptions:** [ASSUMED — golfcourseapi.com docs redirect to auth-gated page]
- Search: `GET /search?search_query=<name>` returns list of courses with id, name, location
- Detail: `GET /courses/{id}` returns full course data including holes array

**golfcourseapi.com base URL:** `https://api.golfcourseapi.com/v1` (confirmed in `AppConstants.golfApiBaseUrl`)

**Confidence:** MEDIUM (endpoint paths [ASSUMED], Dio/Retrofit setup HIGH)

---

### 6. FMTC v9 Tile Pre-Caching

**pubspec version:** `flutter_map_tile_caching: ^9.1.1` (v9, not v10). The v10 API differs — verify against v9 docs. [VERIFIED: pubspec.yaml]

**Initialization in main() (D-07):** [VERIFIED: pub.dev/packages/flutter_map_tile_caching/versions/9.1.4/example]

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.playerPrefsBox);
  await Hive.openBox(AppConstants.courseCacheBox);
  
  // FMTC must initialize before runApp
  Object? fmtcError;
  try {
    await FMTCObjectBoxBackend().initialise();
    await FMTCStore(AppConstants.tileCacheStoreName).manage.create();
  } catch (e) {
    fmtcError = e; // non-blocking; log and continue
  }
  
  runApp(const ProviderScope(child: BrdyApp()));
}
```

Add to `AppConstants`: `static const String tileCacheStoreName = 'brdy_tiles';`

**Bulk download for course bounding box (D-08/09/10):** [VERIFIED: fmtc.jaffaketchup.dev/usage/bulk-downloading]

```dart
// lib/infrastructure/repositories/tile_cache_repository.dart
Future<void> preCacheCourse(List<HoleGpsData> holeCoords) async {
  if (holeCoords.isEmpty) return; // D-08: skip silently if no GPS data

  final bounds = _deriveBounds(holeCoords, bufferDegrees: 0.005);
  final region = RectangleRegion(bounds);
  final downloadable = region.toDownloadable(
    minZoom: 14,  // D-09
    maxZoom: 17,
    options: TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.brdy.brdy01',
    ),
  );

  final (:downloadProgress, :tileEvents) =
      FMTCStore(AppConstants.tileCacheStoreName).download.startForeground(
        downloadable,
        seaTileRemoval: false,
        parallelThreads: 3,
      );

  // D-10: non-blocking — caller listens to stream for UI progress bar
  // but does not await completion before enabling START ROUND
  return; // stream is returned via provider to UI
}
```

**Progress bar (Component 8 in UI-SPEC):** The tile caching provider exposes a `Stream<DownloadProgress>` that the `SetupScreen` listens to via a `StreamProvider` to drive the `LinearProgressIndicator`.

**FMTC v9 vs v10 difference:** v10 uses `FMTCObjectBoxBackend().initialise()` — the same call is used in v9.1.4 example. The store creation API `FMTCStore('name').manage.create()` is consistent across both versions. [VERIFIED: pub.dev example for v9.1.4]

**Confidence:** MEDIUM-HIGH (initialization verified; download API verified from official docs; exact parameter names [ASSUMED] until v9 API reference confirmed)

---

### 7. Golf Course API — Response Shape

**Status:** [ASSUMED — docs require auth; cannot be verified programmatically]

Based on FEATURES.md note ("it does in standard golfcourseapi.com response schema") and comparable golf APIs, the assumed response shape is:

**Search response** (`GET /search?search_query=<name>`):
```json
{
  "courses": [
    {
      "id": "abc123",
      "club_name": "Royal Melbourne Golf Club",
      "course_name": "West Course",
      "location": { "city": "Melbourne", "country": "Australia" },
      "course_rating": 74.0,
      "slope_rating": 145,
      "holes": 18,
      "par": 72
    }
  ]
}
```

**Course detail response** (`GET /courses/{id}`):
```json
{
  "course": {
    "id": "abc123",
    "club_name": "Royal Melbourne Golf Club",
    "course_name": "West Course",
    "location": { ... },
    "course_rating": 74.0,
    "slope_rating": 145,
    "par": 72,
    "holes": [
      {
        "hole_number": 1,
        "par": 4,
        "stroke_index": 7,
        "tee_positions": [
          { "color": "white", "latitude": -37.9, "longitude": 145.1 }
        ],
        "green_latitude": -37.901,
        "green_longitude": 145.102
      }
    ]
  }
}
```

**CRITICAL GATE (from STATE.md):** Verify the API returns `stroke_index` per hole in the first API integration task. WHS pickup scoring (Phase 2) requires SI — if it's absent, a data workaround must be designed before Phase 2 starts. Also verify `course_rating` and `slope_rating` field name casing (snake_case assumed). [ASSUMED]

**API rate limits:** [ASSUMED] Free tier = 300 requests/day (from golfcourseapi.com homepage). Search is used interactively; course detail is called once per load and cached. Under normal use well within limits.

**Confidence:** LOW for exact field names; MEDIUM for data completeness (FEATURES.md reports SI is present)

---

### 8. Domain Model Design

**Freezed models in `lib/domain/models/`:**

```dart
// course_model.dart
@freezed
class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    required String clubName,
    required String courseName,
    double? courseRating,    // nullable per SETUP-05
    int? slope,              // nullable per SETUP-05
    required int par,
    required List<HoleModel> holes,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}

// hole_model.dart  
@freezed
class HoleModel with _$HoleModel {
  const factory HoleModel({
    required int holeNumber,
    required int par,
    int? strokeIndex,    // D-06: nullable — skip if absent
    double? teeLat,      // D-06: nullable GPS fields
    double? teeLng,
    double? greenLat,
    double? greenLng,
  }) = _HoleModel;

  factory HoleModel.fromJson(Map<String, dynamic> json) =>
      _$HoleModelFromJson(json);
}

// round_model.dart
@freezed
class RoundModel with _$RoundModel {
  const factory RoundModel({
    required int id,
    required String courseName,
    double? courseRating,
    int? slope,
    required double handicapIndex,
    required DateTime startedAt,
    DateTime? completedAt,
  }) = _RoundModel;

  factory RoundModel.fromJson(Map<String, dynamic> json) =>
      _$RoundModelFromJson(json);
}
```

**Domain enums in `lib/domain/enums/`:**
```dart
// hole_outcome.dart
enum HoleOutcome { eagle, birdie, par, bogey, double_, pickup }
```

Note: `double` is a reserved Dart keyword — use `double_` or `doubleBogey` as the enum value name. Persist as string `'double'` in Drift.

**Confidence:** HIGH

---

### 9. build_runner Workflow

**Run command:** `dart run build_runner build --delete-conflicting-outputs` [VERIFIED: CLAUDE.md, STACK.md]

**Order of operations (CRITICAL — generators have dependencies):**

1. Write Freezed model files (`.dart` with `@freezed`) → run build_runner → gets `*.freezed.dart` and `*.g.dart`
2. Write Drift table files and `AppDatabase` → run build_runner → gets `*.g.dart` for DAOs
3. Write Retrofit interface file (with `part '*.g.dart'`) → run build_runner → gets Retrofit implementation
4. Write Riverpod provider files (with `@riverpod`) → run build_runner → gets `*.g.dart` provider parts

**Do NOT** write provider files that reference generated types before running build_runner for those types — the analyzer will block code-gen on type errors.

**After Drift schema changes:** Also run `dart run drift_dev schema dump` to update `drift_schemas/1.json`.

**Generated files to commit:** All `*.g.dart` and `*.freezed.dart` files — they are project-controlled build outputs. [VERIFIED: CONVENTIONS.md]

**Confidence:** HIGH

---

### 10. Theme Bootstrap

**Files to create (from UI-SPEC §Files to Create):**
- `lib/theme/brdy_colors.dart` — `abstract final class BrdyColors` with all color tokens
- `lib/theme/brdy_spacing.dart` — `abstract final class BrdySpacing` with spacing scale
- `lib/theme/brdy_text_theme.dart` — `abstract final class BrdyTextTheme` with TextTheme factory
- `lib/theme/brdy_theme.dart` — `BrdyTheme.themeData` assembling ThemeData

**All values are locked in UI-SPEC — do not derive or invent.** The BrdyColors, BrdySpacing, and BrdyTextTheme sections of UI-SPEC are the single source of truth for every pixel value.

**google_fonts usage:** `GoogleFonts.jetBrainsMono(fontSize: 28, fontWeight: FontWeight.w700)` and `GoogleFonts.barlowCondensed(fontSize: 18, fontWeight: FontWeight.w700)`. The `google_fonts` package is already in pubspec.yaml. [VERIFIED: STACK.md]

**Confidence:** HIGH

---

### 11. Walking Skeleton Scope

The Walking Skeleton proves the full stack end-to-end: Drift write, Hive read, API call, GoRouter navigation, Riverpod state.

**Thinnest meaningful capability:**

1. App launches → splash renders → `appStartupProvider` queries Drift → no incomplete round → GoRouter redirects to `/setup`
2. User types handicap (14.3) → stored in Hive `player_prefs`
3. User types "Royal Melbourne" → Retrofit calls golfcourseapi.com → results appear
4. User selects a course → course detail fetched, stored in Hive `course_cache`, `CourseModel` in `selectedCourseProvider`
5. User taps START ROUND → `createRound()` inserts to Drift `rounds` table → GoRouter `context.go('/shot-capture/$roundId')` → placeholder Shot Capture screen renders
6. Kill app → relaunch → splash → `appStartupProvider` finds incomplete round → GoRouter redirects to `/shot-capture/$roundId` → correct screen

This is the SKELETON.md scope. Shot Capture screen renders a placeholder (it already exists as a scaffold). No hole scoring in Phase 1.

**Confidence:** HIGH

---

## Integration Points

```
main()
  ├── Hive.initFlutter() + openBox(player_prefs) + openBox(course_cache)
  ├── FMTCObjectBoxBackend().initialise()          [FMTC — FOUND-05]
  └── ProviderScope(child: BrdyApp())
        └── BrdyApp (ConsumerWidget)
              └── MaterialApp.router(routerConfig: ref.watch(routerProvider))
                    └── routerProvider (keepAlive)
                          ├── watches: appStartupProvider
                          │     └── reads: appDatabaseProvider → roundDao.findIncompleteRoundId()
                          └── redirect callback:
                                loading    → /splash
                                roundId    → /shot-capture/$roundId  [FOUND-02, FOUND-03]
                                no round   → /setup

SetupScreen (ConsumerStatefulWidget)
  ├── reads: hivePlayerPrefsProvider → pre-populate handicap field
  ├── reads: hiveCourseBoxProvider → pre-populate last course (SETUP-04)
  ├── watches: courseSearchResultsProvider (AsyncValue<List<CourseSearchResult>>)
  │     └── reads: courseSearchQueryProvider (debounced string)
  │           └── calls: golfCourseApiProvider.searchCourses()  [SETUP-02]
  ├── watches: selectedCourseProvider (CourseModel?)             [SETUP-03]
  │     └── on select: calls courseRepositoryProvider.getCourseDetail(id)
  │           ├── writes: hiveCourseBoxProvider.writeCourse()   [SETUP-04]
  │           └── triggers: tileCacheProvider.preCacheCourse()  [FOUND-05]
  └── onTap START ROUND:
        └── roundSetupNotifierProvider.createRound(course, handicapIndex)
              ├── writes: appDatabaseProvider.roundDao.insertRound()  [FOUND-01]
              └── on success: context.go('/shot-capture/$roundId')

AppStartupProvider
  └── appDatabaseProvider.roundDao.findIncompleteRoundId()
        └── SELECT id FROM rounds WHERE completedAt IS NULL LIMIT 1
```

**FOUND-04 API key validation:** `AuthInterceptor` attached to `dioProvider`. Interceptor rejects all requests if `golfApiKey.isEmpty`. 401 responses are caught and re-thrown as a typed error. `SetupScreen` shows full-screen `ApiKeyErrorState` widget when this error is present. The error is detected at first API call (search), not at app startup — the setup screen remains functional for handicap entry.

---

## File and Directory Structure

All directories already exist as empty scaffolds. Files to create:

```
lib/
├── main.dart                                  UPDATE — add FMTC init
├── app/
│   ├── app.dart                               UPDATE — MaterialApp.router, BrdyTheme
│   ├── constants.dart                         UPDATE — add tileCacheStoreName
│   └── router.dart                            CREATE — routerProvider, GoRouter, routes
│
├── theme/                                     CREATE ALL
│   ├── brdy_colors.dart
│   ├── brdy_spacing.dart
│   ├── brdy_text_theme.dart
│   └── brdy_theme.dart
│
├── domain/
│   ├── models/                                CREATE ALL
│   │   ├── course_model.dart                  + .freezed.dart + .g.dart (generated)
│   │   ├── hole_model.dart                    + .freezed.dart + .g.dart
│   │   └── round_model.dart                   + .freezed.dart + .g.dart
│   ├── enums/
│   │   └── hole_outcome.dart                  CREATE
│   └── repositories/
│       ├── course_repository.dart             CREATE — abstract interface
│       └── round_repository.dart              CREATE — abstract interface
│
├── data/
│   ├── local/
│   │   ├── database/
│   │   │   ├── app_database.dart              CREATE — @DriftDatabase
│   │   │   ├── app_database.g.dart            GENERATED
│   │   │   ├── tables/
│   │   │   │   ├── rounds_table.dart          CREATE
│   │   │   │   ├── holes_table.dart           CREATE
│   │   │   │   └── shots_table.dart           CREATE
│   │   │   └── daos/
│   │   │       ├── round_dao.dart             CREATE + .g.dart generated
│   │   │       └── hole_dao.dart              CREATE + .g.dart generated
│   │   └── preferences/
│   │       ├── hive_player_prefs.dart         CREATE
│   │       └── hive_course_box.dart           CREATE
│   └── remote/
│       ├── api/
│       │   ├── golf_course_api.dart           CREATE — @RestApi Retrofit
│       │   ├── golf_course_api.g.dart         GENERATED
│       │   └── interceptors/
│       │       └── auth_interceptor.dart      CREATE
│       └── dto/
│           ├── course_search_response_dto.dart  CREATE + .g.dart
│           └── course_detail_response_dto.dart  CREATE + .g.dart
│
├── infrastructure/
│   └── repositories/
│       ├── course_repository_impl.dart        CREATE — implements domain interface
│       └── round_repository_impl.dart         CREATE — implements domain interface
│
├── features/
│   ├── setup/
│   │   ├── setup_screen.dart                  REPLACE — full implementation
│   │   ├── providers/                         CREATE ALL
│   │   │   ├── app_startup_provider.dart
│   │   │   ├── active_round_id_provider.dart
│   │   │   ├── course_search_query_provider.dart
│   │   │   ├── course_search_results_provider.dart
│   │   │   ├── selected_course_provider.dart
│   │   │   └── round_setup_notifier.dart
│   │   └── widgets/                           CREATE ALL (from UI-SPEC)
│   │       ├── handicap_input.dart
│   │       ├── course_search_field.dart
│   │       ├── course_result_tile.dart
│   │       ├── course_card.dart
│   │       └── missing_rating_banner.dart
│   ├── setup/
│   │   └── splash_screen.dart                 CREATE — /splash route
│   └── shot_capture/
│       └── shot_capture_screen.dart           UPDATE — accept roundId param, placeholder UI
│
└── services/                                  (Phase 5 — do not create in Phase 1)

drift_schemas/
└── 1.json                                     GENERATE — dart run drift_dev schema dump

test/
└── widget_test.dart                           UPDATE — fix MyApp → BrdyApp + ProviderScope
```

Note: `lib/features/setup/splash_screen.dart` — put splash in features/setup or create `lib/features/splash/splash_screen.dart`. Either is acceptable; keep consistent with feature-first naming.

---

## Implementation Order

**Wave 0 (prerequisites — must be done before any provider code):**

1. **Create domain models** — `CourseModel`, `HoleModel`, `RoundModel` (Freezed), `HoleOutcome` enum. Run build_runner. These types are imported everywhere else.
2. **Create domain repository interfaces** — abstract `CourseRepository`, `RoundRepository`. No build_runner needed.
3. **Create theme files** — `BrdyColors`, `BrdySpacing`, `BrdyTextTheme`, `BrdyTheme`. No build_runner needed. Theme can be wired immediately.
4. **Update `test/widget_test.dart`** — fix broken `MyApp` import to `BrdyApp` in `ProviderScope`. Run `flutter test` — should compile (currently does not).

**Wave 1 (data layer):**

5. **Write Drift table files** (`Rounds`, `Holes`, `Shots`). Write `AppDatabase` with `@DriftDatabase(tables: [Rounds, Holes, Shots])`. Write `RoundDao` with `findIncompleteRoundId()` and `insertRound()`. Run build_runner. Dump `drift_schemas/1.json`.
6. **Write Hive wrappers** — `HivePlayerPrefs`, `HiveCourseBox`. No build_runner needed.
7. **Write Retrofit interface + DTOs** — `GolfCourseApi`, `CourseSearchResponseDto`, `CourseDetailResponseDto`. Write `AuthInterceptor`. Run build_runner.

**Wave 2 (infrastructure + providers):**

8. **Write repository implementations** — `CourseRepositoryImpl`, `RoundRepositoryImpl`.
9. **Write all Riverpod providers** — database, Hive, Dio, Retrofit, repositories, `appStartupProvider`, `activeRoundIdProvider`, `activeHoleIndexProvider`. Run build_runner.
10. **Update `main.dart`** — add FMTC `FMTCObjectBoxBackend().initialise()` + store creation. Update `AppConstants` with `tileCacheStoreName`.

**Wave 3 (routing + app shell):**

11. **Write `router.dart`** — `routerProvider`, GoRouter with routes and redirect callback. Write `_RouterListenable` ChangeNotifier bridge.
12. **Update `app.dart`** — replace `MaterialApp(home:)` with `MaterialApp.router(routerConfig: ref.watch(routerProvider))` + `BrdyTheme.themeData`.
13. **Write `SplashScreen`** — minimal widget: black background, `BRDY.01` wordmark. No animation needed.

**Wave 4 (Setup screen UI):**

14. **Write Setup screen widgets** in the order defined by UI-SPEC: `HandicapInput` → `CourseSearchField` → `CourseResultTile` → `CourseCard` → `MissingRatingBanner` → `SetupScreen` itself (assembles widgets).
15. **Wire Setup screen providers** — connect search field to `courseSearchQueryProvider` (400ms debounce), connect course selection to `selectedCourseProvider`, wire START ROUND button to `roundSetupNotifierProvider.createRound()`.
16. **Implement FMTC tile pre-caching** — `TileCacheRepository` + stream provider for progress bar.

**Wave 5 (integration verification):**

17. **Run full integration smoke test** — launch app (with API key), search for a course, load it, start a round, kill the app, relaunch, verify redirect to Shot Capture.
18. **Verify FOUND-04** — launch without `--dart-define=GOLF_API_KEY` → expect ApiKeyError state in Setup screen.

---

## Pitfalls and Gotchas

### P-01: HoleOutcome enum `double` keyword collision
**What goes wrong:** Dart reserves `double` as a type keyword. `enum HoleOutcome { ..., double, ... }` is a compile error.
**Prevention:** Name the enum value `doubleBogey` or `double_`. Persist to Drift/JSON as the string `'double'`. Map in `fromJson`/`toJson` manually.

### P-02: build_runner partial run order
**What goes wrong:** Running build_runner with all files present but generated types not yet generated causes cascading errors — `CourseModel` referenced before `course_model.freezed.dart` exists.
**Prevention:** Run build_runner in waves (Step 1: Freezed only; Step 2: Drift only; Step 3: Retrofit only). Use `--delete-conflicting-outputs` on every run.

### P-03: FMTC store creation on every launch
**What goes wrong:** `FMTCStore('brdy_tiles').manage.create()` called in `main()` on every launch. If the store already exists from a prior run, v9 may throw or silently succeed.
**Prevention:** Wrap store creation in try-catch. Alternatively call `manage.ready` first or use `manage.createOrGet()` if available in v9. Research the exact v9 API for idempotent store creation. [ASSUMED — verify against v9 docs]

### P-04: GoRouter `refreshListenable` requires a `Listenable`, not AsyncValue
**What goes wrong:** Passing `appStartupProvider` directly to `refreshListenable` fails — Riverpod `AsyncValue` is not a `Listenable`.
**Prevention:** Use the `_RouterListenable` ChangeNotifier bridge pattern. The notifier calls `ref.listen(appStartupProvider, ...)` and `notifyListeners()` in the callback. [ASSUMED — pattern confirmed in community; exact code must be tested]

### P-05: GoRouter redirect callback called before async state resolves
**What goes wrong:** The redirect callback fires synchronously before `appStartupProvider` has any data. Reading `appStartupProvider` returns `AsyncValue.loading()` — redirect always goes to `/splash`.
**Prevention:** This is intentional (D-13). The splash screen shows until `appStartupProvider` emits data, then `refreshListenable.notifyListeners()` re-triggers the redirect with the actual result. The user sees splash for ~100ms on a fast device, zero Setup flash.

### P-06: Hive TypeAdapter omission for complex objects
**What goes wrong:** Storing a `CourseModel` object (not a String) in Hive fails at runtime — no TypeAdapter registered. This is flagged in CONCERNS.md.
**Prevention:** Store ONLY the JSON string (`course.toJson()` serialized to String via `jsonEncode`). Read back with `CourseModel.fromJson(jsonDecode(raw))`. Never store non-primitive Hive values without a TypeAdapter. (D-05 avoids this correctly.)

### P-07: Drift `completedAt IS NULL` query not using index
**What goes wrong:** `appStartupProvider` runs on every cold start. If `rounds` table grows large (future round history), a full table scan for `completedAt IS NULL` is slow.
**Prevention:** At schemaVersion:1, add an index on `completedAt`. In Drift: `@override Set<Column> get primaryKey => {completedAt};` is wrong — use `@TableIndex.onColumns([#completedAt])` annotation or a raw index in `onCreate`. [ASSUMED — verify Drift index syntax]

### P-08: FMTC v9 vs v10 API difference
**What goes wrong:** FMTC v10 (latest on pub.dev) has a different API surface from v9. Tutorials and search results may reference v10.
**Prevention:** The project is pinned to `^9.1.1`. Always refer to v9 docs at `fmtc.jaffaketchup.dev/v9/`. The initialization call (`FMTCObjectBoxBackend().initialise()`) is shared between v9 and v10. The download API (`startForeground`, `RectangleRegion`, `toDownloadable`) is similar but verify parameter names against v9.

### P-09: golfcourseapi.com Stroke Index not returned
**What goes wrong:** If `stroke_index` is absent from the API response, WHS pickup scoring in Phase 2 cannot be implemented correctly. Discovered late = Phase 2 blocked.
**Prevention:** In the first API integration task, log the raw JSON response and verify `stroke_index` is present in the holes array. If absent, document the workaround (evenly distribute strokes 1-18 by hole number — a known approximation) before proceeding.

### P-10: Retrofit code-gen `part` directive missing
**What goes wrong:** Retrofit interface file missing `part 'golf_course_api.g.dart';` — build_runner silently skips generation, then throws `_GolfCourseApi` not found at runtime.
**Prevention:** Every Retrofit interface file must start with `part 'filename.g.dart';`. Same for Freezed models (`part 'filename.freezed.dart'; part 'filename.g.dart';`).

### P-11: `context.go()` vs `context.push()` on main screen transitions
**What goes wrong:** Using `context.push('/shot-capture/$roundId')` creates a back-stack entry from Setup. Android back button returns to Setup mid-round.
**Prevention:** Use `context.go('/shot-capture/$roundId')` exclusively for Setup → Shot Capture and Shot Capture → Round Review. Back navigation from Shot Capture must never be possible. [VERIFIED: CLAUDE.md Critical Don'ts]

### P-12: test/widget_test.dart `MyApp` import fails
**What goes wrong:** `test/widget_test.dart` imports `MyApp` from `main.dart`. `MyApp` does not exist — `BrdyApp` does. `flutter test` fails to compile.
**Prevention:** Update `test/widget_test.dart` to import and pump `BrdyApp` wrapped in `ProviderScope`. This is Wave 0 step 4. [VERIFIED: codebase analysis]

### P-13: `ShotCaptureScreen` must accept `roundId` parameter
**What goes wrong:** Current `ShotCaptureScreen` is a stateless placeholder with no parameters. After routing, it needs to read its `roundId` from route parameters.
**Prevention:** Update `ShotCaptureScreen` constructor to accept `final int roundId` parameter. The GoRoute builder passes it as `int.parse(state.pathParameters['roundId']!)`.

### P-14: FMTC tile pre-caching blocks if awaited on UI thread
**What goes wrong:** If `preCacheCourse()` is awaited before showing the Course Card or enabling START ROUND, the UI freezes until all tiles are downloaded.
**Prevention:** Fire-and-forget the download. Expose progress via a `StreamProvider`. START ROUND button is always enabled once course is loaded (D-10). [VERIFIED: D-10 decision]

---

## Validation Architecture

`nyquist_validation: false` is set in `.planning/config.json`. Full test framework is not required. However, the following minimal verifications prove phase success:

### Manual Verification Checklist (per ROADMAP.md Phase 1 success criteria)

| Check | Requirement | Manual Test |
|-------|-------------|-------------|
| Course search returns results | SETUP-02 | Type 2+ chars in search field; verify list appears |
| Course loads with all fields | SETUP-03 | Select result; verify Course Card shows name, CR, slope, par |
| Missing rating warning shows | SETUP-05 | Load a course with null CR/slope; verify banner appears |
| Manual rating entry saves | SETUP-05 | Tap ENTER MANUALLY; enter values; verify Course Card updates |
| Handicap persists across restarts | SETUP-01 | Enter 14.3; kill app; relaunch; verify field pre-populated |
| Course cached for offline use | SETUP-04 | Load course; enable airplane mode; relaunch; verify Course Card pre-populated |
| START ROUND creates Drift row | FOUND-01 | Tap START ROUND; use SQLite browser to verify `rounds` row exists |
| Crash recovery navigates to Shot Capture | FOUND-02/03 | Start round; kill app; relaunch; verify `/shot-capture/$roundId` renders |
| API key missing shows error state | FOUND-04 | Build without `--dart-define=GOLF_API_KEY`; verify full-screen error |
| Tile pre-caching shows progress | FOUND-05 | Load a course with GPS data; verify progress bar updates |
| `flutter test` passes | Code quality | `flutter test` must compile and pass the updated widget test |
| `flutter analyze` clean | Code quality | Zero analyzer errors |

### Widget Test (minimal — Wave 0):

```dart
// test/widget_test.dart (replacement)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brdy01/app/app.dart';

void main() {
  testWidgets('BrdyApp renders without crashing', (tester) async {
    // Minimal smoke test: proves ProviderScope + BrdyApp compile and render
    await tester.pumpWidget(
      const ProviderScope(child: BrdyApp()),
    );
    // App should show something (splash or setup)
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

This replaces the broken `MyApp` test. More targeted Setup screen tests are deferred — nyquist_validation is disabled.

---

## Project Constraints (from CLAUDE.md)

The following directives from CLAUDE.md are mandatory and override any research recommendation:

| Directive | Impact on Phase 1 |
|-----------|-------------------|
| Use `@riverpod` code-gen throughout — never hand-write Provider boilerplate | Every provider uses `@riverpod` or `@Riverpod(keepAlive:true)` |
| `appDatabaseProvider`, `hivePlayerPrefsProvider`, `hiveCourseBoxProvider`, `dioProvider`, `golfCourseApiProvider`, all repository providers, `activeRoundIdProvider`, `activeHoleIndexProvider` MUST be `@Riverpod(keepAlive:true)` | See provider list in Technical Approach §3 |
| `context.go()` not `context.push()` for main screen transitions | GoRouter redirect and START ROUND button must use `context.go()` |
| Write-through to Drift on every data entry — never batch | `createRound()` writes immediately; UI updates optimistically |
| Round data ONLY in Drift, not Hive (Hive is not transactional) | Only course prefs and course cache go in Hive |
| Every Table class change bumps `schemaVersion` and adds `onUpgrade` | MigrationStrategy boilerplate must exist at v1 even with empty onUpgrade |
| Commit `drift_schemas/` JSON for every schema version | Wave 1 includes running `drift_dev schema dump` |
| Run `dart run build_runner build --delete-conflicting-outputs` after every schema change | Required after each Wave |
| Brutalist design — all design values are LOCKED in CLAUDE.md and UI-SPEC | All colors, fonts, spacing from UI-SPEC only — no derivation |
| API key via `--dart-define=GOLF_API_KEY=<value>` — never hardcode | `String.fromEnvironment('GOLF_API_KEY')` in `AppConstants.golfApiKey` |
| Local-only — no backend, auth, cloud | No network calls except golfcourseapi.com |
| Don't start GPS/map loading before score buttons appear | Not applicable to Phase 1 (GPS/maps are Phase 5) |
| `flutter_map_tile_caching` must be initialized in `main()` before `runApp` | Wave 2, Step 10 |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | golfcourseapi.com search endpoint is `GET /search?search_query=<name>` | Technical Approach §5 | Retrofit interface won't compile; must be corrected before Wave 3 |
| A2 | Course detail endpoint is `GET /courses/{id}` | Technical Approach §5 | Same as A1 |
| A3 | Response includes `stroke_index` per hole | Technical Approach §7 | Phase 2 pickup scoring requires SI; workaround needed if absent |
| A4 | Response field names use snake_case (`course_rating`, `slope_rating`) | Technical Approach §7 | Freezed `fromJson` field mapping will fail silently |
| A5 | FMTC v9 store creation via `FMTCStore('brdy_tiles').manage.create()` is idempotent | Technical Approach §6 | App crashes on every relaunch after first install |
| A6 | GoRouter redirect callback can call `ref.read(appStartupProvider)` synchronously | Technical Approach §4 | Redirect never fires; user always sees splash |
| A7 | `_RouterListenable` ChangeNotifier bridge is needed for `refreshListenable` | Technical Approach §4 | GoRouter does not re-evaluate redirect when startup resolves |
| A8 | Free tier API rate limit is 300 requests/day | Technical Approach §5 | Rate limit errors in production during heavy course search use |

**Verification priority for A1–A4:** Make a single authenticated API call in Wave 1 exploration before writing DTO code. Log the raw JSON. Adjust DTOs to match actual field names.

---

## Open Questions (RESOLVED)

1. **Does golfcourseapi.com return Stroke Index per hole?** (STATE.md blocker)
   - What we know: FEATURES.md reports "it does in standard golfcourseapi.com response schema" [ASSUMED]
   - What's unclear: Actual field name, format (1–18 ranking or different scale), whether all courses have SI data
   - Recommendation: Make a test API call in Wave 1; verify before writing DTOs
   - **RESOLVED:** Plan 01-03 Task 1 includes a mandatory live API verification step that logs the raw JSON response and confirms the `stroke_index` field name and shape before any DTO code is written. If absent, a workaround is documented in SUMMARY.md before Phase 2 starts.

2. **What is the exact FMTC v9 idempotent store creation API?**
   - What we know: `FMTCStore('brdy_tiles').manage.create()` from v9 docs; may throw if store exists
   - What's unclear: Whether v9 has `createOrGet()`-style method or if `create()` is idempotent
   - Recommendation: Read `FMTCStore.manage` API in v9 dartdoc before implementing main()
   - **RESOLVED:** Plan 01-02 Task 2 wraps FMTC store creation in a try/catch (per P-03) to handle already-exists exceptions on repeat launches. If v9 exposes a `createOrGet`-style method, the executor should prefer it; otherwise the try/catch pattern is sufficient.

3. **Exact syntax for `ref.read()` inside GoRouter `redirect` callback**
   - What we know: Router is a Riverpod provider; `ref` is available in the provider factory
   - What's unclear: Whether `ref.read()` inside a sync GoRouter redirect works correctly when called after build
   - Recommendation: Test the pattern in isolation before full implementation
   - **RESOLVED (medium confidence):** The `_RouterListenable` ChangeNotifier bridge pattern (Plan 01-01 Task 2) calls `ref.read(appStartupProvider)` inside the GoRouter `redirect` callback via the Riverpod provider factory's captured `ref`. Plan 01-01 Task 2 includes a smoke-test verifying the redirect fires correctly on startup; any runtime issue surfaces immediately in Wave 1.

---

## Environment Availability

| Dependency | Required By | Available | Notes |
|------------|-------------|-----------|-------|
| Flutter SDK | All | Yes — project builds | flutter 3.24.5 per STACK.md |
| Dart SDK ≥3.3 | Code-gen annotations | Yes — sdk: >=3.3.0 in pubspec | |
| `dart run build_runner` | Drift, Riverpod, Retrofit, Freezed codegen | Yes — in dev deps | |
| `drift_dev schema dump` | drift_schemas/ generation | Yes — drift_dev in dev deps | |
| golfcourseapi.com API key | SETUP-02, SETUP-03, FOUND-04 | Unknown — requires `--dart-define` | Must be provided at build time |
| SQLite (runtime) | Drift | Yes — sqlite3_flutter_libs in deps | |
| ObjectBox (FMTC backend) | FMTC tile caching | Yes — bundled with flutter_map_tile_caching | |

**Missing dependencies with no fallback:** API key must be provided via `--dart-define=GOLF_API_KEY=<value>`. Without it, SETUP-02 and SETUP-03 cannot be manually verified (FOUND-04 test requires it to be absent). Request key from `golfcourseapi.com` before executing Wave 3.

---

## Sources

### Primary (HIGH confidence)
- `pubspec.yaml` — exact dependency versions confirmed in codebase
- `CLAUDE.md` — architecture rules, keepAlive rules, navigation model, Drift schema rules
- `.planning/codebase/STACK.md` — package versions, patterns
- `.planning/codebase/ARCHITECTURE.md` — layer boundaries, component map
- `.planning/codebase/CONVENTIONS.md` — naming, file organization
- `.planning/codebase/CONCERNS.md` — Hive TypeAdapter risk, FMTC dead dependency
- `.planning/research/PITFALLS.md` — migration pitfalls (P-09, P-11, P-13, P-15)
- `.planning/phase-01/01-CONTEXT.md` — locked decisions D-01 through D-13
- `.planning/phase-01/01-UI-SPEC.md` — all visual/interaction values (locked)
- `drift.simonbinder.eu/migrations/` — MigrationStrategy, onCreate, onUpgrade, drift_schemas/
- `pub.dev/packages/flutter_map_tile_caching/versions/9.1.4/example` — FMTC v9 main() initialization
- `fmtc.jaffaketchup.dev/usage/bulk-downloading` — RectangleRegion, toDownloadable(), startForeground()
- `fmtc.jaffaketchup.dev/get-started/quickstart` — FMTCObjectBoxBackend, FMTCStore, FMTCTileProvider

### Secondary (MEDIUM confidence)
- `.planning/research/FEATURES.md` — Stroke Index claim; stat definitions
- `.planning/research/STACK.md` — Riverpod patterns, Drift schema design, Retrofit gotchas
- Community sources on GoRouter + Riverpod refreshListenable pattern (multiple Medium articles)

### Tertiary (LOW / ASSUMED)
- golfcourseapi.com API endpoint paths and response schema — not publicly documented without auth
- FMTC v9 idempotent store creation behavior
- Exact `ref.read()` syntax inside GoRouter redirect callback

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages verified in pubspec.yaml; versions confirmed
- Drift schema: HIGH — official docs verified
- FMTC initialization: HIGH — v9.1.4 example verified; download API verified from official docs
- FMTC store creation idempotency: LOW — [ASSUMED] until v9 dartdoc checked
- GoRouter+Riverpod redirect pattern: MEDIUM — pattern confirmed; exact syntax [ASSUMED]
- Golf Course API endpoints: LOW — [ASSUMED]; must verify with live call in Wave 1
- Architecture patterns: HIGH — derived from locked CLAUDE.md + CONTEXT.md decisions

**Research date:** 2026-05-16
**Valid until:** 2026-06-16 (stable packages; 30-day window)
