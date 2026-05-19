# Phase 8: Feel & Polish - Research

**Researched:** 2026-05-20
**Domain:** Flutter micro-interactions — haptic feedback, flutter_animate effects, overlay widgets
**Confidence:** HIGH

---

## Summary

Phase 8 adds three premium interactions to the shot capture screen: a mini scorecard overlay triggered by tapping the hole number, per-outcome haptic patterns using the already-installed `haptic_feedback` package, and a brief colour flash on the score counter (`currentHoleShots` text in `HoleHeader`) when an outcome is recorded.

All three packages required are already in `pubspec.yaml`: `haptic_feedback: ^0.5.0+2` for haptic patterns, `flutter_animate: ^4.5.0` for the score counter flash, and the standard Flutter `Stack`/`AnimatedContainer` tools for the overlay. No new packages are needed.

The biggest architectural decision is how to wire the score counter flash — the outcome tap happens in `ShotCaptureScreen._handleOutcomeTapped`, but the counter lives deep inside `HoleHeader`. The cleanest solution (matching the existing codebase pattern) is a `StateProvider<HoleOutcome?>` named `lastScoredOutcomeProvider` that `HoleHeader` watches to drive a `flutter_animate` tint effect on the shot counter text. The provider is reset to null after the animation completes.

The scorecard overlay is a new `MiniScorecardOverlay` widget that renders as a `Stack` child inside `_TopZone`, appearing above `HoleNavDrawer`. It reads `holeListProvider` (already available) and maps outcomes to the same colour codes used in `HoleNavDrawer._outcomeToFill`. It is toggled by the existing `onHoleNumberTap` callback — the callback already toggles `_navStripOpen`; the plan should change that boolean to also control overlay visibility (or replace the nav drawer toggle with overlay toggle).

**Primary recommendation:** Three focused tasks — (1) haptic wiring in `_handleOutcomeTapped`, (2) `MiniScorecardOverlay` widget + overlay toggle in `_TopZone`, (3) `lastScoredOutcomeProvider` + tint effect on score counter in `HoleHeader`.

---

## Project Constraints (from CLAUDE.md)

- All screen-level providers use `@riverpod` (auto-dispose) — `lastScoredOutcomeProvider` must be auto-dispose
- `keepAlive: true` only for: `appDatabaseProvider`, `hivePlayerPrefsProvider`, `hiveCourseBoxProvider`, `dioProvider`, `golfCourseApiProvider`, all repositories, `activeRoundIdProvider`, `activeHoleIndexProvider`
- Hole navigation within Shot Capture uses `activeHoleIndexProvider.notifier.set()` — never `context.go()`/`context.push()`
- No new packages — use what is already in `pubspec.yaml`
- Design system is locked: Brutalist monospace, `SometypeMono` font, `BrdyColors.*` colour tokens only
- Tap targets: 64×80dp minimum for score buttons — overlay must not obscure the outcome buttons
- WCAG AAA contrast (7:1+) on all on-course text — any new overlay text must respect this
- Write-through to Drift on every data entry — Phase 8 adds no data entry, so no new Drift writes required
- Schema stays at current version — no schema changes in Phase 8
- Run `dart run build_runner build --delete-conflicting-outputs` after any new `@riverpod` provider

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Haptic patterns on outcome | Frontend (widget layer) | — | Pure device interaction, no state change needed |
| Score counter colour flash | Frontend (widget layer) | Riverpod state | Widget reads provider to know which outcome colour to flash |
| Mini scorecard overlay | Frontend (widget layer) | Riverpod (holeListProvider) | Reads existing hole list stream, no new data layer work |
| Overlay open/close toggle | Frontend (screen state) | — | Same `_navStripOpen` bool pattern already in screen |

---

## Standard Stack

### Core (already in pubspec — no new installs)

| Library | Version in pubspec | Purpose | Notes |
|---------|--------------------|---------|-------|
| `haptic_feedback` | `^0.5.0+2` | Per-outcome haptic patterns | `Haptics.vibrate(HapticsType.*)` API [VERIFIED: pub.dev/packages/haptic_feedback] |
| `flutter_animate` | `^4.5.0` | Score counter tint flash | `.animate().tint(color:, duration:)` API [VERIFIED: pub.dev/documentation/flutter_animate] |
| `flutter_riverpod` | `^2.5.1` | State for outcome-driven flash | Existing — `StateProvider<HoleOutcome?>` pattern |

