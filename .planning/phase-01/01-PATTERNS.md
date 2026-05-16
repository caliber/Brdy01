# Phase 1: Foundation + Setup — Pattern Map

**Mapped:** 2026-05-16
**Files analyzed:** 38 new/modified files
**Analogs found:** 6 / 38 (codebase is a scaffold — most patterns come from RESEARCH.md verified code)

---

## Analog Coverage Note

The codebase has 6 source files (all scaffolds). No providers, DAOs, Drift tables, Retrofit clients, Freezed models, or theme files exist yet. The 6 existing files ARE the analogs for their own update targets; all new-file patterns are drawn from RESEARCH.md code excerpts (which were verified against official docs and package versions confirmed in pubspec.yaml). Every RESEARCH.md excerpt is marked with its confidence level.

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/main.dart` | config/bootstrap | request-response | `lib/main.dart` (self) | exact |
| `lib/app/app.dart` | config/app shell | request-response | `lib/app/app.dart` (self) | exact |
| `lib/app/constants.dart` | config/constants | — | `lib/app/constants.dart` (self) | exact |
| `lib/app/router.dart` | config/routing | request-response | `lib/app/app.dart` (ConsumerWidget pattern) | role-match |
| `lib/theme/brdy_colors.dart` | utility/constants | — | `lib/app/constants.dart` (abstract class constants pattern) | role-match |
| `lib/theme/brdy_spacing.dart` | utility/constants | — | `lib/app/constants.dart` (abstract class constants pattern) | role-match |
| `lib/theme/brdy_text_theme.dart` | utility/constants | — | `lib/app/constants.dart` (abstract class constants pattern) | role-match |
| `lib/theme/brdy_theme.dart` | utility/factory | — | `lib/app/app.dart` (ThemeData usage) | partial |
| `lib/domain/models/course_model.dart` | model | transform | RESEARCH.md §8 | no codebase analog |
| `lib/domain/models/hole_model.dart` | model | transform | RESEARCH.md §8 | no codebase analog |
| `lib/domain/models/round_model.dart` | model | transform | RESEARCH.md §8 | no codebase analog |
| `lib/domain/enums/hole_outcome.dart` | model/enum | — | RESEARCH.md §8 | no codebase analog |
| `lib/domain/repositories/course_repository.dart` | service/interface | CRUD | RESEARCH.md §3 | no codebase analog |
| `lib/domain/repositories/round_repository.dart` | service/interface | CRUD | RESEARCH.md §3 | no codebase analog |
| `lib/data/local/database/tables/rounds_table.dart` | model/schema | CRUD | RESEARCH.md §1 | no codebase analog |
| `lib/data/local/database/tables/holes_table.dart` | model/schema | CRUD | RESEARCH.md §1 | no codebase analog |
| `lib/data/local/database/tables/shots_table.dart` | model/schema | CRUD | RESEARCH.md §1 | no codebase analog |
| `lib/data/local/database/app_database.dart` | service/database | CRUD | RESEARCH.md §1 | no codebase analog |
| `lib/data/local/database/daos/round_dao.dart` | service/DAO | CRUD | RESEARCH.md §1 | no codebase analog |
| `lib/data/local/database/daos/hole_dao.dart` | service/DAO | CRUD | RESEARCH.md §1 | no codebase analog |
| `lib/data/local/preferences/hive_player_prefs.dart` | service/store | CRUD | RESEARCH.md §2 | no codebase analog |
| `lib/data/local/preferences/hive_course_box.dart` | service/store | CRUD | RESEARCH.md §2 | no codebase analog |
| `lib/data/remote/api/golf_course_api.dart` | service/HTTP client | request-response | RESEARCH.md §5 | no codebase analog |
| `lib/data/remote/api/interceptors/auth_interceptor.dart` | middleware | request-response | RESEARCH.md §5 | no codebase analog |
| `lib/data/remote/dto/course_search_response_dto.dart` | model/DTO | transform | RESEARCH.md §7 | no codebase analog |
| `lib/data/remote/dto/course_detail_response_dto.dart` | model/DTO | transform | RESEARCH.md §7 | no codebase analog |
| `lib/infrastructure/repositories/course_repository_impl.dart` | service/impl | CRUD | RESEARCH.md §3 | no codebase analog |
| `lib/infrastructure/repositories/round_repository_impl.dart` | service/impl | CRUD | RESEARCH.md §1 | no codebase analog |
| `lib/features/setup/providers/app_startup_provider.dart` | provider | request-response | RESEARCH.md §3+4 | no codebase analog |
| `lib/features/setup/providers/active_round_id_provider.dart` | provider/state | — | RESEARCH.md §3 | no codebase analog |
| `lib/features/setup/providers/course_search_query_provider.dart` | provider/state | event-driven | RESEARCH.md §3 | no codebase analog |
| `lib/features/setup/providers/course_search_results_provider.dart` | provider | request-response | RESEARCH.md §3 | no codebase analog |
| `lib/features/setup/providers/selected_course_provider.dart` | provider/state | — | RESEARCH.md §3 | no codebase analog |
| `lib/features/setup/providers/round_setup_notifier.dart` | provider/notifier | CRUD | RESEARCH.md §3 | no codebase analog |
| `lib/features/setup/setup_screen.dart` | component/screen | request-response | `lib/features/setup/setup_screen.dart` (self) + `lib/app/app.dart` (ConsumerWidget) | partial |
| `lib/features/setup/widgets/handicap_input.dart` | component/widget | request-response | `lib/features/setup/setup_screen.dart` (StatelessWidget shell) | partial |
| `lib/features/setup/widgets/course_search_field.dart` | component/widget | event-driven | `lib/features/setup/setup_screen.dart` (StatelessWidget shell) | partial |
| `lib/features/setup/widgets/course_result_tile.dart` | component/widget | request-response | `lib/features/setup/setup_screen.dart` (StatelessWidget shell) | partial |
| `lib/features/setup/widgets/course_card.dart` | component/widget | request-response | `lib/features/setup/setup_screen.dart` (StatelessWidget shell) | partial |
| `lib/features/setup/widgets/missing_rating_banner.dart` | component/widget | — | `lib/features/setup/setup_screen.dart` (StatelessWidget shell) | partial |
| `lib/features/splash/splash_screen.dart` | component/screen | — | `lib/features/setup/setup_screen.dart` (StatelessWidget shell) | role-match |
| `lib/features/shot_capture/shot_capture_screen.dart` | component/screen | request-response | `lib/features/shot_capture/shot_capture_screen.dart` (self) | exact |
| `test/widget_test.dart` | test | — | `test/widget_test.dart` (self) | exact |

---

## Pattern Assignments

### `lib/main.dart` (config/bootstrap — UPDATE)

**Analog:** `lib/main.dart` (lines 1–17 — full file, already read)

**Existing pattern** (lines 1–17):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'app/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.playerPrefsBox);
  await Hive.openBox(AppConstants.courseCacheBox);
  runApp(
    const ProviderScope(
      child: BrdyApp(),
    ),
  );
}
```

