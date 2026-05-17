# Phase 2: Shot Capture — Pattern Map

**Mapped:** 2026-05-17
**Files analyzed:** 15 new/modified files
**Analogs found:** 15 / 15 (Phase 1 is fully implemented — all patterns draw from real codebase files)

---

## Analog Coverage Note

Phase 1 is complete. The codebase has fully implemented providers, DAOs, screens, widgets, and theme files. Every Phase 2 file has a real codebase analog to copy patterns from. No RESEARCH.md-only patterns are needed — all excerpts below are drawn from actual Phase 1 source files.

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/data/local/database/daos/hole_dao.dart` | service/DAO | CRUD | `lib/data/local/database/daos/round_dao.dart` | exact |
| `lib/features/shot_capture/shot_capture_screen.dart` | component/screen | event-driven | `lib/features/setup/setup_screen.dart` | exact |
| `lib/features/shot_capture/providers/hole_score_notifier.dart` | provider/notifier | CRUD | `lib/features/setup/providers/selected_course_provider.dart` + `round_setup_notifier.dart` | exact |
| `lib/features/shot_capture/providers/hole_list_provider.dart` | provider | streaming | `lib/features/setup/providers/course_search_results_provider.dart` | role-match |
| `lib/features/shot_capture/providers/running_score_provider.dart` | provider | transform | `lib/features/setup/providers/app_startup_provider.dart` | role-match |
| `lib/features/shot_capture/providers/course_for_round_provider.dart` | provider | request-response | `lib/features/setup/providers/app_startup_provider.dart` | exact |
| `lib/features/shot_capture/providers/highest_scored_hole_index_provider.dart` | provider | transform | `lib/features/setup/providers/app_startup_provider.dart` | role-match |
| `lib/features/shot_capture/providers/round_complete_provider.dart` | provider | transform | `lib/features/setup/providers/app_startup_provider.dart` | role-match |
| `lib/features/shot_capture/widgets/outcome_button_grid.dart` | component/widget | event-driven | `lib/features/setup/widgets/course_result_tile.dart` (InkWell+tap) | role-match |
| `lib/features/shot_capture/widgets/hole_header.dart` | component/widget | request-response | `lib/features/setup/widgets/course_card.dart` | role-match |
| `lib/features/shot_capture/widgets/putts_counter.dart` | component/widget | event-driven | `lib/features/setup/widgets/handicap_input.dart` (stateful+increment) | partial |
| `lib/features/shot_capture/widgets/fairway_gir_toggles.dart` | component/widget | event-driven | `lib/features/setup/widgets/course_result_tile.dart` (InkWell pattern) | partial |
| `lib/features/shot_capture/widgets/score_bar.dart` | component/widget | streaming | `lib/features/setup/widgets/course_card.dart` (ConsumerWidget + provider watch) | role-match |
| `lib/features/shot_capture/widgets/hole_nav_drawer.dart` | component/widget | event-driven | `lib/features/setup/setup_screen.dart` (ListView.builder + ConsumerWidget) | role-match |
| `lib/features/setup/providers/round_setup_notifier.dart` | provider/notifier | CRUD | `lib/features/setup/providers/round_setup_notifier.dart` (self) | exact |

---

## Pattern Assignments

### `lib/data/local/database/daos/hole_dao.dart` (service/DAO — UPDATE)

**Analog:** `lib/data/local/database/daos/round_dao.dart`

**Current file** (lines 1–11 — entire file):
```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/holes_table.dart';

part 'hole_dao.g.dart';

@DriftAccessor(tables: [Holes])
class HoleDao extends DatabaseAccessor<AppDatabase> with _$HoleDaoMixin {
  HoleDao(super.db);
  // Phase 2 will add insert/update methods
}
```

**Imports pattern to keep** (from `round_dao.dart` lines 1–5):
```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/holes_table.dart';

part 'hole_dao.g.dart';
```

**DAO method pattern** (from `round_dao.dart` lines 8–27):
```dart
// SELECT with where clause + getSingleOrNull — copy this pattern for getHolesForRound:
Future<Round?> getRoundById(int id) =>
    (select(rounds)..where((r) => r.id.equals(id))).getSingleOrNull();

// UPDATE with write(Companion) — copy this pattern for updating a hole row:
Future<void> completeRound(int id, DateTime completedAt) =>
    (update(rounds)..where((r) => r.id.equals(id)))
        .write(RoundsCompanion(completedAt: Value(completedAt)));

