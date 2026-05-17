# Phase 2: Shot Capture — Research

**Researched:** 2026-05-17
**Domain:** Flutter shot-capture UI — Riverpod state, Drift write-through, gesture detection, undo toast, hole navigation
**Confidence:** HIGH (all critical paths verified against codebase, Drift docs, official Flutter API)

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SHOT-01 | Outcome buttons: BIRDIE / PAR / BOGEY / DOUBLE / PICKUP | `OutcomeButton` widget grid, `HoleScoreNotifier.recordOutcome()` → Drift write-through |
| SHOT-02 | EAGLE via double-tap BIRDIE | `GestureDetector.onDoubleTap` on BIRDIE button; delay handled by keeping BIRDIE and EAGLE separate gesture zones |
| SHOT-03 | Auto-advance to next hole immediately after outcome tap | `ActiveHoleIndex.notifier.set(index + 1)` after Drift write; no route push |
| SHOT-04 | 4-second auto-dismiss undo toast ("BIRDIE — Hole 7 [UNDO]") | `ScaffoldMessenger.showSnackBar` with `persist: false` + `duration: 4s` + `SnackBarAction` |
| SHOT-05 | Putts per hole via +/− counter | `HoleScoreNotifier.setPutts()` → immediate Drift write; no buffering |
| SHOT-06 | Fairway hit toggle (hidden on par 3s) | `par == 3` gate on visibility; `HoleScoreNotifier.setFairwayHit(bool?)` → Drift write |
| SHOT-07 | GIR toggle per hole | `HoleScoreNotifier.setGir(bool)` → Drift write |
| SHOT-10 | Running score vs par always visible | `runningScoreProvider(roundId)` — derived from Drift stream of all holes |
| SHOT-11 | Hole number, par, Stroke Index displayed prominently | Read from `CourseModel.holes[activeHoleIndex]` (Hive-cached); SI nullable → show "–" |
| SHOT-12 | Navigate back to any scored hole to correct entry | `activeHoleIndexProvider.notifier.set(targetIndex)` — internal state; no route pop |
</phase_requirements>

---

## Summary

Phase 2 replaces the `ShotCaptureScreen` placeholder with a fully functional hole-by-hole scoring screen. The screen must prioritize score entry speed — outcome buttons must appear instantly, and the write-through to Drift must be non-blocking from the user's perspective.

The primary technical pattern is: **optimistic UI update + immediate Drift write + reactive providers**. When a user taps an outcome button, three things happen in sequence within a single async call: (1) the hole row is inserted/updated in Drift, (2) `activeHoleIndexProvider` advances to the next hole, and (3) the undo SnackBar appears. Riverpod's `runningScoreProvider` derives the running score from a Drift stream that auto-updates on every write.

Hole navigation (SHOT-12) is entirely internal state — `activeHoleIndexProvider.notifier.set(index)`. There is never a GoRouter push for hole changes. The `highestScoredHoleIndex` concept (the furthest hole the user has progressed to) is a secondary provider that prevents the user from navigating beyond the current live hole.

The EAGLE double-tap (SHOT-02) requires a `GestureDetector.onDoubleTap` wrapper on the BIRDIE button only. The known 300ms single-tap delay from `kDoubleTapTimeout` affects BIRDIE single-taps. The accepted solution for a golf scoring app (where the user knows their score before tapping) is to tolerate this delay — they are not interacting while in motion. An alternative is to separate EAGLE into its own second-row button but that contradicts SHOT-02 which specifies double-tap. The `GestureDetector.onDoubleTap` approach is the correct implementation per the requirement.

**Primary recommendation:** Implement `HoleScoreNotifier` as the single authority for all hole writes. All five data points (outcome, putts, fairwayHit, GIR, recordedAt) write to Drift through this one notifier. The running score is a derived `FutureProvider` that reads from Drift on each state change via a stream.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Score entry (outcome tap) | Frontend / Presentation | Drift / Data (write-through) | UI captures gesture; data layer is the source of truth |
| Hole state (which hole is active) | Riverpod keepAlive (`activeHoleIndexProvider`) | — | Cross-screen persistent state; survives hole transitions |
| Round state (which round is active) | Riverpod keepAlive (`activeRoundIdProvider`) | — | Established in Phase 1; not changed |
| Per-hole data (outcome, putts, fairway, GIR) | Drift / Data | Riverpod (optimistic) | Write-through required; OS kill safety |
| Running score computation | Riverpod derived provider | Drift stream | Computed from hole records, not separate state |
| Hole metadata (par, SI, hole number) | Hive cache (CourseModel) | — | Cached at course load; no re-fetch |
| Undo toast | Presentation / ScaffoldMessenger | — | 4-second UI concern only; Drift already has the correct state |
| EAGLE gesture | Presentation / GestureDetector | — | Double-tap is a UI detection pattern |
| Round completion check | Riverpod derived provider | Drift | Derived: count scored holes == 18 |
| Hole back-navigation | Riverpod (`activeHoleIndexProvider`) | — | Internal state; no router involvement |

---

## Standard Stack

### Core (all from Phase 1 — no new packages needed)

| Library | Version | Purpose | Role in Phase 2 |
|---------|---------|---------|-----------------|
| `drift` | 2.19.1+1 | SQLite ORM | `HoleDao.insertOrUpdateHole()` — write-through persistence |
| `flutter_riverpod` | 2.6.1 | State management | `HoleScoreNotifier`, `runningScoreProvider`, `holeListProvider` |
| `riverpod_annotation` | 2.6.1 | Code gen for providers | All Phase 2 providers use `@riverpod` |
| `flutter_animate` | 4.5.2 | Micro-animations | Score button tap feedback; undo toast slide-in |
| `haptic_feedback` | 0.5.1+2 | Haptic response | On outcome tap, on undo tap |
| `hive_flutter` | 1.1.0 | Course data access | Read `CourseModel` from Hive cache to get par, SI, hole count |

**No new packages required for Phase 2.** All libraries needed are already declared in `pubspec.yaml` and initialized in `main.dart`. [VERIFIED: pubspec.yaml, codebase analysis]

### Phase 2 has no new package installations

The Package Legitimacy Audit section is omitted — Phase 2 installs zero new packages.

---

## Architecture Patterns

### System Architecture Diagram