**What to add — FMTC init (D-07, RESEARCH.md §6 — confidence HIGH):**
Insert after `openBox` calls, before `runApp`:
```dart
// FMTC must initialize before runApp (D-07)
try {
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore(AppConstants.tileCacheStoreName).manage.create();
} catch (e) {
  // P-03: store may already exist on re-launch — non-blocking
  Logger().w('FMTC init: $e');
}
```

Add import: `import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';`

---

### `lib/app/app.dart` (config/app shell — UPDATE)

**Analog:** `lib/app/app.dart` (lines 1–19 — full file, already read)

**Existing pattern** (lines 1–19):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/setup/setup_screen.dart';

class BrdyApp extends ConsumerWidget {
  const BrdyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BRDY.01',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFE8520A)),
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}
```

**What to replace** — swap `MaterialApp(home:)` for `MaterialApp.router` and wire `BrdyTheme`:
```dart
// Remove: import '../features/setup/setup_screen.dart';
// Add:
import '../app/router.dart';
import '../theme/brdy_theme.dart';

class BrdyApp extends ConsumerWidget {
  const BrdyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'BRDY.01',
      theme: BrdyTheme.themeData,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
```

**ConsumerWidget pattern** — `BrdyApp extends ConsumerWidget` with `(BuildContext context, WidgetRef ref)` signature is the established pattern. All screens that read providers must follow the same signature.

---

### `lib/app/constants.dart` (config/constants — UPDATE)

**Analog:** `lib/app/constants.dart` (lines 1–9 — full file, already read)

**Existing pattern** (lines 1–9):
```dart
abstract class AppConstants {
  static const String golfApiBaseUrl = 'https://api.golfcourseapi.com/v1';
  static const String golfApiKey = String.fromEnvironment('GOLF_API_KEY');
  static const String playerPrefsBox = 'player_prefs';
  static const String courseCacheBox  = 'course_cache';
  static const int maxRoundHoles = 18;
  static const int whsDifferentialsToStore = 20;
  static const int whsBestDifferentials = 8;
}
```

**Add one constant (D-07, RESEARCH.md §6):**
```dart
static const String tileCacheStoreName = 'brdy_tiles';
```

**Convention:** `abstract class` with `static const` members, `camelCase` names. Never top-level constants.

---

### `lib/app/router.dart` (config/routing — CREATE)

**Analog:** `lib/app/app.dart` for ConsumerWidget/provider pattern + RESEARCH.md §4 for GoRouter structure.

**Imports pattern** (from RESEARCH.md §4 — confidence HIGH):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/setup/setup_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/shot_capture/shot_capture_screen.dart';
import '../features/round_review/round_review_screen.dart';
import '../features/setup/providers/app_startup_provider.dart';
import '../features/setup/providers/active_round_id_provider.dart';

part 'router.g.dart';
```

**keepAlive provider pattern** (RESEARCH.md §3 — confidence HIGH):
```dart
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final notifier = _RouterListenable(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final startupState = ref.read(appStartupProvider);
      return startupState.when(
        loading: () => '/splash',
        error: (_, __) => '/setup',
        data: (incompleteRoundId) {
          if (incompleteRoundId != null) {
            ref.read(activeRoundIdProvider.notifier).set(incompleteRoundId);
            return '/shot-capture/$incompleteRoundId';
          }
          if (state.uri.path == '/splash') return '/setup';
          return null;
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

**_RouterListenable bridge pattern** (RESEARCH.md §4 / Pitfall P-04 — confidence MEDIUM):
```dart
class _RouterListenable extends ChangeNotifier {
  _RouterListenable(Ref ref) {
    ref.listen(appStartupProvider, (_, __) => notifyListeners());
  }
}
```

**Navigation rule:** All main screen transitions use `context.go()`, NEVER `context.push()`. CLAUDE.md Critical Don'ts.

---

### `lib/theme/brdy_colors.dart` (utility/constants — CREATE)

**Analog:** `lib/app/constants.dart` — `abstract class` with `static const` pattern.

**Full pattern** (from UI-SPEC §Color Tokens — all values locked):
```dart
import 'package:flutter/material.dart';

abstract final class BrdyColors {
  static const Color background     = Color(0xFF0A0A0A);
  static const Color surface        = Color(0xFF1A1A1A);
  static const Color onSurface      = Color(0xFFF0F0F0);
  static const Color onSurfaceMuted = Color(0xFFA0A0A0);
  static const Color accent         = Color(0xFFE8520A);
  static const Color onAccent       = Color(0xFF0A0A0A);
  static const Color destructive    = Color(0xFFCC2200);
  static const Color onDestructive  = Color(0xFFF0F0F0);
  static const Color divider        = Color(0xFF2A2A2A);
}
```

**Convention:** `abstract final class` (cannot be instantiated or extended), `static const Color`, no methods.

---

### `lib/theme/brdy_spacing.dart` (utility/constants — CREATE)

**Analog:** `lib/app/constants.dart` — `abstract class` with `static const` pattern.

**Full pattern** (from UI-SPEC §Spacing Scale — all values locked):
```dart
abstract final class BrdySpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double x2l = 48.0;
  static const double x3l = 64.0;  // reserved for Phase 2 score buttons
}
```

---

### `lib/theme/brdy_text_theme.dart` (utility/factory — CREATE)

**Analog:** `lib/app/constants.dart` for class structure; `lib/app/app.dart` for ThemeData style.

**Full pattern** (from UI-SPEC §Typography — all values locked):
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class BrdyTextTheme {
  static TextTheme get textTheme => TextTheme(
    displaySmall: _jetBrains(28, FontWeight.w700, 1.2),  // displayNumeric
    bodyMedium:   _jetBrains(16, FontWeight.w400, 1.5),  // bodyNumeric
    labelLarge:   _barlow(18, FontWeight.w700, 1.2),     // buttons, section headings
    bodySmall:    _barlow(14, FontWeight.w400, 1.5),     // labels, helper text
  );

  static TextStyle _jetBrains(double size, FontWeight weight, double height) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, height: height);

  static TextStyle _barlow(double size, FontWeight weight, double height) =>
      GoogleFonts.barlowCondensed(fontSize: size, fontWeight: weight, height: height);
}
```