### No New Packages Required

All capabilities are achievable with the existing stack. The overlay is a plain Flutter `Stack` + `AnimatedContainer`. No additional pub.dev packages needed.

---

## Package Legitimacy Audit

No new packages are being installed in this phase. All packages used are already resolved in `pubspec.lock` and have been in production use throughout Phases 1–7.

---

## Architecture Patterns

### System Architecture Diagram

```
OutcomeTapped (ShotCaptureScreen._handleOutcomeTapped)
    │
    ├─► Haptics.vibrate(HapticsType.[outcome-specific]) ──► device motor
    │
    ├─► Drift write (existing)
    │
    ├─► lastScoredOutcomeProvider.notifier.state = outcome
    │        │
    │        └─► HoleHeader watches provider
    │                 └─► score counter Text
    │                          └─► .animate().tint(color: outcomeColor, duration: 300ms)
    │                               .then().tint(color: transparent, duration: 200ms)
    │                               .callback(onComplete: reset provider to null)
    │
    └─► existing undo toast + hole advance (unchanged)

HoleNumberTap (onHoleNumberTap callback in ShotCaptureScreen)
    │
    └─► setState _overlayOpen = !_overlayOpen
             │
             └─► _TopZone Stack
                      └─► MiniScorecardOverlay(isOpen: _overlayOpen)
                               └─► holeListProvider stream (existing)
                                        └─► 18 coloured chips + score vs par
                                             (same colour tokens as HoleNavDrawer)
```

### Recommended Project Structure

No new directories needed. New files slot into existing locations:

```
lib/features/shot_capture/
├── providers/
│   └── last_scored_outcome_provider.dart   # NEW — StateProvider<HoleOutcome?>
└── widgets/
    ├── hole_header.dart                    # MODIFIED — add tint flash to score counter
    ├── mini_scorecard_overlay.dart         # NEW — overlay widget
    └── shot_capture_screen.dart            # MODIFIED — wire haptics, overlay toggle
```

### Pattern 1: Per-Outcome Haptic Patterns

**What:** Call `Haptics.vibrate(HapticsType.*)` from the `haptic_feedback` package with a distinct type per outcome, replacing the current `await HapticFeedback.mediumImpact()` call in `_handleOutcomeTapped`.

**When to use:** Inside `_ShotCaptureScreenState._handleOutcomeTapped`, immediately after capturing `holeIndex` and before the Drift write (order matches existing code structure).

**Outcome-to-haptic mapping (recommended):**

| Outcome | HapticsType | Rationale |
|---------|-------------|-----------|
| eagle | `HapticsType.success` | Celebratory — distinct notification-style pattern |
| birdie | `HapticsType.heavy` | Strong positive — heavier than par |
| par | `HapticsType.medium` | Neutral — same weight as current mediumImpact |
| bogey | `HapticsType.light` | Softer — understated negative |
| doubleBogey | `HapticsType.warning` | Perceptibly different from bogey |
| pickup | `HapticsType.rigid` | Hard stop — distinct from all score outcomes |

**Example:** [CITED: pub.dev/documentation/haptic_feedback/latest/haptic_feedback/HapticsType.html]
```dart
// In _handleOutcomeTapped, replace HapticFeedback.mediumImpact():
await Haptics.vibrate(switch (outcome) {
  HoleOutcome.eagle      => HapticsType.success,
  HoleOutcome.birdie     => HapticsType.heavy,
  HoleOutcome.par        => HapticsType.medium,
  HoleOutcome.bogey      => HapticsType.light,
  HoleOutcome.doubleBogey => HapticsType.warning,
  HoleOutcome.pickup     => HapticsType.rigid,
});
```

**Import required:** `import 'package:haptic_feedback/haptic_feedback.dart';`
(Note: the existing code uses `import 'package:flutter/services.dart'` for `HapticFeedback` — the new import is separate.)

### Pattern 2: Score Counter Colour Flash

**What:** When an outcome is tapped, the large `currentHoleShots` Text in `HoleHeader` briefly flashes the outcome's colour, then returns to `BrdyColors.onSurface`.

**Mechanism:** A new `lastScoredOutcomeProvider` (`StateProvider<HoleOutcome?>`, auto-dispose) is set in `_handleOutcomeTapped`. `HoleHeader` watches it and drives a `flutter_animate` `.tint()` effect keyed on the provider value. A `.callback()` at the end of the animation resets the provider to null.

