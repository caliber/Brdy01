---
phase: 05-gps-voice-polish
plan: 03
subsystem: voice
tags: [flutter, riverpod, voice, speech-to-text, drift, callback, undo-toast]

# Dependency graph
requires:
  - phase: 05-02
    provides: ShotCaptureScreen with GPS map overlay and _showUndoToast already wired for tap scoring

provides:
  - VoiceService.onOutcomeRecorded callback field — fires after every Drift write in _recordOutcome
  - ShotCaptureScreen._handleVoiceOutcome — shows undo toast, sets _lastScoredHoleIndex, handles hole 18 round completion

affects:
  - future voice phases (Wear OS / Phase 4 WatchApp)
  - SHOT-09 requirement verification

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Nullable callback on service class (onOutcomeRecorded) bridges Drift write to screen UI without coupling service to BuildContext"
    - "Fire-and-forget completeRound in void callback avoids async leaking to synchronous callback signature"

key-files:
  created: []
  modified:
    - lib/features/shot_capture/services/voice_service.dart
    - lib/features/shot_capture/shot_capture_screen.dart

key-decisions:
  - "Voice outcome does NOT auto-advance the hole — user taps NEXT button separately, matching tap-scoring behavior in OutcomeButtonGrid"
  - "onOutcomeRecorded is nullable (?.call) so VoiceService remains functional without a screen callback — preserves Wear OS compatibility"
  - "completeRound called fire-and-forget in void _handleVoiceOutcome; roundCompleteProvider listener triggers context.go('/round-review/...')"

patterns-established:
  - "Service callback pattern: nullable Function field on service, assigned in initState before any session can start"

requirements-completed: [SHOT-09]

# Metrics
duration: 15min
completed: 2026-05-20
---

# Phase 05 Plan 03: Voice Outcome Undo Toast Summary

**VoiceService.onOutcomeRecorded callback bridges voice Drift writes to ShotCaptureScreen's undo toast and hole-18 round completion, closing the confirmed SHOT-09 gap**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-05-20T00:00:00Z
- **Completed:** 2026-05-20T00:15:00Z
- **Tasks:** 2 (plus 1 checkpoint awaiting human verify)
- **Files modified:** 2

## Accomplishments

- VoiceService gains `onOutcomeRecorded` nullable callback field; called after Drift write and `_speak` in `_recordOutcome`
- `ShotCaptureScreen._handleVoiceOutcome` wired to the callback in `initState` — shows undo toast with outcome label and hole number
- Hole 18 voice score calls `completeRound` fire-and-forget; `roundCompleteProvider` listener navigates to RoundReviewScreen
- Pre-existing Rule 1 bug fixed: missing `_onHeard` field declaration in VoiceService (referenced in initialize onError but never declared)

## Task Commits

1. **Task 1: Add onOutcomeRecorded callback to VoiceService** - `469de79` (feat)
2. **Task 2: Wire _handleVoiceOutcome in ShotCaptureScreen** - `311bf90` (feat)

## Files Created/Modified

- `lib/features/shot_capture/services/voice_service.dart` — Added `onOutcomeRecorded` and `_onHeard` fields; wired `_onHeard` in `startListening`; added `onOutcomeRecorded?.call(outcome, holeIndex)` in `_recordOutcome`
- `lib/features/shot_capture/shot_capture_screen.dart` — Added `_handleVoiceOutcome` method; wired `_voiceService.onOutcomeRecorded = _handleVoiceOutcome` in `initState`

## Decisions Made

- Voice outcome does NOT auto-advance the hole — tap scoring doesn't either (OutcomeButtonGrid only calls `onOutcomeTapped`; NEXT is a separate user gesture). Voice mirrors this exactly.
- `onOutcomeRecorded` is nullable so VoiceService works standalone (Wear OS, unit tests) without a screen callback.
- `completeRound` is fire-and-forget inside the void callback — avoids changing the callback signature to async; round navigation is handled by the existing `roundCompleteProvider` listener.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed missing `_onHeard` field declaration in VoiceService**
- **Found during:** Task 1 verification (`flutter analyze`)
- **Issue:** `_onHeard` was referenced in `initialize()` onError handler (lines 38, 40) but never declared as a field. This would cause a compile error and prevent STT "error_no_match" feedback from displaying to the user.
- **Fix:** Declared `void Function(String)? _onHeard` field alongside `_onListeningChanged`; wired `_onHeard = onPartialResult` in `startListening` so it captures the partial-result callback.
- **Files modified:** `lib/features/shot_capture/services/voice_service.dart`
- **Verification:** `flutter analyze` passes with no errors; deprecated `cancelOnError` info warning is pre-existing and unrelated.
- **Committed in:** `469de79` (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 — pre-existing bug unmasked by analyze)
**Impact on plan:** Fix was necessary for correctness; no scope change.

## Issues Encountered

- `grep -c` counts matching lines (not total occurrences), so the Task 2 verify count of 2 is correct — line 49 has both `onOutcomeRecorded` and `_handleVoiceOutcome` together, giving 2 distinct matching lines rather than 3.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Human verification checkpoint pending: voice toast, hole advance, undo, hole 18 completion, and voice unavailable state must be confirmed on device
- After checkpoint approval, SHOT-09 requirement is fully satisfied
- flutter analyze clean across shot_capture feature (no errors; pre-existing info/warning items in other files unchanged)

---
*Phase: 05-gps-voice-polish*
*Completed: 2026-05-20*