// SELECT list (no limit) — copy for getHolesForRound:
Future<int?> findIncompleteRoundId() async {
  final row = await (select(rounds)
        ..where((r) => r.completedAt.isNull())
        ..limit(1))
      .getSingleOrNull();
  return row?.id;
}
```

**Full replacement for `hole_dao.dart`:**
```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/holes_table.dart';

part 'hole_dao.g.dart';

@DriftAccessor(tables: [Holes])
class HoleDao extends DatabaseAccessor<AppDatabase> with _$HoleDaoMixin {
  HoleDao(super.db);

  Future<void> insertOrUpdateHole(HolesCompanion hole) async {
    final existing = await (select(holes)
          ..where((h) => h.roundId.equals(hole.roundId.value))
          ..where((h) => h.holeNumber.equals(hole.holeNumber.value)))
        .getSingleOrNull();
    if (existing == null) {
      await into(holes).insert(hole);
    } else {
      await (update(holes)
            ..where((h) => h.id.equals(existing.id)))
          .write(hole);
    }
  }

  Future<List<Hole>> getHolesForRound(int roundId) =>
      (select(holes)..where((h) => h.roundId.equals(roundId))).get();

  Stream<List<Hole>> watchHolesForRound(int roundId) =>
      (select(holes)..where((h) => h.roundId.equals(roundId))).watch();
}
```

**After update:** Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `hole_dao.g.dart`. The `_$HoleDaoMixin` includes the generated query helpers.

**Schema stays at v1 — no migration needed.**

---

### `lib/features/shot_capture/shot_capture_screen.dart` (component/screen — REPLACE)

**Analog:** `lib/features/setup/setup_screen.dart`

**ConsumerStatefulWidget pattern** (from `setup_screen.dart` lines 22–54):
```dart
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  @override
  void build(BuildContext context) { ... }
}
```

**`ref.listen` pattern for reactive navigation** (from `setup_screen.dart` lines 58–67):
```dart
// Fire side effects when a provider value changes — copy for roundCompleteProvider:
ref.listen(selectedCourseProvider, (prev, next) {
  final wasNull = prev?.valueOrNull == null;
  final nowLoaded = next.valueOrNull;
  if (wasNull && nowLoaded != null) {
    HapticFeedback.lightImpact();
    // ... trigger side effect
  }
});
```

**Imports pattern** (from `setup_screen.dart` lines 1–20):
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../theme/brdy_colors.dart';
import '../../theme/brdy_spacing.dart';
// ... feature-local imports
```

**Scaffold/SafeArea pattern** (from `setup_screen.dart` lines 69–108):
```dart
return Scaffold(
  backgroundColor: BrdyColors.background,
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [ ... ],
      ),
    ),
  ),
);
```

**SnackBar pattern** (from `setup_screen.dart` lines 129–139):
```dart
// EXISTING snackbar pattern — adapt for undo toast:
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('...'),
    backgroundColor: BrdyColors.surface,
    duration: Duration(seconds: 6),
  ),
);
// Phase 2 undo toast adds: persist: false + SnackBarAction
```

**Navigation pattern** (from `setup_screen.dart` line 188):
```dart
// CORRECT: replaces stack — use for round completion:
context.go('/round-review/$roundId');
```

**Two-zone layout for ShotCaptureScreen** (from UI-SPEC):
```dart
// Replace entire scaffold body with:
body: SafeArea(
  child: Column(
    children: [
      Expanded(flex: 55, child: _TopZone()),
      Container(height: 1, color: BrdyColors.divider),
      Expanded(flex: 45, child: _BottomZone()),
    ],
  ),
),
```

**Phase 2 `ref.listen` pattern for round completion:**
```dart
// In build(), before return Scaffold:
ref.listen<bool>(roundCompleteProvider(roundId), (prev, next) {
  if (next == true) {
    context.go('/round-review/$roundId');
  }
});
```