**Animation spec:**
- Duration: 300ms fade in (outcome colour tint at ~40% strength) → 200ms fade out
- Colour: same palette as `HoleNavDrawer._outcomeToFill` — birdie orange, par blue, bogey surface, double/pickup red, eagle gold
- Tint end value: `0.4` (40%) — preserves text legibility against the dark background

**Example:** [CITED: pub.dev/documentation/flutter_animate/latest/flutter_animate/TintEffect-class.html]
```dart
// Inside HoleHeader — wrapping the currentHoleShots Text:
final flashOutcome = ref.watch(lastScoredOutcomeProvider(roundId));
final flashColor = _outcomeFlashColor(flashOutcome);

Text(
  '$currentHoleShots',
  style: ...,
).animate(key: ValueKey(flashOutcome))
 .tint(
   color: flashColor ?? Colors.transparent,
   end: flashColor != null ? 0.4 : 0.0,
   duration: 300.ms,
 )
 .then()
 .tint(
   color: flashColor ?? Colors.transparent,
   begin: flashColor != null ? 0.4 : 0.0,
   end: 0.0,
   duration: 200.ms,
 );
```

**Provider pattern:**
```dart
// last_scored_outcome_provider.dart
@riverpod
class LastScoredOutcome extends _$LastScoredOutcome {
  @override
  HoleOutcome? build(int roundId) => null;
  void set(HoleOutcome? outcome) => state = outcome;
}
```

### Pattern 3: Mini Scorecard Overlay

**What:** A semi-transparent overlay sliding in from the top of `_TopZone` when the hole number is tapped. Shows all 18 holes as coloured chips with hole number, scored outcome colour, and a score-vs-par summary at the bottom. Tapping the hole number again (or tapping outside) dismisses it.

**Relationship to HoleNavDrawer:** The mini scorecard overlay is a **different thing** from `HoleNavDrawer`. `HoleNavDrawer` is a horizontal scrolling chip strip for navigation. The overlay is a 2D grid showing the full 18-hole picture. The current `onHoleNumberTap` callback toggles `_navStripOpen` (which controls `HoleNavDrawer`). In Phase 8, the plan should either:
- (A) Replace the `_navStripOpen` toggle with `_overlayOpen` and retire the nav drawer from the hole number tap (preferred — the overlay serves the same navigation purpose plus adds scores), or
- (B) Keep both and add a separate trigger

Option A is recommended for simplicity — the overlay renders the same hole chips with outcome colours and chip taps use `activeHoleIndexProvider.notifier.set()` exactly as `HoleNavDrawer` does.

**Layout:**
```
┌──────────────────────────────────────────┐  ← top of _TopZone (behind header content)
│  ██ ██ ██ ██ ██ ██ ██ ██ ██  │  F9: -2  │
│  ██ ██ ██ ██ ██ ██ ██ ██ ██  │  B9: +1  │
│  Tap to dismiss                           │
└──────────────────────────────────────────┘
```

**Widget structure:**
```dart
class MiniScorecardOverlay extends ConsumerWidget {
  final int roundId;
  final bool isOpen;

  // Reads: holeListProvider(roundId), activeHoleIndexProvider,
  //        courseForRoundProvider(roundId)
  // On chip tap: activeHoleIndexProvider.notifier.set(i)
  // Colours: same HoleNavDrawer._outcomeToFill() logic
}
```

**Animation:** `AnimatedContainer` with `height: isOpen ? _overlayHeight : 0` and `curve: Curves.easeOut, duration: 200.ms` — matching the `HoleNavDrawer` pattern already in the codebase.

**Placement:** Inside `_TopZone`'s `Stack`, positioned as `Positioned.fill` at the top, rendered above `HoleHeader` and `HoleNavDrawer` but below nothing (it IS the overlay). Overlay dismisses on:
- Second tap of hole number (onHoleNumberTap toggles bool)
- Tapping any hole chip (which navigates, then closes overlay)

### Anti-Patterns to Avoid

