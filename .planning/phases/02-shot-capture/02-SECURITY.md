---
phase: 2
slug: shot-capture
status: verified
threats_open: 0
asvs_level: 1
created: 2026-05-18
---

# Phase 2 — Security: Shot Capture

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Widget → HoleScoreNotifier | User tap enters the notifier; malformed input (negative putts, invalid outcome string) must not corrupt Drift | Outcome enum (typed), putts integer, boolean flags |
| Drift ← HolesCompanion | All writes go through insertOrUpdateHole; concurrent writes on same (roundId, holeNumber) could race | Round and hole data (local device only) |
| HoleNavDrawer chip tap → activeHoleIndexProvider | Index must be within valid range [0..highestScoredHoleIndex]; future chips are disabled | Integer index |
| FairwayGirToggles → HoleScoreNotifier | Toggle writes boolean; only called when hole has outcome | Boolean flags |
| RoundSetupNotifier.createRound → activeHoleIndexProvider.set(0) | Reset must happen before context.go to shot-capture | Integer index |

---

## Threat Register

| Threat ID | Category | Component | Disposition | Mitigation | Status |
|-----------|----------|-----------|-------------|------------|--------|
| T-02-01 | Tampering | HoleDao.insertOrUpdateHole | accept | SELECT-then-branch is non-atomic but acceptable: single-user app, sequential taps; no concurrent writers | closed |
| T-02-02 | Denial of Service | runningScoreProvider — byName parse | mitigate | `try/catch` wraps `HoleOutcome.values.byName` at `running_score_provider.dart:15`; unknown outcome string skips the hole rather than crashing the provider | closed |
| T-02-03 | Information Disclosure | courseJson in Drift rounds row | accept | Local device storage; no PII beyond course name; no network exposure | closed |
| T-02-04 | Elevation of Privilege | ref.read vs ref.watch in notifier | mitigate | All async mutation methods in `hole_score_notifier.dart` use `ref.read`; only `build()` uses `ref.watch` | closed |
| T-02-05 | Tampering | SnackBar UNDO — _lastScoredHoleIndex nullable | mitigate | `if (last == null) return` guard in `_handleUndo` at `shot_capture_screen.dart:162-163` | closed |
| T-02-06 | Denial of Service | GestureDetector 300ms BIRDIE delay | accept | Documented known Flutter behavior (flutter/flutter#50458); acceptable for golf app | closed |
| T-02-07 | Repudiation | context.go() fires twice if roundCompleteProvider emits twice | accept | GoRouter replaceStack semantics — navigating to same route twice is idempotent; no data corruption | closed |
| T-02-08 | Information Disclosure | courseJson deserialization in courseForRoundProvider | accept | Local device data; no PII exposed over network | closed |
| T-02-09 | Tampering | NEXT tap when holeIndex == 17 | mitigate | `if (hi < 17)` guard in `_handleNext` at `shot_capture_screen.dart:118` | closed |
| T-02-10 | Tampering | HoleNavDrawer — chip index out of range | mitigate | `onTap: null` for chips where `i > highestScoredIndex + 1` at `hole_nav_drawer.dart:66-73` | closed |
| T-02-11 | Denial of Service | FairwayGirToggles tapped before outcome recorded | accept | `if (current == null) return` guards in `hole_score_notifier.dart:57-58,70-71` — no-op if not yet scored | closed |
| T-02-12 | Tampering | P2-08 race: activeHoleIndexProvider.set(0) fires after navigation | mitigate | `set(0)` called synchronously inside `createRound` before `return roundId` at `round_setup_notifier.dart:26-28` | closed |
| T-02-13 | Repudiation | fairwayHit written as false instead of null for par 3 | mitigate | `par == 3 ? const Value(null) : const Value(false)` in `hole_score_notifier.dart:36`; fairway toggle hidden on par 3 prevents write | closed |
| T-02-SC | Tampering | npm/pip/cargo installs | accept | Phase 2 installs zero new packages — no package legitimacy gate required | closed |

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-02-01 | T-02-01 | SELECT-then-branch is non-atomic; acceptable because BRDY.01 is single-user with no concurrent writers | caliber | 2026-05-18 |
| AR-02-02 | T-02-06 | GestureDetector 300ms delay is a documented Flutter limitation (flutter/flutter#50458); golfers deliberate before tapping | caliber | 2026-05-18 |
| AR-02-03 | T-02-07 | GoRouter replaceStack is idempotent on same-route navigation — double-fire cannot corrupt state | caliber | 2026-05-18 |
| AR-02-04 | T-02-03, T-02-08 | courseJson stored locally only; no PII exposure; no network path | caliber | 2026-05-18 |
| AR-02-05 | T-02-11 | FairwayGir no-op guard already in HoleScoreNotifier; accepted because UI hides the toggle until an outcome is recorded | caliber | 2026-05-18 |
| AR-02-06 | T-02-SC | Zero new packages in Phase 2 — no supply-chain surface added | caliber | 2026-05-18 |

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-05-18 | 14 | 13 | 1 | gsd-security-auditor |
| 2026-05-18 | 14 | 14 | 0 | gsd-security-auditor (post-fix) |

**T-02-02 remediation:** Applied `try/catch` guard around `HoleOutcome.values.byName` in `running_score_provider.dart`. `flutter analyze` clean after fix.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-05-18
