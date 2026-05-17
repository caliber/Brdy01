# Phase 2: Shot Capture — Research

**Researched:** 2026-05-17
**Domain:** Flutter shot-capture UI — Riverpod state, Drift write-through, gesture detection, undo toast, hole navigation
**Confidence:** HIGH — all critical paths verified against live codebase, Drift docs, official Flutter API

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SHOT-01 | Outcome buttons: BIRDIE / PAR / BOGEY / DOUBLE / PICKUP | `OutcomeButton` widget grid; `HoleScoreNotifier.recordOutcome()` writes immediately to Drift via `HoleDao.insertOrUpdateHole()` |
| SHOT-02 | EAGLE via double-tap BIRDIE | `GestureDetector.onDoubleTap` on BIRDIE button only; 300ms single-tap delay on BIRDIE is accepted in this context |
| SHOT-03 | Auto-advance to next hole immediately after outcome tap | `ref.read(activeHoleIndexProvider.notifier).set(holeIndex + 1)` called inside `recordOutcome()` after Drift write |
| SHOT-04 | 4-second auto-dismiss undo toast | `ScaffoldMessenger.showSnackBar` with `persist: false` + `duration: 4s` + `SnackBarAction`; `persist: false` is required in Flutter 3.38+ |
| SHOT-05 | Putts per hole via +/− counter | `HoleScoreNotifier.setPutts()` writes to Drift on every tap; no buffering or debounce |
| SHOT-06 | Fairway hit toggle, hidden on par 3s | `holePar == 3` gates widget to absent (not disabled); `setFairwayHit(null)` never called for par 3 — notifier enforces null |
| SHOT-07 | GIR toggle per hole | `HoleScoreNotifier.setGir(bool?)` writes immediately to Drift |
| SHOT-10 | Running score vs par always visible | `runningScoreProvider(roundId)` derived from Drift `watchHolesForRound` stream; `ScoreBar` widget reads it |
| SHOT-11 | Hole number, par, Stroke Index prominently displayed | `CourseModel.holes[activeHoleIndex]` from Hive-cached `courseJson` column in rounds table; SI nullable — show "–" |
| SHOT-12 | Navigate back to any previously scored hole to correct entry | `ref.read(activeHoleIndexProvider.notifier).set(targetIndex)` — internal state only, no GoRouter push |
</phase_requirements>

---

## Summary

Phase 2 replaces the `ShotCaptureScreen` stub with a fully functional hole-by-hole scoring screen. The screen must prioritise score entry speed — outcome buttons must appear immediately on load, with no GPS or map initialisation blocking the first render.

The primary technical pattern is **immediate Drift write + reactive Riverpod providers**. When a user taps an outcome button: (1) the hole row is inserted or updated in Drift via `HoleDao.insertOrUpdateHole()`, (2) `activeHoleIndexProvider` advances to the next hole, and (3) the undo SnackBar appears. The `runningScoreProvider` derives the running score from a Drift stream that auto-updates on every write. All providers for Phase 2 are auto-dispose — the two existing keepAlive providers (`activeRoundIdProvider`, `activeHoleIndexProvider`) remain unchanged.

No new packages are required. Everything needed is already declared in `pubspec.yaml` and initialised in `main.dart`. The Drift schema stays at version 1 — the `Holes` table already has all required columns; only the empty `HoleDao` stub needs implementing.

**Primary recommendation:** Implement `HoleScoreNotifier` as the single write authority for all hole data. All five data points (outcome, putts, fairwayHit, GIR, recordedAt) write to Drift through this one notifier. Derive all display state (running score, hole metadata, navigation state) from Drift streams — never from Riverpod state accumulated separately.

---

## Project Constraints (from CLAUDE.md)

| Directive | Phase 2 Impact |
|-----------|---------------|
| Write-through to Drift on every score entry — never accumulate state in Riverpod alone | Every `HoleScoreNotifier` method writes to Drift before updating any local state; `ref.invalidateSelf()` after each Drift write |
| `activeHoleIndexProvider` and `activeRoundIdProvider` MUST be `@Riverpod(keepAlive: true)` | These exist from Phase 1 — do not modify their annotations |
| All screen-level providers use `@riverpod` (auto-dispose) | All 6 new Phase 2 providers are auto-dispose |
| Hole navigation is internal `activeHoleIndexProvider` state change, NOT route pushes | SHOT-12 implementation never calls `context.push()` or `context.go()` for hole changes |
| Don't start GPS/map loading before score buttons appear | Phase 2 has no GPS or map code (Phase 5 only). No FMTC or geolocator calls in this phase. |
| 64×80dp minimum tap targets for score buttons | Outcome buttons enforce `BoxConstraints(minHeight: 80)` and use `Expanded` for width |
| Brutalist monospace aesthetic — all design decisions locked | BrdyColors, BrdySpacing, BrdyTextTheme from Phase 1 apply unchanged |
| Accent `#E8520A` for birdie; gold `#FFD700` for eagle | `BrdyColors.accent` on BIRDIE; inline `Color(0xFFFFD700)` for eagle chips |
| Scorecard colour coding — eagle=gold, birdie=orange, par=plain, bogey=underline, double+=red | Applied in `HoleNavDrawer` hole chips now; Phase 3 scorecard inherits this |
| `context.go()` not `context.push()` for main screen transitions | Round completion → `/round-review/$roundId` uses `context.go()` |
| Every `Table` class change bumps `schemaVersion` | Phase 2 makes NO table changes — schema stays at v1 |
| Run `build_runner` after every schema/provider change | Required after `hole_dao.dart` update and all new provider file creations |

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Score entry (outcome tap) | Presentation / Widget | Drift / Data (write-through) | UI captures gesture; Drift is source of truth |
| Active hole tracking | Riverpod keepAlive (`activeHoleIndexProvider`) | — | Cross-screen persistent state; survives hole transitions |
| Active round identity | Riverpod keepAlive (`activeRoundIdProvider`) | — | Established in Phase 1; no change |
| Per-hole data (outcome, putts, fairway, GIR) | Drift / Data | Riverpod (derived view) | Write-through required by CLAUDE.md and FOUND-01 |
| Running score computation | Riverpod derived provider | Drift stream | Computed from hole records, not separate counter state |
| Hole metadata (par, SI, hole number) | Hive cache (CourseModel via Drift courseJson) | — | Cached at course load; no re-fetch during round |
| Undo toast | Presentation / ScaffoldMessenger | — | 4-second UI concern; Drift already holds correct state |
| EAGLE gesture | Presentation / GestureDetector | — | `onDoubleTap` on BIRDIE button only |
| Round completion detection | Riverpod derived provider | Drift | Derived: count of scored holes >= 18 |
| Hole back-navigation | Riverpod (`activeHoleIndexProvider`) | — | Internal state; no router involvement |
| Round → Review navigation | Presentation / ref.listen | go_router | Notifiers have no context; screen listens and calls `context.go()` |

