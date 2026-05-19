# Phase 7: Stats & Trends - Research

**Researched:** 2026-05-20
**Domain:** Flutter / fl_chart / Riverpod / Drift — aggregate stats + line chart over completed rounds
**Confidence:** HIGH

---

## Summary

Phase 7 adds a Stats screen showing (1) a handicap differential trend line chart over the last 20
rounds and (2) per-metric averages (score-to-par, putts, FIR%, GIR%) across all completed rounds.
The data layer is already in place: `watchCompletedRounds()` streams every completed `Round` row
from Phase 6, `whsDifferentialProvider` computes the WHS differential for a single round from
Phase 3, and `statsProvider` computes per-round aggregates. Phase 7 reuses these building blocks
to create cross-round aggregates and a new chart widget.

The one new dependency is fl_chart for the line chart. **Critical:** fl_chart 1.x requires
Flutter >=3.27.4 but the project currently runs Flutter 3.24.5. The correct version to pin is
`fl_chart: ^0.71.0` (published April 2025, requires Flutter >=3.16.0, Dart ^3.2.0).
[VERIFIED: pub.dev API, github.com/imaNNeo/fl_chart]

Computing per-round differentials for the trend chart requires calling `whsDifferentialProvider`
for each of the last 20 completed rounds. Since `whsDifferentialProvider` already performs the
full WHS calculation including ESC adjustment, the stats screen provider simply maps over the
list of round IDs returned by `watchCompletedRounds()` and collects the numeric differential from
each. Rounds where differential is "N/A" (missing rating/slope) are excluded from the chart.

The stats screen should be accessible from the Setup screen via a dedicated STATS button alongside
the existing ROUND HISTORY button. The route `/stats` requires a new GoRouter entry and an update
to the redirect allowlist to prevent the active-round redirect from blocking navigation.

**Primary recommendation:** Wave 1 = `trendChartProvider` + `crossRoundAveragesProvider` +
build_runner. Wave 2 = `StatsScreen` with `LineChart` widget + stat average cards + router wiring.

---

## Project Constraints (from CLAUDE.md)

- All `@Riverpod(keepAlive: true)` providers: `appDatabaseProvider`, `hivePlayerPrefsProvider`,
  `hiveCourseBoxProvider`, `dioProvider`, `golfCourseApiProvider`, all repository providers,
  `activeRoundIdProvider`, `activeHoleIndexProvider`. **Stats providers must use `@riverpod`
  (auto-dispose).**
- Write-through to Drift — stats are computed from Drift, not buffered in memory.
- `context.go()` not `context.push()` for main screen transitions (but stats screen is a push
  from Setup, consistent with round history pattern — use `context.push('/stats')`).