**Local state for undo:**
```dart
// In _ShotCaptureScreenState — track last scored hole for undo:
int? _lastScoredHoleIndex;

void _showUndoToast(BuildContext context, HoleOutcome outcome, int holeNumber) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${outcome.name.toUpperCase()} — HOLE $holeNumber',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: BrdyColors.onSurface),
        ),
        backgroundColor: BrdyColors.surface,
        duration: const Duration(seconds: 4),
        persist: false,  // REQUIRED — Flutter 3.38+ auto-dismiss with action
        action: SnackBarAction(
          label: 'UNDO',
          textColor: BrdyColors.accent,
          onPressed: () { /* undo logic */ },
        ),
      ),
    );
}
```

---

### `lib/features/shot_capture/providers/hole_score_notifier.dart` (provider/notifier — CREATE)

**Analog:** `lib/features/setup/providers/selected_course_provider.dart` (AsyncNotifier with state transitions) + `lib/features/setup/providers/round_setup_notifier.dart` (DAO write pattern)

**Imports + part directive pattern** (from `round_setup_notifier.dart` lines 1–7):
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
// ... other imports

part 'hole_score_notifier.g.dart';
```

**AsyncNotifier build pattern** (from `selected_course_provider.dart` lines 8–11):
```dart
@riverpod
class SelectedCourse extends _$SelectedCourse {
  @override
  AsyncValue<CourseModel?> build() => const AsyncData(null);
```

**DAO write pattern inside notifier** (from `round_setup_notifier.dart` lines 14–32):
```dart
Future<int> createRound(CourseModel course, double handicapIndex) async {
  state = const AsyncLoading();
  try {
    final repo = ref.read(roundRepositoryProvider);  // use ref.read in callbacks
    final roundId = await repo.createRound(...);
    ref.read(activeRoundIdProvider.notifier).set(roundId);  // cross-notifier write
    state = const AsyncData(null);
    return roundId;
  } catch (e, st) {
    state = AsyncError(e, st);
    rethrow;
  }
}
```

**Phase 2 `HoleScoreNotifier` full pattern:**
```dart
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../data/local/database/app_database.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../../setup/providers/active_round_id_provider.dart';
import '../../shot_capture/providers/active_hole_index_provider.dart';

part 'hole_score_notifier.g.dart';

// @riverpod (auto-dispose) — NOT keepAlive; this is a family provider
@riverpod
class HoleScoreNotifier extends _$HoleScoreNotifier {
  @override
  Future<Hole?> build(int roundId, int holeIndex) async {
    final db = ref.watch(appDatabaseProvider);
    final rows = await db.holeDao.getHolesForRound(roundId);
    final holeNumber = holeIndex + 1;
    try {
      return rows.firstWhere((h) => h.holeNumber == holeNumber);
    } catch (_) {
      return null;
    }
  }

  Future<void> recordOutcome({
    required HoleOutcome outcome,
    required int par,
    int? strokeIndex,
  }) async {
    final db = ref.read(appDatabaseProvider);  // ref.read in callbacks
    final holeNumber = holeIndex + 1;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(roundId),
      holeNumber: Value(holeNumber),
      par: Value(par),
      strokeIndex: Value(strokeIndex),
      outcome: Value(outcome.name),
      fairwayHit: par == 3 ? const Value(null) : const Value(false),
      recordedAt: Value(DateTime.now()),
    ));
    ref.invalidateSelf();  // rebuild from Drift — Drift is source of truth
  }

  Future<void> setPutts(int putts) async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(current.roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      putts: Value(putts),
    ));
    ref.invalidateSelf();
  }

  Future<void> setFairwayHit(bool? fairwayHit) async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(current.roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      fairwayHit: Value(fairwayHit),
    ));
    ref.invalidateSelf();
  }

  Future<void> setGir(bool? gir) async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(current.roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      greenInRegulation: Value(gir),
    ));
    ref.invalidateSelf();
  }

  Future<void> undoOutcome() async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(current.roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      outcome: const Value(null),
      recordedAt: const Value(null),
    ));
    ref.invalidateSelf();
  }
}
```

**Key rules:**
- Use `ref.read(appDatabaseProvider)` (not `ref.watch`) inside async mutation methods — callbacks never use `watch`
- Use `ref.watch(appDatabaseProvider)` in `build()` only
- `ref.invalidateSelf()` after every Drift write — never update Riverpod state directly
- `holeIndex` is 0-based; `holeNumber = holeIndex + 1`
- `outcome.name` stores the enum string e.g. `'doubleBogey'` — NEVER store `'double'`

---

### `lib/features/shot_capture/providers/hole_list_provider.dart` (provider — CREATE)

**Analog:** `lib/features/setup/providers/app_startup_provider.dart` (simple functional provider watching appDatabaseProvider)

**FutureProvider pattern** (from `app_startup_provider.dart` lines 7–11):
```dart
@riverpod
Future<int?> appStartup(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.roundDao.findIncompleteRoundId();
}
```

**Phase 2 StreamProvider (family) pattern:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../data/local/database/app_database.dart';

part 'hole_list_provider.g.dart';

// @riverpod = auto-dispose; family param = roundId
@riverpod
Stream<List<Hole>> holeList(Ref ref, int roundId) {
  final db = ref.watch(appDatabaseProvider);
  return db.holeDao.watchHolesForRound(roundId);
}
```

