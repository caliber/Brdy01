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
- [x] **Phase 3: Round Review** - User can see their scorecard and stats
- [ ] **Phase 4: Wear OS** - User can score from the watch *(skipped — deferred)*
- [x] **Phase 5: GPS + Voice Polish** - GPS pins, voice, and edge-case hardening (completed 2026-05-19)
- [x] **Phase 6: Round History** - User can browse, view and delete past rounds (completed 2026-05-20)
- [x] **Phase 7: Stats & Trends** - User can see handicap trend and stats over time (completed 2026-05-20)
- [x] **Phase 8: Feel & Polish** - Scorecard overlay, haptic patterns, score animations (completed 2026-05-20)

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

**Plans**: 5 plans — ✅ All complete

### Phase 2: Shot Capture

**Goal**: User can record and correct a full 18-hole round outcome-by-outcome, with putts, fairway, and GIR, and always see their running score
**Mode:** mvp
**Depends on**: Phase 1
**Requirements**: SHOT-01, SHOT-02, SHOT-03, SHOT-04, SHOT-05, SHOT-06, SHOT-07, SHOT-10, SHOT-11, SHOT-12

**Plans**: 3 plans — ✅ All complete

### Phase 3: Round Review

**Goal**: User can see a complete scorecard, stat summary, and WHS differential when the round is finished, and share or restart from the same screen
**Mode:** mvp
**Depends on**: Phase 2
**Requirements**: SHOT-13, REV-01, REV-02, REV-03, REV-04, REV-05, REV-06, REV-07

**Plans**: 3 plans — ✅ All complete

### Phase 4: Wear OS *(deferred)*

**Goal**: User can tap a score button on their watch and the outcome syncs to the active round on their phone
**Status**: Skipped — deferred to a future milestone. `wear_plus` package is already in pubspec.
**Requirements**: WEAR-01, WEAR-02, WEAR-03

### Phase 5: GPS + Voice Polish

**Goal**: GPS shot pins and voice scoring are live; every edge case and error state is handled across the full app
**Mode:** mvp
**Depends on**: Phase 3 (Phase 4 deferred)
**Requirements**: SHOT-08, SHOT-09

**Plans**: 3 plans — ✅ All complete (completed 2026-05-19)

**Note**: GPS map overlay is currently disabled (commented out in `_TopZone`). Voice uses en_AU locale with shot-count commands ("four shots", "took four").

### Phase 6: Round History

**Goal**: User can browse all past rounds, tap into a completed round's scorecard, and delete rounds they don't want
**Mode:** mvp
**Depends on**: Phase 3
**Requirements**: HIST-01, HIST-02, HIST-03

**Plans**: 3 plans — ✅ All complete (completed 2026-05-20)

### Phase 7: Stats & Trends

**Goal**: User can see their handicap trend and scoring averages across all rounds
**Mode:** mvp
**Depends on**: Phase 6
**Requirements**: STAT-01, STAT-02, STAT-03

**Plans**: 2 plans — ✅ All complete (completed 2026-05-20)

**Note**: fl_chart pinned to 0.66.0 (not ^0.71.0) — 0.71+ requires Flutter ≥3.27.4, project runs 3.24.5.

### Phase 8: Feel & Polish

**Goal**: The app feels premium and responsive — scorecard overlay on shot capture, haptic patterns for outcomes, and score reveal animations
**Mode:** mvp
**Depends on**: Phase 7

**Plans**: 3 plans — ✅ All complete (completed 2026-05-20)

- Per-outcome haptics: eagle→success, birdie→heavy, par→medium, bogey→light, double→warning, pickup→rigid
- Score counter tint flash: gold eagle, green birdie, blue par, orange bogey, red double/pickup
- MiniScorecardOverlay: tap HOLE chip (top-right) to reveal 18-hole colour grid + score summary

---

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → (4 deferred) → 5 → 6 → 7 → 8

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation + Setup | 5/5 | ✅ Complete | 2026-05-17 |
| 2. Shot Capture | 3/3 | ✅ Complete | 2026-05-17 |
| 3. Round Review | 3/3 | ✅ Complete | 2026-05-18 |
| 4. Wear OS | 0/TBD | ⏸ Deferred | - |
| 5. GPS + Voice Polish | 3/3 | ✅ Complete | 2026-05-19 |
| 6. Round History | 3/3 | ✅ Complete | 2026-05-20 |
| 7. Stats & Trends | 2/2 | ✅ Complete | 2026-05-20 |
| 8. Feel & Polish | 3/3 | ✅ Complete | 2026-05-20 |

**v1.0 milestone: COMPLETE** — all planned phases shipped.

---

## Future Considerations

Items not yet planned. Each would become a new phase or milestone.

### High priority

| Item | Notes |
|------|-------|
| **iOS deployment** | Needs paid Apple Developer account ($99/yr). Codemagic YAML is ready — just needs signing credentials wired up. IPA builds today, sideloading blocked on iOS 26 free tier. |
| **Wear OS companion** | Phase 4 deferred. `wear_plus` already in pubspec. Would need WearOS message channel + watch face UI. |
| **GPS map re-enable** | Map overlay is commented out in `_TopZone`. FlutterMap + FMTC tile caching is fully built — just needs uncommenting and a UX decision on the toggle. |
| **App icon + splash** | Currently uses Flutter default icon. Needs custom BRDY icon across all Android/iOS sizes. |

### Medium priority

| Item | Notes |
|------|-------|
| **Stableford scoring mode** | Currently strokeplay only. Stableford is common in NZ/AU club golf. Would need a scoring mode toggle on Setup and adjusted differential calc. |
| **Handicap calculation (WHS)** | Differential shown on Round Review but not fed back as a running index. Full WHS requires storing best-8-of-20 differentials and adjusting the stored handicap index. |
| **Push notifications** | Post-round summary notification. Would need a notification service and permission flow. |
| **Course favourites** | Pin frequently played courses to the top of search results / pre-populate on Setup. |
| **Multiple players per round** | Currently single-player only. Useful for social rounds — each player scored separately. |

### Low priority / nice to have

| Item | Notes |
|------|-------|
| **Dark/light theme toggle** | App is dark-only. Some users prefer light outdoors. |
| **Landscape / tablet layout** | Currently portrait-only. Shot Capture layout could adapt for wider screens. |
| **Export to CSV / share stats** | Round history exportable as CSV for use in external spreadsheets. |
| **Google Play / App Store submission** | Store listing, screenshots, privacy policy. Android APK is production-ready. |
| **Flutter upgrade to 3.27+** | Currently pinned to 3.24.5 for Codemagic/riverpod_generator compatibility. Upgrading unlocks fl_chart 0.71+ and other newer package versions. |
| **Accessibility audit** | Semantics labels exist on key widgets. Full WCAG AA pass not yet verified. |
| **Unit + widget test coverage** | No automated tests written. Integration tests for the scoring flow would catch regressions. |

---

*Roadmap created: 2026-05-16*
*v1.0 milestone complete: 2026-05-20*
*Coverage: 33/33 v1 requirements mapped and shipped*