---

### `lib/theme/brdy_theme.dart` (utility/factory — CREATE)

**Analog:** `lib/app/app.dart` (existing ThemeData construction) + `lib/theme/brdy_colors.dart`.

**Full pattern** (from UI-SPEC §ThemeData Bootstrap — all values locked):
```dart
import 'package:flutter/material.dart';
import 'brdy_colors.dart';
import 'brdy_text_theme.dart';

abstract final class BrdyTheme {
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: BrdyColors.background,
    colorScheme: const ColorScheme.dark(
      surface: BrdyColors.surface,
      primary: BrdyColors.accent,
      onPrimary: BrdyColors.onAccent,
      secondary: BrdyColors.surface,
      onSecondary: BrdyColors.onSurface,
      error: BrdyColors.destructive,
      onError: BrdyColors.onDestructive,
    ),
    textTheme: BrdyTextTheme.textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BrdyColors.accent,
        foregroundColor: BrdyColors.onAccent,
        minimumSize: const Size(double.infinity, 56),
        shape: const RoundedRectangleBorder(),  // 0dp radius — brutalist
        textStyle: BrdyTextTheme.textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BrdyColors.surface,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,  // 0dp radius — brutalist
        borderSide: BorderSide(color: BrdyColors.divider, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: BrdyColors.accent, width: 2),
      ),
    ),
  );
}
```

