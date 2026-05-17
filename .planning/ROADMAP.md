# Roadmap: BRDY.01

## Overview

BRDY.01 delivers frictionless strokeplay scoring in five vertical slices. Phase 1 wires up the full persistence and infrastructure stack so a golfer can load a course and start a round. Phase 2 builds the complete Shot Capture screen so they can score every hole. Phase 3 surfaces the scorecard and WHS differential on Round Review. Phase 4 extends scoring to the wrist via Wear OS. Phase 5 layers in GPS shot pins, voice commands, and surface polish that require all prior features to be stable.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation + Setup** - User can load a course and start a round
- [x] **Phase 2: Shot Capture** - User can score a full 18-hole round
- [ ] **Phase 3: Round Review** - User can see their scorecard and stats
- [ ] **Phase 4: Wear OS** - User can score from the watch
- [ ] **Phase 5: Polish** - GPS pins, voice, and edge-case hardening

## Phase Details

### Phase 1: Foundation + Setup
**Goal**: User can load a course and start a round with crash-safe persistence backing every subsequent feature
**Mode:** mvp
**Depends on**: Nothing (first phase)
**Requirements**: FOUND-01, FOUND-02, FOUND-03, FOUND-04, FOUND-05, SETUP-01, SETUP-02, SETUP-03, SETUP-04, SETUP-05
**Success Criteria** (what must be TRUE):
  1. User can type a handicap index and search for a course by name; the course loads with name, par, rating, slope, and hole layout
  2. A loaded course is available offline on next app open — no network request needed
  3. If the app is killed mid-round and relaunched, it returns automatically to the correct hole on Shot Capture without data loss
  4. If Course Rating or Slope is missing, the user sees a warning with an option to enter both values manually
**Plans**: 5 plans

Plans:

**Wave 1**
- [ ] 01-01-PLAN.md — Theme bootstrap, GoRouter shell, splash, keepAlive providers, fixed widget test

**Wave 2** *(blocked on Wave 1 completion)*
- [ ] 01-02-PLAN.md — Domain models, Drift schema v1 (rounds+holes+shots), Hive wrappers, FMTC init, DB providers

**Wave 3** *(blocked on Wave 2 completion)*
- [ ] 01-03-PLAN.md — Retrofit GolfCourseApi, AuthInterceptor, CourseRepositoryImpl, Setup screen UI (handicap, search, CourseCard, API key error)

**Wave 4** *(blocked on Wave 3 completion)*
- [ ] 01-04-PLAN.md — RoundRepositoryImpl, RoundSetupNotifier, START ROUND flow, crash-recovery human-verify

**Wave 5** *(blocked on Wave 4 completion)*
- [ ] 01-05-PLAN.md — FMTC tile pre-cache (Z14–17), MissingRatingBanner + ManualRatingForm, SETUP-05 human-verify

**Cross-cutting constraints:**
- All CLAUDE.md keepAlive providers MUST use `@Riverpod(keepAlive: true)`
- Write-through to Drift on every data entry — no Riverpod-only state
- `context.go()` exclusively for main screen transitions
**UI hint**: yes

### Phase 2: Shot Capture
**Goal**: User can record and correct a full 18-hole round outcome-by-outcome, with putts, fairway, and GIR, and always see their running score
**Mode:** mvp
**Depends on**: Phase 1
**Requirements**: SHOT-01, SHOT-02, SHOT-03, SHOT-04, SHOT-05, SHOT-06, SHOT-07, SHOT-10, SHOT-11, SHOT-12
**Success Criteria** (what must be TRUE):
  1. User taps an outcome button (EAGLE / BIRDIE / PAR / BOGEY / DOUBLE / PICKUP) and the app immediately advances to the next hole; an undo toast appears for 4 seconds
  2. Each hole displays its number, par, and Stroke Index; running score vs par is always visible across all hole transitions
  3. User can record putts, toggle fairway hit (hidden on par 3s), and toggle GIR for each hole
  4. User can navigate back to any previously scored hole, correct the entry, and return to the current hole
**Plans**: 3 plans

Plans:

