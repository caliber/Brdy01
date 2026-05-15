# Requirements: BRDY.01

**Defined:** 2026-05-16
**Core Value:** A golfer finishes a hole, taps one button, and the round stays accurate — frictionless hole-by-hole scoring on the course.

## v1 Requirements

### Foundation

Infrastructure requirements that underpin every user-facing feature.

- [ ] **FOUND-01**: Round data (outcome, putts, fairway, GIR per hole) is written to Drift immediately on entry — write-through persistence, no batching
- [ ] **FOUND-02**: App recovers an in-progress round if restarted mid-round (Drift-backed crash recovery)
- [ ] **FOUND-03**: App redirects automatically to Shot Capture at the correct hole if an incomplete round is detected on startup
- [ ] **FOUND-04**: Golf Course API key is validated at startup; clear error state shown if absent or returning 401
- [ ] **FOUND-05**: OSM map tiles are pre-cached for the loaded course bounding box when a course is loaded (offline-first guarantee for on-course use)

### Setup

- [ ] **SETUP-01**: User can enter handicap index (decimal numeric input, e.g. 14.3, stored in Hive)
- [ ] **SETUP-02**: User can search for a golf course by name via golfcourseapi.com
- [ ] **SETUP-03**: User can load a course (stores: name, Course Rating, Slope, hole-by-hole par, Stroke Index per hole, GPS hole layout, course metadata)
- [ ] **SETUP-04**: Loaded course is cached locally in Hive for offline use; last-used course is pre-selected on next Setup open
- [ ] **SETUP-05**: User sees a warning if a loaded course is missing Course Rating or Slope, with option to enter both values manually

### Shot Capture

- [ ] **SHOT-01**: User can record hole outcome via outcome buttons: BIRDIE / PAR / BOGEY / DOUBLE / PICKUP
- [ ] **SHOT-02**: User can record EAGLE outcome by double-tapping the BIRDIE button (displayed as distinct from birdie in all stats)
- [ ] **SHOT-03**: App auto-advances to the next hole immediately after an outcome button is tapped
- [ ] **SHOT-04**: User can undo the last score entry within 4 seconds via an auto-dismissing toast ("BIRDIE — Hole 7 [UNDO]")
- [ ] **SHOT-05**: User can record putts per hole via a +/− counter
- [ ] **SHOT-06**: User can toggle fairway hit per hole (toggle is hidden / marked N/A on par 3s)
- [ ] **SHOT-07**: User can toggle GIR (Green in Regulation) per hole
- [ ] **SHOT-08**: User can drop GPS shot pins on the map overlay by tapping the map (pins stored in Drift, not used in scoring)
- [ ] **SHOT-09**: User can record hole outcome by voice command ("eagle", "birdie", "par", "bogey", "double", "pickup"); voice confirmation shown as toast with undo option
- [ ] **SHOT-10**: Running score vs par is always visible during the round (persists across hole transitions, no tap required)
- [ ] **SHOT-11**: Each hole displays its hole number, par, and Stroke Index prominently
- [ ] **SHOT-12**: User can navigate back to any previously scored hole to correct an entry (internal state change, not route back-stack)
- [ ] **SHOT-13**: Voice recognition shows "Voice unavailable" state when network is absent or `speech_to_text.initialize()` fails; outcome buttons remain fully functional

### Round Review

- [ ] **REV-01**: User sees a full 18-hole scorecard grid (hole number, par, outcome, putts per hole) with colour-coded outcome cells (eagle=gold, birdie=orange, par=plain, bogey=underline, double+=red)
- [ ] **REV-02**: Scorecard shows front 9 and back 9 subtotals
- [ ] **REV-03**: User sees stat cards: total strokes, score vs par, net score (gross minus playing handicap), eagles, birdies, pars, bogeys, doubles, triples (par+3 or worse), pickups, total putts, putts per GIR, GIR count, GIR%, fairways hit, FIR%
- [ ] **REV-04**: User sees this round's WHS differential: (Adjusted Gross Score − Course Rating) × 113 ÷ Slope; pickup holes scored at net double bogey (par + 2 + handicap strokes on that hole); differential shown as "N/A" if Course Rating or Slope is missing
- [ ] **REV-05**: Differential is only calculated and displayed when all 18 holes have a recorded outcome; if fewer than 18 holes are complete, an indicative differential is shown with a clear label ("Indicative — fewer than 18 holes")
- [ ] **REV-06**: User can share/export the scorecard via the native share sheet (screenshot of the scorecard view)
- [ ] **REV-07**: User can start a new round (resets active round state, returns to Setup)