- **Wrapping the entire HoleHeader in Animate:** The tint should only apply to the shot counter text (`currentHoleShots`), not the whole header. Tinting course name / hole number / chevrons would look broken.
- **Using a GlobalKey + OverlayEntry for the mini scorecard:** This is over-engineered. A Stack child with AnimatedContainer is sufficient and already the project pattern (HoleNavDrawer uses this).
- **Calling `Haptics.canVibrate()` on every outcome tap:** Cache the result at screen init or call once — per-tap canVibrate() adds async overhead before the Drift write.
- **Setting lastScoredOutcomeProvider without resetting it:** The provider must be reset to null after the animation or the tint will re-fire on every rebuild. Use `.callback()` at the end of the animate chain.
- **Using `persist: false` on SnackBar:** The codebase comment already notes this is only available in Flutter >=3.38+. Project is on 3.22+. Do not add it.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Per-outcome haptic patterns | Custom vibration timing loops | `haptic_feedback` `Haptics.vibrate(HapticsType.*)` | Native iOS Taptic Engine patterns + Android emulation are already tuned |
| Score counter colour flash | `AnimationController` + `ColorTween` + `TickerProviderStateMixin` | `flutter_animate` `.tint()` chain | 4 lines vs 40; `flutter_animate` already used in `HoleHeader` and `ScoreBar` |
| Overlay open/close animation | Custom `AnimatedWidget` subclass | `AnimatedContainer` with `height` transition | Exact same pattern as `HoleNavDrawer` — consistent, zero boilerplate |

---

## Common Pitfalls

### Pitfall 1: `HapticsType` import collision
**What goes wrong:** `import 'package:haptic_feedback/haptic_feedback.dart'` exports `Haptics` class. The existing code imports `import 'package:flutter/services.dart'` for `HapticFeedback`. Both names live in the same file after the change.
**Why it happens:** `haptic_feedback` package uses `Haptics` (different class), Flutter SDK uses `HapticFeedback`.
**How to avoid:** Keep both imports. `Haptics` (from haptic_feedback) replaces the outcome tap haptic. `HapticFeedback.lightImpact()` (from flutter/services) remains for chevron taps, undo button, NEXT button — do not remove it.
**Warning signs:** Dart analyzer error `The name 'Haptics' isn't defined` if the import is missing.

### Pitfall 2: `flutter_animate` key management on the score counter
**What goes wrong:** If `animate(key: ValueKey(flashOutcome))` is not set, the animation fires once on widget creation and never re-fires when the outcome changes.
**Why it happens:** `flutter_animate` only replays the animation when the `key` changes (new `ValueKey`).
**How to avoid:** Key on `ValueKey(flashOutcome)` so every new outcome triggers a fresh animation. Reset provider to null after animation so the next outcome always produces a distinct key change (`null` → `someOutcome` → `null` → `nextOutcome`).
**Warning signs:** Flash only plays on first outcome tap, not subsequent ones.