---

## 1. Architecture Overview

### How ShotCaptureScreen fits the existing codebase

The stub `ShotCaptureScreen` (`lib/features/shot_capture/shot_capture_screen.dart`) is a `ConsumerWidget` that already accepts a `roundId` int parameter from the go_router route `/shot-capture/:roundId`. It reads `activeRoundIdProvider` but renders only debug text. Phase 2 replaces its `build()` method body entirely.

The two existing keepAlive providers are already wired:
- `activeRoundIdProvider` — set to the round ID when `RoundSetupNotifier.createRound()` completes (Phase 1)
- `activeHoleIndexProvider` — `ActiveHoleIndex` StateNotifier, currently starts at 0

**Critical gap to fix:** `RoundSetupNotifier.createRound()` does NOT currently reset `activeHoleIndexProvider` to 0 before starting a new round. If the user completes a round (ends on hole 17, index 17) and starts a new one, the new round begins on hole 18. Phase 2 must fix this in `round_setup_notifier.dart`.

### Data source for hole metadata

`CourseModel` is deserialized from the `courseJson` TEXT column on the `rounds` row (stored at round creation). This is the correct source — not Hive directly — because it captures the exact course data used when the round started. `getRoundById(roundId)` in `RoundDao` already exists and returns this field. [VERIFIED: lib/data/local/database/daos/round_dao.dart, lib/data/local/database/tables/rounds_table.dart]

### Data source for per-hole scoring state

All hole scoring data (outcome, putts, fairwayHit, GIR) lives in the `Holes` table. `HoleDao` is a fully empty stub — Phase 2 implements it. The `Holes` table already has all required columns. [VERIFIED: lib/data/local/database/daos/hole_dao.dart, lib/data/local/database/tables/holes_table.dart]

---

## 2. HoleDao Design

### Confirmed Holes table schema (Phase 1, schemaVersion 1)

```dart
// lib/data/local/database/tables/holes_table.dart — VERIFIED
class Holes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  IntColumn get holeNumber => integer()();          // 1-based
  IntColumn get par => integer()();
  IntColumn get strokeIndex => integer().nullable()();
  TextColumn get outcome => text().nullable()();    // HoleOutcome.name string
  IntColumn get putts => integer().nullable()();
  BoolColumn get fairwayHit => boolean().nullable()();
  BoolColumn get greenInRegulation => boolean().nullable()();
  DateTimeColumn get recordedAt => dateTime().nullable()();
}
```

### Recommended HoleDao methods

```dart
// lib/data/local/database/daos/hole_dao.dart
@DriftAccessor(tables: [Holes])
class HoleDao extends DatabaseAccessor<AppDatabase> with _$HoleDaoMixin {
  HoleDao(super.db);

  /// Insert a new hole row or update existing one matched by (roundId, holeNumber).
  /// No unique index exists on these columns (schema v1), so use SELECT-then-branch.
  Future<void> insertOrUpdateHole(HolesCompanion hole) async {
    final existing = await (select(holes)
          ..where((h) => h.roundId.equals(hole.roundId.value))
          ..where((h) => h.holeNumber.equals(hole.holeNumber.value)))
        .getSingleOrNull();
    if (existing == null) {
      await into(holes).insert(hole);
    } else {
      await (update(holes)..where((h) => h.id.equals(existing.id))).write(hole);
    }
  }

  /// One-shot fetch of all holes for a round (used for hydrating notifier state).
  Future<List<Hole>> getHolesForRound(int roundId) =>
      (select(holes)..where((h) => h.roundId.equals(roundId))).get();

  /// Reactive stream of all holes — drives runningScoreProvider and holeListProvider.
  Stream<List<Hole>> watchHolesForRound(int roundId) =>
      (select(holes)..where((h) => h.roundId.equals(roundId))).watch();
}
```

**Schema decision: No schema version bump for Phase 2.**
Option A (SELECT-then-INSERT/UPDATE, above) avoids a schemaVersion bump. Option B (add `@TableIndex.onColumns([#roundId, #holeNumber], unique: true)` + schemaVersion 2 + migration) enables `insertOnConflictUpdate` but is an optimisation with no user-visible benefit at this scale. Use Option A. [CITED: drift.simonbinder.eu/dart_api/writes/]

**After updating `hole_dao.dart`:** Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `hole_dao.g.dart`.

### Batch insert vs lazy upsert

Do NOT pre-insert 18 empty hole rows at round start. Use lazy upsert: insert the first time a hole is scored, update on corrections. This keeps Drift data clean (only scored holes exist as rows) and simplifies the `highestScoredHoleIndexProvider` logic (count rows where `outcome IS NOT NULL`).