---

### `lib/features/shot_capture/providers/running_score_provider.dart` (provider — CREATE)

**Analog:** `lib/features/setup/providers/app_startup_provider.dart` (functional provider deriving from another provider)

**Derived provider pattern:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/enums/hole_outcome.dart';
import 'hole_list_provider.dart';

part 'running_score_provider.g.dart';

@riverpod
int? runningScore(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.whenData((holes) {
    int score = 0;
    for (final h in holes) {
      if (h.outcome == null) continue;
      final outcome = HoleOutcome.values.byName(h.outcome!);
      final offset = switch (outcome) {
        HoleOutcome.eagle       => -2,
        HoleOutcome.birdie      => -1,
        HoleOutcome.par         =>  0,
        HoleOutcome.bogey       => +1,
        HoleOutcome.doubleBogey => +2,
        HoleOutcome.pickup      => +2,
      };
      score += offset;
    }
    return score;
  }).value;  // null while loading
}
```

**Note:** `HoleOutcome.values.byName(h.outcome!)` is the only safe way to parse stored strings — never compare `h.outcome == 'double'` (the stored string is `'doubleBogey'`).

---

### `lib/features/shot_capture/providers/course_for_round_provider.dart` (provider — CREATE)

**Analog:** `lib/features/setup/providers/app_startup_provider.dart` (FutureProvider reading from appDatabaseProvider)

**FutureProvider pattern** (from `app_startup_provider.dart` lines 7–11):
```dart
@riverpod
Future<int?> appStartup(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.roundDao.findIncompleteRoundId();
}
```

**Phase 2 pattern:**
```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../domain/models/course_model.dart';

part 'course_for_round_provider.g.dart';

@riverpod
Future<CourseModel?> courseForRound(Ref ref, int roundId) async {
  final db = ref.watch(appDatabaseProvider);
  final round = await db.roundDao.getRoundById(roundId);
  if (round == null || round.courseJson.isEmpty) return null;
  return CourseModel.fromJson(
    jsonDecode(round.courseJson) as Map<String, dynamic>,
  );
}
```

**Source of course data:** Drift `rounds.courseJson` column (written at round creation in `round_setup_notifier.dart` line 23: `courseJson: Value(jsonEncode(course.toJson()))`). This is more reliable than Hive — works after crash recovery even if Hive cache is cleared.

---

### `lib/features/shot_capture/providers/highest_scored_hole_index_provider.dart` (provider — CREATE)

**Analog:** `lib/features/setup/providers/app_startup_provider.dart` + `hole_list_provider.dart` derivation pattern

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'hole_list_provider.dart';

part 'highest_scored_hole_index_provider.g.dart';

@riverpod
int highestScoredHoleIndex(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.when(
    loading: () => 0,
    error: (_, __) => 0,
    data: (holes) {
      final scored = holes.where((h) => h.outcome != null).length;
      return scored > 0 ? scored - 1 : 0;  // 0-based
    },
  );
}
```

---

### `lib/features/shot_capture/providers/round_complete_provider.dart` (provider — CREATE)

**Analog:** Same derivation pattern as `highest_scored_hole_index_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'hole_list_provider.dart';

part 'round_complete_provider.g.dart';

@riverpod
bool roundComplete(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.whenData((holes) =>
    holes.where((h) => h.outcome != null).length >= 18
  ).value ?? false;
}
```

**Used in screen via `ref.listen`** — see `shot_capture_screen.dart` pattern above. The notifier does NOT call `context.go()` — only screen widgets can navigate.

---

### `lib/features/shot_capture/widgets/outcome_button_grid.dart` (component/widget — CREATE)