```
User taps OUTCOME button (BIRDIE / PAR / BOGEY / DOUBLE / PICKUP)
         │
         ▼
ShotCaptureScreen (ConsumerStatefulWidget)
         │
         ├── reads: activeRoundIdProvider (keepAlive) ─────────────────────────────┐
         │                                                                          │
         ├── reads: activeHoleIndexProvider (keepAlive) ────────────────────────┐  │
         │                                                                       │  │
         ├── reads: courseForRoundProvider(roundId) ─────── HiveCourseBox ──────┼──┘
         │            (loads CourseModel from Hive cache)                        │
         │                                                                       │
         └── calls: HoleScoreNotifier(roundId, holeIndex).recordOutcome(outcome)│
                      │                                                          │
                      ├── 1. INSERT OR UPDATE holes row in Drift ◄───────────────┘
                      │      (HoleDao.insertOrUpdateHole)
                      │      Fields: roundId, holeNumber, par, strokeIndex,
                      │              outcome, recordedAt = DateTime.now()
                      │
                      ├── 2. activeHoleIndexProvider.notifier.set(holeIndex + 1)
                      │      (if holeIndex < 17; else trigger round completion)
                      │
                      └── 3. ScaffoldMessenger.showSnackBar(undo toast)
                               persist: false, duration: 4s, action: UNDO
                               onUndo: HoleScoreNotifier.undoLastOutcome()
                                         ├── activeHoleIndexProvider.notifier.set(prev)
                                         └── clear outcome in Drift hole row

Reactive updates:
runningScoreProvider(roundId) ──── watches Drift stream of all holes for round
         │                         auto-recalculates score vs par on every write
         │
         └── ScoreBar widget rebuilds with new score string (e.g. "+2")

holeListProvider(roundId) ──────── Stream<List<Hole>> from Drift
         │                          drives hole-navigation drawer (SHOT-12)
         └── ScoredHoleTile widgets (coloured by outcome)
```

### Recommended Project Structure for Phase 2

```
lib/features/shot_capture/
├── shot_capture_screen.dart          REPLACE placeholder with full impl
├── providers/
│   ├── active_hole_index_provider.dart   EXISTS (Phase 1)
│   ├── hole_score_notifier.dart          CREATE — primary write authority
│   ├── running_score_provider.dart       CREATE — derived score vs par
│   ├── hole_list_provider.dart           CREATE — Stream<List<Hole>> for navigation
│   └── course_for_round_provider.dart    CREATE — reads CourseModel from Hive
└── widgets/
    ├── outcome_button_grid.dart          CREATE — 5 buttons + EAGLE double-tap
    ├── hole_header.dart                  CREATE — hole number, par, SI display
    ├── putts_counter.dart                CREATE — +/− counter widget
    ├── fairway_gir_toggles.dart          CREATE — FW toggle (hidden par3) + GIR toggle
    ├── score_bar.dart                    CREATE — running score always visible
    └── hole_nav_drawer.dart              CREATE — swipe or button to navigate history

lib/data/local/database/daos/
└── hole_dao.dart                    UPDATE — add insertOrUpdateHole, getHolesForRound, watchHolesForRound

lib/domain/repositories/
└── round_repository.dart            NO CHANGE — Phase 2 works via HoleDao directly
```

---

## Pattern 1: HoleDao — insertOrUpdate (upsert)

**What:** Single DAO method handles both first-score insert and correction-update on the same hole row.

**Why:** Drift's `insertOnConflictUpdate` generates `INSERT OR REPLACE` SQL. Since `Holes.id` is the autoincrement primary key and not a composite key, we need a different approach: check for existing row by `(roundId, holeNumber)`, then insert or update. The cleanest pattern is a custom unique index plus `DoUpdate`. [CITED: drift.simonbinder.eu/dart_api/writes/]

**Drift schema consideration:** The existing `Holes` table (Phase 1 schema v1) has no unique constraint on `(roundId, holeNumber)`. Two approaches exist:

Option A — No schema change: Use a SELECT-then-INSERT-or-UPDATE in the DAO (two queries).
Option B — Add unique index: Add `@TableIndex.onColumns(#roundId, #holeNumber, unique: true)` to the Holes table, bump schemaVersion to 2, add `onUpgrade` migration. Then use `insertOnConflictUpdate`. [CITED: drift.simonbinder.eu/dart_api/writes/]

**Recommendation: Option A (no schema change)** to avoid a schemaVersion bump for what is essentially an implementation detail. The DAO method does a `getSingleOrNull` then branches:

```dart
// lib/data/local/database/daos/hole_dao.dart
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

**Drift schema stays at v1 — no bump required for Phase 2.** [VERIFIED: Phase 1 schema analysis — no structural table changes needed]

**Note:** After updating `hole_dao.dart`, run `dart run build_runner build --delete-conflicting-outputs` to regenerate `hole_dao.g.dart`. The `_$HoleDaoMixin` includes generated query helpers.

---

## Pattern 2: HoleScoreNotifier — Primary Write Authority

**What:** A `@riverpod` `AsyncNotifier` scoped to `(roundId, holeIndex)` that owns all writes to a single hole row.

**When to use:** Outcome tap, putts change, fairway toggle, GIR toggle. All five data points route through this one notifier.

```dart
// lib/features/shot_capture/providers/hole_score_notifier.dart
part 'hole_score_notifier.g.dart';

@riverpod
class HoleScoreNotifier extends _$HoleScoreNotifier {
  // build reads the current hole state from Drift (nullable if not yet scored)
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
      outcome: Value(outcome.name),  // stored as string e.g. 'doubleBogey'
      recordedAt: Value(DateTime.now()),
    ));
    // Refresh own state
    ref.invalidateSelf();
  }

  Future<void> setPutts(int putts) async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return; // must score before setting putts
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
}
```

**Key design decisions:**
- `holeIndex` is 0-based (matches `activeHoleIndexProvider`); `holeNumber` = `holeIndex + 1`
- `outcome` stored as `HoleOutcome.name` string in Drift — `'eagle'`, `'birdie'`, `'par'`, `'bogey'`, `'doubleBogey'`, `'pickup'` [VERIFIED: codebase hole_outcome.dart, holes_table.dart]
- `fairwayHit` is `null` for par 3 holes (not a `bool` — `null` means N/A, not "missed") [VERIFIED: Phase 1 schema]
- The notifier is auto-dispose (`@riverpod` not `@Riverpod(keepAlive:true)`) — it rebuilds when the hole changes, which is correct
- `ref.invalidateSelf()` after each write causes the provider to rerun `build()` and pick up the new Drift state

---

## Pattern 3: Running Score Provider

**What:** A derived provider that computes total score vs par across all scored holes for the active round.

**Design:** Use a Drift `watchHolesForRound` stream exposed via a `StreamProvider`, then derive the score via a `Provider` that reads it.

```dart
// lib/features/shot_capture/providers/hole_list_provider.dart
part 'hole_list_provider.g.dart';