---

## 3. Provider Architecture

### New providers for Phase 2

| Provider | Type | File | Notes |
|----------|------|------|-------|
| `holeScoreNotifierProvider(roundId, holeIndex)` | `AsyncNotifier` family, auto-dispose | `providers/hole_score_notifier.dart` | Primary write authority for all hole fields |
| `holeListProvider(roundId)` | `StreamProvider` family, auto-dispose | `providers/hole_list_provider.dart` | Drift stream of all holes; drives score + nav |
| `runningScoreProvider(roundId)` | `Provider` derived, auto-dispose | `providers/running_score_provider.dart` | Derived from `holeListProvider` |
| `courseForRoundProvider(roundId)` | `FutureProvider` family, auto-dispose | `providers/course_for_round_provider.dart` | Deserializes `CourseModel` from Drift rounds row |
| `highestScoredHoleIndexProvider(roundId)` | `Provider` derived, auto-dispose | `providers/highest_scored_hole_index_provider.dart` | Max index with a recorded outcome |
| `roundCompleteProvider(roundId)` | `Provider` derived, auto-dispose | `providers/round_complete_provider.dart` | Boolean: scored holes >= 18 |

**No new keepAlive providers.** The two existing keepAlive providers (`activeRoundIdProvider`, `activeHoleIndexProvider`) are from Phase 1 and must not have their annotations changed.

### HoleScoreNotifier — the primary write authority

```dart
// lib/features/shot_capture/providers/hole_score_notifier.dart
part 'hole_score_notifier.g.dart';

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
    final db = ref.read(appDatabaseProvider);
    final holeNumber = holeIndex + 1;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(roundId),
      holeNumber: Value(holeNumber),
      par: Value(par),
      strokeIndex: Value(strokeIndex),
      outcome: Value(outcome.name),   // 'eagle', 'birdie', 'par', 'bogey', 'doubleBogey', 'pickup'
      recordedAt: Value(DateTime.now()),
    ));
    ref.invalidateSelf();
  }

  Future<void> setPutts(int putts) async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return; // outcome must be recorded first
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      putts: Value(putts),
    ));
    ref.invalidateSelf();
  }

  Future<void> setFairwayHit(bool? fairwayHit) async { /* same pattern */ }
  Future<void> setGir(bool? gir) async { /* same pattern */ }

  Future<void> undoOutcome() async {
    final current = await future;
    if (current == null) return;
    final db = ref.read(appDatabaseProvider);
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      outcome: const Value(null),
      recordedAt: const Value(null),
    ));
    ref.invalidateSelf();
  }
}
```

**Key design decisions:**
- `holeIndex` is 0-based (matches `activeHoleIndexProvider`); `holeNumber` = `holeIndex + 1` [VERIFIED: active_hole_index_provider.dart]
- `outcome` stored as `HoleOutcome.name` string: `'eagle'`, `'birdie'`, `'par'`, `'bogey'`, `'doubleBogey'`, `'pickup'` [VERIFIED: lib/domain/enums/hole_outcome.dart — enum value is `doubleBogey`, not `double`]
- `fairwayHit` is `null` for par 3 holes — `null` means N/A (not "missed"); par 4/5 default is `false` when outcome first recorded [ASSUMED: A1]
- Auto-dispose (`@riverpod`) — correct; each hole gets its own instance, auto-disposes on hole transition
- `ref.invalidateSelf()` after each Drift write re-runs `build()` and syncs state from Drift

---

## 4. Outcome Recording Flow

### System Architecture Diagram

```
User taps OUTCOME button (BIRDIE / PAR / BOGEY / DOUBLE / PICKUP)
         |
         v
ShotCaptureScreen (ConsumerStatefulWidget)
         |
         +-- reads: activeRoundIdProvider (keepAlive)
         |
         +-- reads: activeHoleIndexProvider (keepAlive)
         |
         +-- reads: courseForRoundProvider(roundId) -- HiveCourseBox/Drift rounds row
         |            deserializes CourseModel (par, SI per hole)
         |
         +-- calls: HoleScoreNotifier(roundId, holeIndex).recordOutcome(outcome)
                      |
                      +-- 1. HoleDao.insertOrUpdateHole() --> Drift write
                      |      Fields: roundId, holeNumber, par, strokeIndex, outcome, recordedAt
                      |
                      +-- 2. ref.read(activeHoleIndexProvider.notifier).set(holeIndex + 1)
                      |      (if holeIndex < 17; else leave at 17 — roundComplete fires)
                      |
                      +-- 3. ref.invalidateSelf() -- HoleScoreNotifier rebuilds from Drift
                      |
                      +-- 4. ScaffoldMessenger.showSnackBar(undo toast) -- called from screen

Reactive updates (always-on):
runningScoreProvider(roundId) <-- holeListProvider(roundId) <-- db.holeDao.watchHolesForRound(roundId)
         |
         +-- ScoreBar widget rebuilds with new score string ("E", "+2", "-1")

roundCompleteProvider(roundId) <-- holeListProvider(roundId)
         |
         +-- ShotCaptureScreen ref.listen --> context.go('/round-review/$roundId')
```

### EAGLE double-tap (SHOT-02)

`GestureDetector.onDoubleTap` must be placed on the BIRDIE button widget **only** — not on any parent container. When `onDoubleTap` is set alongside `onTap`, Flutter's gesture arena delays the `onTap` callback by `kDoubleTapTimeout` (~300ms) while it waits to see if a second tap arrives. [CITED: api.flutter.dev/flutter/widgets/GestureDetector-class.html; flutter/flutter#50458]