**Wave 1**
- [x] 02-01-PLAN.md — HoleDao upsert, 6 providers (HoleScoreNotifier, holeList, runningScore, courseForRound, highestScoredHoleIndex, roundComplete), build_runner

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 02-02-PLAN.md — HoleHeader, ScoreBar, OutcomeButtonGrid (EAGLE double-tap), ShotCaptureScreen (undo toast, NEXT, round completion)

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 02-03-PLAN.md — FairwayGirToggles, HoleNavDrawer, full screen assembly, P2-08 fix, human-verify

**Cross-cutting constraints:**
- Drift write-through on every tap — no Riverpod buffering
- Hole navigation is internal state only — never context.go/push for hole changes
- Schema stays at v1 — no schemaVersion bump in Phase 2
- All new providers are auto-dispose (@riverpod lowercase)
**UI hint**: yes

### Phase 3: Round Review
**Goal**: User can see a complete scorecard, stat summary, and WHS differential when the round is finished, and share or restart from the same screen
**Mode:** mvp
**Depends on**: Phase 2
**Requirements**: SHOT-13, REV-01, REV-02, REV-03, REV-04, REV-05, REV-06, REV-07
**Success Criteria** (what must be TRUE):
  1. User sees a colour-coded 18-hole scorecard grid with front 9 and back 9 subtotals, outcome, and putts per hole
  2. User sees stat cards covering strokes, score vs par, net score, all outcome counts, putts, GIR%, and fairways hit
  3. WHS differential is shown for a complete 18-hole round; an indicative differential with a clear label is shown for incomplete rounds; "N/A" is shown when Rating or Slope is missing
  4. User can share the scorecard via the native share sheet, or start a new round and return to Setup
**Plans**: 3 plans

Plans:

**Wave 1**
- [x] 03-01-PLAN.md — ScorecardData/StatsData/WhsDifferential models + scorecardProvider, statsProvider, whsDifferentialProvider; build_runner

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 03-02-PLAN.md — ScorecardTable, WhsBlock, StatCard, StatsSection widgets

**Wave 3** *(blocked on Wave 2 completion)*
- [ ] 03-03-PLAN.md — RoundReviewScreen assembly, ShareService, SHOT-13 in ShotCaptureScreen, human-verify

**Cross-cutting constraints:**
- All new providers are auto-dispose (@riverpod lowercase) — never keepAlive in Phase 3
- No new packages — use screenshot + share_plus already in pubspec
- schema stays at v1 — no Drift schema changes in Phase 3
- context.go('/setup') for Start New Round; PopScope(canPop: false) to block back from Round Review
**UI hint**: yes

### Phase 4: Wear OS
**Goal**: User can tap a score button on their watch and the outcome syncs to the active round on their phone
**Mode:** mvp
**Depends on**: Phase 3
**Requirements**: WEAR-01, WEAR-02, WEAR-03
**Success Criteria** (what must be TRUE):
  1. The watch displays the current hole number, par, and score buttons (EAGLE / BIRDIE / PAR / BOGEY / DOUBLE / PICKUP)
  2. Tapping a score button on the watch records the outcome in the active phone round within the same session
  3. When the phone is not connected, the watch queues the entry and syncs on reconnect, with a visible connection status indicator
**Plans**: TBD

### Phase 5: Polish
**Goal**: GPS shot pins and voice scoring are live; every edge case and error state is handled across the full app
**Mode:** mvp
**Depends on**: Phase 4
**Requirements**: SHOT-08, SHOT-09
**Success Criteria** (what must be TRUE):
  1. User can tap the map overlay to drop GPS shot pins; pins persist across app restarts and are visible throughout the round
  2. User can say "eagle", "birdie", "par", "bogey", "double", or "pickup" to record a score; a confirmation toast appears with an undo option
  3. When voice recognition is unavailable (no network, init failure), the mic UI shows "Voice unavailable" and outcome buttons remain fully functional
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation + Setup | 5/5 | ✅ Complete | 2026-05-17 |
| 2. Shot Capture | 3/3 | ✅ Complete | 2026-05-17 |
| 3. Round Review | 2/3 | In progress | - |
| 4. Wear OS | 0/TBD | Not started | - |
| 5. Polish | 0/TBD | Not started | - |

---
*Roadmap created: 2026-05-16*
*Coverage: 33/33 v1 requirements mapped*
*Phase 2 planned: 2026-05-17*
*Phase 2 complete: 2026-05-17*
*Phase 3 planned: 2026-05-18*