@riverpod
Stream<List<Hole>> holeList(Ref ref, int roundId) {
  final db = ref.watch(appDatabaseProvider);
  return db.holeDao.watchHolesForRound(roundId);
}
```

```dart
// lib/features/shot_capture/providers/running_score_provider.dart
part 'running_score_provider.g.dart';

@riverpod
int? runningScore(Ref ref, int roundId) {
  // Returns null while loading, or the score-vs-par integer (+2, -1, E)
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.whenData((holes) {
    int score = 0;
    for (final h in holes) {
      if (h.outcome == null) continue;
      final outcome = HoleOutcome.values.byName(h.outcome!);
      // strokes = par + offset
      final offset = switch (outcome) {
        HoleOutcome.eagle      => -2,
        HoleOutcome.birdie     => -1,
        HoleOutcome.par        =>  0,
        HoleOutcome.bogey      => +1,
        HoleOutcome.doubleBogey => +2,
        HoleOutcome.pickup     => +2, // treated as double bogey for running display
      };
      score += offset;
    }
    return score;
  }).value;  // .value is null during loading
}
```

**Display:** `ScoreBar` shows `E` for 0, `+{n}` for positive, `−{n}` for negative. [ASSUMED — standard golf display convention]

**Why not keep score in Riverpod state directly?** Writing score to Riverpod state separately from Drift would create two sources of truth. The write-through mandate (CLAUDE.md) means Drift is always current. Deriving from Drift ensures score is correct after app restart and after undo. [VERIFIED: CLAUDE.md Critical Don'ts]

---

## Pattern 4: EAGLE Double-Tap (SHOT-02)

**What:** BIRDIE button wrapped in `GestureDetector` with both `onTap` (BIRDIE) and `onDoubleTap` (EAGLE).

**Known limitation:** When `onDoubleTap` is set on a `GestureDetector`, the `onTap` callback fires after the `kDoubleTapTimeout` window (~300ms) elapses. This is a known Flutter behavior tracked at [flutter/flutter#50458](https://github.com/flutter/flutter/issues/50458). On a golf scoring app, 300ms is acceptable — the golfer has time to deliberate. [CITED: api.flutter.dev/flutter/widgets/GestureDetector-class.html]

```dart
// In OutcomeButtonGrid widget — BIRDIE button only:
GestureDetector(
  onTap: () => _recordOutcome(HoleOutcome.birdie),
  onDoubleTap: () => _recordOutcome(HoleOutcome.eagle),
  child: OutcomeButton(label: 'BIRDIE', color: BrdyColors.accent),
)

// All other buttons (PAR, BOGEY, DOUBLE, PICKUP) use InkWell:
InkWell(
  onTap: () => _recordOutcome(HoleOutcome.par),
  child: OutcomeButton(label: 'PAR', ...),
)
```

**Anti-pattern to avoid:** Do NOT put `onDoubleTap` on a parent `GestureDetector` that wraps all buttons — this delays ALL button taps by 300ms. The double-tap detector must be scoped to the BIRDIE button only.

**Visual distinction:** EAGLE outcome is displayed identically to `HoleOutcome.eagle` in the scorecard (gold `#FFD700`). The running score computation treats eagle as −2. [VERIFIED: REQUIREMENTS.md — SHOT-02 "displayed as distinct from birdie in all stats"]

---

## Pattern 5: Undo Toast (SHOT-04)

**What:** Auto-dismissing SnackBar with "UNDO" action, 4 seconds, using `persist: false`.

**Breaking change awareness:** As of Flutter stable circa 3.38, `SnackBar` with an `action` no longer auto-dismisses by default. Must set `persist: false` to restore 4-second auto-dismiss. [CITED: docs.flutter.dev/release/breaking-changes/snackbar-with-action-behavior-update]

```dart
// In ShotCaptureScreen, called after recordOutcome() completes:
void _showUndoToast(BuildContext context, HoleOutcome outcome, int holeNumber) {
  final label = outcome.name.toUpperCase(); // 'EAGLE', 'BIRDIE', etc.
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()  // dismiss any existing toast first
    ..showSnackBar(
      SnackBar(
        content: Text(
          '$label — Hole $holeNumber',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: BrdyColors.onSurface,
          ),
        ),
        backgroundColor: BrdyColors.surface,
        duration: const Duration(seconds: 4),
        persist: false,  // REQUIRED — restores auto-dismiss with action
        action: SnackBarAction(
          label: 'UNDO',
          textColor: BrdyColors.accent,
          onPressed: () => _undoLastOutcome(context),
        ),
      ),
    );
}
```

**Undo logic:**
1. Store `_lastScoredHoleIndex` in local widget state (or the notifier).
2. On UNDO tap: call `HoleScoreNotifier(roundId, lastHoleIndex).undoOutcome()` which clears the `outcome` field in Drift (sets to `null`), then sets `activeHoleIndexProvider` back to `lastHoleIndex`.
3. The hole header and score bar both react via their Drift-stream providers.

**Undo is only valid for the immediately preceding hole** — toast auto-dismisses after 4 seconds, making multi-level undo impossible by design.

**SnackBar position:** Default (bottom). Do not float over the score buttons. [ASSUMED — standard Material bottom position]

---

## Pattern 6: Putts +/− Counter (SHOT-05)

**What:** Two `IconButton` widgets (minus, plus) with a `Text` displaying current putts count.

**Write-through timing:** Write to Drift on EVERY tap of +/−, not on a debounce or on-blur. The write-through mandate requires immediate persistence. This means every +/− tap triggers `HoleScoreNotifier.setPutts()` → Drift write. [VERIFIED: CLAUDE.md FOUND-01]

**Putts range:** 0–8. Minimum clamps at 0. No maximum enforced (pathological rounds).

```dart
// PuttsCounter widget (ConsumerWidget, accepts roundId + holeIndex):
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      icon: const Icon(Icons.remove),
      iconSize: 32,
      onPressed: putts > 0
          ? () => ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                    .setPutts(putts - 1)
          : null,
    ),
    SizedBox(
      width: 64,
      child: Text(
        '$putts',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall,  // JetBrains Mono 28dp
      ),
    ),
    IconButton(
      icon: const Icon(Icons.add),
      iconSize: 32,
      onPressed: () => ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                          .setPutts(putts + 1),
    ),
  ],
)
```

**Source of `putts` value:** `ref.watch(holeScoreNotifierProvider(roundId, holeIndex))` → `.value?.putts ?? 0`. The provider builds from Drift, so putts value is always from the source of truth.

---

## Pattern 7: Fairway Hit + GIR Toggles (SHOT-06, SHOT-07)

**What:** Two toggle buttons. Fairway hit is hidden entirely on par 3 holes. GIR is always shown.