**Analog:** `lib/features/setup/widgets/course_result_tile.dart` (InkWell tap pattern) + `lib/features/setup/widgets/course_card.dart` (ConsumerWidget + provider interaction)

**ConsumerWidget imports pattern** (from `course_card.dart` lines 1–8):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/selected_course_provider.dart';
```

**InkWell on dark surface pattern** (from `course_result_tile.dart` lines 29–33):
```dart
Material(
  color: BrdyColors.surface,
  child: InkWell(
    splashColor: Colors.white.withOpacity(0.08),
    highlightColor: Colors.white.withOpacity(0.04),
    onTap: onTap,
```

**flutter_animate tap feedback** (from `course_card.dart` lines 120–123):
```dart
.animate()
.fadeIn(duration: 200.ms, curve: Curves.easeOut)
.slideY(begin: 0.1, end: 0, duration: 200.ms, curve: Curves.easeOut);
// Phase 2 uses .scale() instead of .fadeIn for button press feedback
```

**Minimum tap target** (from `course_result_tile.dart` line 35):
```dart
constraints: const BoxConstraints(minHeight: 64),
// Phase 2 outcome buttons: minWidth: 64, minHeight: 80 (CLAUDE.md)
```

**Phase 2 button grid structure:**
```dart
// OutcomeButtonGrid is a ConsumerWidget accepting (roundId, holeIndex, holePar)
// Row 1: PAR, SUB (putts-), ADD (putts+), BIRDY
// Row 2: PICKUP, BOGEY, DOUBLE, NEXT
// Button on dark bottom zone — use BrdyColors.background ink instead of white:
InkWell(
  splashColor: Colors.black.withOpacity(0.08),   // light surface = inverted ripple
  highlightColor: Colors.black.withOpacity(0.04),
  onTap: () => _recordOutcome(HoleOutcome.par),
  child: _OutcomeButtonBody(label: 'PAR', ...),
)

// BIRDIE only — GestureDetector for double-tap EAGLE:
GestureDetector(
  onTap: () => _recordOutcome(HoleOutcome.birdie),
  onDoubleTap: () => _recordOutcome(HoleOutcome.eagle),
  child: _OutcomeButtonBody(label: 'BIRDY', ...),
)
// WARNING: Never put onDoubleTap on a parent container — delays ALL button taps 300ms
```

**Button BoxDecoration:**
```dart
BoxDecoration(
  color: isActive ? activeColor : BrdyColors.surface,
  borderRadius: BorderRadius.circular(8),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ],
)
```

**flutter_animate scale press feedback:**
```dart
.animate()
.scale(
  begin: const Offset(1, 1),
  end: const Offset(0.95, 0.95),
  duration: 80.ms,
)
.then()
.scale(end: const Offset(1, 1), duration: 80.ms)
```

---

### `lib/features/shot_capture/widgets/hole_header.dart` (component/widget — CREATE)

**Analog:** `lib/features/setup/widgets/course_card.dart` (ConsumerWidget reading async provider with `.when()`)

**AsyncProvider consumption pattern** (from `course_card.dart` lines 22–127):
```dart
return ref.watch(selectedCourseProvider).when(
  data: (course) {
    if (course == null) return const SizedBox.shrink();
    // ... build UI with data
    return Container(
      decoration: BoxDecoration(
        color: BrdyColors.surface,
        border: Border.all(color: BrdyColors.accent, width: 1),
      ),
      // ...
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),
);
```

**Text style pattern** (from `course_card.dart` lines 37–49):
```dart
Text(
  course.courseName.toUpperCase(),
  style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: BrdyColors.accent,
      ),
),
Text(
  'PAR ${course.par}',
  style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: BrdyColors.onSurfaceMuted,
      ),
),
```

**Phase 2 HoleHeader structure:**
```dart
// ConsumerWidget — reads: activeHoleIndexProvider, courseForRoundProvider(roundId)
// Displays: giant hole number (96dp JetBrains Mono), score badge pill, course info row
// Uses: ref.watch(courseForRoundProvider(roundId)).when(...)
// Giant hole number uses GoogleFonts.jetBrainsMono directly (not TextTheme slot):
GoogleFonts.jetBrainsMono(
  fontSize: 96,
  fontWeight: FontWeight.w700,
  height: 1.0,
  color: BrdyColors.onSurface,
)
```

---

### `lib/features/shot_capture/widgets/putts_counter.dart` (component/widget — CREATE)

**Analog:** `lib/features/setup/widgets/handicap_input.dart` (ConsumerStatefulWidget with validation + immediate write) + `course_result_tile.dart` (InkWell interaction)

**ConsumerStatefulWidget pattern** (from `handicap_input.dart` lines 7–15):
```dart
class HandicapInput extends ConsumerStatefulWidget {
  const HandicapInput({super.key});

