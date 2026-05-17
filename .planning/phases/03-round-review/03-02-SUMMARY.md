---
phase: "03-round-review"
plan: 02
subsystem: "round-review-widgets"
tags: [flutter, riverpod, widgets, scorecard, whs, stats, google-fonts]
dependency_graph:
  requires:
    - lib/features/round_review/providers/scorecard_provider.dart
    - lib/features/round_review/providers/stats_provider.dart
    - lib/features/round_review/providers/whs_differential_provider.dart
    - lib/theme/brdy_colors.dart
    - lib/theme/brdy_spacing.dart
  provides:
    - lib/features/round_review/widgets/scorecard_table.dart
    - lib/features/round_review/widgets/whs_block.dart
    - lib/features/round_review/widgets/stat_card.dart
    - lib/features/round_review/widgets/stats_section.dart
  affects:
    - lib/features/round_review/round_review_screen.dart (Wave 3 assembles these)
tech_stack:
  added: []
  patterns:
    - "ConsumerWidget with ref.watch(provider(roundId)) for all data-reading widgets"
    - "StatelessWidget const-constructable for pure display widgets (StatCard)"
    - "Table widget with FixedColumnWidth/FlexColumnWidth for pixel-aligned scorecard grid"
    - "TextDecoration.underline on bogey outcome only (D-02 convention)"
    - "GoogleFonts.jetBrainsMono for all numeric values; GoogleFonts.barlowCondensed for all labels"
    - "Gap(BrdySpacing.*) from gap package for semantic spacing in StatsSection"
    - "Wrap for stat card layout — responsive to available width"
key_files:
  created:
    - lib/features/round_review/widgets/scorecard_table.dart
    - lib/features/round_review/widgets/whs_block.dart
    - lib/features/round_review/widgets/stat_card.dart
    - lib/features/round_review/widgets/stats_section.dart
  modified: []
decisions:
  - "ScorecardTable renders header + all 18 hole rows + subtotals in a single Table widget — column widths align across all row types"
  - "Subtotal rows use BoxDecoration with border top (divider) not a separate Divider widget — stays within Table constraints"
  - "WhsBlock does NOT hold the screenshot GlobalKey — key is managed at screen level (Wave 3 wraps scorecard+WHS block)"
  - "StatCard has fullWidth bool param (defaults false) for future use in full-width layout slots"
  - "StatsSection uses Wrap not Row/Column for stat cards — handles variable screen widths naturally"
metrics:
  duration: "~4 minutes"
  completed_date: "2026-05-18"
  tasks_completed: 2
  files_created: 4
---

# Phase 3 Plan 02: Round Review Widgets Summary

Four composable widgets for the Round Review screen visual surface: scrollable scorecard Table grid with sticky-compatible header, WHS differential block with prominent 48sp numeric display, a reusable const StatCard, and a stats section grouping all stat cards in two labelled Wrap groups.

## What Was Built

### Task 1: ScorecardTable widget (commit: 92efda7)

Created `lib/features/round_review/widgets/scorecard_table.dart`:

- `ScorecardTable` extends `ConsumerWidget`; constructor `const ScorecardTable({super.key, required this.roundId})`
- Watches `scorecardProvider(roundId)` — null check shows `CircularProgressIndicator(accent)` during loading
- `Table` widget with 4 typed `columnWidths`: HOLE=`FixedColumnWidth(48)`, PAR=`FixedColumnWidth(36)`, OUTCOME=`FlexColumnWidth(1)`, PUTTS=`FixedColumnWidth(48)`
- Header `TableRow`: Barlow Condensed 12sp w700 onSurfaceMuted labels, 36px height, `BrdyColors.surface` background
- Hole `TableRow`s: rows 1–9, then front9 subtotal, then rows 10–18, then back9 subtotal
  - Alternating backgrounds: odd holeNumber = `BrdyColors.background`, even = `BrdyColors.surface`
  - `0.5px` bottom divider border on each hole row
  - JetBrains Mono 14sp for HOLE, PAR, PUTTS values
  - OUTCOME text: `row.outcomeColor ?? onSurfaceMuted`; `TextDecoration.underline` ONLY when `outcomeAbbr == '+1'` (bogey, per D-02)
- Subtotal `TableRow`s: `1px` top border (divider), label in HOLE column (Barlow Condensed 12sp w700 muted), total strokes + score-to-par suffix in OUTCOME column

### Task 2: WhsBlock, StatCard, StatsSection widgets (commit: 276a6a4)