**Par 3 detection:** Read from `CourseModel.holes[holeIndex].par`. If `par == 3`, do not render the fairway toggle widget at all (not just disabled — completely absent from the tree).

```dart
// FairwayGirToggles widget:
Column(
  children: [
    if (holePar != 3)
      _ToggleRow(
        label: 'FAIRWAY HIT',
        value: fairwayHit,  // bool? — null = not yet set
        onChanged: (v) => notifier.setFairwayHit(v),
      ),
    _ToggleRow(
      label: 'GIR',
      value: gir,
      onChanged: (v) => notifier.setGir(v),
    ),
  ],
)
```

**Drift storage:** `fairwayHit` is `BoolColumn.nullable()` — `null` means "par 3, not applicable" OR "not yet set". For correctness, only write `null` for par 3 holes (not set after outcome recorded). For par 4/5, write `false` as the default when outcome is first recorded. [ASSUMED — reasonable default; confirm with user if needed]

**Toggle UI:** Two-state toggle (hit / missed) using a custom styled `ToggleButtons` or a pair of `OutlinedButton` widgets. Background: `BrdyColors.accent` when hit, `BrdyColors.surface` when missed/null. Tap target: minimum 64×48dp. [VERIFIED: CLAUDE.md — 64×80dp reserved for score buttons specifically; 48dp minimum elsewhere]

---

## Pattern 8: Hole Navigation — Jump to Any Previously Scored Hole (SHOT-12)

**What:** User can tap a hole number (in a navigation strip or drawer) to jump to that hole's entry, correct it, and return to the current active hole.

**Implementation:** Two providers work together:
1. `activeHoleIndexProvider` — which hole is currently shown (can be set to any previous hole)
2. `highestScoredHoleIndexProvider(roundId)` — derived from `holeListProvider`; equals the count of scored holes minus 1 (or 0)

```dart
// highestScoredHoleIndexProvider — prevents forward navigation past scored holes
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

**Navigation strip (HoleNavDrawer):** A horizontal `ListView` of 18 `HoleChip` widgets. Each chip shows the hole number; scored holes show outcome color. Tapping a chip calls `ref.read(activeHoleIndexProvider.notifier).set(targetIndex)`. Chips for holes beyond `highestScoredHoleIndex + 1` are disabled (cannot jump forward into unscored holes).

**Return to current hole:** A "BACK TO CURRENT" button appears when `activeHoleIndex < highestScoredHoleIndex`. Tapping it calls `ref.read(activeHoleIndexProvider.notifier).set(highestScoredHoleIndex)`.

**Key rule (CLAUDE.md):** Hole navigation is NEVER a GoRouter push. No route back-stack accumulates. [VERIFIED: CLAUDE.md architecture constraints]

---

## Pattern 9: Running Score Bar (SHOT-10)

**What:** A persistent top bar (or bottom overlay) showing the running score vs par across all transitions.

**Widget:** `ScoreBar` — a `ConsumerWidget` that reads `runningScoreProvider(roundId)`. Positioned outside the hole-content area so it does not disappear during hole transitions. Implemented as part of `ShotCaptureScreen`'s `Scaffold` body top section, not as a floating overlay.

**Display format:**
- Score == 0 → `E` (even par)
- Score > 0 → `+{score}` in white (`onSurface`)
- Score < 0 → `−{abs(score)}` in accent orange (`accent`, implies under par)

**Typography:** JetBrains Mono (`displaySmall`, 28dp bold) for the score number. Barlow Condensed (`bodySmall`) for the label "SCORE" or hole count context. [VERIFIED: UI-SPEC Phase 1 typography tokens — same system applies]

---

## Pattern 10: Round Completion Flow

**What:** After scoring hole 18 (holeIndex == 17), navigate to `/round-review/$roundId`.

**Trigger:** Inside `HoleScoreNotifier.recordOutcome()`, after advancing `activeHoleIndexProvider`:

```dart
// In HoleScoreNotifier.recordOutcome(), after Drift write:
final nextIndex = holeIndex + 1;
if (nextIndex >= 18) {
  // All 18 holes scored — complete the round
  final db = ref.read(appDatabaseProvider);
  await db.roundDao.completeRound(roundId, DateTime.now());
  // Navigation from within a notifier is wrong — use ref.listen in screen
  // Signal completion via a separate provider
} else {
  ref.read(activeHoleIndexProvider.notifier).set(nextIndex);
}
```

**Navigation pattern:** The notifier must NOT call `context.go()` directly (notifiers do not have context). Use `ref.listen` in the screen widget:

```dart
// In ShotCaptureScreen.build():
ref.listen<bool>(roundCompleteProvider(roundId), (prev, next) {
  if (next) {
    context.go('/round-review/$roundId');
  }
});
```

```dart
// roundCompleteProvider:
@riverpod
bool roundComplete(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.whenData((holes) =>
    holes.where((h) => h.outcome != null).length >= 18
  ).value ?? false;
}
```

**`completeRound()` in RoundDao** already exists from Phase 1 (`completeRound(id, DateTime.now())`). [VERIFIED: lib/data/local/database/daos/round_dao.dart]

**Navigation:** `context.go('/round-review/$roundId')` — replaces the stack, no back button to Shot Capture. [VERIFIED: CLAUDE.md navigation model]

---

## Pattern 11: Course Data for a Round

**What:** Phase 2 needs `CourseModel` (par, SI per hole) from Hive during shot capture. The round has a `courseJson` column (stored at round creation in Phase 1).

**Two options:**
- Option A: Read `courseJson` from the Drift `rounds` row and deserialize `CourseModel.fromJson(jsonDecode(courseJson))`.
- Option B: Read from Hive `course_cache` using `lastUsedCourseId`.

**Recommendation: Option A — use `courseJson` from the Drift rounds row.** This is the correct approach because: (1) the exact course data used at round start is persisted in the round itself, (2) it works correctly if the user loads a different course in Hive between sessions, and (3) it is the crash-recovery path that works without Hive. [VERIFIED: Phase 1 schema — `rounds.courseJson` text column exists]

```dart
// lib/features/shot_capture/providers/course_for_round_provider.dart
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

This provider is auto-dispose (`@riverpod`) and caches within the screen's lifetime.

---

## Pattern 12: HoleScoreNotifier is parameterized (family)

The notifier takes `(int roundId, int holeIndex)` as family parameters, generated via Riverpod code-gen:

```dart
@riverpod
class HoleScoreNotifier extends _$HoleScoreNotifier {
  @override
  Future<Hole?> build(int roundId, int holeIndex) async { ... }
}
// Generated: holeScoreNotifierProvider(roundId, holeIndex)
```