### Wear OS

- [ ] **WEAR-01**: Wear OS companion displays the current hole number, par, and score buttons (EAGLE / BIRDIE / PAR / BOGEY / DOUBLE / PICKUP) on the watch screen
- [ ] **WEAR-02**: Score entry on the watch syncs the outcome to the phone's active round
- [ ] **WEAR-03**: Watch handles "phone not connected" state gracefully (queues locally, syncs on reconnect; shows connection status indicator)

## v2 Requirements

### Round History

- **HIST-01**: User can view a list of completed rounds with date, course, score, and differential
- **HIST-02**: User can view the scorecard and stats for any past round
- **HIST-03**: App calculates WHS handicap projection using best 8 of last 20 differentials

### 9-Hole Rounds

- **NINE-01**: User can play and score a 9-hole round
- **NINE-02**: App applies WHS 9-hole posting formula and shows the adjusted differential

### Enhanced Voice

- **VOIC-01**: User can record putts by voice ("two putts", "three putts")
- **VOIC-02**: User can toggle fairway and GIR by voice ("fairway", "green")

### Course Management

- **COUR-01**: User can manually add or edit course details (name, rating, slope, pars) for courses not in the API
- **COUR-02**: User can delete a cached course

## Out of Scope

| Feature | Reason |
|---------|--------|
| User accounts / authentication | Local-only by design; no server needed |
| Cloud sync or backup | Local data only; simplicity over continuity |
| Multi-round WHS handicap projection | Single-round differential is sufficient; round history deferred to v2 |
| Shot-by-shot stroke counting as primary model | Outcome buttons are faster on-course; counting is secondary |
| Stableford / match play modes | Strokeplay only; keeps scoring model simple |
| Multiplayer / group scoring | Solo tool; doubles the complexity of every screen |
| Club tracking | Requires sensor hardware or AI inference; out of scope |
| Shot distance display from GPS | GPS accuracy 3-5m; distances would mislead; pins are decorative |
| Full voice dictation (navigation, stats) | Fixed vocabulary only; NLP adds complexity and outdoor failure modes |
| Wear OS GPS, voice, or stat toggles | Score buttons only; anything more is complexity without on-course gain |
| Push notifications | Round reminders are intrusive; local-only app has no server to push from |
| Advertising | Incompatible with design aesthetic and user trust |
| Weather overlay | API dependency, connectivity requirement, visual noise |
| Round history / past-round list | Single round at a time; share sheet is the archive; history deferred to v2 |
| Always-on voice listening | Battery drain, false positives outdoors; tap-to-speak only |

## Traceability

*Populated during roadmap creation.*

| Requirement | Phase | Status |
|-------------|-------|--------|
| FOUND-01 | — | Pending |
| FOUND-02 | — | Pending |
| FOUND-03 | — | Pending |
| FOUND-04 | — | Pending |
| FOUND-05 | — | Pending |
| SETUP-01 | — | Pending |
| SETUP-02 | — | Pending |
| SETUP-03 | — | Pending |
| SETUP-04 | — | Pending |
| SETUP-05 | — | Pending |
| SHOT-01 | — | Pending |
| SHOT-02 | — | Pending |
| SHOT-03 | — | Pending |
| SHOT-04 | — | Pending |
| SHOT-05 | — | Pending |
| SHOT-06 | — | Pending |
| SHOT-07 | — | Pending |
| SHOT-08 | — | Pending |
| SHOT-09 | — | Pending |
| SHOT-10 | — | Pending |
| SHOT-11 | — | Pending |
| SHOT-12 | — | Pending |
| SHOT-13 | — | Pending |
| REV-01 | — | Pending |
| REV-02 | — | Pending |
| REV-03 | — | Pending |
| REV-04 | — | Pending |
| REV-05 | — | Pending |
| REV-06 | — | Pending |
| REV-07 | — | Pending |
| WEAR-01 | — | Pending |
| WEAR-02 | — | Pending |
| WEAR-03 | — | Pending |

**Coverage:**
- v1 requirements: 33 total
- Mapped to phases: 0 (pending roadmap)
- Unmapped: 33 ⚠️

---
*Requirements defined: 2026-05-16*
*Last updated: 2026-05-16 after initial definition*
