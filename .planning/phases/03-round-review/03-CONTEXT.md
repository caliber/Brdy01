# Phase 3: Round Review - Context

**Gathered:** 2026-05-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 3 delivers the `RoundReviewScreen` — the post-round destination where a golfer can see their full 18-hole scorecard, stat summary, and WHS differential, then share the scorecard or start a new round. Phase 3 also includes SHOT-13 (voice unavailable state in Shot Capture). No round history, no cloud sync, no multi-round handicap projection — single-round review only.

</domain>

<decisions>
## Implementation Decisions

### Scorecard Grid Layout
- **D-01:** Single scrollable table — all 18 holes in one vertical list. Sticky header row (Hole / Par / Outcome / Putts). Subtotal separator rows after hole 9 and hole 18 (front 9 total, back 9 total).
- **D-02:** Outcome colour via **coloured text only** — no background fill on cells. Outcome abbreviation (E, B, –, +1, +2, P) rendered in the outcome colour. Eagle = gold, birdie = orange/accent, par = plain (onSurface), bogey = underline (or muted indicator), double+ = red (`BrdyColors.destructive`). Keeps brutalist minimal look consistent with the rest of the app.
- **D-03:** Four columns per row: **Hole / Par / Outcome / Putts**. Compact and readable on mobile. SI, FIR, and GIR are not columns in the scorecard grid (FIR% and GIR% appear as aggregate stat cards below).
- **D-04:** **Scorecard first, stats scroll below** — scorecard grid at top of screen, stat cards and WHS differential in the same scroll view below it. Natural top-to-bottom reading order.

### Screen Entry Flow
- **D-05:** **Auto-navigate immediately** — when `roundCompleteProvider` becomes true in ShotCaptureScreen, call `context.go('/round-review/$roundId')`. No intermediate prompt or modal.
- **D-06:** Use `context.go()` (not `context.push()`) for the Shot Capture → Round Review transition. This replaces Shot Capture in the navigation stack so the Android back button does not return to Shot Capture after the round is complete.

### Claude's Discretion
- **Back navigation from Round Review:** User selected "you decide." Use `go_router` `WillPopScope` / `PopScope` to block back navigation from Round Review to Shot Capture. The only exit from Round Review is the "Start New Round" button (which calls `context.go('/setup')`). This is consistent with the no-round-history constraint and single-active-round model.
- **SHOT-13 placement:** Voice unavailable state lives in ShotCaptureScreen's mic/voice area (Phase 5 will fully wire voice; Phase 3 just needs the fallback state when `speech_to_text.initialize()` fails or network is absent). Implement as a `"Voice unavailable"` label replacing the voice button, with outcome buttons remaining fully functional.
- **Outcome abbreviations:** Eagle → "E" (gold `#FFD700`), Birdie → "B" (accent `BrdyColors.accent`), Par → "–" (onSurface), Bogey → "+1" (onSurfaceMuted with underline decoration), Double → "+2" (destructive `BrdyColors.destructive`), Pickup → "P" (destructive `BrdyColors.destructive`).
- **WHS differential formula:** `(Adjusted Gross Score − Course Rating) × 113 ÷ Slope`. For pickup holes: count as `par + 2 + handicap_strokes_on_hole` where `handicap_strokes_on_hole = (floor(handicap_index × slope ÷ 113) ≥ strokeIndex) ? 1 : 0` (simplified: 1 stroke if playing handicap ≥ SI on that hole, else 0). This is the standard WHS net double bogey ESC cap. Show "N/A" when courseRating or slope is null. Show "Indicative — fewer than 18 holes" label when fewer than 18 outcomes are recorded.
- **Stat card organisation:** Group into two visual sections below the scorecard: (1) Scoring — total strokes, score vs par, net score, all outcome counts (eagles, birdies, pars, bogeys, doubles, triples, pickups); (2) Approach & Putting — total putts, putts per GIR, GIR count, GIR%, fairways hit, FIR%. WHS differential appears as its own prominent block between the scorecard and the stat cards.
- **Share implementation:** Use `screenshot` package to capture the scorecard `GlobalKey` widget, then pass the resulting `Uint8List` to `share_plus` `ShareXFiles`. Capture the scorecard grid + WHS differential only (not the full screen). A `ShareService` class in `lib/services/share/` wraps this logic.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Requirements
- `.planning/REQUIREMENTS.md` — Full v1 requirements. Phase 3 requirements: SHOT-13, REV-01, REV-02, REV-03, REV-04, REV-05, REV-06, REV-07. Read the full requirement text for each — do not rely on summaries.
- `.planning/PROJECT.md` — Design system (brutalist monospace, orange accent, BrdyColors), tech stack constraints, key decisions table.

