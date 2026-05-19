# Phase 6: Round History - Research

**Researched:** 2026-05-20
**Domain:** Flutter / Drift / Riverpod / GoRouter — list-detail pattern with delete
**Confidence:** HIGH

---

## Summary

Phase 6 adds a round history list to the app so the user can browse all past rounds, view their
full scorecard in read-only mode, and delete rounds they no longer want. The database, providers,
and Round Review screen already exist from Phase 3 — this phase is primarily additive: a new
`watchCompletedRounds()` / `deleteRound()` DAO method pair, a new `completedRoundsProvider`,
a `RoundHistoryScreen`, a `RoundHistoryTile` widget, a route, and a small modification to
`RoundReviewScreen` to support read-only (history) mode in addition to its current post-round mode.

**Critical verified finding:** `holes_table.dart` and `shots_table.dart` use `.references()` but
WITHOUT `onDelete: KeyAction.cascade`. [VERIFIED: codebase table files] This means a `deleteRound`
call will fail or orphan related rows unless the plan includes a Drift schema migration to
`schemaVersion: 2` that adds cascade delete to both FKs. This is Wave 1's first task.

The second hardest design decision is how `RoundReviewScreen` signals read-only vs post-round mode.
A `readOnly: bool` constructor parameter is the cleanest approach.

**Primary recommendation:** Wave 1 = schema v2 migration (cascade FK + build_runner). Wave 2 = DAO
methods + `completedRoundsProvider` + `RoundHistoryScreen` + router. Wave 3 = `RoundReviewScreen`
read-only mode + SetupScreen entry point + human-verify.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| List all completed rounds | Database / Drift | Riverpod provider | Query is a DAO concern; provider exposes it as async stream |
| Show round summary row (date, course, score) | Frontend widget | Drift DAO | Formatting is widget concern; data comes from Drift rows |
| Navigate into past round scorecard | GoRouter route | RoundReviewScreen | Route already exists; reuse with a `readOnly` flag |
| Delete a round with cascade | Database / Drift | Schema migration | FK cascade must be declared; DAO owns the delete call |
| Confirm delete | Frontend widget | — | `confirmDismiss` callback on `Dismissible` |
| Entry point from Setup screen | SetupScreen widget | GoRouter | Button in SetupScreen pushes `/round-history` |

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| HIST-01 | Round history list accessible from Setup — date, course name, score and shots per round | `watchCompletedRounds()` stream DAO method; `completedRoundsProvider`; `RoundHistoryScreen` ListView; History button added to SetupScreen |
| HIST-02 | Tapping a past round opens full Round Review screen in read-only mode | Existing `/round-review/:roundId` route; add `readOnly: bool` param to `RoundReviewScreen`; `context.push()` from tile |
| HIST-03 | User can delete a past round with swipe-to-delete gesture and confirmation | Flutter `Dismissible.confirmDismiss` + `showDialog` + `deleteRound()` DAO; schema v2 migration for cascade FK required first |
</phase_requirements>

---

## Project Constraints (from CLAUDE.md)

| Directive | Applies to This Phase |
|-----------|-----------------------|
| `@riverpod` code-gen throughout — never hand-write Provider boilerplate | `completedRoundsProvider` must use `@riverpod` annotation + build_runner |
| Drift write-through — never accumulate state in Riverpod alone | Delete goes through DAO, not in-memory list splice |
| `context.go()` not `context.push()` for main screen transitions | `/round-history` is a sub-screen of Setup; use `context.push()` to preserve the Setup route in back-stack |
| Schema version bump REQUIRED for every Table class change; commit `drift_schemas/` JSON | Schema v2 required for FK cascade; `drift_schemas/schema.v2.json` must be committed |
| Screen-level providers use `@riverpod` auto-dispose | `completedRoundsProvider` is screen-scoped — must NOT be `keepAlive` |
| Brutalist monospace design — SometypeMono labels, accent `#E8520A`, background `#0A0A0A` | `RoundHistoryTile` and `RoundHistoryScreen` must use BrdyColors + GoogleFonts.sometypeMono |
| No new packages without REQUIREMENTS.md update | All required functionality is in Flutter SDK or already-installed packages |

---

## Standard Stack