When `activeHoleIndexProvider` changes (user taps a different hole), the `ShotCaptureScreen` rebuilds and watches `holeScoreNotifierProvider(roundId, newHoleIndex)`. The old notifier auto-disposes. This gives clean isolation between hole states without manual cleanup. [VERIFIED: Riverpod 2.x family pattern — standard]

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Upsert semantics for hole rows | Custom SELECT-then-INSERT/UPDATE boilerplate | `HoleDao.insertOrUpdateHole()` (Pattern 1 above) | Single DAO method; testable |
| Auto-dismiss toast with undo | Custom `OverlayEntry` with `Timer` | `ScaffoldMessenger.showSnackBar` + `persist: false` + `SnackBarAction` | Material-standard; handles queue, theme, accessibility |
| Score-vs-par computation | Riverpod state machine | Derived `runningScoreProvider` from Drift stream | Always in sync with source of truth; crash-safe |
| Hole state isolation per hole | Single global hole state | Riverpod family provider `holeScoreNotifierProvider(roundId, holeIndex)` | Each hole gets its own provider instance; auto-dispose on transition |
| Animation on outcome tap | `AnimationController` + `Tween` | `flutter_animate` `.animate().fadeIn().scale()` | Already in pubspec; 1-line chain syntax |

**Key insight:** The biggest mistake in shot-capture screens is accumulating state in Riverpod and flushing to DB on round completion. OS will kill the app mid-round. Write immediately on every user action; derive display state from Drift.

---

## Common Pitfalls

### Pitfall P2-01: Buffering outcome state in Riverpod before writing to Drift
**What goes wrong:** App is killed between hole 12 and hole 13; holes 1–12 are in Riverpod state but only holes 1–11 are in Drift. Crash recovery restores to hole 12 instead of hole 13.
**Why it happens:** Developer treats Drift write as a "save" action rather than "immediate persistence."
**How to avoid:** Every tap of any scoring control writes immediately via `HoleDao`. Update Riverpod state by calling `ref.invalidateSelf()` after the Drift write — Riverpod state is always derived from Drift.
**Warning signs:** Any `async` gap between user action and `db.holeDao.*` call.

### Pitfall P2-02: Using `context.push()` for hole navigation
**What goes wrong:** 18 hole screens are pushed onto the GoRouter stack. Android back button goes back through all 18 holes.
**Why it happens:** Treating hole transitions like page navigation.
**How to avoid:** Hole navigation is `ref.read(activeHoleIndexProvider.notifier).set(index)` only. `ShotCaptureScreen` is a single route; internal state drives which hole is displayed. [VERIFIED: CLAUDE.md]
**Warning signs:** Any call to `context.push('/shot-capture/...')` in the codebase.