```dart
// BIRDIE button — GestureDetector only here, all others use InkWell
GestureDetector(
  onTap: () => _recordOutcome(HoleOutcome.birdie),
  onDoubleTap: () => _recordOutcome(HoleOutcome.eagle),
  child: OutcomeButton(label: 'BIRDIE', ...),
)

// All other buttons
InkWell(
  onTap: () => _recordOutcome(HoleOutcome.par),
  child: OutcomeButton(label: 'PAR', ...),
)
```

The 300ms delay on BIRDIE single-tap is accepted — golfers deliberate before tapping, this is not a reflex UI.

### Undo toast (SHOT-04)

```dart
void _showUndoToast(BuildContext context, HoleOutcome outcome, int holeNumber, int scoredHoleIndex) {
  final label = outcome.name.toUpperCase();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$label — Hole $holeNumber'),
        backgroundColor: BrdyColors.surface,
        duration: const Duration(seconds: 4),
        persist: false,   // REQUIRED in Flutter 3.38+ — restores auto-dismiss with action
        action: SnackBarAction(
          label: 'UNDO',
          textColor: BrdyColors.accent,
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(holeScoreNotifierProvider(roundId, scoredHoleIndex).notifier)
               .undoOutcome();
            ref.read(activeHoleIndexProvider.notifier).set(scoredHoleIndex);
          },
        ),
      ),
    );
}
```

**Breaking change:** As of Flutter 3.38, `SnackBar` with an `action` no longer auto-dismisses by default. `persist: false` is mandatory to restore 4-second auto-dismiss. [CITED: docs.flutter.dev/release/breaking-changes/snackbar-with-action-behavior-update]

Undo is valid only for the immediately preceding hole — the toast auto-dismisses after 4 seconds, making multi-level undo structurally impossible.

---

## 5. Secondary Controls

### Putts counter (SHOT-05)

Every `+` or `-` tap writes to Drift immediately — no debounce, no blur-triggered save. This is the write-through mandate. [VERIFIED: CLAUDE.md FOUND-01]

- Minimum: 0 (minus button disabled, not hidden, when putts == 0)
- No maximum enforced
- Source of displayed value: `ref.watch(holeScoreNotifierProvider(roundId, holeIndex)).value?.putts ?? 0`
- Button size: `iconSize: 32`; no haptic (low-priority action)

### Fairway hit toggle (SHOT-06)

Fairway toggle is **absent from the widget tree entirely** on par 3 holes — not disabled, not hidden with `Visibility` — completely not rendered. Par 3 detection uses `CourseModel.holes[holeIndex].par == 3`. [VERIFIED: REQUIREMENTS.md SHOT-06 — "hidden / marked N/A on par 3s"]

For par 4/5 holes, the toggle writes `true` (hit) or `false` (missed) immediately to Drift. The notifier enforces that `fairwayHit` is never written for a par 3 hole — the widget not rendering is the primary guard, but the notifier guards defensively.

### GIR toggle (SHOT-07)

Always shown. Writes `true`/`false` immediately to Drift. Toggle in inactive (false/null) state by default. No par-based gating.

### Drift write-through pattern for secondary controls

```dart
// All secondary controls call HoleScoreNotifier methods — never write to Drift directly from widgets
ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier).setPutts(newValue);
ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier).setFairwayHit(true);
ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier).setGir(true);
```

Secondary controls are only active after an outcome has been recorded for the hole (`holeScoreNotifierProvider.value != null`). Putts/fairway/GIR write requires an existing row to update — the `setPutts` guard (`if (current == null) return`) enforces this.

---

## 6. Running Score

### Calculation

```dart
// lib/features/shot_capture/providers/running_score_provider.dart
@riverpod
int? runningScore(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.whenData((holes) {
    int score = 0;
    for (final h in holes) {
      if (h.outcome == null) continue;
      final outcome = HoleOutcome.values.byName(h.outcome!);
      score += switch (outcome) {
        HoleOutcome.eagle       => -2,
        HoleOutcome.birdie      => -1,
        HoleOutcome.par         =>  0,
        HoleOutcome.bogey       => +1,
        HoleOutcome.doubleBogey => +2,
        HoleOutcome.pickup      => +2, // display as double for running score [ASSUMED: A2]
      };
    }
    return score;
  }).value;
}
```

Pickup is shown as +2 (same as double bogey) for the running score display. The real WHS pickup value (net double bogey, which requires per-hole handicap strokes) is computed in Phase 3. [ASSUMED: A2]

### Display format

- Score == 0 → `"E"`
- Score > 0 → `"+{score}"` in `BrdyColors.onSurface`
- Score < 0 → `"-{abs(score)}"` (ASCII hyphen, not Unicode minus) in `BrdyColors.accent`

Use `HoleOutcome.values.byName(h.outcome!)` — never compare raw strings. `'doubleBogey'` is the stored string, not `'double'`. [VERIFIED: lib/domain/enums/hole_outcome.dart]

### Why not keep score in Riverpod state?

