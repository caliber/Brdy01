# Features Research

> Confidence: HIGH for WHS rules and stat definitions. MEDIUM for competitor UX patterns (training data, cutoff Aug 2025).

## Table Stakes

Features golfers expect. Absence makes the app feel unfinished.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Running total vs par | Every scorecard shows +/- at all times | Low | Show on every hole screen, not just review |
| Front 9 / Back 9 subtotals | Standard scorecard format | Low | Subtotals at holes 9 and 18 in Round Review |
| Per-hole par reminder | Golfer needs par to understand their outcome button | Low | Show par on Shot Capture screen beside hole number |
| Stroke Index display | Golfers know which holes their handicap strokes fall on | Medium | Requires SI from API per hole; enables net score display |
| Net score display | Playing off handicap — they want net alongside gross | Medium | Net = gross minus handicap strokes on that hole |
| Shareable scorecard | Paper scorecard is the social object of golf | Low | Already in scope; output must look worth sharing |
| Visual hole-by-hole scorecard grid | Industry-standard: holes 1-18, par, score, putts | Low | Already in scope |
| Stat summary post-round | GIR%, FIR%, putts per hole, putts per GIR | Low | Already in scope |
| WHS differential display | Most golfers post their scores — want differential immediately | Low | Already in scope |
| Correction capability | Everyone fat-fingers a score | Low | Already in scope (back-navigation) |

**What Arccos gets right:** Automatic shot detection removes recording burden. BRDY.01's tradeoff is intentional entry for simplicity — must be faster at intentional entry than Arccos at automatic detection + post-round correction.

**What 18Birdies gets right:** Large hole number, par, and running score dominate the screen. Buttons are big enough to tap without looking. Auto-advance to next hole after score entry. BRDY.01 should match both.

**What Golfshot gets right:** Post-round scorecard is shareable as an image, not just text. The scorecard image is what golfers post socially.

**What Shot Scope gets right:** Wrist-based score entry — one button per outcome, no screen unlock. BRDY.01's Wear OS companion does the same without proprietary hardware.

## Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Brutalist design aesthetic | Golfers are tired of green/nature themes; JetBrains Mono numerics look precise | Low | Already defined |
| Voice score entry | Saying "bogey" is faster than tapping with wet gloves; no major competitor does fixed-vocab voice | Medium | Already in scope |
| No account required, ever | Every major competitor has account friction; local-only is a genuine differentiator | None | Already decided |
| Zero subscription | 18Birdies, Golfshot, Arccos all have premium tiers; no paywall surface | None | By design |
| Wear OS on existing hardware | Shot Scope requires proprietary hardware; BRDY.01 works with any Wear OS watch | Medium | Already in scope |
| GPS shot pins as map art | Not used in scoring — a visual record; the accumulated pin cloud is a unique "story of the round" artefact | Low | Already in scope |
| WHS differential shown immediately | Competitors bury this or require posting via their platform | Low | Already in scope |

## Anti-Features

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Round history / list screen | Navigation complexity, implicit expectation of cloud sync | Share sheet is the archive |
| Stroke-by-stroke counting | Slower than outcome buttons for recreational golfers | Outcome buttons are the model |
| Club tracking | Arccos's value proposition; requires sensor hardware | Explicitly out of scope |
| Course flyover / hole preview animations | Bandwidth-heavy, conflicts with offline-first | Show hole map from cached GPS layout only |
| Leaderboard / social scoring | Requires accounts and server | Solo tool by design |
| AI tips on-course | Annoying on-course; conflicts with fast UX | Never |
| Advertising | Incompatible with brutalist aesthetic and trust | Never |
| Push notifications | Round reminders are intrusive | Never |
| Stableford / match play modes | Scoring model branching | Strokeplay only |
| Shot distance display from GPS | GPS accuracy 3-5m; distances would mislead | Pins are decorative, not measurements |
| Live weather overlay | API dependency, connectivity, visual noise | Not worth it for a local-first app |
| Multi-player group scoring | Doubles complexity of every screen | Solo only |

## On-Course UX Patterns

### Physical Context Constraints

**Gloves.** Golf gloves degrade touch sensitivity. Minimum tap target: 56dp × 56dp. Outcome buttons should be at least 72dp tall. No tap target smaller than 44dp on any on-course screen.