### Pitfall 3: Overlay height calculation on small screens
**What goes wrong:** The mini scorecard overlay needs to fit inside the 36% top zone. If the overlay height is hardcoded and the phone is small (e.g., SE 4.7"), it may clip or push the `HoleHeader` off screen.
**Why it happens:** `_TopZone` is `MediaQuery.of(context).size.height * 0.36` — ~280dp on a 5.5" screen, ~240dp on a 4.7" screen.
**How to avoid:** Use a fixed chip grid height of ~120dp (2 rows of 9 chips at 36dp each + padding). This fits comfortably in the 36% zone even on the smallest supported device. Do not expand the `_TopZone` height.
**Warning signs:** HoleHeader content visible below the overlay boundary; score buttons partially obscured.

### Pitfall 4: `lastScoredOutcomeProvider` not scoped to `roundId`
**What goes wrong:** If the provider takes no argument, a second concurrent round (edge case) or provider being watched across a screen rebuild could carry stale outcome state.
**Why it happens:** Provider family pattern required for any provider tied to a round.
**How to avoid:** Define as `@riverpod HoleOutcome? lastScoredOutcome(Ref ref, int roundId)` (family). Consistent with all other shot capture providers.

### Pitfall 5: `_navStripOpen` and overlay toggle conflict
**What goes wrong:** If the plan adds a new `_overlayOpen` bool alongside `_navStripOpen`, the hole number tap toggles both independently, and they can both be open at once — visually broken.
**Why it happens:** Additive implementation without replacing the old behavior.
**How to avoid:** Either (A) replace `_navStripOpen` with `_overlayOpen` (Option A is recommended), or (B) ensure the two booleans are mutually exclusive with a single `_activeTopPanel` enum (`none | navDrawer | scorecard`).

---

## Code Examples

### Haptic swap in `_handleOutcomeTapped`
```dart
// Source: pub.dev/documentation/haptic_feedback/latest — HapticsType enum
// Replace: await HapticFeedback.mediumImpact();
await Haptics.vibrate(switch (outcome) {
  HoleOutcome.eagle       => HapticsType.success,
  HoleOutcome.birdie      => HapticsType.heavy,
  HoleOutcome.par         => HapticsType.medium,
  HoleOutcome.bogey       => HapticsType.light,
  HoleOutcome.doubleBogey => HapticsType.warning,
  HoleOutcome.pickup      => HapticsType.rigid,
});
```

### Score counter tint in `HoleHeader`
```dart
// Source: pub.dev/documentation/flutter_animate/latest/flutter_animate/TintEffect-class.html
// Wrap the currentHoleShots Text:
Text(
  '$currentHoleShots',
  style: GoogleFonts.sometypeMono(
    fontSize: 100,
    fontWeight: FontWeight.w700,
    color: BrdyColors.onSurface,
  ),
).animate(key: ValueKey(flashOutcome))
 .tint(
   color: _outcomeFlashColor(flashOutcome),
   end: flashOutcome != null ? 0.4 : 0.0,
   duration: 300.ms,
   curve: Curves.easeOut,
 )
 .then()
 .tint(
   color: _outcomeFlashColor(flashOutcome),
   begin: flashOutcome != null ? 0.4 : 0.0,
   end: 0.0,
   duration: 200.ms,
 )
 .callback(callback: (_) {
   ref.read(lastScoredOutcomeProvider(roundId).notifier).set(null);
 });

// Colour mapping (matches HoleNavDrawer._outcomeToFill convention):
Color _outcomeFlashColor(HoleOutcome? outcome) => switch (outcome) {
  HoleOutcome.eagle       => const Color(0xFFFFD700),
  HoleOutcome.birdie      => BrdyColors.accent,       // #E8520A
  HoleOutcome.par         => const Color(0xFF1F82B4),
  HoleOutcome.bogey       => const Color(0xFFF3490E),
  HoleOutcome.doubleBogey => BrdyColors.destructive,  // #CC2200
  HoleOutcome.pickup      => BrdyColors.destructive,
  null                    => Colors.transparent,
};
```

### `lastScoredOutcomeProvider`
```dart
// Source: existing provider patterns in lib/features/shot_capture/providers/
// File: last_scored_outcome_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/enums/hole_outcome.dart';

part 'last_scored_outcome_provider.g.dart';

@riverpod
class LastScoredOutcome extends _$LastScoredOutcome {
  @override
  HoleOutcome? build(int roundId) => null;

  void set(HoleOutcome? outcome) => state = outcome;
}
```

### `MiniScorecardOverlay` scaffold
```dart
// Source: HoleNavDrawer pattern in lib/features/shot_capture/widgets/hole_nav_drawer.dart
class MiniScorecardOverlay extends ConsumerWidget {
  final int roundId;
  final bool isOpen;

  const MiniScorecardOverlay({
    super.key,
    required this.roundId,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeHoleIndex = ref.watch(activeHoleIndexProvider);
    final holesAsync = ref.watch(holeListProvider(roundId));
    final courseAsync = ref.watch(courseForRoundProvider(roundId));
    final runningScore = ref.watch(runningScoreProvider(roundId));

    final Map<int, String?> outcomeByHole = {};
    holesAsync.whenData((holes) {
      for (final h in holes) {
        outcomeByHole[h.holeNumber] = h.outcome;
      }
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: isOpen ? 132 : 0,  // 2 rows × 36dp chip + 24dp score bar + 12dp padding
      color: BrdyColors.background.withOpacity(0.92),
      child: isOpen ? _buildContent(
        context, ref, outcomeByHole, activeHoleIndex, runningScore,
      ) : const SizedBox.shrink(),
    );
  }
  // ... _buildContent renders 9+9 chip grid + score summary
}
```

---

## State of the Art

| Old Approach | Current Approach | Notes |
|--------------|------------------|-------|
| `HapticFeedback.mediumImpact()` for all outcomes | `Haptics.vibrate(HapticsType.*)` per-outcome | `haptic_feedback` pkg already installed — just unused for differentiation |
| No score counter feedback | `.animate().tint()` on counter Text | `flutter_animate` already used in `ScoreBar` and `HoleHeader` hole-number fadeOut |
| `HoleNavDrawer` opened by hole number tap | `MiniScorecardOverlay` opened by hole number tap | Overlay supersedes nav drawer for this gesture |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Bogey flash colour should be `#F3490E` (orange) not `#CC2200` (red) — bogey already uses `0xFFF3490E` in `OutcomeButtonGrid` active colour | Code Examples | Flash colour inconsistent with button active state — easy fix |
| A2 | The overlay should replace the `HoleNavDrawer` tap handler (Option A) rather than coexist | Architecture Patterns | If user wants both, plan needs `_activeTopPanel` enum instead of bool |
| A3 | `haptic_feedback` `HapticsType.rigid` is perceptibly different from `HapticsType.warning` on Android — the package documents Android "emulation" but exact motor patterns vary by device | Standard Stack | Pickup and double may feel identical on some Android devices |
| A4 | `flutter_animate` `.callback()` fires reliably on AnimationController completion — assumed based on package documentation | Code Examples | If callback fires prematurely, tint may reset before animation finishes |

---

## Open Questions

1. **Overlay vs nav drawer replacement**
   - What we know: `onHoleNumberTap` currently opens `HoleNavDrawer`. The overlay is a new separate feature.
   - What's unclear: Should the overlay fully replace the nav drawer trigger, or should both coexist (different tap targets)?
   - Recommendation: Replace. The overlay shows more information (scores + navigation) and the nav drawer tap is already the same gesture. Mark as planner decision.

2. **Bogey flash colour**
   - What we know: `BrdyColors.destructive` (#CC2200 red) is used for double bogey/pickup chips in `HoleNavDrawer`. `OutcomeButtonGrid` uses `0xFFF3490E` (orange) for bogey active state.
   - What's unclear: Should the bogey flash be orange (button active colour) or something more muted?
   - Recommendation: Use the button active colour `0xFFF3490E` for bogey, reserve destructive red for double/pickup. This matches user's existing colour expectations from the buttons.

---

## Environment Availability

Step 2.6: SKIPPED (no new external dependencies — all packages already resolved in pubspec.lock)

---

## Validation Architecture

`nyquist_validation: false` in `.planning/config.json` — section omitted.

---

## Security Domain

Phase 8 introduces no network calls, no new data entry, no authentication, no external services, and no new storage. ASVS categories do not apply. Section omitted.

---

## Sources

### Primary (HIGH confidence)
- [pub.dev/packages/haptic_feedback](https://pub.dev/packages/haptic_feedback) — package overview, HapticsType enum values
- [pub.dev/documentation/haptic_feedback/latest/haptic_feedback/HapticsType.html](https://pub.dev/documentation/haptic_feedback/latest/haptic_feedback/HapticsType.html) — full HapticsType enum with descriptions [VERIFIED: pub.dev official docs]
- [pub.dev/documentation/flutter_animate/latest/flutter_animate/TintEffect-class.html](https://pub.dev/documentation/flutter_animate/latest/flutter_animate/TintEffect-class.html) — TintEffect constructor and parameters [VERIFIED: pub.dev official docs]
- [pub.dev/documentation/flutter_animate/latest/flutter_animate/ColorEffect-class.html](https://pub.dev/documentation/flutter_animate/latest/flutter_animate/ColorEffect-class.html) — ColorEffect API [VERIFIED: pub.dev official docs]

### Secondary (MEDIUM confidence)
- Existing codebase: `hole_nav_drawer.dart` — AnimatedContainer height pattern used as template for overlay
- Existing codebase: `score_bar.dart` — `.animate(key: ValueKey(score))` pattern used as template for keyed re-animation
- Existing codebase: `hole_header.dart` — `.animate(key: ValueKey(holeIndex)).fadeOut().then().fadeIn()` confirms `flutter_animate` chaining works in this project

### Tertiary (LOW confidence)
- [A3] Android haptic emulation fidelity for `HapticsType.rigid` vs `HapticsType.warning` — device-dependent, not formally documented

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages are installed, APIs verified via pub.dev official docs
- Architecture: HIGH — three tightly scoped additions to existing patterns; no new data layer
- Pitfalls: HIGH — all five pitfalls are grounded in the actual codebase state (import names, provider keys, screen layout constraints)

**Research date:** 2026-05-20
**Valid until:** 2026-08-20 (flutter_animate and haptic_feedback are stable packages with infrequent API changes)