**whs_block.dart — `WhsBlock` extends `ConsumerWidget`:**
- Watches `whsDifferentialProvider(roundId)` as `AsyncValue<WhsDifferential>`
- Loading state: 48-height empty `Container` (no flicker spinner for compact widget)
- Error state: `Text('WHS N/A', ...)` in Barlow Condensed muted
- Data state: `Container` with `BrdyColors.surface`, rounded corners (radius 8), 16dp padding
  - Row 1: "WHS DIFFERENTIAL" in Barlow Condensed 12sp w700 muted, letterSpacing 1.5
  - Row 2: `whs.displayValue` in JetBrains Mono 48sp w700 onSurface (shows "N/A" when `isUnavailable`)
  - Row 3 (conditional): `whs.indicativeLabel` in Barlow Condensed 11sp muted when `isIndicative && indicativeLabel != null`

**stat_card.dart — `StatCard` extends `StatelessWidget`:**
- `const StatCard({super.key, required this.label, required this.value, this.fullWidth = false})`
- `Container` with `BrdyColors.surface`, `BorderRadius.circular(4)`, 16px horizontal / 8px vertical padding
- Label: Barlow Condensed 11sp w700 muted, letterSpacing 1.2
- Value: JetBrains Mono 20sp w700 onSurface
- No provider reads — pure display widget

**stats_section.dart — `StatsSection` extends `ConsumerWidget`:**
- Watches `statsProvider(roundId)` as `AsyncValue<StatsData?>`
- Loading: centered `CircularProgressIndicator(accent)`
- Error: `Text('Stats unavailable', ...)` in Barlow Condensed muted
- Data: `Column` with two `Wrap` sections separated by `Gap(BrdySpacing.md)`:
  - **Scoring**: STROKES, VS PAR (formatted E/+N/−N), NET SCORE, EAGLES, BIRDIES, PARS, BOGEYS, DOUBLES, TRIPLES, PICKUPS
  - **Approach & Putting**: PUTTS, PUTTS/GIR (1dp), GIRS, GIR% (0dp + %), FWY HIT, FIR% (0dp + %)
- Private `_formatScoreToPar(int)` helper: "E" for 0, "+N" for positive, "N" for negative

## Verification Results

| Check | Result |
|-------|--------|
| flutter analyze lib/features/round_review/widgets/ | No issues found |
| grep -c keepAlive all widget files | 0 (all auto-dispose) |
| grep StatelessWidget stat_card.dart | PASS — StatCard is NOT ConsumerWidget |
| grep ConsumerWidget scorecard_table + whs_block + stats_section | PASS — all three are ConsumerWidgets |
| grep TextDecoration.underline scorecard_table.dart | PASS — bogey underline present |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Added `const` to BoxDecoration in subtotal row**
- **Found during:** Task 1 — flutter analyze lint check (`prefer_const_constructors`)
- **Issue:** `BoxDecoration` in `_buildSubtotalRow` used `const` on the nested `Border` but not the outer `BoxDecoration`, triggering the lint
- **Fix:** Changed `BoxDecoration(color: ..., border: const Border(...))` to `const BoxDecoration(color: ..., border: Border(...))` — valid since all fields are compile-time constants
- **Files modified:** lib/features/round_review/widgets/scorecard_table.dart
- **Commit:** Part of 276a6a4 (fixed before Task 2 commit)

None other — plan executed as written.

## Known Stubs

None — all widgets render live data from Wave 1 providers. No placeholder text or hardcoded values in rendered output.

## Threat Flags

No new trust boundaries introduced. All four widgets are pure renderers consuming pre-validated data from Wave 1 providers. T-03-05 (overflow risk from outcome strings) is mitigated by `FixedColumnWidth(36)` PAR column and `FixedColumnWidth(48)` PUTTS column with `FlexColumnWidth(1)` for OUTCOME — outcome abbreviations are 1–2 characters maximum ("E", "B", "–", "+1", "+2", "P") and cannot overflow the flex column.

## Self-Check

- [x] scorecard_table.dart exists with ScorecardTable ConsumerWidget
- [x] whs_block.dart exists with WhsBlock ConsumerWidget
- [x] stat_card.dart exists with StatCard StatelessWidget (NOT ConsumerWidget)
- [x] stats_section.dart exists with StatsSection ConsumerWidget
- [x] flutter analyze: no issues on all 4 widget files
- [x] No keepAlive in any widget file
- [x] TextDecoration.underline present for bogey in scorecard_table.dart
- [x] Commit 92efda7: Task 1 (ScorecardTable)
- [x] Commit 276a6a4: Task 2 (WhsBlock, StatCard, StatsSection)

## Self-Check: PASSED