---

### `lib/domain/models/course_model.dart` (model — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §8 (confidence HIGH).

**Imports pattern:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'hole_model.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';
```

**Core Freezed pattern** (RESEARCH.md §8):
```dart
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
```

**Rule:** Every Freezed model file needs BOTH `part` directives: `part 'x.freezed.dart'` AND `part 'x.g.dart'` (for json_serializable). Run build_runner after creating.

---

### `lib/domain/models/hole_model.dart` (model — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §8 (confidence HIGH).

**Core Freezed pattern:**
```dart
@freezed
class HoleModel with _$HoleModel {
  const factory HoleModel({
    required int holeNumber,
    required int par,
    int? strokeIndex,   // D-06: nullable
    double? teeLat,     // D-06: nullable GPS
    double? teeLng,
    double? greenLat,
    double? greenLng,
  }) = _HoleModel;

  factory HoleModel.fromJson(Map<String, dynamic> json) =>
      _$HoleModelFromJson(json);
}
```

---

### `lib/domain/models/round_model.dart` (model — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §8 (confidence HIGH).

**Core Freezed pattern:**
```dart
@freezed
class RoundModel with _$RoundModel {
  const factory RoundModel({
    required int id,
    required String courseName,
    double? courseRating,
    int? slope,
    required double handicapIndex,
    required DateTime startedAt,
    DateTime? completedAt,    // null = round in progress
  }) = _RoundModel;

  factory RoundModel.fromJson(Map<String, dynamic> json) =>
      _$RoundModelFromJson(json);
}
```

---

### `lib/domain/enums/hole_outcome.dart` (model/enum — CREATE)

**Pitfall P-01:** `double` is a reserved Dart keyword. Use `doubleBogey`.

```dart
enum HoleOutcome {
  eagle,
  birdie,
  par,
  bogey,
  doubleBogey,   // P-01: persisted as string 'double' in Drift/JSON
  pickup,
}
```

---

### `lib/domain/repositories/course_repository.dart` (service/interface — CREATE)

**No codebase analog.** Abstract repository pattern from ARCHITECTURE.md + RESEARCH.md §3.

```dart
import '../models/course_model.dart';

abstract class CourseRepository {
  Future<List<CourseModel>> searchCourses(String query);
  Future<CourseModel> getCourseDetail(String id);
  CourseModel? getCachedCourse(String id);
  void cacheCourse(CourseModel course);
}
```

---

### `lib/domain/repositories/round_repository.dart` (service/interface — CREATE)

**No codebase analog.** Abstract repository pattern.

```dart
import '../models/round_model.dart';

abstract class RoundRepository {
  Future<int> createRound({
    required String courseName,
    required double handicapIndex,
    double? courseRating,
    int? slope,
    required String courseJson,
  });
  Future<int?> findIncompleteRoundId();
  Future<RoundModel?> getRound(int id);
  Future<void> completeRound(int id);
}
```

---

### Drift Tables: `rounds_table.dart`, `holes_table.dart`, `shots_table.dart` (model/schema — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §1 (verified against drift.simonbinder.eu — confidence HIGH).

**Table class pattern** (RESEARCH.md §1):
```dart
import 'package:drift/drift.dart';

class Rounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get courseName => text()();
  RealColumn get courseRating => real().nullable()();
  IntColumn get courseSlope => integer().nullable()();
  RealColumn get handicapIndex => real()();
  TextColumn get courseJson => text()();        // Hive-cached course snapshot (D-05)
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()(); // null = in progress
}
```

```dart
class Holes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  IntColumn get holeNumber => integer()();    // 1–18
  IntColumn get par => integer()();
  IntColumn get strokeIndex => integer().nullable()();
  TextColumn get outcome => text().nullable()(); // 'eagle','birdie','par','bogey','double','pickup'
  IntColumn get putts => integer().nullable()();
  BoolColumn get fairwayHit => boolean().nullable()(); // null = par 3
  BoolColumn get greenInRegulation => boolean().nullable()();
  DateTimeColumn get recordedAt => dateTime().nullable()();
}
```

```dart
class Shots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get holeId => integer().references(Holes, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get shotNumber => integer()();
  DateTimeColumn get recordedAt => dateTime()();
}
```

---

### `lib/data/local/database/app_database.dart` (service/database — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §1 (confidence HIGH).

**Imports pattern:**
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/rounds_table.dart';
import 'tables/holes_table.dart';
import 'tables/shots_table.dart';
import 'daos/round_dao.dart';
import 'daos/hole_dao.dart';

part 'app_database.g.dart';
```