### Pitfall P2-03: Putting `onDoubleTap` on a parent container wrapping all buttons
**What goes wrong:** All 5 outcome buttons now have 300ms single-tap delay because the parent GestureDetector's double-tap recognizer is in the gesture arena for every tap event.
**Why it happens:** Developer wraps the entire button grid in a GestureDetector to "keep it centralized."
**How to avoid:** Double-tap detector goes on the BIRDIE button widget ONLY. All other buttons use plain `InkWell.onTap`. [CITED: flutter/flutter#50458]
**Warning signs:** `GestureDetector(onDoubleTap: ...)` wrapping a `Row` or `Column` of multiple buttons.

### Pitfall P2-04: SnackBar with action that never auto-dismisses
**What goes wrong:** The undo toast stays on screen permanently because `persist` defaults to `null` (persistent) when `action` is set in Flutter 3.38+.
**Why it happens:** Developer follows pre-3.38 SnackBar examples that did not need `persist: false`.
**How to avoid:** Always set `persist: false` when using `SnackBarAction` and needing auto-dismiss. [CITED: docs.flutter.dev/release/breaking-changes/snackbar-with-action-behavior-update]
**Warning signs:** Undo toast remains visible indefinitely during manual testing.

### Pitfall P2-05: `fairwayHit = false` written for par 3 holes
**What goes wrong:** Par 3 fairway data corrupts stats in Phase 3. FIR% calculation becomes wrong because par 3 holes are counted as "fairway missed."
**Why it happens:** Default state of a boolean toggle is `false` rather than `null`.
**How to avoid:** When inserting the first hole row for a par 3, write `fairwayHit: const Value(null)` (Drift `Value.null`-equivalent is `Value<bool?>(null)`). Never write `false` for a par 3 fairway. [VERIFIED: Phase 1 schema — `fairwayHit BoolColumn.nullable()`]
**Warning signs:** FIR% in Phase 3 includes par 3 holes.

### Pitfall P2-06: HoleOutcome enum name vs Drift string mismatch
**What goes wrong:** `HoleOutcome.doubleBogey.name` returns the string `'doubleBogey'`, not `'double'`. If Phase 3 stats code expects `'double'` it breaks.
**Why it happens:** The enum value is `doubleBogey` (to avoid Dart keyword collision), but consumers may assume the stored string is `'double'`.
**How to avoid:** Consistently use `HoleOutcome.values.byName(h.outcome!)` to parse stored strings. Never compare raw strings to `'double'`. [VERIFIED: lib/domain/enums/hole_outcome.dart — enum is `doubleBogey`]
**Warning signs:** Any hardcoded `'double'` string comparison against `h.outcome`.

### Pitfall P2-07: Navigating to Round Review from inside a notifier
**What goes wrong:** `HoleScoreNotifier.recordOutcome()` tries to call `context.go('/round-review/$roundId')` — notifiers do not have `BuildContext`.
**Why it happens:** Developers conflate business logic (notifier) with navigation (context).
**How to avoid:** Use a `roundCompleteProvider` boolean provider; the screen listens via `ref.listen` and calls `context.go()` from the widget tree. [ASSUMED — standard Riverpod pattern; consistent with existing Phase 1 router pattern]

### Pitfall P2-08: `activeHoleIndexProvider` not reset when starting a new round
**What goes wrong:** After completing a round and navigating to Round Review, then starting a new round, `activeHoleIndexProvider` is still 17 (last hole) — new round starts on hole 18.
**Why it happens:** `activeHoleIndexProvider` is `keepAlive: true` and persists across navigation.
**How to avoid:** Reset `activeHoleIndexProvider` to 0 when a new round begins. The setup screen's `roundSetupNotifierProvider.createRound()` should call `ref.read(activeHoleIndexProvider.notifier).set(0)` after creating the round. [ASSUMED — logical requirement; verify against existing `RoundSetupNotifier`]

---

## Code Examples

### Running Score Display

```dart
// Source: Pattern 9 above + BrdyColors/BrdyTextTheme (Phase 1)
class ScoreBar extends ConsumerWidget {
  final int roundId;
  const ScoreBar({super.key, required this.roundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(runningScoreProvider(roundId));
    final display = switch (score) {
      null  => '–',
      0     => 'E',
      > 0   => '+$score',
      _     => '$score',  // negative shows as -1, -2 etc
    };
    return Container(
      color: BrdyColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: BrdySpacing.md,
        vertical: BrdySpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('SCORE', style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: BrdyColors.onSurfaceMuted)),
          Text(
            display,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: (score ?? 0) < 0 ? BrdyColors.accent : BrdyColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Outcome Button Grid Layout

```dart
// Brutalist layout: 2 rows, 3+2 arrangement
// Row 1: BIRDIE (double-tap), PAR, BOGEY
// Row 2: DOUBLE, PICKUP
// Score button minimum 64×80dp (CLAUDE.md)
Column(
  children: [
    Row(
      children: [
        _birdieButton(context, ref),   // GestureDetector with onTap + onDoubleTap
        _outcomeButton(context, ref, HoleOutcome.par),
        _outcomeButton(context, ref, HoleOutcome.bogey),
      ],
    ),
    Row(
      children: [
        _outcomeButton(context, ref, HoleOutcome.doubleBogey),
        _outcomeButton(context, ref, HoleOutcome.pickup),
      ],
    ),
  ],
)
```

### HoleHeader — Hole Number, Par, Stroke Index

```dart
// Source: Pattern derivation from UI-SPEC typography tokens
class HoleHeader extends ConsumerWidget {
  final int roundId;
  const HoleHeader({super.key, required this.roundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holeIndex = ref.watch(activeHoleIndexProvider);
    final courseAsync = ref.watch(courseForRoundProvider(roundId));

    return courseAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (course) {
        if (course == null) return const SizedBox.shrink();
        final hole = course.holes[holeIndex]; // HoleModel
        final siDisplay = hole.strokeIndex?.toString() ?? '–';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HOLE ${holeIndex + 1}',
              style: Theme.of(context).textTheme.displaySmall,  // JetBrains Mono 28dp
            ),
            Text('PAR ${hole.par}',
                style: Theme.of(context).textTheme.labelLarge),  // Barlow Condensed 18dp
            Text('SI $siDisplay',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: BrdyColors.onSurfaceMuted)),
          ],
        );
      },
    );
  }
}
```

---

## Implementation Order / Wave Structure

Phase 2 delivers a **vertical MVP** — working outcome tap with write-through first, then additive layers.

### Wave 1 — Core persistence (unblocks everything)

1. **Implement `HoleDao` methods**: `insertOrUpdateHole`, `getHolesForRound`, `watchHolesForRound`. Run `build_runner`.
2. **Implement `courseForRoundProvider`**: reads `courseJson` from Drift rounds row, deserializes `CourseModel`.
3. **Implement `HoleScoreNotifier`** (outcome + recordedAt only — putts/fairway/GIR to follow). Run `build_runner`.
4. **Smoke test**: tap BIRDIE on hole 1, verify `holes` row in Drift with `outcome = 'birdie'`.

### Wave 2 — Outcome flow UX (SHOT-01, SHOT-02, SHOT-03, SHOT-04)

5. **Replace `ShotCaptureScreen` placeholder** with `HoleHeader` + `OutcomeButtonGrid` + `ScoreBar` layout.
6. **Implement `OutcomeButtonGrid`** with `GestureDetector` on BIRDIE for double-tap EAGLE (SHOT-02).
7. **Wire `activeHoleIndexProvider.notifier.set(nextIndex)`** after outcome write (SHOT-03).
8. **Implement undo toast** `showSnackBar(persist: false, duration: 4s)` (SHOT-04).
9. **Implement `runningScoreProvider`** and `ScoreBar` widget (SHOT-10).
10. **Implement `HoleHeader`** with par, hole number, SI display (SHOT-11).
11. **Smoke test end-to-end**: score all 18 holes, verify score bar updates, verify undo works.

### Wave 3 — Secondary scoring controls (SHOT-05, SHOT-06, SHOT-07)

12. **Add putts to `HoleScoreNotifier`** (`setPutts` method). Run `build_runner`.
13. **Implement `PuttsCounter` widget** (+/− with immediate Drift write).
14. **Add fairwayHit and GIR to `HoleScoreNotifier`** (`setFairwayHit`, `setGir`).
15. **Implement `FairwayGirToggles` widget** with par 3 fairway gate.
16. **Wire all three into `ShotCaptureScreen`**.

### Wave 4 — Hole navigation and round completion (SHOT-12, round-complete flow)

17. **Implement `highestScoredHoleIndexProvider`** and `roundCompleteProvider`.
18. **Implement `HoleNavDrawer`** (hole chip strip, jump-to-hole, back-to-current).
19. **Wire `ref.listen(roundCompleteProvider)` → `context.go('/round-review/$roundId')`** in screen.
20. **Call `roundDao.completeRound()`** when all 18 holes scored.
21. **Reset `activeHoleIndexProvider` to 0** in `RoundSetupNotifier.createRound()` (P2-08 fix).

### Wave 5 — Polish and verification

22. **Haptic feedback** on outcome tap (`HapticFeedback.mediumImpact`) and undo (`HapticFeedback.lightImpact`).
23. **flutter_animate** entry animations: hole header slide-in on hole change, score bar pulse on score change.
24. **Human verify** all 6 success criteria from ROADMAP.md Phase 2.

---

## Drift Schema Assessment

**Schema version stays at 1 — no bump required for Phase 2.**

The existing `Holes` table schema from Phase 1 has all required columns:
- `roundId`, `holeNumber`, `par`, `strokeIndex` (nullable) — hole metadata
- `outcome` (nullable text) — outcome string
- `putts` (nullable int)
- `fairwayHit` (nullable bool)
- `greenInRegulation` (nullable bool)
- `recordedAt` (nullable datetime)

The only change is implementing the empty `HoleDao` methods. No new columns, no new tables. [VERIFIED: lib/data/local/database/tables/holes_table.dart]

**If a unique index is desired on `(roundId, holeNumber)`** for true upsert semantics, that is an optional optimization. If added, it requires schemaVersion bump to 2 and an `onUpgrade` migration that adds the index. The SELECT-then-INSERT/UPDATE approach in Pattern 1 avoids this.

---

## New Providers Needed

| Provider | Type | Location | Replaces / Extends |
|----------|------|----------|-------------------|
| `holeScoreNotifierProvider(roundId, holeIndex)` | `AsyncNotifier` (family, auto-dispose) | `features/shot_capture/providers/hole_score_notifier.dart` | Extends empty `HoleDao` |
| `holeListProvider(roundId)` | `StreamProvider` (family, auto-dispose) | `features/shot_capture/providers/hole_list_provider.dart` | New |
| `runningScoreProvider(roundId)` | `Provider` (derived, auto-dispose) | `features/shot_capture/providers/running_score_provider.dart` | New |
| `courseForRoundProvider(roundId)` | `FutureProvider` (family, auto-dispose) | `features/shot_capture/providers/course_for_round_provider.dart` | New |
| `highestScoredHoleIndexProvider(roundId)` | `Provider` (derived, auto-dispose) | `features/shot_capture/providers/highest_scored_hole_index_provider.dart` | New |
| `roundCompleteProvider(roundId)` | `Provider` (derived, auto-dispose) | `features/shot_capture/providers/round_complete_provider.dart` | New |

**No new keepAlive providers.** `activeRoundIdProvider` and `activeHoleIndexProvider` (both keepAlive) are from Phase 1 and are not modified. [VERIFIED: existing provider files]

---

## Files to Create or Update in Phase 2

| File | Action | Purpose |
|------|--------|---------|
| `lib/data/local/database/daos/hole_dao.dart` | UPDATE | Add `insertOrUpdateHole`, `getHolesForRound`, `watchHolesForRound` |
| `lib/features/shot_capture/shot_capture_screen.dart` | REPLACE | Full implementation |
| `lib/features/shot_capture/providers/hole_score_notifier.dart` | CREATE | Primary write authority |
| `lib/features/shot_capture/providers/hole_list_provider.dart` | CREATE | Drift stream of all holes |
| `lib/features/shot_capture/providers/running_score_provider.dart` | CREATE | Score vs par computation |
| `lib/features/shot_capture/providers/course_for_round_provider.dart` | CREATE | CourseModel from Drift courseJson |
| `lib/features/shot_capture/providers/highest_scored_hole_index_provider.dart` | CREATE | Max navigable hole index |
| `lib/features/shot_capture/providers/round_complete_provider.dart` | CREATE | 18-hole completion signal |
| `lib/features/shot_capture/widgets/outcome_button_grid.dart` | CREATE | 5 outcome buttons + EAGLE double-tap |
| `lib/features/shot_capture/widgets/hole_header.dart` | CREATE | Hole #, par, SI |
| `lib/features/shot_capture/widgets/putts_counter.dart` | CREATE | +/− putts widget |
| `lib/features/shot_capture/widgets/fairway_gir_toggles.dart` | CREATE | Fairway (par3 gate) + GIR |
| `lib/features/shot_capture/widgets/score_bar.dart` | CREATE | Running score vs par |
| `lib/features/shot_capture/widgets/hole_nav_drawer.dart` | CREATE | Hole navigation strip |
| `lib/features/setup/providers/round_setup_notifier.dart` | UPDATE | Reset `activeHoleIndexProvider` to 0 on new round |

---

## Environment Availability

Step 2.6: SKIPPED for new packages — no new external dependencies. All packages required for Phase 2 were verified in Phase 1 and are initialized in `main.dart`.

| Dependency | Required By | Available | Version | Note |
|------------|------------|-----------|---------|------|
| `drift` | HoleDao writes | Yes | 2.19.1+1 | HoleDao exists, methods are empty |
| `flutter_riverpod` | All providers | Yes | 2.6.1 | Initialized in Phase 1 |
| `build_runner` | Code generation | Yes | 2.4.13 | Must run after HoleDao + provider changes |
| `flutter_animate` | Animations | Yes | 4.5.2 | In pubspec; no init needed |
| `haptic_feedback` | Tap response | Yes | 0.5.1+2 | In pubspec; used in Phase 1 Setup |

**All dependencies available — no blockers.** [VERIFIED: pubspec.yaml, codebase file listing]

---

## Validation Architecture

`nyquist_validation: false` is set in `.planning/config.json`. Full test framework is not required.

### Manual Verification Checklist (Phase 2 success criteria from ROADMAP.md)

| Check | Requirement | Manual Test |
|-------|-------------|-------------|
| Outcome buttons appear and tap | SHOT-01 | Load round; tap PAR; verify hole advances |
| EAGLE via double-tap BIRDIE | SHOT-02 | Double-tap BIRDIE on hole 1; verify `outcome = 'eagle'` in Drift |
| Auto-advance after outcome tap | SHOT-03 | Tap outcome; verify hole header advances to next hole number |
| Undo toast appears for 4 seconds | SHOT-04 | Tap outcome; verify toast appears; wait 4s; verify auto-dismiss |
| Undo reverts last score | SHOT-04 | Tap outcome; tap UNDO within 4s; verify hole reverts to unscored |
| Putts counter writes through | SHOT-05 | Set putts to 3; kill app; relaunch; verify putts = 3 in Drift |
| Fairway toggle hidden on par 3 | SHOT-06 | Navigate to a par 3; verify fairway toggle is absent from screen |
| GIR toggle writes through | SHOT-07 | Toggle GIR; verify `greenInRegulation` in Drift |
| Running score persists across holes | SHOT-10 | Score 3 holes (−1, 0, +1); verify score bar shows E |
| Hole header shows number, par, SI | SHOT-11 | Verify hole 1 shows "HOLE 1", correct par, SI or "–" |
| Back-navigate to correct earlier hole | SHOT-12 | Score hole 1; navigate back; change outcome; verify Drift updated |
| Round completes after hole 18 | Completion | Score all 18 holes; verify navigation to /round-review/$roundId |
| Crash recovery returns to correct hole | FOUND-02/03 | Score 5 holes; kill app; relaunch; verify /shot-capture at hole 6 |
| `flutter analyze` clean | Code quality | Zero analyzer errors |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `fairwayHit = null` (not `false`) is the correct default for par 3 holes at outcome record time | Pattern 7 | FIR% in Phase 3 counts par 3s incorrectly |
| A2 | Running score shows pickup holes as +2 (same as double bogey) | Pattern 3 | Score display differs from what golfer expects during round |
| A3 | Score bar is positioned as a top-of-screen permanent bar, not floating | Pattern 9 | Layout conflicts with outcome buttons |
| A4 | `HoleOutcome.values.byName(string)` is safe for all stored outcome strings | Pattern 3 | `ArgumentError` if a typo was stored in Drift |
| A5 | Resetting `activeHoleIndexProvider` to 0 in `createRound()` is the correct fix for P2-08 | Pitfall P2-08 | New round starts on wrong hole |
| A6 | 5-button layout (2 rows: 3+2) is acceptable for the brutalist design without a formal UI-SPEC for Phase 2 | Pattern 4 / Outcome button grid | Planner/designer may override layout |
| A7 | Stroke Index from the API/Hive cache is available for all 18 holes; show "–" gracefully when null | SHOT-11 / HoleHeader | If all holes have null SI, the display always shows "–" which is visible but not ideal |

---

## Open Questions (RESOLVED)

1. **Layout / UI-SPEC for Shot Capture** — RESOLVED
   - Resolution: `02-UI-SPEC.md` was generated by `gsd-ui-phase` and covers the full two-zone layout, outcome button arrangement (4+4 in two rows), score bar position, and hole nav drawer. All layout decisions are locked in that document.

2. **A3 — Stroke Index availability** — RESOLVED
   - Resolution: HoleHeader shows SI if available, "–" (em-dash) when null. This is implemented in `courseForRoundProvider` + HoleHeader widget. No blocking issue — nullable SI is handled at display time.

3. **Pickup scoring for running display** — RESOLVED
   - Resolution: Pickup is displayed as +2 (same offset as double bogey) in the running score. The true WHS net double bogey value (requiring handicap index + per-hole SI) is computed only in Phase 3 Round Review. Marked as assumption A2 in the Assumptions Log above.

---

## Project Constraints (from CLAUDE.md)

| Directive | Phase 2 Impact |
|-----------|---------------|
| Write-through to Drift on every score entry; never accumulate state in Riverpod alone | Every `HoleScoreNotifier` method writes to Drift before updating any local state |
| `activeHoleIndexProvider` and `activeRoundIdProvider` MUST be `@Riverpod(keepAlive: true)` | These exist from Phase 1; do not change their annotations |
| All screen-level providers use `@riverpod` (auto-dispose) | All 6 new Phase 2 providers are auto-dispose |
| Hole navigation is internal `activeHoleIndexProvider.state = index`, NOT route pushes | SHOT-12 implementation never calls `context.push()` or `context.go()` for hole changes |
| Don't start GPS/map loading before score buttons appear | Phase 2 includes no GPS/map work (Phase 5). No FMTC or geolocator calls in this phase. |
| 64×80dp minimum tap targets for score buttons | Outcome buttons in `OutcomeButtonGrid` must have `constraints: BoxConstraints(minWidth: 64, minHeight: 80)` |
| Brutalist monospace aesthetic — all design decisions locked | BrdyColors, BrdySpacing, BrdyTextTheme from Phase 1 apply unchanged |
| Accent `#E8520A` for birdie outcome highlight | `BrdyColors.accent` on BIRDIE button background; eagle gets gold `Color(0xFFFFD700)` |
| Scorecard colour coding — eagle=gold, birdie=orange, par=plain, bogey=underline, double+=red | Applied in `HoleNavDrawer` hole chips and in future Phase 3 scorecard |
| `context.go()` not `context.push()` for main screen transitions | Round completion → `/round-review/$roundId` uses `context.go()` |
| Every `Table` class change bumps `schemaVersion` | Phase 2 makes NO table changes — schema stays at v1 |
| Run `build_runner` after every schema/provider change | Required after `hole_dao.dart` update and all new provider files |
| Commit `drift_schemas/` JSON for every schema version | No schema bump → no new schema dump needed in Phase 2 |
| Don't display WHS differential without all 18 holes (or label "Indicative") | Phase 2 does not display differential — that is Phase 3 |