### Roadmap
- `.planning/ROADMAP.md` §Phase 3 — Goal, success criteria, cross-cutting constraints, UI hint.

### Existing Implementation (Phase 2 — direct dependency)
- `lib/features/shot_capture/providers/hole_list_provider.dart` — `holeListProvider(roundId)`: `Stream<List<Hole>>` — primary data source for scorecard
- `lib/features/shot_capture/providers/running_score_provider.dart` — `runningScoreProvider(roundId)`: running score logic (reuse or extend for final score)
- `lib/features/shot_capture/providers/course_for_round_provider.dart` — `courseForRoundProvider(roundId)`: course with Rating, Slope, holes with SI
- `lib/features/shot_capture/providers/round_complete_provider.dart` — `roundCompleteProvider`: fires when hole 18 scored; triggers auto-navigation
- `lib/data/local/database/tables/holes_table.dart` — Holes schema: `outcome` (text nullable), `putts`, `fairwayHit`, `greenInRegulation`, `strokeIndex` per hole
- `lib/domain/enums/hole_outcome.dart` — `HoleOutcome` enum: eagle, birdie, par, bogey, doubleBogey, pickup
- `lib/domain/models/round_model.dart` — `RoundModel`: `courseRating`, `slope`, `handicapIndex`

### Design System
- `lib/theme/brdy_colors.dart` — `BrdyColors` tokens (background, surface, accent, destructive, etc.)
- `lib/theme/brdy_spacing.dart` — spacing constants
- `lib/theme/brdy_text_theme.dart` — text styles
- `lib/features/shot_capture/widgets/score_bar.dart` — reference widget: JetBrains Mono numeric display in accent chip — reuse this pattern for scorecard numerics
- `lib/features/shot_capture/widgets/hole_header.dart` — reference for pill/chip display pattern and Barlow Condensed labels

### Share Stack
- `lib/services/share/` — empty placeholder; ShareService goes here
- Stack: `share_plus: ^9.0.0` + `screenshot: ^2.5.0` (both already in pubspec.yaml)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ScoreBar` widget (`lib/features/shot_capture/widgets/score_bar.dart`): JetBrains Mono score display with accent chip + flutter_animate pulse — reuse pattern for WHS differential display
- `BrdyColors.destructive` (`#CC2200`): available for double+/pickup cell text colour
- `holeListProvider(roundId)`: already streams all hole data with outcome, putts, fairway, GIR, strokeIndex — no new DAOs needed for the scorecard
- `courseForRoundProvider(roundId)`: provides course name, Rating, Slope, and per-hole SI — all WHS inputs available
- `intl` (already in pubspec): use `NumberFormat` for displaying differential to 1 decimal place
- `gap` package (already in pubspec): `Gap(n)` for semantic spacing in stat card layout

### Established Patterns
- `@riverpod` (auto-dispose) for all new providers — never `@Riverpod(keepAlive: true)` for Phase 3 providers
- `.whenData()` for transforming `AsyncValue` streams in providers
- `ConsumerWidget` for all widgets that read providers
- `context.go()` exclusively for screen transitions (never `context.push()` for main screens)
- `GoogleFonts.jetBrainsMono()` for scores/numerics, `GoogleFonts.barlowCondensed()` for labels
- `flutter_animate` for micro-animations — already wired via `flutter_animate.dart` import
- `const` constructors throughout; `super.key` in all constructors

### Integration Points
- `RoundReviewScreen` (`lib/features/round_review/round_review_screen.dart`): currently a stub — this is the canvas for Phase 3
- `lib/features/round_review/widgets/`: empty — all new scorecard/stat widgets go here
- `lib/app/router.dart`: go_router already configured; Phase 3 needs `/round-review/:roundId` route confirmed/wired
- `ShotCaptureScreen`: add `ref.listen(roundCompleteProvider(roundId), ...)` listener that calls `context.go('/round-review/$roundId')` on completion
- `lib/services/share/`: empty placeholder — `ShareService` class goes here

</code_context>

<specifics>
## Specific Ideas

No specific design references beyond what is captured in decisions — open to standard approaches within the brutalist monospace design system.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 3-Round Review*
*Context gathered: 2026-05-18*