**Core Drift database pattern** (RESEARCH.md §1):
```dart
@DriftDatabase(tables: [Rounds, Holes, Shots], daos: [RoundDao, HoleDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'brdy.sqlite'));
    return NativeDatabase(file);
  });
}
```

---

### `lib/data/local/database/daos/round_dao.dart` (service/DAO — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §1 (confidence HIGH).

**DAO pattern:**
```dart
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'round_dao.g.dart';

@DriftAccessor(tables: [Rounds])
class RoundDao extends DatabaseAccessor<AppDatabase> with _$RoundDaoMixin {
  RoundDao(super.db);

  Future<int> insertRound(RoundsCompanion round) =>
      into(rounds).insert(round);

  // For appStartupProvider (FOUND-02)
  Future<int?> findIncompleteRoundId() async {
    final row = await (select(rounds)
          ..where((r) => r.completedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }

  Future<Round?> getRoundById(int id) =>
      (select(rounds)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<void> completeRound(int id, DateTime completedAt) =>
      (update(rounds)..where((r) => r.id.equals(id))).write(
        RoundsCompanion(completedAt: Value(completedAt)),
      );
}
```

---

### `lib/data/local/preferences/hive_player_prefs.dart` (service/store — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §2 (confidence HIGH) + `AppConstants` box names.

```dart
import 'package:hive/hive.dart';

class HivePlayerPrefs {
  final Box _box;
  HivePlayerPrefs(this._box);

  static const _keyHandicapIndex = 'handicap_index';
  static const _keyLastUsedCourseId = 'last_used_course_id';

  double? get handicapIndex => _box.get(_keyHandicapIndex) as double?;
  void setHandicapIndex(double value) => _box.put(_keyHandicapIndex, value);

  String? get lastUsedCourseId => _box.get(_keyLastUsedCourseId) as String?;
  void setLastUsedCourseId(String id) => _box.put(_keyLastUsedCourseId, id);
}
```

---

### `lib/data/local/preferences/hive_course_box.dart` (service/store — CREATE)

**No codebase analog.** D-05: JSON string only — no TypeAdapter. Pattern from RESEARCH.md §2 (confidence HIGH).

```dart
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/models/course_model.dart';

class HiveCourseBox {
  final Box _box;
  HiveCourseBox(this._box);

  // D-05: Store as JSON string — never store CourseModel directly (P-06)
  void writeCourse(String courseId, CourseModel course) =>
      _box.put(courseId, jsonEncode(course.toJson()));

  CourseModel? readCourse(String courseId) {
    final raw = _box.get(courseId) as String?;
    if (raw == null) return null;
    return CourseModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
```

---

### `lib/data/remote/api/golf_course_api.dart` (service/HTTP client — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §5 (confidence HIGH for Retrofit structure; MEDIUM for endpoint paths — [ASSUMED]).

**Imports + Retrofit pattern** (RESEARCH.md §5 — Pitfall P-10: `part` directive is mandatory):
```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dto/course_search_response_dto.dart';
import '../dto/course_detail_response_dto.dart';

part 'golf_course_api.g.dart';

@RestApi()
abstract class GolfCourseApi {
  factory GolfCourseApi(Dio dio, {String baseUrl}) = _GolfCourseApi;

  @GET('/search')
  Future<CourseSearchResponseDto> searchCourses(
    @Query('search_query') String query,
  );

  @GET('/courses/{id}')
  Future<CourseDetailResponseDto> getCourseDetail(
    @Path('id') String id,
  );
}
```

**CRITICAL GATE (from RESEARCH.md):** Verify `stroke_index` field name and endpoint paths with a live API call before finalizing DTOs.

---

### `lib/data/remote/api/interceptors/auth_interceptor.dart` (middleware — CREATE)

**No codebase analog.** Pattern from RESEARCH.md §5 (confidence HIGH).