Writing score to Riverpod state separately from Drift creates two sources of truth. If the app restarts, Riverpod state is lost but Drift is not. Deriving from the Drift stream ensures the score is always correct after crash recovery and after undo. [VERIFIED: CLAUDE.md Critical Don'ts]

---

## 7. Hole Navigation

### activeHoleIndexProvider is the single source of truth for which hole is displayed

`ActiveHoleIndex` is a keepAlive `StateNotifier` with a single `set(int index)` method. [VERIFIED: lib/features/shot_capture/providers/active_hole_index_provider.dart]

It is never a GoRouter push. [VERIFIED: CLAUDE.md navigation model]

### highestScoredHoleIndex

```dart
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

### Navigation strip (HoleNavDrawer)

Horizontal `ListView` of 18 `HoleChip` widgets:
- Unscored: `BrdyColors.surface` background, `BrdyColors.divider` border
- Scored: outcome color background (eagle=`#FFD700`, birdie=`BrdyColors.accent`, par=`BrdyColors.surface`, bogey=`BrdyColors.onSurface`+underline, double/pickup=`BrdyColors.destructive`)
- Active hole (currently displayed): border `width: 2`, `BrdyColors.onSurface`
- Future holes (beyond `highestScoredHoleIndex + 1`): `opacity: 0.4`, `onTap: null`
- Tapping a chip: `ref.read(activeHoleIndexProvider.notifier).set(targetIndex)`

### "Back to Current" affordance

Shown only when `activeHoleIndex < highestScoredHoleIndex`. Renders as a small text button (`"NOW"`) at the far right of the nav strip (outside the scrollable `ListView`, in a fixed `Row` position). Tapping calls `ref.read(activeHoleIndexProvider.notifier).set(highestScoredHoleIndex)`.

### Round completion navigation

The notifier CANNOT call `context.go()` — notifiers have no `BuildContext`. Use `ref.listen` in the screen widget:

```dart
// In ShotCaptureScreen.build():
ref.listen<bool>(roundCompleteProvider(roundId), (prev, next) {
  if (next == true && prev != true) {
    // Complete the round in Drift before navigating
    ref.read(appDatabaseProvider).roundDao.completeRound(roundId, DateTime.now());
    context.go('/round-review/$roundId');
  }
});
```

`completeRound()` exists in `RoundDao` from Phase 1. [VERIFIED: lib/data/local/database/daos/round_dao.dart]

---

## 8. Schema Decisions

### Schema version stays at 1 — no bump for Phase 2

The `Holes` table already has all required columns. Phase 2 only implements the empty `HoleDao` stub. No new columns, no new tables, no new indexes. [VERIFIED: lib/data/local/database/tables/holes_table.dart, lib/data/local/database/app_database.dart — schemaVersion: 1]

Because there is no schema change, no new `drift_schemas/` JSON dump is needed.

### Outcome string values stored in Drift

| HoleOutcome enum value | Stored string (`.name`) |
|------------------------|------------------------|
| `eagle` | `"eagle"` |
| `birdie` | `"birdie"` |
| `par` | `"par"` |
| `bogey` | `"bogey"` |
| `doubleBogey` | `"doubleBogey"` |
| `pickup` | `"pickup"` |

Always parse with `HoleOutcome.values.byName(stored)`. Never compare raw strings. The stored value for double bogey is `"doubleBogey"` — not `"double"`, not `"double_bogey"`. [VERIFIED: lib/domain/enums/hole_outcome.dart]

---

## 9. Recommended Plan Breakdown

Phase 2 delivers a vertical MVP — core outcome recording first, additive layers follow.

### Wave 1 — Core persistence (unblocks everything)

Files: `hole_dao.dart`, `course_for_round_provider.dart`, `hole_score_notifier.dart`

1. Implement `HoleDao.insertOrUpdateHole`, `getHolesForRound`, `watchHolesForRound`. Run `build_runner`.
2. Implement `courseForRoundProvider(roundId)` — reads `courseJson` from `RoundDao.getRoundById()`, deserializes `CourseModel.fromJson()`.
3. Implement `HoleScoreNotifier` — `recordOutcome()` only (putts/fairway/GIR in Wave 3). Run `build_runner`.
4. Smoke test: tap BIRDIE in debug console; verify `holes` row exists in Drift with `outcome = 'birdie'`.

### Wave 2 — Outcome flow UX (SHOT-01, SHOT-02, SHOT-03, SHOT-04, SHOT-10, SHOT-11)

Files: `shot_capture_screen.dart` (replace), `widgets/outcome_button_grid.dart`, `widgets/hole_header.dart`, `widgets/score_bar.dart`, `providers/hole_list_provider.dart`, `providers/running_score_provider.dart`

5. Replace `ShotCaptureScreen` placeholder with `ScoreBar` + `HoleHeader` + `OutcomeButtonGrid` layout.
6. Implement `OutcomeButtonGrid` with `GestureDetector` on BIRDIE for `onDoubleTap` EAGLE (SHOT-02).
7. Wire `activeHoleIndexProvider.notifier.set(nextIndex)` after outcome write (SHOT-03).
8. Implement undo toast (`persist: false`, `duration: 4s`, SnackBarAction with undo logic) (SHOT-04).
9. Implement `holeListProvider` + `runningScoreProvider` + `ScoreBar` widget (SHOT-10).
10. Implement `HoleHeader` with hole number, par, SI display from `courseForRoundProvider` (SHOT-11).
11. Wire `ref.listen(roundCompleteProvider)` → `context.go('/round-review/$roundId')`.
12. Smoke test end-to-end: score all 18 holes; verify score bar updates; verify undo works.

### Wave 3 — Secondary scoring controls (SHOT-05, SHOT-06, SHOT-07)

Files: updates to `hole_score_notifier.dart`, `widgets/putts_counter.dart`, `widgets/fairway_gir_toggles.dart`

13. Add `setPutts`, `setFairwayHit`, `setGir` to `HoleScoreNotifier`. Run `build_runner`.
14. Implement `PuttsCounter` widget (+/− with immediate Drift write, disabled at 0).
15. Implement `FairwayGirToggles` widget (absent on par 3 for fairway, always present for GIR).
16. Wire all three into `ShotCaptureScreen`.

### Wave 4 — Hole navigation and completion flow (SHOT-12)

Files: `providers/highest_scored_hole_index_provider.dart`, `providers/round_complete_provider.dart`, `widgets/hole_nav_drawer.dart`, `providers/round_setup_notifier.dart` (update)

17. Implement `highestScoredHoleIndexProvider` and `roundCompleteProvider`.
18. Implement `HoleNavDrawer` (hole chip strip, jump-to-hole, "NOW" button).
19. Wire `ref.listen(roundCompleteProvider)` → `context.go('/round-review/$roundId')` + `completeRound()`.
20. Fix `RoundSetupNotifier.createRound()` to reset `activeHoleIndexProvider` to 0 before returning (P2-08 fix).

### Wave 5 — Polish and verification

21. Haptic feedback: `HapticFeedback.mediumImpact()` on outcome tap (including EAGLE); `HapticFeedback.lightImpact()` on UNDO.
22. `flutter_animate` press animation on outcome buttons: scale 1.0→0.96→1.0, 80ms each.
23. `flutter analyze` — zero errors required.
24. Human verify all 6 Phase 2 success criteria from ROADMAP.md.

---

## 10. Files to Create or Update

| File | Action | Purpose |
|------|--------|---------|
| `lib/data/local/database/daos/hole_dao.dart` | UPDATE | Add `insertOrUpdateHole`, `getHolesForRound`, `watchHolesForRound` |
| `lib/features/shot_capture/shot_capture_screen.dart` | REPLACE | Full implementation replacing placeholder |
| `lib/features/shot_capture/providers/hole_score_notifier.dart` | CREATE | Primary write authority for all hole fields |
| `lib/features/shot_capture/providers/hole_list_provider.dart` | CREATE | Drift stream of all holes for round |
| `lib/features/shot_capture/providers/running_score_provider.dart` | CREATE | Score vs par computation |
| `lib/features/shot_capture/providers/course_for_round_provider.dart` | CREATE | CourseModel from Drift courseJson |
| `lib/features/shot_capture/providers/highest_scored_hole_index_provider.dart` | CREATE | Max navigable hole index (0-based) |
| `lib/features/shot_capture/providers/round_complete_provider.dart` | CREATE | Boolean: 18 holes with outcomes |
| `lib/features/shot_capture/widgets/outcome_button_grid.dart` | CREATE | 5 outcome buttons + EAGLE double-tap |
| `lib/features/shot_capture/widgets/hole_header.dart` | CREATE | Hole number, par, SI display |
| `lib/features/shot_capture/widgets/putts_counter.dart` | CREATE | +/− putts widget with immediate write |
| `lib/features/shot_capture/widgets/fairway_gir_toggles.dart` | CREATE | Fairway (par 3 gate) + GIR toggles |
| `lib/features/shot_capture/widgets/score_bar.dart` | CREATE | Running score always visible |
| `lib/features/shot_capture/widgets/hole_nav_drawer.dart` | CREATE | Hole navigation chip strip |
| `lib/features/setup/providers/round_setup_notifier.dart` | UPDATE | Reset `activeHoleIndexProvider` to 0 in `createRound()` |

---

## 11. Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Upsert semantics for hole rows | Custom SELECT-then-INSERT boilerplate | `HoleDao.insertOrUpdateHole()` (Pattern 1) | Single testable DAO method |
| Auto-dismiss toast with undo | Custom `OverlayEntry` with `Timer` | `ScaffoldMessenger.showSnackBar` + `persist: false` + `SnackBarAction` | Material-standard; handles queue, theme, accessibility |
| Score-vs-par computation | Riverpod state machine | Derived `runningScoreProvider` from Drift stream | Always in sync with source of truth; correct after restart and undo |
| Hole state isolation per hole | Single global hole state | Riverpod family provider `holeScoreNotifierProvider(roundId, holeIndex)` | Each hole gets its own provider instance; auto-disposes on transition |
| Animation on outcome tap | `AnimationController` + `Tween` | `flutter_animate` `.animate().scale()` chain | Already in pubspec; single-line syntax |

**Key insight:** The most common mistake in shot-capture screens is accumulating state in Riverpod and flushing to the database at round completion. The OS will kill the app mid-round. Write immediately on every user action; derive all display state from Drift.

---

## 12. Standard Stack

### Core (all from Phase 1 — no new packages)

| Library | Version | Purpose | Phase 2 Role |
|---------|---------|---------|--------------|
| `drift` | 2.19.1+1 | SQLite ORM | `HoleDao.insertOrUpdateHole()` — write-through persistence |
| `flutter_riverpod` | 2.6.1 | State management | `HoleScoreNotifier`, `runningScoreProvider`, `holeListProvider` |
| `riverpod_annotation` | 2.6.1 | Code gen for providers | All Phase 2 providers use `@riverpod` |
| `flutter_animate` | 4.5.2 | Micro-animations | Score button tap feedback |
| `haptic_feedback` | 0.5.1+2 | Haptic response | On outcome tap; on undo tap |
| `hive_flutter` | 1.1.0 | Course data access | Used indirectly via Drift `courseJson` deserialization |

**No new packages required for Phase 2.** [VERIFIED: pubspec.yaml analysis — all required libraries already declared]

### Package Legitimacy Audit

Phase 2 installs zero new packages. This section is omitted.

---

## 13. UI Design Contract (summary from 02-UI-SPEC.md)

The full UI-SPEC lives at `.planning/phase-02/02-UI-SPEC.md`. Key binding decisions for the planner:

**Screen structure (top to bottom):**
```
Scaffold (BrdyColors.background)
└── SafeArea
    └── Column (full height, no scroll)
        +-- ScoreBar              [~56dp, BrdyColors.surface]
        +-- HoleHeader            [~56dp, BrdyColors.surface]
        +-- Divider
        +-- FairwayGirToggles     [~48dp per row]
        +-- PuttsCounter          [~64dp]
        +-- Spacer
        +-- OutcomeButtonGrid     [2 rows x 80dp + 8dp gap = 168dp]
        +-- Divider
        +-- HoleNavDrawer         [56dp, BrdyColors.surface]
```

**Outcome button colors:**
- BIRDIE: `BrdyColors.accent` background, `BrdyColors.onAccent` text
- PAR / BOGEY: `BrdyColors.surface` background, `BrdyColors.onSurface` text
- DOUBLE / PICKUP: `BrdyColors.destructive` background, `BrdyColors.onDestructive` text
- Border radius: 0dp (brutalist)
- Row 1: BIRDIE | PAR | BOGEY (Expanded flex, equal width)
- Row 2: DOUBLE | PICKUP (Expanded flex, wider than row 1 individually)

**Copywriting (all uppercase, ASCII only):**
- Hole header: `"HOLE {n}"`, `"PAR {n}"`, `"SI {n}"` or `"SI –"`
- Score bar label: `"SCORE"`; values: `"E"`, `"+{n}"`, `"-{n}"` (ASCII hyphen)
- Putts label: `"PUTTS"`
- Fairway toggle: label `"FAIRWAY HIT"`, states `"HIT"` / `"MISS"`
- GIR toggle: label `"GIR"`, states `"GIR"` / `"NO GIR"`
- Undo toast content: `"{OUTCOME} — Hole {n}"` (e.g. `"BIRDIE — Hole 7"`)
- Undo toast action: `"UNDO"`
- Back-to-current button: `"NOW"`

---

## 14. Validation Architecture

`nyquist_validation: false` is set in `.planning/config.json`. [VERIFIED: .planning/config.json] No automated test framework is required.

### Manual verification checklist (maps to Phase 2 success criteria)

| Check | Requirement | Method |
|-------|-------------|--------|
| Outcome buttons appear immediately | SHOT-01, perf | Load round; time from tap to buttons visible |
| PAR tap writes to Drift; hole advances | SHOT-01, SHOT-03 | Tap PAR; verify hole header increments; verify Drift row |
| Double-tap BIRDIE records eagle | SHOT-02 | Double-tap BIRDIE hole 1; verify `outcome = 'eagle'` in Drift |
| Undo toast appears; 4-second auto-dismiss | SHOT-04 | Tap outcome; verify toast; wait 4s; verify auto-dismiss |
| UNDO tap reverts outcome and hole index | SHOT-04 | Tap outcome; tap UNDO within 4s; verify hole reverts |
| Putts +/− writes through immediately | SHOT-05 | Increment putts to 3; kill app; relaunch; verify putts = 3 |
| Fairway toggle absent on par 3 | SHOT-06 | Navigate to par 3 hole; verify no fairway toggle in widget tree |
| Fairway toggle visible on par 4/5 | SHOT-06 | Navigate to par 4/5; verify toggle present; toggle; verify Drift |
| GIR toggle writes through | SHOT-07 | Toggle GIR; verify `greenInRegulation = true` in Drift |
| Score bar persists across hole transitions | SHOT-10 | Score 3 holes (eagle, par, bogey); verify score bar shows `"E"` |
| Hole header shows number, par, SI | SHOT-11 | Verify hole 1 shows "HOLE 1", correct par, "SI {n}" or "SI –" |
| Navigate back to earlier hole | SHOT-12 | Score hole 1 (PAR); tap hole 1 chip from hole 3; verify hole 1 shown |
| Correction on earlier hole persists | SHOT-12 | Navigate back; change outcome; verify Drift updated; tap "NOW" |
| Round completes after hole 18 | Completion | Score all 18 holes; verify navigation to `/round-review/$roundId` |
| Crash recovery returns to correct hole | FOUND-02/03 | Score 5 holes; kill app; relaunch; verify `/shot-capture` at hole 6 |
| New round starts at hole 1 | P2-08 fix | Complete round; start new round; verify activeHoleIndex == 0 |
| `flutter analyze` clean | Code quality | Zero analyzer errors |

---

## 15. Risk Flags

### R1: A3 gate — Stroke Index availability is unverified

Stroke Index (`HoleModel.strokeIndex`) is nullable. It may be null for some or all courses from `golfcourseapi.com` until tested with a live API key and real course data. `HoleHeader` must always gracefully show "SI –" when null. SHOT-11 is not blocked, but SHOT-11's SI display will degrade gracefully rather than error. First live run must check the `/courses/{id}` API response to confirm whether SI data is present. [ASSUMED: A7 — see Assumptions Log]

### R2: `activeHoleIndexProvider` reset bug (P2-08)

`RoundSetupNotifier.createRound()` does not currently call `ref.read(activeHoleIndexProvider.notifier).set(0)` after creating the round. [VERIFIED: lib/features/setup/providers/round_setup_notifier.dart — no reset present] If a user completes an 18-hole round (provider ends at index 17) and immediately starts a new round, the new round opens on hole 18. This must be fixed in Wave 4.

### R3: `persist: false` SnackBar breaking change

Flutter 3.38 changed `SnackBar` with `action` to persist indefinitely by default. Omitting `persist: false` causes the undo toast to never auto-dismiss. This is a known breaking change documented at `docs.flutter.dev/release/breaking-changes/snackbar-with-action-behavior-update`. Plan tasks must include `persist: false` in all SnackBar implementations with actions.

### R4: GestureDetector scope for EAGLE

Placing `onDoubleTap` on any parent widget wrapping multiple buttons delays ALL those buttons by ~300ms. The double-tap detector must be scoped to the BIRDIE button widget exclusively. Verification: test each non-BIRDIE button for absence of 300ms delay.

### R5: `doubleBogey` string in Drift

The stored string for double bogey is `"doubleBogey"` (from `HoleOutcome.doubleBogey.name`). Any code that compares `h.outcome == "double"` will silently fail to match. Always use `HoleOutcome.values.byName(h.outcome!)`. Phase 3 stats code must follow this same rule.

### R6: `fairwayHit` nullability semantics

`null` means "par 3, not applicable" or "not yet set". `false` means "par 4/5, fairway missed". Writing `false` for a par 3 hole corrupts Phase 3 FIR% stats. The notifier-level guard is the second line of defence; the first is the widget being absent on par 3 holes.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `fairwayHit = false` (not null) is the correct Drift default for a par 4/5 hole when outcome is first recorded | HoleScoreNotifier | If `null` is preferred, toggle display logic needs a tri-state (null/false/true) rather than binary |
| A2 | Running score shows pickup as +2 (same as double bogey) | Running Score | Score display differs from golfer expectation during round; confirmed correct at Phase 3 WHS calculation |
| A3 | Score bar is positioned at the top of the screen (before hole content), not as a floating overlay | Screen layout | Layout conflict with outcome buttons if position differs |
| A4 | `HoleOutcome.values.byName(string)` is safe for all outcome strings stored in Drift | Running score provider | `ArgumentError` if a typo or unexpected string was stored |
| A5 | Resetting `activeHoleIndexProvider` to 0 in `createRound()` is the correct and complete fix for P2-08 | Risk Flags R2 | New round might still start on wrong hole if reset happens at wrong point in flow |
| A6 | 3+2 button row layout (row 1: BIRDIE/PAR/BOGEY, row 2: DOUBLE/PICKUP) is the correct arrangement | UI-SPEC | Confirmed in 02-UI-SPEC.md |
| A7 | Stroke Index from the API is available for most holes; graceful "–" display for null is sufficient | SHOT-11 / HoleHeader | If SI is always null, the display always shows "–" which is visible but not informative |

---

## Open Questions

1. **A3 gate — live API verification**
   - What we know: `HoleModel.strokeIndex` is nullable; "–" displayed gracefully when null
   - What's unclear: What fraction of real courses from `golfcourseapi.com` return SI data
   - Recommendation: Proceed with graceful null handling; mark as human-verify gate on first real device run

2. **Pickup running score**
   - What we know: Pickup = +2 for WHS (net double bogey), but net double bogey requires per-hole handicap strokes
   - What's unclear: Does the user expect the running score to reflect true WHS pickup value during the round?
   - Recommendation: Show +2 during round (simple, correct for display); compute true value in Phase 3 Round Review only. Confirmed as A2.

---

## Sources

### Primary (HIGH confidence — codebase verified)

- `lib/data/local/database/tables/holes_table.dart` — all column names, types, nullability confirmed
- `lib/data/local/database/daos/hole_dao.dart` — empty stub confirmed; Phase 2 implements it
- `lib/data/local/database/daos/round_dao.dart` — `completeRound()`, `getRoundById()` exist confirmed
- `lib/data/local/database/app_database.dart` — schemaVersion 1, `onUpgrade` stub confirmed
- `lib/domain/enums/hole_outcome.dart` — `doubleBogey` enum value name confirmed
- `lib/features/shot_capture/providers/active_hole_index_provider.dart` — keepAlive, 0-based, `set()` method confirmed
- `lib/features/setup/providers/active_round_id_provider.dart` — keepAlive confirmed
- `lib/features/setup/providers/round_setup_notifier.dart` — no `activeHoleIndexProvider` reset present (P2-08 confirmed)
- `lib/domain/models/course_model.dart` — `holes: List<HoleModel>`, `fromJson()` confirmed
- `lib/domain/models/hole_model.dart` — `par`, `strokeIndex` (nullable), GPS fields confirmed
- `CLAUDE.md` — architecture rules, keepAlive rules, navigation model, tap target sizes, Drift schema rules
- `.planning/config.json` — `nyquist_validation: false` confirmed

### Secondary (MEDIUM confidence — cited from official sources)

- `drift.simonbinder.eu/dart_api/writes/` — `insertOnConflictUpdate`, `DoUpdate`, SELECT-then-branch upsert patterns [CITED]
- `drift.simonbinder.eu/dart_api/streams/` — `watch()`, stream update semantics [CITED]
- `api.flutter.dev/flutter/widgets/GestureDetector-class.html` — `onDoubleTap` + `onTap` coexistence, gesture arena behavior [CITED]
- `docs.flutter.dev/release/breaking-changes/snackbar-with-action-behavior-update` — `persist: false` requirement for auto-dismiss SnackBar with action in Flutter 3.38+ [CITED]
- `flutter/flutter#50458` — `onDoubleTap` causing ~300ms delay on `onTap` — known open issue [CITED]

### Tertiary (LOW / ASSUMED — flagged in Assumptions Log)

- Pickup = +2 running display (A2) — reasonable convention; not explicit in REQUIREMENTS.md
- Score bar at top of screen (A3) — confirmed in 02-UI-SPEC.md layout spec
- `fairwayHit = false` default for par 4/5 at first record (A1) — reasonable; not explicitly specified

---

## Metadata

**Confidence breakdown:**
- HoleDao pattern: HIGH — Drift docs cited; Phase 1 schema verified from source
- HoleScoreNotifier: HIGH — Riverpod family notifier is standard; write-through from CLAUDE.md
- Running score provider: HIGH — Drift stream + derived provider is the established pattern
- EAGLE double-tap: HIGH — GestureDetector.onDoubleTap is the correct API; 300ms delay is documented
- Undo toast: HIGH — `persist: false` from official Flutter breaking-change docs
- Hole navigation: HIGH — architectural constraint verified in CLAUDE.md and existing provider
- Screen layout: HIGH — confirmed in 02-UI-SPEC.md
- Pickup running score display: LOW — convention assumed; not specified in REQUIREMENTS.md

**Research date:** 2026-05-17
**Valid until:** 2026-06-17 (stable packages; all packages unchanged from Phase 1)