  @override
  ConsumerState<HandicapInput> createState() => _HandicapInputState();
}

class _HandicapInputState extends ConsumerState<HandicapInput> {
```

**Immediate write on change pattern** (from `handicap_input.dart` lines 32–41):
```dart
void _onChanged(String value) {
  final parsed = double.tryParse(value);
  if (parsed != null && parsed >= 0.0 && parsed <= 54.0) {
    ref.read(hivePlayerPrefsProvider).setHandicapIndex(parsed);  // immediate write
    setState(() => _error = null);
  }
}
```

**Phase 2 PuttsCounter structure:**
```dart
// ConsumerWidget (not stateful — putts value comes from holeScoreNotifierProvider)
// Reads: ref.watch(holeScoreNotifierProvider(roundId, holeIndex))
// On +/-: ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier).setPutts(n)
// Write is immediate on every tap — no debounce, no buffer
// Minimum constraints: BoxConstraints(minWidth: 48, minHeight: 48) for +/- buttons
// Putts value: holeState.value?.putts ?? 0
```

---

### `lib/features/shot_capture/widgets/fairway_gir_toggles.dart` (component/widget — CREATE)

**Analog:** `lib/features/setup/widgets/course_result_tile.dart` (InkWell + stateless toggle pattern) + `course_card.dart` (conditional rendering `if (missingRating)`)

**Conditional rendering pattern** (from `course_card.dart` lines 91–103):
```dart
// Conditional presence — not hidden with Visibility, REMOVED from tree:
if (missingRating) ...[
  const SizedBox(height: BrdySpacing.sm),
  if (!_manualFormOpen)
    MissingRatingBanner(...)
  else
    ManualRatingForm(...),
],
```

**Phase 2 FairwayGirToggles pattern:**
```dart
// ConsumerWidget accepting (roundId, holeIndex, holePar)
// holePar == 3 gate: fairway toggle removed from tree entirely (not hidden)
Row(children: [
  if (holePar != 3) Expanded(child: _FairwayToggle(...)),
  if (holePar != 3) SizedBox(width: BrdySpacing.sm),
  Expanded(child: _GirToggle(...)),
  SizedBox(width: BrdySpacing.sm),
  Expanded(child: _VoiceToggle()),  // always inactive in Phase 2
])
// Each toggle: InkWell-wrapped Container with active/inactive fill + label/descriptor
// Write on tap: ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier).setFairwayHit(bool)
// fairwayHit = null for par 3 (set in HoleScoreNotifier.recordOutcome, not in this widget)
```

---

### `lib/features/shot_capture/widgets/score_bar.dart` (component/widget — CREATE)

**Analog:** `lib/features/setup/widgets/course_card.dart` (ConsumerWidget watching async provider + Container with BrdyColors)

**ConsumerWidget + async watch pattern** (from `course_card.dart` lines 22–23):
```dart
return ref.watch(selectedCourseProvider).when(
  data: (course) { ... },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),
);
```

**Container with BrdyColors** (from `course_card.dart` lines 29–33):
```dart
Container(
  decoration: BoxDecoration(
    color: BrdyColors.surface,
    border: Border.all(color: BrdyColors.accent, width: 1),
  ),
  padding: const EdgeInsets.all(BrdySpacing.md),
```

**Phase 2 ScoreBar — positioned inside the top zone of ShotCaptureScreen as a score badge pill:**
```dart
// ConsumerWidget accepting (roundId)
// Reads: ref.watch(runningScoreProvider(roundId))  — int? (null while loading)
// Display: E (0), +{n} (>0), -{n} (<0)   [ASCII hyphen-minus for negative]
// Badge pill Container:
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: BrdyColors.accent,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    display,  // 'E', '+3', '-1'
    style: GoogleFonts.jetBrainsMono(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: BrdyColors.onAccent,
    ),
  ),
)
```

---

### `lib/features/shot_capture/widgets/hole_nav_drawer.dart` (component/widget — CREATE)

**Analog:** `lib/features/setup/setup_screen.dart` (ListView.builder + ConsumerWidget watching stream provider) + `course_result_tile.dart` (InkWell per-item taps)

**ListView.builder pattern** (from `setup_screen.dart` lines 143–159):
```dart
return ListView.builder(
  itemCount: results.length,
  itemBuilder: (context, i) {
    final result = results[i];
    return CourseResultTile(
      courseName: result.clubName,
      onTap: () => ref
          .read(selectedCourseProvider.notifier)
          .loadCourse(result.id),
    );
  },
);
```

**Phase 2 HoleNavDrawer structure:**
```dart
// ConsumerWidget accepting (roundId)
// Reads: holeListProvider(roundId), activeHoleIndexProvider, highestScoredHoleIndexProvider(roundId)
// Show/hide via local bool state toggled by tapping the giant hole number
// Horizontal scrollable: scrollDirection: Axis.horizontal in ListView
// 18 hole chips + optional 'NOW' chip
// Each chip: 40×40dp, BorderRadius.circular(4), tap → activeHoleIndexProvider.notifier.set(i)
// Future holes (i > highestScoredHoleIndex + 1): onTap: null, BrdyColors.divider fill
// Scored holes: outcome color fill (gold/accent/blue/surface/destructive)
// Active chip: 2dp BrdyColors.onSurface border added
// flutter_animate height reveal: 0→56dp in 200ms Curves.easeOut
```

---

### `lib/features/setup/providers/round_setup_notifier.dart` (provider/notifier — UPDATE)

**Analog:** `lib/features/setup/providers/round_setup_notifier.dart` (self)

**Current file** (lines 1–33 — entire file):
```dart
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/course_model.dart';
import '../../../infrastructure/repositories/round_repository_provider.dart';
import 'active_round_id_provider.dart';