- No backend, auth, or cloud services.
- Design system is locked: SometypeMono font, `BrdyColors.accent` (#E8520A), dark background.
  JetBrains Mono for numerics. No new visual styles.
- No features not in REQUIREMENTS.md. Stats scope is exactly STAT-01, STAT-02, STAT-03.
- Drift schema: every `Table` change MUST bump `schemaVersion` and add `onUpgrade` migration.
  **Phase 7 does NOT change the schema** — stats are computed from existing Drift rows.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Stream of completed rounds | Database / Drift | Riverpod provider | `watchCompletedRounds()` already exists in RoundDao; provider wraps it |
| Per-round WHS differential | Riverpod provider | Database / Drift | `whsDifferentialProvider(roundId)` already computes this; reuse it |
| Differential trend data (last 20) | Riverpod provider | Riverpod (chained) | New provider maps over last-20 round IDs, collects differentials |
| Cross-round averages | Riverpod provider | Database / Drift | New provider maps over all completed rounds, aggregates via `statsProvider` |
| Line chart rendering | Frontend widget | fl_chart | `LineChart` widget consumes `List<FlSpot>` from provider |
| Average stat cards | Frontend widget | — | Reuse `StatCard` widget pattern from Phase 3 |
| Route + entry point | GoRouter + SetupScreen | — | New `/stats` route; STATS button on Setup screen |
| Reactivity on new round | Riverpod stream | Drift watch | `watchCompletedRounds()` stream fires on insert; providers re-derive |

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| STAT-01 | Stats screen shows handicap differential trend as a line chart across the last 20 rounds | `trendChartProvider` maps last-20 round IDs → `whsDifferentialProvider` → `List<FlSpot>`; rendered by `fl_chart` `LineChart` widget |
| STAT-02 | Averages for score-to-par, putts, fairways hit and GIR% shown across all rounds | `crossRoundAveragesProvider` maps all completed rounds → `statsProvider(id)` → aggregate averages; displayed as stat cards |
| STAT-03 | Stats update immediately when a new round is completed | `completedRoundsProvider` is a `Stream` backed by `watchCompletedRounds()` — Drift stream fires on any insert/update; providers rebuild automatically |
</phase_requirements>

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| fl_chart | ^0.71.0 | Line chart for differential trend | Dominant Flutter chart library (7.1k pub.dev likes, verified publisher); only version compatible with Flutter 3.24.5 |
| flutter_riverpod | ^2.5.1 (already in pubspec) | Provider for async stream + derived state | Already in use; `@riverpod` codegen pattern established |
| drift | ^2.18.0 (already in pubspec) | Data source via `watchCompletedRounds()` | Already in use; `RoundDao` already has the required DAO method |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| google_fonts | ^6.2.1 (already in pubspec) | SometypeMono labels, JetBrains Mono numerics | All text — established project convention |
| intl | ^0.19.0 (already in pubspec) | Format differential values (e.g. "12.3") | Formatting differential and percentage values |
| gap | ^3.0.1 (already in pubspec) | Semantic spacing | Between chart and stat card sections |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| fl_chart ^0.71.0 | syncfusion_flutter_charts | Syncfusion requires a license for commercial use; overkill for one line chart |
| fl_chart ^0.71.0 | flutter_charts (pub.dev) | Much lower adoption; weaker dark mode support |
| fl_chart ^0.71.0 | Hand-rolled CustomPainter | High implementation cost; see Don't Hand-Roll |
| fl_chart ^0.71.0 | fl_chart ^1.2.0 | Requires Flutter >=3.27.4 — incompatible with current Flutter 3.24.5 install |

**Installation:**
```bash
# Run from /Users/simonnewland/development/brdy01
flutter pub add fl_chart:^0.71.0
```

**Version verification (completed during research):**
- `fl_chart 0.71.0` — pub.dev confirmed, published 2025-04-15, Flutter >=3.16.0, Dart ^3.2.0
  [VERIFIED: pub.dev API https://pub.dev/api/packages/fl_chart/versions/0.71.0]
- Installed Flutter: 3.24.5 — satisfies `>=3.16.0` constraint.
- Dart SDK in project: `>=3.3.0 <4.0.0` — satisfies `^3.2.0` constraint.

---

## Package Legitimacy Audit

> slopcheck is a Python/npm tool and does not support the Dart/pub.dev ecosystem. Verification
> was performed directly against the pub.dev API and the official GitHub repository.

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| fl_chart 0.71.0 | pub.dev | 4+ years (first release ~2019) | 7.1k pub.dev likes, #1 charting pkg | github.com/imaNNeo/fl_chart | N/A (Dart ecosystem) | Approved — verified publisher `flchart.dev`, official GitHub, long track record |

**Packages removed due to slopcheck [SLOP] verdict:** none

**Packages flagged as suspicious [SUS]:** none

*slopcheck does not cover pub.dev (Dart/Flutter). Verification performed via pub.dev API +
official GitHub repository. All packages tagged `[VERIFIED: pub.dev API]`.*

---

## Architecture Patterns

### System Architecture Diagram

```
Drift DB (rounds + holes tables)
        │
        ▼ watchCompletedRounds() — stream fires on new round insert
completedRoundsProvider (Stream<List<Round>>)
        │
        ├──► trendChartProvider
        │       │  takes last-20 rounds (by completedAt desc)
        │       │  for each round → whsDifferentialProvider(roundId)
        │       │  collects numeric differentials → List<FlSpot>
        │       ▼
        │    StatsScreen ──► LineChart (fl_chart)
        │
        └──► crossRoundAveragesProvider
                │  for each completed round → statsProvider(roundId)
                │  averages scoreToPar, totalPutts, fairwaysHit%, girPercent
                ▼
             StatsScreen ──► AverageStatCard × 4
```

Data flows left-to-right. The Drift stream is the single reactive source — no polling needed.
Both new providers are derived from existing providers; no new DAO methods required.

### Recommended Project Structure

```
lib/features/stats/
├── providers/
│   ├── trend_chart_provider.dart       # List<FlSpot> for last-20 differential trend
│   ├── trend_chart_provider.g.dart
│   ├── cross_round_averages_provider.dart  # Avg scoreToPar, putts, FIR%, GIR%
│   └── cross_round_averages_provider.g.dart
├── widgets/
│   ├── differential_line_chart.dart    # Wraps fl_chart LineChart, BRDY styled
│   └── average_stat_card.dart          # Single avg-value display card
└── stats_screen.dart                   # Top-level screen ConsumerWidget
```

Routes: `/stats` added to `lib/app/router.dart`.

### Pattern 1: Riverpod Provider Chaining for Per-Round Aggregation

**What:** A top-level provider watches `completedRoundsProvider` (a stream), extracts round IDs,
then calls an existing per-round provider for each ID. Results are collected into a new view model.

**When to use:** When cross-round aggregation can be built from existing per-round providers
without adding new DAO queries.

**Example:**
```dart
// Source: established Riverpod codegen pattern from Phase 3/6 codebase
@riverpod
Future<List<FlSpot>> trendChart(Ref ref) async {
  final rounds = await ref.watch(completedRoundsProvider.future);
  // Take last 20 by most recent first (watchCompletedRounds is ordered desc)
  final last20 = rounds.take(20).toList().reversed.toList(); // oldest-first for chart x-axis
  
  final spots = <FlSpot>[];
  for (int i = 0; i < last20.length; i++) {
    final diff = await ref.watch(whsDifferentialProvider(last20[i].id).future);
    if (!diff.isUnavailable) {
      final numericValue = double.tryParse(diff.displayValue);
      if (numericValue != null) {
        spots.add(FlSpot(i.toDouble(), numericValue));
      }
    }
  }
  return spots;
}
```

### Pattern 2: fl_chart LineChart with BRDY Dark Theme

**What:** Minimal LineChart configuration matching the project's brutalist dark aesthetic.

**When to use:** STAT-01 differential trend chart.

**Example:**
```dart
// Source: fl_chart 0.71.0 API docs — github.com/imaNNeo/fl_chart
LineChart(
  LineChartData(
    backgroundColor: BrdyColors.background,
    gridData: FlGridData(
      show: true,
      getDrawingHorizontalLine: (_) => FlLine(
        color: BrdyColors.divider,
        strokeWidth: 1,
      ),
      drawVerticalLine: false,
    ),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (value, _) => Text(
            value.toStringAsFixed(1),
            style: GoogleFonts.sometypeMono(
              color: BrdyColors.onSurfaceMuted,
              fontSize: 10,
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false), // round index, no label needed
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    lineBarsData: [
      LineChartBarData(
        spots: spots, // List<FlSpot> from trendChartProvider
        color: BrdyColors.accent, // #E8520A
        barWidth: 2,
        isCurved: false,
        dotData: FlDotData(
          show: true,
          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 3,
            color: BrdyColors.accent,
            strokeColor: BrdyColors.background,
            strokeWidth: 1,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: BrdyColors.accent.withOpacity(0.08),
        ),
      ),
    ],
  ),
)
```

### Pattern 3: Cross-Round Averages Provider

**What:** Derives average metrics across all completed rounds by consuming `statsProvider` per round.

**When to use:** STAT-02 scoring averages.

```dart
// Source: established Riverpod codegen pattern from Phase 3/6 codebase
class CrossRoundAverages {
  const CrossRoundAverages({
    required this.avgScoreToPar,
    required this.avgPutts,
    required this.avgFirPercent,
    required this.avgGirPercent,
    required this.roundCount,
  });
  final double avgScoreToPar;
  final double avgPutts;
  final double avgFirPercent;
  final double avgGirPercent;
  final int roundCount;
}

@riverpod
Future<CrossRoundAverages?> crossRoundAverages(Ref ref) async {
  final rounds = await ref.watch(completedRoundsProvider.future);
  if (rounds.isEmpty) return null;

  double totalScoreToPar = 0;
  double totalPutts = 0;
  double totalFir = 0;
  double totalGir = 0;
  int count = 0;

  for (final round in rounds) {
    final stats = await ref.watch(statsProvider(round.id).future);
    if (stats == null) continue;
    totalScoreToPar += stats.scoreToPar;
    totalPutts += stats.totalPutts;
    totalFir += stats.firPercent;
    totalGir += stats.girPercent;
    count++;
  }

  if (count == 0) return null;
  return CrossRoundAverages(
    avgScoreToPar: totalScoreToPar / count,
    avgPutts: totalPutts / count,
    avgFirPercent: totalFir / count,
    avgGirPercent: totalGir / count,
    roundCount: count,
  );
}
```

### Anti-Patterns to Avoid

- **Awaiting whsDifferentialProvider inside a loop without `ref.watch`:** Use `ref.watch(...future)` inside the loop so Riverpod tracks dependencies and invalidates the parent provider when any child changes. `ref.read` inside a loop breaks reactivity (STAT-03 would fail).
- **Using `fl_chart ^1.x` in pubspec:** Version 1.x requires Flutter >=3.27.4; the project is on 3.24.5. The resolver will either fail or silently downgrade. Pin to `^0.71.0` explicitly.
- **Schema change for stats:** All statistics are computable from existing `rounds` + `holes` rows. No new Drift tables or columns are needed. Any schema change in this phase would require a migration and could conflict with Phase 6's v2 migration.
- **keepAlive for stats providers:** Stats providers are screen-level and should be `@riverpod` (auto-dispose). Using `@Riverpod(keepAlive: true)` wastes memory and contradicts the project rule that only infrastructure providers use keepAlive.
- **Blocking Setup screen with a full aggregate query:** `crossRoundAveragesProvider` iterates all rounds — if there are 200 rounds this is 200 provider watches. This is acceptable for a local-only mobile app but should not run eagerly on Setup screen load. It only runs when the user navigates to the Stats screen.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Line chart rendering | Custom `CustomPainter` with canvas path drawing | `fl_chart LineChart` | fl_chart handles axis scaling, touch interactions, dot rendering, animation, clipping. A custom painter requires 200+ lines for what fl_chart does in 20. |
| Spline/curve interpolation | Manual Bezier calculation | `isCurved: true` in `LineChartBarData` | fl_chart includes smooth curve rendering. |
| Chart axis label formatting | Manual text layout with `TextPainter` | `getTitlesWidget` callback in `SideTitles` | fl_chart handles layout; callback only needs to return a styled `Text` widget. |

**Key insight:** Charts look deceptively simple but have deep complexity in edge cases (empty data, single point, negative values, axis scaling, touch hit testing). fl_chart's 4+ years of production hardening cover these. A custom painter will always have subtle bugs on edge cases like 1-round or 0-differential datasets.

---

## Common Pitfalls

### Pitfall 1: fl_chart Version Incompatibility

**What goes wrong:** `flutter pub add fl_chart` installs 1.2.0 (latest), which requires
Flutter >=3.27.4. The project runs Flutter 3.24.5. The build fails with SDK constraint error.

**Why it happens:** `pub add` without a version constraint always fetches the latest published
version.

**How to avoid:** Always pin: `flutter pub add fl_chart:^0.71.0` (or manually add
`fl_chart: ^0.71.0` to pubspec.yaml). 0.71.0 requires Flutter >=3.16.0 — compatible.

**Warning signs:** `pubspec.yaml` shows `fl_chart: ^1.0.0` or higher; `flutter pub get` fails
with "...requires Flutter sdk version >=3.27.4".

### Pitfall 2: Empty Spots List Crashes LineChart

**What goes wrong:** `LineChart` with an empty `spots` list throws a RangeError at runtime when
computing axis bounds.

**Why it happens:** fl_chart computes `minX/maxX/minY/maxY` from the spots list; if empty,
`.reduce()` throws on an empty iterable.

**How to avoid:** Guard in `trendChartProvider` and in the widget: if `spots.isEmpty`, render
a placeholder text widget ("NOT ENOUGH DATA") instead of `LineChart`. Minimum 2 spots are needed
for a meaningful line.

**Warning signs:** Crash when user has 0 or 1 completed rounds with a valid differential.

### Pitfall 3: whsDifferentialProvider Returns N/A for Rounds Without Rating/Slope

**What goes wrong:** Some rounds were recorded without `courseRating` or `slope` (user skipped
the warning). `whsDifferentialProvider` returns `WhsDifferential(isUnavailable: true)`. If these
are included in the chart spots, `double.tryParse('N/A')` returns null and corrupts x-axis indices.

**Why it happens:** `displayValue` is "N/A" for these rounds; the chart provider must skip them.

**How to avoid:** Check `diff.isUnavailable` before calling `double.tryParse`. Skip rounds where
differential is unavailable. Consider showing a count of excluded rounds ("2 rounds excluded —
missing course rating/slope").

**Warning signs:** X-axis points jump non-sequentially; chart shows null FlSpot entries.

### Pitfall 4: Riverpod ref.watch Inside async for-loop

**What goes wrong:** Calling `await ref.watch(someProvider.future)` inside a for-loop in a
Riverpod provider is valid, but using `ref.read` breaks the dependency graph — the parent provider
won't rebuild when a child changes (STAT-03 broken).

**Why it happens:** `ref.read` reads once without subscribing; `ref.watch` subscribes and
triggers rebuild on change.

**How to avoid:** Always use `ref.watch(...future)` inside the loop body when the provider needs
to react to changes. This is the established pattern in `statsProvider` and
`whsDifferentialProvider` in this codebase.

### Pitfall 5: GoRouter Redirect Blocks /stats Navigation

**What goes wrong:** During an active round, the router's `redirect` logic sends all unknown
paths back to `/shot-capture/$incompleteRoundId`. The `/stats` path is not in the allowlist,
so navigating to stats mid-round bounces back to Shot Capture.

**Why it happens:** `router.dart` has an explicit allowlist: `/round-history` and
`/round-review/...?readOnly=true` are allowed through. `/stats` is not listed.

**How to avoid:** Add `if (state.uri.path == '/stats') return null;` to the redirect allowlist
in `router.dart`, alongside the existing `/round-history` entry. This follows the exact same
pattern used in Phase 6.

---

## Code Examples

Verified patterns from official sources:

### Minimal BRDY-Styled LineChart (fl_chart 0.71.0)

```dart
// Source: fl_chart 0.71.0 documentation — github.com/imaNNeo/fl_chart
// Adapted for BRDY design system (BrdyColors, SometypeMono)
Widget _buildChart(List<FlSpot> spots) {
  if (spots.length < 2) {
    return Center(
      child: Text(
        'NOT ENOUGH DATA',
        style: GoogleFonts.sometypeMono(color: BrdyColors.onSurfaceMuted),
      ),
    );
  }
  return LineChart(
    LineChartData(
      backgroundColor: BrdyColors.background,
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: BrdyColors.divider, strokeWidth: 1),
        drawVerticalLine: false,
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(1),
              style: GoogleFonts.sometypeMono(
                color: BrdyColors.onSurfaceMuted,
                fontSize: 10,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          color: BrdyColors.accent,
          barWidth: 2,
          isCurved: false,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 3,
              color: BrdyColors.accent,
              strokeColor: BrdyColors.background,
              strokeWidth: 1.5,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: BrdyColors.accent.withOpacity(0.08),
          ),
        ),
      ],
    ),
  );
}
```

### Riverpod Stream-Derived Provider (established codebase pattern)

```dart
// Source: lib/features/round_history/providers/completed_rounds_provider.dart
// Pattern used for completedRoundsProvider in Phase 6 — reused in Phase 7
@riverpod
Stream<List<Round>> completedRounds(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.roundDao.watchCompletedRounds();
}
```

### GoRouter Allowlist Addition (established pattern)

```dart
// Source: lib/app/router.dart — existing allowlist pattern from Phase 6
// Add /stats alongside /round-history in the redirect block:
if (state.uri.path == '/round-history') return null;
if (state.uri.path == '/stats') return null;          // ADD THIS
if (state.uri.path.startsWith('/round-review/') &&
    state.uri.queryParameters['readOnly'] == 'true') return null;
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `charts_flutter` (Google) | `fl_chart` | 2022 (charts_flutter deprecated) | charts_flutter is no longer maintained; fl_chart is the ecosystem standard |
| Manual `CustomPainter` charts | `fl_chart` | 2020+ | fl_chart provides built-in touch, animation, axis scaling |
| fl_chart 0.x API (`FLTitlesData` camelCase) | fl_chart 1.x breaking API change | 2024 (v1.0.0) | 1.x renamed many classes; 0.71.0 uses the 0.x API which is stable |

**Deprecated/outdated:**
- `charts_flutter`: Archived/unmaintained by Google since 2022. Do not use.
- `syncfusion_flutter_charts` free tier: Requires license for commercial use. Not appropriate.
- `fl_chart ^1.x`: Requires Flutter >=3.27.4 — incompatible with this project's installed Flutter.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `whsDifferentialProvider` is cheap enough to call for 20 rounds in sequence inside `trendChartProvider` without noticeable UI lag | Architecture Patterns — Pattern 1 | If each call involves multiple Drift queries, 20 chained awaits may be slow; mitigation: add a dedicated DAO query that returns differential-ready data in one SQL call |
| A2 | Phase 6 `completedRoundsProvider` is live (06-02-PLAN.md completed) when Phase 7 executes | Standard Stack | If Phase 6 is incomplete, `completedRoundsProvider` import won't exist; Phase 7 must depend on Phase 6 completion |
| A3 | User will have >=2 completed rounds with valid differentials before the chart renders | Common Pitfalls | Chart renders "NOT ENOUGH DATA" state instead; this is handled by the empty-spots guard |

**If this table is empty:** It isn't — see A1–A3 above.

---

## Open Questions

1. **Performance of 20 chained `whsDifferentialProvider` calls**
   - What we know: Each `whsDifferentialProvider` call reads 2 Drift tables (rounds + holes) and performs O(18) arithmetic. 20 in sequence = 40 Drift reads.
   - What's unclear: Whether this completes fast enough on a mid-range Android device (< 200ms).
   - Recommendation: Implement with chained providers first (clean, matches existing pattern). If profiling shows lag, add a `RoundDao.getDifferentialsForLastN(int n)` DAO method that computes all 20 in one SQL query — but only if needed.

2. **STAT-02 scope: "averages across all rounds" vs "last N rounds"**
   - What we know: The requirement says "across all rounds" without a cap.
   - What's unclear: If a user has 200 rounds, computing averages requires 200 provider instantiations. This could be slow.
   - Recommendation: Implement for all rounds as specified. If performance is an issue, a raw SQL aggregate query can replace the provider chain — but only if needed.

3. **Setup screen layout: STATS button alongside ROUND HISTORY**
   - What we know: The existing ROUND HISTORY button is an `OutlinedButton` at the bottom of the Setup screen column.
   - What's unclear: Whether both buttons should stack vertically or sit side-by-side in a row.
   - Recommendation: Stack vertically (consistent with existing layout), with STATS above ROUND HISTORY. The planner can decide on exact placement.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | fl_chart 0.71.0 | ✓ | 3.24.5 (>=3.16.0 required) | — |
| Dart SDK | fl_chart 0.71.0 | ✓ | 3.x (^3.2.0 required) | — |
| fl_chart 0.71.0 | STAT-01 line chart | ✗ (not in pubspec yet) | — | No fallback; must be added |
| RoundDao.watchCompletedRounds() | trendChartProvider | ✓ (Phase 6 Wave 1 complete) | — | — |
| completedRoundsProvider | trendChartProvider, crossRoundAveragesProvider | Depends on Phase 6 Wave 2 | — | Must complete Phase 6 first |
| whsDifferentialProvider | trendChartProvider | ✓ (Phase 3 complete) | — | — |
| statsProvider | crossRoundAveragesProvider | ✓ (Phase 3 complete) | — | — |

**Missing dependencies with no fallback:**
- `fl_chart: ^0.71.0` must be added to pubspec.yaml before chart work begins.
- Phase 6 Wave 2 must be complete (`completedRoundsProvider` must exist) before Phase 7 providers can be written.

**Missing dependencies with fallback:**
- None.

---

## Sources

### Primary (HIGH confidence)
- `pub.dev/api/packages/fl_chart` — version, SDK constraints, publish date [VERIFIED: pub.dev API]
- `pub.dev/api/packages/fl_chart/versions/0.71.0` — v0.71.0 constraints confirmed [VERIFIED: pub.dev API]
- `github.com/imaNNeo/fl_chart` — official repository, LineChart API, documentation [CITED: github.com/imaNNeo/fl_chart/blob/0.71.0/repo_files/documentations/line_chart.md]
- Codebase: `lib/features/round_review/providers/whs_differential_provider.dart` — WHS formula implementation [VERIFIED: codebase]
- Codebase: `lib/features/round_review/providers/stats_provider.dart` — StatsData model [VERIFIED: codebase]
- Codebase: `lib/data/local/database/daos/round_dao.dart` — watchCompletedRounds() [VERIFIED: codebase]
- Codebase: `lib/app/router.dart` — redirect allowlist pattern [VERIFIED: codebase]
- Codebase: `CLAUDE.md` — design system, keepAlive rules, navigation rules [VERIFIED: codebase]

### Secondary (MEDIUM confidence)
- pub.dev package page `fl_chart` — likes count, publisher verification [CITED: pub.dev/packages/fl_chart]

### Tertiary (LOW confidence)
- None.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — fl_chart version and compatibility verified via pub.dev API; all other libraries are already in pubspec
- Architecture: HIGH — providers can be built directly from existing codebase patterns; no novel architecture
- Pitfalls: HIGH — version incompatibility and empty-spots crash are verified failure modes; router redirect pattern is confirmed from existing code

**Research date:** 2026-05-20
**Valid until:** 2026-11-20 (fl_chart 0.71.0 stable; BRDY data model not changing)