**Sunlight.** Contrast ratio must exceed 7:1+ for all text used during the round. The brutalist design (orange on black, white on black) naturally achieves this. Never use mid-grey text on white for any on-course screen.

**One-handed use.** All primary on-course interactions must be reachable in the thumb zone on both left and right hand. Bottom-of-screen placement for score buttons is correct. Avoid placing critical actions in the top half of the screen during Shot Capture.

**Wet hands.** Swipe gestures are unreliable on-course — use explicit taps for primary actions. Avoid placing "submit" and "back" adjacent without visual gap.

**Battery anxiety.** Rounds last 4-5 hours. Do not keep GPS running when the map is off-screen. App must resume instantly to current hole on wake — no loading spinners.

**Pocket / resume.** Golfers pocket the phone between shots. State must survive screen-off without re-querying the database. Hold current hole state in Riverpod memory; restore from DB only after process kill.

### Interaction Speed

**Target:** Hole recorded in under 3 seconds from screen unlock.

**Score entry first, always.** Outcome buttons must be reachable without scrolling, without toggling any view, without any modal.

**No confirmation modals after score entry.** Just record and allow back-navigation to correct. The only appropriate confirmation is "End Round" — irreversible and consequential.

**Auto-advance after outcome tap.** Automatically advance to the next hole after recording an outcome. This is the single biggest speed improvement over apps that require an explicit "Next" button. 18Birdies does this; Golfshot does not.

**Running score always visible.** Total strokes vs par should persist across all hole transitions, never requiring a tap to see.

**Voice command visual confirmation.** After "birdie" is accepted, immediately highlight the BIRDIE button and/or trigger haptic. Silent acceptance creates doubt.

### Scorecard Colour Conventions

These are universal across golf apps — derive from paper scorecard tradition:

- Eagle or better: Gold / yellow circle
- Birdie: Red circle (BRDY.01's orange accent is an acceptable variant)
- Par: No highlight (plain)
- Bogey: Single underline or square
- Double bogey+: Double underline or red square

Do not invent novel colour coding. Golfers read scorecards by colour pattern.

**Grid layout.** Standard: hole numbers across top row, par row, score row, putts row. Front 9 then Back 9 with subtotals.

## Stat Definitions

Standard definitions used by USGA/R&A. Confidence: HIGH — published sport definitions.

| Stat | Definition | Notes |
|------|------------|-------|
| Score vs Par | Total strokes minus total par for the course | Use course total par (18-hole sum) |
| Birdies | Holes where score = par − 1 | |
| Eagles | Holes where score = par − 2 | Keep separate from birdies |
| Pars | Holes where score = par | |
| Bogeys | Holes where score = par + 1 | |
| Doubles | Holes where score = par + 2 | |
| Triples+ | Holes where score ≥ par + 3 | Distinct from pickups |
| Pickups | Holes where golfer did not complete | Scored at net double bogey for WHS |
| Total putts | Sum of putts per hole | |
| Putts per hole | Total putts ÷ completed holes | Benchmark: scratch ~1.7, bogey golfer ~2.0 |
| Putts per GIR | Total putts on GIR holes ÷ GIR count | The skill putting metric |
| GIR | Ball on putting surface in (par − 2) or fewer strokes | Par 3: on in 1. Par 4: on in 2. Par 5: on in 3. |
| GIR % | GIR holes ÷ total holes × 100 | Tour ~65%, bogey golfer ~20-30% |
| FIR | Tee shot in fairway | Par 4s and par 5s only — never count par 3s |
| FIR % | FIR holes ÷ eligible holes × 100 | Common mistake: including par 3s deflates this incorrectly |

### Critical Gap: Eagle vs Birdie Cannot Be Distinguished

The five-button model (BIRDIE/PAR/BOGEY/DOUBLE/PICKUP) causes information loss:

1. **Eagle vs Birdie.** A 2 on a par 4 is an eagle but would be recorded as BIRDIE. Stat card spec calls for eagles separately — impossible with 5 buttons.
2. **Double vs Triple+.** A 10 on a par 4 cannot be distinguished from a 6.

**Recommended resolutions:**

- **Option A (Recommended):** Add EAGLE button (6 buttons). Eagles matter emotionally and statistically. One extra button; permanent data loss from omitting it.
- **Option B:** Collapse eagles into birdies for stats with a footnote. Acceptable if 6-button layout is rejected.
- **Option C:** DOUBLE button cycles on long-press (double-tap = triple). Low-discoverability edge case.

## WHS Differential Edge Cases

Confidence: HIGH. Rules of Handicapping (USGA/R&A, effective 2020).

### The Formula

```
Handicap Differential = (Adjusted Gross Score − Course Rating) × 113 ÷ Slope Rating
```

Round to 1 decimal place.

### Adjusted Gross Score (AGS)

Each hole's score is capped at net double bogey before summing:

```
Net Double Bogey cap = Par + 2 + handicap strokes received on that hole
```

**Playing Handicap calculation:**
```
Playing Handicap = round(Handicap Index × (Slope Rating ÷ 113))
```

**Stroke allocation:** Playing Handicap 17 = 1 stroke on each of SI 1–17. Playing Handicap 20 = 2 strokes on SI 1–2, 1 stroke on SI 3–18.

**Implementation requirement:** BRDY.01 must store Stroke Index per hole from the API, calculate Playing Handicap, and determine strokes received per hole to compute the net double bogey cap. This drives both pickup scoring and the AGS cap.

### Pickup Scoring

```
Pickup score = par_for_hole + 2 + handicap_strokes_received_on_hole
```

Requires Stroke Index — verify Golf Course API returns SI per hole (it does in standard golfcourseapi.com response schema).

### ESC vs WHS Terminology

The PROJECT.md mentions "ESC (Equitable Stroke Control)." ESC was the pre-2020 USGA system (fixed caps by handicap range bucket). WHS replaced it in 2020 with the per-hole net double bogey cap. Label internal code and UI as "net double bogey" not "ESC."

### Incomplete Rounds

WHS requires minimum 7 holes for score posting. If golfer quits early, display indicative differential but label: "Minimum 7 completed holes required for official WHS posting." Do not block calculation — just flag it.

### Missing Course Rating or Slope

Display: "Differential unavailable — Course Rating or Slope not found." Do not block round completion or scorecard sharing.

## GPS Shot Pinning UX

Confidence: MEDIUM.

### How Golfers Actually Use GPS Pins

Most recreational golfers try pinning for 2-3 holes and stop — it adds friction. Consistent users are stat-obsessed single-digit handicappers and golfers wanting a visual record.

**Implication:** GPS pins must feel effortless and skippable. If pinning adds more than 5 seconds per hole, most golfers abandon it. The Shot Capture screen must not require the map visible at all.

### What Works

- **Tap to pin, long-press to drag.** No multi-step workflows.
- **Auto-zoom to current hole.** Map centers on hole fairway when hole transitions. No manual pan/zoom.
- **Current location dot.** Show golfer's GPS position for context.
- **Pin accumulation at round end.** Full pin cloud across all 18 holes = the "story of the round" artefact.

### What Doesn't Work

- **GPS accuracy is 3-5m open sky, 10-15m under trees.** Do not display calculated distances. Pins are visual markers, not measurements.
- **On-course connectivity is unreliable.** OSM tiles must be pre-cached when the course is loaded. Without caching: blank map with GPS layout lines only — tolerable, suboptimal.
- **Continuous GPS drains battery.** GPS active only when map is visible. Suspend on screen-off.

### Map as Secondary Panel

Map is a secondary panel on Shot Capture, not primary view. Score buttons dominate; map is below or behind a toggle. Golfers who skip it never see it.

## Open Questions

1. **Does the Golf Course API return Stroke Index per hole?** Required for net double bogey and Playing Handicap stroke allocation. Confirm in Phase 1 API integration.
2. **Eagle button decision.** Five-button model cannot capture eagles. Decide before Shot Capture screen implementation — adding a sixth button later requires UI rework.
3. **Map tile pre-caching.** `flutter_map_tile_caching` adds a dependency outside the locked stack. Evaluate whether tile caching is required or whether GPS layout overlay alone is sufficient.
4. **Net score display.** The stat card spec doesn't mention net score. Low complexity to add — flag for Round Review phase.
5. **Triple+/worse scoring.** DOUBLE button is inaccurate for par+3 or worse. Decide: WORSE button, cycling interaction, or document the known limitation.