part 'round_setup_notifier.g.dart';

@riverpod
class RoundSetupNotifier extends _$RoundSetupNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<int> createRound(CourseModel course, double handicapIndex) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(roundRepositoryProvider);
      final roundId = await repo.createRound(
        courseName: course.clubName,
        handicapIndex: handicapIndex,
        courseRating: course.courseRating,
        slope: course.slope,
        courseJson: jsonEncode(course.toJson()),
      );
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

**What to add (Pitfall P2-08 fix):** After `ref.read(activeRoundIdProvider.notifier).set(roundId)`, add:
```dart
// Reset hole index to 0 — prevents new round starting on hole 18
// activeHoleIndexProvider is keepAlive and persists across navigation
ref.read(activeHoleIndexProvider.notifier).set(0);
```

**New import needed:**
```dart
import '../../shot_capture/providers/active_hole_index_provider.dart';
```

---

## Shared Patterns

### Riverpod Provider Annotation Rules
**Source:** `lib/features/setup/providers/active_round_id_provider.dart` (keepAlive) + `lib/features/setup/providers/app_startup_provider.dart` (auto-dispose)
**Apply to:** All Phase 2 provider files

```dart
// keepAlive — ONLY for: activeRoundIdProvider, activeHoleIndexProvider (existing)
// ALL Phase 2 providers are auto-dispose:
@riverpod  // lowercase = auto-dispose
class MyNotifier extends _$MyNotifier { ... }

@riverpod  // lowercase = auto-dispose functional provider
Future<X> myProvider(Ref ref, int param) async { ... }

// Family providers (parameterized): add args to build() or function signature
// Generated accessor: myProvider(param1, param2)
```

Every provider file needs:
1. `part 'filename.g.dart';`
2. Run `dart run build_runner build --delete-conflicting-outputs` after creation

### Import Order Convention
**Source:** `lib/features/setup/setup_screen.dart` lines 1–20
**Apply to:** All Phase 2 Dart files

```dart
// 1. dart: imports first
import 'dart:convert';
// 2. package: imports (Flutter, Riverpod, other packages)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
// 3. Relative local imports (theme → data → domain → feature-local)
import '../../theme/brdy_colors.dart';
import '../../theme/brdy_spacing.dart';
import '../../../data/local/database/app_database_provider.dart';
```

No barrel files. No path aliases. Direct relative imports only.