```dart
import 'package:dio/dio.dart';
import '../../../app/constants.dart';

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

---

### DTOs: `course_search_response_dto.dart`, `course_detail_response_dto.dart` (model/DTO — CREATE)

**No codebase analog.** Freezed + json_serializable pattern. Same structure as domain models but maps to API JSON shapes. Field names [ASSUMED] from RESEARCH.md §7.

```dart
// course_search_response_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_search_response_dto.freezed.dart';
part 'course_search_response_dto.g.dart';

@freezed
class CourseSearchResponseDto with _$CourseSearchResponseDto {
  const factory CourseSearchResponseDto({
    required List<CourseSearchResultDto> courses,
  }) = _CourseSearchResponseDto;

  factory CourseSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CourseSearchResponseDtoFromJson(json);
}

@freezed
class CourseSearchResultDto with _$CourseSearchResultDto {
  const factory CourseSearchResultDto({
    required String id,
    @JsonKey(name: 'club_name') required String clubName,
    @JsonKey(name: 'course_name') required String courseName,
    @JsonKey(name: 'course_rating') double? courseRating,
    @JsonKey(name: 'slope_rating') int? slopeRating,
    required int par,
    required LocationDto location,
  }) = _CourseSearchResultDto;

  factory CourseSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$CourseSearchResultDtoFromJson(json);
}
```

**Note:** `@JsonKey(name: 'snake_case_field')` is required wherever the API uses snake_case and Dart uses camelCase.

---

### Riverpod Providers: keepAlive infrastructure (CREATE)

**No codebase analog.** Pattern from RESEARCH.md §3 (confidence HIGH) + CLAUDE.md keepAlive rules.

**Pattern for ALL keepAlive infrastructure providers:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider_name.g.dart';

@Riverpod(keepAlive: true)
ProviderType providerName(Ref ref) {
  // inject dependencies via ref.watch(otherProvider)
  return ProviderType(...);
}
```

**Specific provider implementations:**

`app_database_provider.dart`:
```dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();
```

`hive_player_prefs_provider.dart`:
```dart
@Riverpod(keepAlive: true)
HivePlayerPrefs hivePlayerPrefs(Ref ref) =>
    HivePlayerPrefs(Hive.box(AppConstants.playerPrefsBox));
```

`hive_course_box_provider.dart`:
```dart
@Riverpod(keepAlive: true)
HiveCourseBox hiveCourseBox(Ref ref) =>
    HiveCourseBox(Hive.box(AppConstants.courseCacheBox));
```

`dio_provider.dart`:
```dart
@Riverpod(keepAlive: true)
Dio dio(Ref ref) => Dio(BaseOptions(
  baseUrl: AppConstants.golfApiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  headers: {'Authorization': 'Key ${AppConstants.golfApiKey}'},
))..interceptors.add(AuthInterceptor());
```

`golf_course_api_provider.dart`:
```dart
@Riverpod(keepAlive: true)
GolfCourseApi golfCourseApi(Ref ref) =>
    GolfCourseApi(ref.watch(dioProvider));
```

`active_round_id_provider.dart` (keepAlive Notifier):
```dart
@Riverpod(keepAlive: true)
class ActiveRoundId extends _$ActiveRoundId {
  @override
  int? build() => null;
  void set(int id) => state = id;
  void clear() => state = null;
}
```

---

### `lib/features/setup/providers/app_startup_provider.dart` (provider — CREATE)

**No codebase analog.** Auto-dispose FutureProvider pattern from RESEARCH.md §3 (confidence HIGH).

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_startup_provider.g.dart';