---

## Sources

### Primary (HIGH confidence)
- `lib/data/local/database/tables/holes_table.dart` — exact Phase 1 schema columns verified
- `lib/data/local/database/daos/hole_dao.dart` — empty DAO confirmed; Phase 2 adds methods
- `lib/domain/enums/hole_outcome.dart` — `doubleBogey` (not `double_`) confirmed
- `lib/features/shot_capture/providers/active_hole_index_provider.dart` — keepAlive, 0-based confirmed
- `lib/features/setup/providers/active_round_id_provider.dart` — keepAlive confirmed
- `lib/data/local/database/daos/round_dao.dart` — `completeRound()` exists confirmed
- `CLAUDE.md` — architecture rules, keepAlive rules, navigation model, tap target sizes, Drift schema rules
- `drift.simonbinder.eu/dart_api/writes/` — `insertOnConflictUpdate`, `DoUpdate`, upsert patterns [CITED]
- `drift.simonbinder.eu/dart_api/streams/` — `watch()`, `watchSingle()`, stream update semantics [CITED]
- `api.flutter.dev/flutter/widgets/GestureDetector-class.html` — `onDoubleTap` + `onTap` coexistence behavior [CITED]
- `docs.flutter.dev/release/breaking-changes/snackbar-with-action-behavior-update` — `persist: false` requirement for auto-dismiss SnackBar with action [CITED]

