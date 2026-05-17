# Phase 3: Round Review - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-18
**Phase:** 3-Round Review
**Areas discussed:** Scorecard grid layout, Screen entry flow

---

## Scorecard Grid Layout

| Option | Description | Selected |
|--------|-------------|----------|
| Single scrollable table | All 18 holes in one vertical list. Sticky header row. Subtotal rows after hole 9 and 18. | ✓ |
| Two fixed panels — front 9 / back 9 | Side-by-side or stacked panels, each showing exactly 9 rows. Both visible without scrolling. | |
| Horizontal table (golf card style) | Holes run left-to-right. Requires horizontal scroll. | |

**User's choice:** Single scrollable table
**Notes:** Familiar golf scorecard pattern.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Coloured text only | Outcome abbreviation in outcome colour. Cells stay black. | ✓ |
| Filled cell background | Cell background fills with outcome colour across 18 cells. | |
| Coloured left border per row | 3px accent stripe on left edge of each row. | |

**User's choice:** Coloured text only
**Notes:** Consistent with brutalist minimal aesthetic.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Hole / Par / Outcome / Putts | 4 columns. Tight and readable on mobile. | ✓ |
| Hole / Par / SI / Outcome / Putts | 5 columns — adds Stroke Index. | |
| Hole / Par / Outcome / Putts / FIR / GIR | 6 columns — adds fairway and GIR per hole. | |

**User's choice:** Hole / Par / Outcome / Putts
**Notes:** FIR and GIR appear as aggregate stat cards below the scorecard, not per-hole columns.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Scorecard first, stats scroll below | Scorecard at top, stats below in same scroll view. | ✓ |
| Stats first, scorecard below | Differential and stat cards at top, scorecard below. | |
| Tabbed — Scorecard tab / Stats tab | Two tabs, no scrolling required in either. | |

**User's choice:** Scorecard first, stats scroll below
**Notes:** Natural top-to-bottom reading order.

---

## Screen Entry Flow

| Option | Description | Selected |
|--------|-------------|----------|
| Auto-navigate immediately | roundCompleteProvider → context.go('/round-review/$roundId') | ✓ |
| Prompt with a banner/button | 'VIEW RESULTS' button appears after hole 18. | |
| Modal / bottom sheet | Full-screen modal over Shot Capture with 'Round complete' CTA. | |

**User's choice:** Auto-navigate immediately
**Notes:** Fastest path once scoring is done.

---

| Option | Description | Selected |
|--------|-------------|----------|
| No back navigation — round is done | Only exit is 'Start New Round'. | |
| Yes — back button returns to Shot Capture | Standard back behaviour. | |
| You decide | Handle however fits the navigation architecture. | ✓ |

**User's choice:** You decide (Claude discretion)
**Notes:** Claude decided: use `context.go()` (not push) so back-stack does not include Shot Capture. `PopScope` to block back navigation from Round Review.

---

## Claude's Discretion

- **Back navigation from Round Review:** Claude chose to block back navigation using `context.go()` transition and `PopScope`. Consistent with no-round-history constraint.
- **Outcome abbreviations and colours:** Eagle = "E" (gold `#FFD700`), Birdie = "B" (accent), Par = "–" (onSurface), Bogey = "+1" (muted + underline), Double = "+2" (destructive), Pickup = "P" (destructive).
- **WHS formula detail:** Net double bogey = `par + 2 + handicap_strokes_on_hole`. Playing handicap = `floor(handicap_index × slope ÷ 113)`. Stroke on hole = 1 if playing handicap ≥ SI, else 0.
- **Stat card grouping:** Two sections — Scoring (outcome counts) and Approach & Putting (putts, GIR, FIR). WHS differential as its own block between scorecard and stats.
- **Share implementation:** `screenshot` captures scorecard GlobalKey + WHS block → `share_plus` XFiles. `ShareService` in `lib/services/share/`.
- **SHOT-13:** "Voice unavailable" label replaces voice button when `speech_to_text.initialize()` fails. Outcome buttons remain functional.

## Deferred Ideas

None — discussion stayed within phase scope.
