# Plan 01-04 Summary — Round Creation + Walking Skeleton Complete

**Phase:** 01-foundation-setup  
**Plan:** 01-04  
**Wave:** 4  
**Status:** Complete  
**Completed:** 2026-05-17

## Files Created

| File | Purpose |
|------|---------|
| `lib/infrastructure/repositories/round_repository_impl.dart` | `RoundRepositoryImpl`: createRound (RoundsCompanion.insert), findIncompleteRoundId, getRound, completeRound |
| `lib/infrastructure/repositories/round_repository_provider.dart` | `roundRepositoryProvider` keepAlive |
| `lib/features/setup/providers/round_setup_notifier.dart` | `RoundSetupNotifier`: AsyncValue<void>, createRound → Drift → activeRoundIdProvider.set → return roundId |

## Files Modified

| File | Change |
|------|--------|
| `lib/features/setup/setup_screen.dart` | `_StartRoundButton` wired to `roundSetupNotifierProvider.notifier.createRound` + `context.go('/shot-capture/$roundId')`, spinner during loading, mediumImpact haptic, error snackbar |
| `lib/features/shot_capture/shot_capture_screen.dart` | Changed to `ConsumerWidget`, reads `activeRoundIdProvider`, displays route param + provider value for verification |

## Build Results

- `dart run build_runner build --delete-conflicting-outputs` — exit 0
- `flutter analyze --no-fatal-warnings` — No issues found
- `flutter test` — 1 passing (BrdyApp smoke test)

## Human-Verify Checkpoint (Task 3) — APPROVED

**Outcome:** Approved 2026-05-17. Architecture review completed for Steps 1–4.

**Verification notes:**
- Steps 1–4 verified via architecture review
- End-to-end device test (FOUND-02/03 crash recovery) deferred until Android Studio is installed; will verify on physical Android device
- **Web target explicitly excluded** — Drift FFI is incompatible with dart2js; web builds are not supported for this project
- No Setup flash observed in redirect path (D-13 satisfied architecturally: `_RouterListenable` + `refreshListenable` wiring confirmed correct from code review)

**Drift inspection (architecture review):**
- `rounds` table: 8 columns, `completedAt` nullable (null = in-progress)
- `holes` table: empty in Phase 1 (D-02)
- `shots` table: empty in Phase 1 (D-03)

## Key Notes

- Walking Skeleton complete: search → select course → START ROUND → Drift insert → Shot Capture → kill → relaunch → crash recovery redirect
- `context.go('/shot-capture/$roundId')` confirmed (no `context.push` — P-11 maintained)
- Web target excluded from project scope: Drift FFI + sqlite3_flutter_libs are incompatible with dart2js
- Walking Skeleton complete; Plan 05 closes FMTC pre-cache + SETUP-05 missing-rating warning
