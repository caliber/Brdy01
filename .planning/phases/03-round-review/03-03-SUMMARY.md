---
phase: "03-round-review"
plan: 03
subsystem: "round-review-screen-assembly"
tags: [flutter, riverpod, share, screenshot, speech-to-text, navigation]
dependency_graph:
  requires:
    - lib/features/round_review/widgets/scorecard_table.dart
    - lib/features/round_review/widgets/whs_block.dart
    - lib/features/round_review/widgets/stats_section.dart
    - lib/theme/brdy_colors.dart
    - lib/theme/brdy_spacing.dart
  provides:
    - lib/features/round_review/round_review_screen.dart
    - lib/services/share/share_service.dart
  affects:
    - lib/features/shot_capture/shot_capture_screen.dart (SHOT-13 voice unavailable)
tech_stack:
  added: []
  patterns:
    - "ConsumerStatefulWidget for screens with local state (GlobalKey, ShareService)"
    - "RepaintBoundary + GlobalKey for screenshot capture of specific widget subtree"
    - "SliverPersistentHeader pinned:true for sticky scorecard column header"
    - "PopScope(canPop: false) to block back navigation from terminal screens"
    - "Plain Dart class (no Riverpod) for service layer (ShareService)"
    - "speech_to_text.initialize() bool result stored as local _voiceAvailable state"
key_files:
  created:
    - lib/services/share/share_service.dart
  modified:
    - lib/features/round_review/round_review_screen.dart
    - lib/features/shot_capture/shot_capture_screen.dart
decisions:
  - "ShareService is a plain Dart class — screens call it directly, no Riverpod provider wrapper needed"
  - "RepaintBoundary wraps ScorecardTable + WhsBlock only — stats and action buttons excluded from screenshot"
  - "SliverPersistentHeader delegate (height 36) aligns HOLE/PAR/OUTCOME/PUTTS header with ScorecardTable column widths"
  - "SpeechToText instance is local to _initVoice — not stored as field; no sensitive data flows through voice init"
  - "VOICE UNAVAILABLE label is informational only — does not disable OutcomeButtonGrid"
metrics:
  completed_date: "2026-05-18"
  tasks_completed: 1
  files_created: 1
  files_modified: 2
---

# Phase 3 Plan 03: Screen Assembly + Share Summary

Complete RoundReviewScreen assembled from Wave 1 providers and Wave 2 widgets, ShareService implemented, and SHOT-13 voice unavailable state added to ShotCaptureScreen. Phase 3 is now complete.

## What Was Built

### RoundReviewScreen (`lib/features/round_review/round_review_screen.dart`)

Converted from StatelessWidget stub to `ConsumerStatefulWidget`:

- `PopScope(canPop: false)` — back navigation blocked; only exit is "Start New Round"
- `CustomScrollView` with `SliverPersistentHeader(pinned: true)` for sticky HOLE/PAR/OUTCOME/PUTTS header
- `RepaintBoundary(key: _screenshotKey)` wrapping `ScorecardTable` + `WhsBlock` — screenshot capture target
- `StatsSection` and `_ActionButtons` in subsequent slivers
- `_ScorecardHeaderDelegate` matches ScorecardTable column widths exactly (HOLE=48, PAR=36, OUTCOME=flex, PUTTS=48)
- Share button: ElevatedButton.icon with `BrdyColors.accent` background, calls `_shareService.shareScorecard`
- Start New Round: OutlinedButton calls `context.go('/setup')`

### ShareService (`lib/services/share/share_service.dart`)

Plain Dart class with `shareScorecard(BuildContext context, GlobalKey key)`:

- Resolves `RenderRepaintBoundary` from key; returns early if null (non-fatal)
- Captures image at `pixelRatio: 3.0`
- Converts to PNG bytes via `ui.ImageByteFormat.png`
- Passes `XFile.fromData(bytes, mimeType: 'image/png')` to `Share.shareXFiles`
- Share failures are non-fatal — user may cancel the OS share sheet

### SHOT-13 in ShotCaptureScreen (`lib/features/shot_capture/shot_capture_screen.dart`)

Minimal additions:

- `bool _voiceAvailable = true` field with optimistic default (avoids flicker)
- `_initVoice()` called in `initState` — creates `SpeechToText()`, calls `initialize()`, sets state on result
- `_voiceAvailable` passed to `_BottomZone` via `voiceAvailable` parameter
- `if (!voiceAvailable)` guard renders "VOICE UNAVAILABLE" label above `OutcomeButtonGrid`
- `OutcomeButtonGrid` remains fully functional regardless of voice state

## Verification Results

| Check | Result |
|-------|--------|
| flutter analyze lib/features/round_review/ lib/services/share/ lib/features/shot_capture/shot_capture_screen.dart | No issues found |
| PopScope present | 1 occurrence |
| canPop: false present | 1 occurrence |
| RepaintBoundary present | 1 occurrence |
| shareScorecard in ShareService | 1 occurrence |
| _voiceAvailable \| VOICE UNAVAILABLE in ShotCaptureScreen | 4 occurrences |

## Deviations from Plan

None — all three files implemented as specified. Implementation was complete at session resume.

## Self-Check

- [x] RoundReviewScreen is ConsumerStatefulWidget
- [x] PopScope(canPop: false) present
- [x] RepaintBoundary with _screenshotKey wraps ScorecardTable + WhsBlock
- [x] ShareService exists with shareScorecard method
- [x] context.go('/setup') in _handleStartNewRound
- [x] _voiceAvailable field and _initVoice() in ShotCaptureScreen
- [x] VOICE UNAVAILABLE label conditional on !voiceAvailable
- [x] flutter analyze: no issues on all three files

## Self-Check: PASSED

## Phase 3 Complete

All three plans executed successfully. Phase 3 goal achieved: user can see their full scorecard, WHS differential, and stat cards after a round, share the scorecard via the native share sheet, or start a new round.