### AsyncValue Consumption Pattern
**Source:** `lib/features/setup/setup_screen.dart` lines 118–162 + `lib/features/setup/widgets/course_card.dart` lines 22–127
**Apply to:** All widgets reading FutureProvider or StreamProvider

```dart
// In ConsumerWidget.build():
ref.watch(someAsyncProvider).when(
  loading: () => const SizedBox.shrink(),  // Phase 2 pattern: hide during load
  error: (e, st) => const SizedBox.shrink(),  // graceful degradation
  data: (value) => /* build with value */,
);

// maybeWhen for partial matching (from setup_screen.dart line 88):
ref.watch(provider).maybeWhen(
  data: (v) => v != null ? WidgetA() : WidgetB(),
  orElse: () => WidgetB(),
);
```

### Drift Write-Through Rule
**Source:** CLAUDE.md Critical Don'ts + `lib/features/setup/providers/round_setup_notifier.dart` line 18
**Apply to:** All `HoleScoreNotifier` methods

```dart
// ALWAYS write to Drift before any Riverpod state update:
await db.holeDao.insertOrUpdateHole(companion);  // Drift first
ref.invalidateSelf();  // then rebuild from Drift

// NEVER:
// state = someLocalValue;  // buffering in Riverpod
// await db.write(...)  later  // deferred write
```

### Navigation Rule (no back-stack for hole changes)
**Source:** CLAUDE.md + `lib/features/setup/setup_screen.dart` line 188
**Apply to:** All hole navigation and round completion

```dart
// Hole navigation — NEVER a route push:
ref.read(activeHoleIndexProvider.notifier).set(targetIndex);

// Round completion — replace stack:
context.go('/round-review/$roundId');  // CORRECT
// context.push('/round-review/$roundId');  // NEVER

// Notifiers CANNOT navigate — use ref.listen in screen:
ref.listen<bool>(roundCompleteProvider(roundId), (_, next) {
  if (next) context.go('/round-review/$roundId');
});
```

### Haptic Feedback Pattern
**Source:** `lib/features/setup/setup_screen.dart` lines 63, 180
**Apply to:** All tap handlers in Phase 2

```dart
import 'package:flutter/services.dart';

// Outcome button tap:
await HapticFeedback.mediumImpact();

// NEXT, UNDO, hole chip, chevron taps:
await HapticFeedback.lightImpact();

// Putts +/−, fairway/GIR toggles:
await HapticFeedback.selectionClick();
```

### BrdyColors Token Usage
**Source:** `lib/theme/brdy_colors.dart` (verified in codebase)
**Apply to:** All Phase 2 widgets

```dart
import '../../theme/brdy_colors.dart';

// Top zone (dark): background #0A0A0A, text: onSurface #F0F0F0
// Bottom zone (light): background = BrdyColors.onSurface #F0F0F0, text: background #0A0A0A
// Accent: BrdyColors.accent #E8520A — NEXT button, fairway active, score badge
// Destructive: BrdyColors.destructive #CC2200 — double/pickup hole chips

// InkWell ripple — dark surface (top zone):
splashColor: Colors.white.withOpacity(0.08),
highlightColor: Colors.white.withOpacity(0.04),

// InkWell ripple — light surface (bottom zone):
splashColor: Colors.black.withOpacity(0.08),
highlightColor: Colors.black.withOpacity(0.04),
```

### Gap/Spacing Usage
**Source:** `lib/features/setup/setup_screen.dart` lines 77–101
**Apply to:** All Phase 2 screen and widget files

```dart
import 'package:gap/gap.dart';
import '../../theme/brdy_spacing.dart';

const Gap(BrdySpacing.xs)  // 4dp — between buttons in a row, dot-to-label
const Gap(BrdySpacing.sm)  // 8dp — between button rows
const Gap(BrdySpacing.md)  // 16dp — horizontal screen padding
const Gap(BrdySpacing.lg)  // 24dp — vertical section gaps in top zone
```

---

## No Analog Found

All 15 Phase 2 files have a codebase analog. No RESEARCH.md-only patterns required.

---

## Metadata

**Analog search scope:** `/Users/simonnewland/development/brdy01/lib/`
**Files scanned:** 89 Dart source files (Phase 1 fully implemented)
**Pattern extraction date:** 2026-05-17
**Confidence:** HIGH for all patterns — drawn from actual Phase 1 codebase files, not RESEARCH.md hypotheticals