### Core (already in pubspec — no new installs)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| drift | ^2.18.0 | Schema v2 migration; `watchCompletedRounds()` + `deleteRound()` DAO | Already the project's persistence layer [VERIFIED: pubspec.yaml] |
| drift_dev | ^2.18.0 | `dart run build_runner build` after schema change | Already in dev_dependencies [VERIFIED: pubspec.yaml] |
| flutter_riverpod | ^2.5.1 | `completedRoundsProvider` exposes list as stream `AsyncValue` | Already the state layer [VERIFIED: pubspec.yaml] |
| riverpod_annotation + riverpod_generator | ^2.3.5 / 2.6.3 | `@riverpod` code-gen | Required by CLAUDE.md [VERIFIED: pubspec.yaml] |
| go_router | ^14.2.0 | `/round-history` route; `context.push()` from Setup + tile | Already the nav layer [VERIFIED: pubspec.yaml] |
| intl | ^0.19.0 | `DateFormat('d MMM yyyy')` in history tile | Already in pubspec [VERIFIED: pubspec.yaml] |
| google_fonts | ^6.2.1 | SometypeMono for tile labels | Already in pubspec [VERIFIED: pubspec.yaml] |
| gap | ^3.0.1 | Spacing widgets | Already in pubspec [VERIFIED: pubspec.yaml] |

**No new packages required for this phase.** [VERIFIED: codebase pubspec.yaml]

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `Dismissible` for swipe-delete | `flutter_slidable` | `flutter_slidable` is richer but adds a package; `Dismissible` is Flutter SDK and sufficient |
| `showDialog` confirmation | Inline undo snackbar | Dialog is safer — prevents accidental delete; snackbar undo requires keeping round in memory |
| Per-tile `statsProvider(roundId)` for score display | Pre-computed `totalStrokes` column on `rounds` table | Per-tile async is simpler (no additional schema migration beyond v2); column approach is more performant for long lists |

---

## Package Legitimacy Audit

No new external packages are installed in this phase. All dependencies are already in
`pubspec.yaml` and have been part of the project since Phase 1.