### Secondary (MEDIUM confidence)
- `.planning/phase-01/01-RESEARCH.md` — Phase 1 patterns, provider conventions, Drift companion syntax
- `.planning/phase-01/01-PATTERNS.md` — analog map for all Phase 1 files; Phase 2 provider pattern is identical
- `.planning/codebase/STACK.md` — package versions confirmed
- `pub.dev/packages/flutter_animate` — `flutter_animate` extension method syntax confirmed in pubspec
- `flutter/flutter#50458` — onDoubleTap 300ms single-tap delay is a known open issue; accepted for golf app

### Tertiary (LOW / ASSUMED — flagged in Assumptions Log)
- Pickup = +2 running display (A2) — reasonable golf convention but not explicitly specified in REQUIREMENTS.md
- 3+2 button row layout (A6) — no UI-SPEC for Phase 2 yet
- Score bar at top of screen (A3) — no UI-SPEC constraint confirmed

---

## Metadata

**Confidence breakdown:**
- HoleDao pattern: HIGH — Drift docs verified; existing Phase 1 schema confirmed
- HoleScoreNotifier pattern: HIGH — Riverpod family notifier is standard; write-through mandate from CLAUDE.md
- Running score provider: HIGH — Drift stream + derived provider is standard pattern
- EAGLE double-tap: HIGH — GestureDetector.onDoubleTap is the correct Flutter API; 300ms delay is a known documented behavior
- Undo toast: HIGH — `persist: false` confirmed from official Flutter breaking-change docs
- Hole navigation: HIGH — architectural constraint verified in CLAUDE.md
- Screen layout: MEDIUM — no Phase 2 UI-SPEC exists; layout arrangement is open
- Pickup running score display: LOW — convention assumed, not specified

**Research date:** 2026-05-17
**Valid until:** 2026-06-17 (stable packages; all packages unchanged from Phase 1)