// Auto-dispose: runs once on startup; router redirect consumes it then discards
@riverpod
Future<int?> appStartup(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.roundDao.findIncompleteRoundId();
}
```

---

### `lib/features/setup/providers/round_setup_notifier.dart` (provider/notifier — CREATE)

**No codebase analog.** AsyncNotifier pattern from RESEARCH.md §3 (confidence HIGH).

```dart
@riverpod
class RoundSetupNotifier extends _$RoundSetupNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<int> createRound(CourseModel course, double handicapIndex) async {
    state = const AsyncLoading();
    try {
      final db = ref.read(appDatabaseProvider);
      final roundId = await db.roundDao.insertRound(RoundsCompanion(
        courseName: Value(course.clubName),
        courseRating: Value(course.courseRating),
        courseSlope: Value(course.slope),
        handicapIndex: Value(handicapIndex),
        courseJson: Value(jsonEncode(course.toJson())),
        startedAt: Value(DateTime.now()),
      ));
      ref.read(activeRoundIdProvider.notifier).set(roundId);
      state = const AsyncData(null);
      return roundId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
```

---

### `lib/features/setup/providers/course_search_results_provider.dart` (provider — CREATE)

**No codebase analog.** Debounced FutureProvider pattern from RESEARCH.md §3 (confidence HIGH) + UI-SPEC §2 (400ms debounce, min 2 chars).

```dart
@riverpod
Future<List<CourseSearchResultDto>> courseSearchResults(Ref ref) async {
  final query = ref.watch(courseSearchQueryProvider);
  if (query.length < 2) return [];

  // 400ms debounce (UI-SPEC §2)
  await Future.delayed(const Duration(milliseconds: 400));
  ref.keepAlive();  // cancel keepAlive if query changes before 400ms

  final api = ref.watch(golfCourseApiProvider);
  final response = await api.searchCourses(query);
  return response.courses;
}
```

---

### Setup Screen Widgets (component/widget — CREATE)

**Analog:** `lib/features/setup/setup_screen.dart` (StatelessWidget shell — lines 1–12) + `lib/app/app.dart` (ConsumerWidget pattern for provider-consuming widgets).

**StatelessWidget pattern** (existing setup_screen.dart):
```dart
import 'package:flutter/material.dart';

class WidgetName extends StatelessWidget {
  const WidgetName({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(...);
  }
}
```

**ConsumerWidget pattern** (for widgets that read providers — from app.dart):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WidgetName extends ConsumerWidget {
  const WidgetName({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() for reactive state
    // ref.read() for one-off reads in callbacks
  }
}
```

**Tap target rule (UI-SPEC §Accessibility):** All interactive elements minimum 48dp height. Score buttons (Phase 2) use 64×80dp.

**InkWell ripple color (UI-SPEC §Interaction States):**
```dart
splashColor: Colors.white.withOpacity(0.08),
highlightColor: Colors.white.withOpacity(0.04),
```

**Animation pattern (flutter_animate — UI-SPEC §Animation):**
```dart
Widget.animate().fadeIn(duration: 200.ms, curve: Curves.easeOut)
Widget.animate().slideY(begin: 0.1, end: 0, duration: 200.ms, curve: Curves.easeOut)
```

---

### `lib/features/setup/setup_screen.dart` (component/screen — REPLACE)

**Analog:** `lib/features/setup/setup_screen.dart` (self — current StatelessWidget shell) + `lib/app/app.dart` (ConsumerWidget).

**Screen must become ConsumerStatefulWidget** (UI-SPEC requires stateful lifecycle for debounce timer):
```dart
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrdyColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md),
          child: Column(
            children: [
              // ... sub-widgets assembled in order from UI-SPEC layout
            ],
          ),
        ),
      ),
    );
  }
}
```

**Navigation** (CLAUDE.md Critical Don'ts — P-11):
```dart
// CORRECT — replaces stack, no back button to setup
context.go('/shot-capture/$roundId');

// WRONG — never use this for main screen transitions
// context.push('/shot-capture/$roundId');
```

**Haptic feedback** (UI-SPEC §Haptic Feedback):
```dart
import 'package:haptic_feedback/haptic_feedback.dart';

// On successful course load:
await HapticFeedback.lightImpact();
// On START ROUND tap:
await HapticFeedback.mediumImpact();
```

---

### `lib/features/splash/splash_screen.dart` (component/screen — CREATE)

**Analog:** `lib/features/setup/setup_screen.dart` (StatelessWidget shell).

**Full implementation** (D-13, UI-SPEC §Crash Recovery, RESEARCH.md §4):
```dart
import 'package:flutter/material.dart';
import '../../theme/brdy_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: BrdyColors.background,  // #0A0A0A
      body: Center(
        child: Text(
          'BRDY.01',
          style: TextStyle(/* labelLarge style — from BrdyTextTheme */),
        ),
      ),
    );
  }
}
```

**No spinner. No animation.** User sees this for ~100ms max while `appStartupProvider` resolves.

---

### `lib/features/shot_capture/shot_capture_screen.dart` (component/screen — UPDATE)

**Analog:** `lib/features/shot_capture/shot_capture_screen.dart` (self — lines 1–14).

**Existing pattern** (lines 1–14 — full file, already read):
```dart
class ShotCaptureScreen extends StatelessWidget {
  final String roundId;    // NOTE: must change to int
  final int holeNumber;
  const ShotCaptureScreen({super.key, required this.roundId, required this.holeNumber});
```

**What to change (P-13):** `roundId` type must be `int` (not `String`) to match GoRouter `int.parse(state.pathParameters['roundId']!)`. Remove `holeNumber` from constructor — it comes from `activeHoleIndexProvider` (internal state, not route param):
```dart
class ShotCaptureScreen extends StatelessWidget {
  final int roundId;
  const ShotCaptureScreen({super.key, required this.roundId});
  // holeNumber is NOT a route param — read from activeHoleIndexProvider
}
```

---

### `test/widget_test.dart` (test — UPDATE)

**Analog:** `test/widget_test.dart` (self — lines 1–30) — must fix broken `MyApp` import (P-12).

**Replacement** (RESEARCH.md §Validation Architecture):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brdy01/app/app.dart';

void main() {
  testWidgets('BrdyApp renders without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BrdyApp()),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

---

## Shared Patterns

### Riverpod Provider Annotation
**Apply to:** All provider files
**Rule:** ALWAYS use `@riverpod` code generation — never hand-write `Provider(...)` boilerplate.

```dart
// keepAlive providers (CLAUDE.md list — all infrastructure providers)
@Riverpod(keepAlive: true)
SomeType providerName(Ref ref) => SomeType(...);

// Auto-dispose providers (screen-level, setup screen providers)
@riverpod
Future<SomeType> providerName(Ref ref) async { ... }

// Notifier (keepAlive — activeRoundId, activeHoleIndex)
@Riverpod(keepAlive: true)
class NotifierName extends _$NotifierName {
  @override
  StateType build() => initialValue;
  void methodName() => state = newValue;
}
```

Every provider file needs: `part 'filename.g.dart';` and a `build_runner` pass after creation.

### Import Order Convention
**Apply to:** All Dart files
**Source:** `lib/main.dart` (lines 1–5) + CONVENTIONS.md

```dart
// 1. dart: SDK imports (if needed)
// 2. package: imports (Flutter, third-party)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 3. Relative local imports
import '../app/constants.dart';
```

No path aliases. No barrel files. Direct relative imports.

### Error Handling with AsyncValue
**Apply to:** All async providers and service calls
**Source:** CONVENTIONS.md + RESEARCH.md §3

```dart
// In UI: consume AsyncValue via .when()
ref.watch(someProvider).when(
  loading: () => const CircularProgressIndicator(),
  error: (e, st) => ErrorWidget(e.toString()),
  data: (value) => SuccessWidget(value),
);

// In notifiers: wrap mutations in try/catch with state transitions
state = const AsyncLoading();
try {
  final result = await someCall();
  state = AsyncData(result);
} catch (e, st) {
  state = AsyncError(e, st);
}
```

### Constants Pattern
**Apply to:** All constant-holder files (theme, config)
**Source:** `lib/app/constants.dart`

```dart
abstract class ClassName {        // abstract: not instantiable
  static const Type name = value; // static const: compile-time
}
// OR for theme classes that cannot be extended:
abstract final class ClassName {
  static const Type name = value;
}
```

### Drift Write-Through Rule
**Apply to:** All DAO calls that modify round/hole/shot data
**Source:** CLAUDE.md Critical Don'ts + FOUND-01

```dart
// WRITE IMMEDIATELY — never buffer or batch
await db.roundDao.insertRound(companion);
// Then update UI state optimistically via provider
```

### Navigation Rule
**Apply to:** All `context.go()` calls in setup screen and router
**Source:** CLAUDE.md Critical Don'ts + P-11

```dart
context.go('/shot-capture/$roundId');    // CORRECT
// context.push('/shot-capture/$roundId'); // NEVER — creates back-stack
```

---

## No Analog Found

Files with no close match in the codebase — planner should use RESEARCH.md patterns:

| File | Role | Data Flow | Reason |
|---|---|---|---|
| All domain models | model | transform | No Freezed models exist in codebase yet |
| All Drift tables/DAOs | model/service | CRUD | No Drift code exists in codebase yet |
| All Hive wrappers | service/store | CRUD | No Hive wrappers exist in codebase yet |
| Retrofit client + DTOs | service/HTTP | request-response | No Retrofit code exists in codebase yet |
| All Riverpod providers | provider | various | No providers exist in codebase yet |
| `app/router.dart` | config/routing | request-response | GoRouter not yet configured |
| All theme files | utility | — | No custom theme files exist yet |
| `infrastructure/repositories/` | service/impl | CRUD | No repository implementations exist yet |
| `features/splash/splash_screen.dart` | component/screen | — | Only 3 feature screens exist; none are splash |

---

## Metadata

**Analog search scope:** `/Users/simonnewland/development/brdy01/lib/` + `/Users/simonnewland/development/brdy01/test/`
**Files scanned:** 7 (6 source + 1 test — entire codebase)
**Pattern extraction date:** 2026-05-16
**Confidence note:** Codebase is a scaffold. All new-file patterns are from RESEARCH.md code excerpts verified against official docs and pubspec versions. High-confidence patterns are safe to copy directly. MEDIUM/LOW items are marked — verify before implementation.