**Packages removed due to slopcheck [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

---

## Architecture Patterns

### System Architecture Diagram

```
SetupScreen
    │
    │  "HISTORY" button  →  context.push('/round-history')
    ▼
RoundHistoryScreen (ConsumerWidget)
    │  ref.watch(completedRoundsProvider)
    │      → RoundDao.watchCompletedRounds()
    │          → Drift: SELECT * FROM rounds WHERE completedAt IS NOT NULL ORDER BY completedAt DESC
    │
    ├─ [empty state widget if list is empty]
    │
    ├─ RoundHistoryTile (x N)   [Dismissible wrapper]
    │       • date (intl DateFormat), courseName, totalStrokes (statsProvider)
    │       • onTap → context.push('/round-review/$roundId?readOnly=true')
    │       • confirmDismiss → showDialog → [Cancel | DELETE]
    │           └─ confirmed → RoundDao.deleteRound(id)
    │                               → DELETE FROM rounds WHERE id = ?
    │                               → CASCADE: DELETE FROM holes WHERE roundId = ?
    │                               → CASCADE: DELETE FROM shots WHERE holeId IN (...)
    │           └─ cancelled → tile snaps back
    │
    │  (stream re-emits updated list automatically after delete)
    ▼
RoundReviewScreen (readOnly: true)
    │  existing providers: scorecardProvider(roundId), statsProvider(roundId), whsDifferentialProvider(roundId)
    │  readOnly=true → hides Share + New Round buttons; shows back row; PopScope(canPop: true)
    └─ context.pop() → back to RoundHistoryScreen
```

### Recommended Project Structure

```
lib/
├── features/
│   ├── round_history/                         # New feature folder
│   │   ├── round_history_screen.dart           # ConsumerWidget
│   │   ├── providers/
│   │   │   ├── completed_rounds_provider.dart  # @riverpod Stream<List<Round>>
│   │   │   └── completed_rounds_provider.g.dart
│   │   └── widgets/
│   │       └── round_history_tile.dart         # Dismissible + ListTile
│   ├── round_review/
│   │   └── round_review_screen.dart            # Add readOnly param
│   └── setup/
│       └── setup_screen.dart                   # Add History button
├── data/local/database/
│   └── daos/
│       └── round_dao.dart                      # Add watchCompletedRounds + deleteRound
└── app/
    └── router.dart                             # Add /round-history route + redirect allowlist
```

### Pattern 1: Schema v2 migration — add ON DELETE CASCADE to FK columns

**What:** `holes_table.dart` currently has `integer().references(Rounds, #id)` (no cascade).
`shots_table.dart` has `integer().references(Holes, #id)` (no cascade). [VERIFIED: codebase]
Both need `onDelete: KeyAction.cascade` added. This requires bumping `schemaVersion` to 2 and
adding an `onUpgrade` migration.

**Why this matters:** SQLite `PRAGMA foreign_keys = ON` is already set in `app_database.dart`.
When the FK constraint is present but no `ON DELETE CASCADE` is declared, SQLite will either
(a) reject the parent row delete with a constraint violation, or (b) leave child rows orphaned
depending on the default action. Either outcome is wrong.

**Drift migration pattern:**
```dart
// holes_table.dart — change:
IntColumn get roundId => integer().references(Rounds, #id,
    onDelete: KeyAction.cascade)();

// shots_table.dart — change:
IntColumn get holeId => integer().references(Holes, #id,
    onDelete: KeyAction.cascade)();

// app_database.dart — bump:
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async => await m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      // Re-create holes and shots with CASCADE — SQLite does not support ALTER COLUMN.
      // Steps: create new tables, copy data, drop old, rename new.
      // Or: use recreateAllViews / Drift's stepByStep migrations.
      // See Drift docs: https://drift.simonbinder.eu/docs/advanced-features/migrations/
      await m.recreateAllViews();  // placeholder — actual migration is table recreation
    }
  },
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
  },
);
```

**Important:** SQLite does not support `ALTER COLUMN`. Adding `ON DELETE CASCADE` to an existing
column requires recreating the table. The Drift recommended approach is `Migrator.alterTable()`
or using `stepByStep` migration with a temporary table. Research the Drift migration docs for
the exact pattern when writing the plan. [ASSUMED: Drift `alterTable` supports FK changes —
verify in Drift docs before writing migration plan steps]

After any table changes, run `dart run build_runner build --delete-conflicting-outputs` and
generate `drift_schemas/schema.v2.json` with `dart run drift_dev schema dump`.

### Pattern 2: Drift DAO — watchCompletedRounds + deleteRound

**What:** Two new methods on `RoundDao`. Stream emits newest-first; delete is a single row delete
(cascade handles children once FK is set up per Pattern 1).

```dart
// Source: Drift docs — select with where + orderBy + watch; delete with where
// In round_dao.dart

Stream<List<Round>> watchCompletedRounds() =>
    (select(rounds)
      ..where((r) => r.completedAt.isNotNull())
      ..orderBy([(r) => OrderingTerm.desc(r.completedAt)]))
    .watch();

Future<void> deleteRound(int id) =>
    (delete(rounds)..where((r) => r.id.equals(id))).go();
```

[ASSUMED: `OrderingTerm.desc(r.completedAt)` is valid Drift syntax — matches existing codebase pattern of `OrderingTerm` usage]

### Pattern 3: completedRoundsProvider (Riverpod stream)

**What:** Auto-dispose stream provider that calls `watchCompletedRounds()`. The `.watch()` stream
automatically emits an updated list after `deleteRound()` commits — no manual refresh needed.

```dart
// Source: project pattern — matches hole_list_provider.dart [VERIFIED: codebase]
// In features/round_history/providers/completed_rounds_provider.dart
part 'completed_rounds_provider.g.dart';

@riverpod
Stream<List<Round>> completedRounds(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.roundDao.watchCompletedRounds();
}
```

### Pattern 4: RoundReviewScreen read-only mode

**What:** Add `readOnly` constructor parameter (defaults to `false`). When `true`: show a back
button row instead of the `_ActionButtons` (Share + New Round), and set `PopScope(canPop: true)`.

```dart
// Modified RoundReviewScreen constructor
class RoundReviewScreen extends ConsumerStatefulWidget {
  final int roundId;
  final bool readOnly;  // default false — existing post-round behaviour preserved

  const RoundReviewScreen({
    super.key,
    required this.roundId,
    this.readOnly = false,
  });
  ...
}

// In build() — replace _ActionButtons and PopScope:
PopScope(
  canPop: widget.readOnly,   // allow back when in history mode
  child: Scaffold(
    ...
    // At bottom of CustomScrollView slivers:
    SliverToBoxAdapter(
      child: widget.readOnly
          ? _BackButton()           // simple "BACK" button
          : _ActionButtons(...),    // existing Share + New Round
    ),
  ),
),
```

### Pattern 5: GoRouter — /round-history route + redirect allowlist

**What:** Add the new route. Also update the `redirect` function to allow `/round-history` through
when a crash-recovery `incompleteRoundId` is present (otherwise the user would be bounced to
Shot Capture when trying to browse history while a round is in progress — which is a valid state
if the user has navigated away). [VERIFIED: router.dart — redirect currently has no allowlist
entry for paths beyond `/round-review/` and `/shot-capture/`]

```dart
// In router.dart routes list:
GoRoute(
  path: '/round-history',
  builder: (_, __) => const RoundHistoryScreen(),
),

// Update read-only review navigation — query parameter approach:
GoRoute(
  path: '/round-review/:roundId',
  builder: (_, state) => RoundReviewScreen(
    roundId: int.parse(state.pathParameters['roundId']!),
    readOnly: state.uri.queryParameters['readOnly'] == 'true',
  ),
),

// In redirect function, inside the incompleteRoundId != null block:
if (state.uri.path == '/round-history') return null;
if (state.uri.path.startsWith('/round-review/') &&
    state.uri.queryParameters['readOnly'] == 'true') return null;
```

Navigate from tile: `context.push('/round-review/$id?readOnly=true')`
Navigate from Setup: `context.push('/round-history')`

### Pattern 6: Dismissible swipe-to-delete with confirmation

**What:** Wrap each `RoundHistoryTile` in `Dismissible`. Use `confirmDismiss` (async bool callback)
to show the dialog BEFORE the tile is removed from the tree. If user cancels, returns `false`
and the tile snaps back. If confirmed, returns `true` and `onDismissed` fires.

```dart
Dismissible(
  key: ValueKey(round.id),          // stable key — NOT list index
  direction: DismissDirection.endToStart,
  background: Container(
    color: BrdyColors.destructive,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: BrdySpacing.md),
    child: const Icon(Icons.delete_outline, color: BrdyColors.onDestructive),
  ),
  confirmDismiss: (_) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BrdyColors.surface,
        title: Text(
          'DELETE ROUND?',
          style: GoogleFonts.sometypeMono(
            fontSize: 16, fontWeight: FontWeight.w700, color: BrdyColors.onSurface),
        ),
        content: Text(
          round.courseName,
          style: GoogleFonts.sometypeMono(fontSize: 14, color: BrdyColors.onSurfaceMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL',
              style: GoogleFonts.sometypeMono(color: BrdyColors.onSurfaceMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE',
              style: GoogleFonts.sometypeMono(color: BrdyColors.destructive,
                fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ) ?? false;
  },
  onDismissed: (_) =>
      ref.read(appDatabaseProvider).roundDao.deleteRound(round.id),
  child: RoundHistoryTile(round: round),
),
```

### Anti-Patterns to Avoid

- **Deleting in-memory and deferring Drift delete:** The stream provider will re-emit the deleted
  round from Drift until the DELETE is committed — list would flicker back. Always delete via DAO
  first; the stream emits the updated list automatically.
- **Using `context.go()` for `/round-history`:** Destroys the Setup screen in the back-stack.
  Use `context.push()`.
- **`ValueKey(index)` on Dismissible:** Flutter reuses keys by position, not identity. After
  deleting item 0, the former item 1 gets key 0 and Flutter's widget tree can show the wrong tile.
  Use `ValueKey(round.id)`.
- **Not adding `/round-history` to the redirect allowlist:** A user with an incomplete active
  round (crash-recovery state) would be bounced to Shot Capture every time they push to the
  history screen. The redirect must explicitly allow `/round-history` through.
- **Hiding Share button instead of omitting it in read-only mode:** `Visibility(visible: false)`
  still occupies space. Use a conditional widget tree or a ternary that returns `_BackButton()`
  vs `_ActionButtons()`.
- **Skipping the schema migration:** Running `deleteRound()` without the FK cascade in place will
  either throw a foreign key constraint violation or leave orphaned holes/shots rows.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Swipe-to-delete UI | Custom gesture detector + slide animation | `Dismissible` (Flutter SDK) | Handles RTL, drag physics, snap-back, accessibility |
| Confirm delete dialog | Custom overlay | `showDialog` with `AlertDialog` | Platform-standard, handles back-button, focus trap |
| Reactive list after delete | Manual list state splice | Drift `.watch()` stream + Riverpod stream provider | Stream automatically re-emits; no manual splice needed |
| Date formatting | Manual string concatenation | `intl` `DateFormat` (already in pubspec) | Locale-aware, handles edge cases |
| Cascade delete across tables | Manual DAO calls to delete holes then shots then rounds | SQLite `ON DELETE CASCADE` (schema migration) | Atomic, correct ordering, no partial-delete risk |

---

## Common Pitfalls

### Pitfall 1: No ON DELETE CASCADE on holes/shots FKs — schema migration required

**What goes wrong:** `deleteRound(id)` either throws a SQLite foreign key constraint violation or
orphans all `holes` and `shots` rows for that round.
**Root cause — VERIFIED:** `holes_table.dart` has `integer().references(Rounds, #id)` without
`onDelete: KeyAction.cascade`. `shots_table.dart` has `integer().references(Holes, #id)` without
cascade. [VERIFIED: codebase] `PRAGMA foreign_keys = ON` is set, so SQLite WILL enforce the FK
and may block the delete.
**How to avoid:** Wave 1 of this phase MUST include a schema v2 migration. Add
`onDelete: KeyAction.cascade` to both FK columns, bump `schemaVersion` to 2, add `onUpgrade`
migration, run `build_runner`, generate and commit `drift_schemas/schema.v2.json`.
**Warning signs:** `deleteRound()` throws a `DatabaseException` with "FOREIGN KEY constraint failed".

### Pitfall 2: `PopScope(canPop: false)` traps the user in read-only Round Review

**What goes wrong:** The current `RoundReviewScreen` sets `PopScope(canPop: false)` to prevent
back navigation after completing a round. If `readOnly` mode does not change this to
`canPop: true`, the user is trapped on the historical scorecard with no way to return.
**How to avoid:** Condition `canPop` on `widget.readOnly`:
```dart
PopScope(canPop: widget.readOnly, ...)
```

### Pitfall 3: Router redirect bounces user from history screen during active round

**What goes wrong:** A user starts a round, navigates to Setup (valid — round still in progress),
then tries to open history. The redirect detects `incompleteRoundId != null` and redirects to
Shot Capture, preventing history access.
**How to avoid:** Add `if (state.uri.path == '/round-history') return null;` to the redirect's
`incompleteRoundId != null` branch. [VERIFIED: router.dart has no allowlist for this path]

### Pitfall 4: Score display requires async join — tiles may show blank briefly

**What goes wrong:** The `rounds` table has no pre-computed score column. Each tile needs an
async `statsProvider(roundId)` call to display totalStrokes / scoreToPar.
**How to avoid:** Show a skeleton/placeholder (e.g., `'--'`) while the async value loads.
Use `AsyncValue.when` with a `loading` fallback. For Phase 6 this is acceptable; if jank
appears in testing, consider adding `totalStrokes`/`scoreToPar` to the rounds table in v3.

### Pitfall 5: Drift migration for ALTER COLUMN is non-trivial in SQLite

**What goes wrong:** SQLite does not support `ALTER TABLE ... MODIFY COLUMN`. Adding `ON DELETE CASCADE`
to an existing FK requires recreating the table (create-copy-drop-rename pattern).
**How to avoid:** Use Drift's `Migrator` with a step-by-step approach. Drift 2.x supports
`m.createTable(newTable)` / `m.deleteTable(oldName)` in sequence. Alternatively use
`customStatement` with raw SQL for the recreation. This is the single most complex task in Wave 1.
**Resource:** Drift docs — "Complex migrations" section.

### Pitfall 6: `Dismissible` with list index as key shows wrong tile after delete

**What goes wrong:** After deleting item at index 0, Flutter reuses `ValueKey(0)` for the new
first item, causing a visual glitch or incorrect tile identity.
**How to avoid:** Always use `ValueKey(round.id)` — Drift's auto-increment ID is stable.

---

## Runtime State Inventory

This phase involves a schema migration but is not a rename/refactor. The only runtime state concern:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | Existing `holes` and `shots` rows in Drift (brdy.sqlite) — FK columns have no CASCADE | Schema v2 migration must recreate tables preserving existing rows |
| Live service config | None | — |
| OS-registered state | None | — |
| Secrets/env vars | None | — |
| Build artifacts | `app_database.g.dart` and `*.g.dart` files — will be stale after schema change | `dart run build_runner build --delete-conflicting-outputs` in Wave 1 |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Using a `?readOnly=true` query parameter on the existing `/round-review/:roundId` route is the preferred approach (vs a new `/round-history/:roundId` route) | Pattern 4/5 | If planner prefers a separate route, router and navigation calls change — minor effort difference |
| A2 | Score (totalStrokes, scoreToPar) in history tiles is derived per-tile via `statsProvider(roundId)` rather than a pre-computed column on `rounds` | Pitfall 4, Architecture | If N > ~50 rounds causes visible jank, a schema v3 migration to add columns is the fix |
| A3 | `SetupScreen` history entry point is a text/icon button added to the existing layout (not a new bottom nav or tab bar) | Pattern 5, SetupScreen | If planner chooses bottom nav, more layout changes are needed across screens |
| A4 | Drift `OrderingTerm.desc(r.completedAt)` is valid syntax for nullable DateTimeColumn | Pattern 2 | If not supported, use `.orderBy([(r) => OrderingTerm(expression: r.completedAt, mode: OrderingMode.desc)])` |
| A5 | Drift's schema migration approach for adding FK cascade (table recreation) is the correct method — verify Drift 2.18.x migration docs for exact API | Pattern 1 | If Drift has a simpler `alterTable` path for FK changes, the migration code changes |

---

## Open Questions

1. **Exact Drift migration API for table recreation with FK cascade**
   - What we know: SQLite does not support ALTER COLUMN; table recreation is needed
   - What's unclear: Whether Drift 2.18.x `Migrator.recreateAllViews()`, `alterTable()`, or a
     custom `customStatement` recreation is the cleanest approach
   - Recommendation: Planner should look up Drift migration docs before writing Wave 1 tasks;
     the pattern is well-documented in Drift's official migration guide

2. **Score display in history tile (async per-tile vs pre-computed column)**
   - What we know: `statsProvider` works; `rounds` table has no score column
   - What's unclear: Whether per-tile async lookup will feel snappy at typical list sizes (< 20 rounds)
   - Recommendation: Start with `statsProvider` per tile; add pre-computed column in a follow-up
     if testing reveals jank

3. **Setup screen layout — where to place the History button**
   - What we know: Setup screen has Logo, HandicapInput, CourseSearchField, results list,
     TileCacheProgress, and a LOAD button
   - What's unclear: Whether the History button is a text link above/below the LOAD button,
     a small icon button in the logo area, or something else
   - Recommendation: A text button or outlined button row below the LOAD button; planner/user
     decides exact placement

---

## Environment Availability

Step 2.6: SKIPPED — no new external tools, CLIs, or services introduced. All dependencies are
already installed and verified in prior phases.

---

## Validation Architecture

`nyquist_validation: false` in `.planning/config.json` — this section is skipped per config.

---

## Security Domain

Phase 6 operates entirely on local SQLite data (no network calls, no new user inputs beyond
gestures). No new ASVS attack surface is introduced. Delete confirmation dialog mitigates
accidental data destruction. No additional security controls needed beyond existing PRAGMA FK
enforcement.

---

## Sources

### Primary (HIGH confidence)
- `[VERIFIED: codebase]` `/lib/data/local/database/tables/holes_table.dart` — FK without cascade confirmed
- `[VERIFIED: codebase]` `/lib/data/local/database/tables/shots_table.dart` — FK without cascade confirmed
- `[VERIFIED: codebase]` `/lib/data/local/database/daos/round_dao.dart` — existing DAO patterns
- `[VERIFIED: codebase]` `/lib/data/local/database/app_database.dart` — schemaVersion:1, PRAGMA FK ON
- `[VERIFIED: codebase]` `/lib/features/round_review/round_review_screen.dart` — PopScope, readOnly extension point
- `[VERIFIED: codebase]` `/lib/app/router.dart` — redirect logic, existing routes
- `[VERIFIED: codebase]` `/lib/features/shot_capture/providers/hole_list_provider.dart` — stream provider pattern to follow
- `[VERIFIED: codebase]` `/CLAUDE.md` — all project constraints applied
- `[VERIFIED: codebase]` `/pubspec.yaml` — confirmed no new packages needed

### Secondary (MEDIUM confidence)
- `[ASSUMED]` Flutter SDK `Dismissible.confirmDismiss` pattern — standard Flutter widget, matches training knowledge
- `[ASSUMED]` Drift `OrderingTerm.desc()` syntax — inferred from Drift conventions; verify in build

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages confirmed in pubspec.yaml, no new installs
- Architecture: HIGH — providers, DAO, screen structure directly inferred from Phase 3 codebase
- Schema migration: MEDIUM — FK cascade absence verified; exact Drift 2.18 migration API not confirmed via docs
- Navigation: HIGH — router.dart read directly; redirect logic fully understood
- Pitfalls: HIGH — FK issue is a verified codebase finding, not a guess

**Research date:** 2026-05-20
**Valid until:** 2026-06-20 (stable stack — drift, riverpod, go_router all stable releases)
