import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/hole_score_notifier.dart';

class OutcomeButtonGrid extends ConsumerWidget {
  final int roundId;
  final int holeIndex;
  final int holePar;
  final int? holeStrokeIndex;
  final void Function(HoleOutcome outcome, int par, int? si) onOutcomeTapped;
  final void Function() onNextTapped;

  const OutcomeButtonGrid({
    super.key,
    required this.roundId,
    required this.holeIndex,
    required this.holePar,
    required this.holeStrokeIndex,
    required this.onOutcomeTapped,
    required this.onNextTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holeStateAsync =
        ref.watch(holeScoreNotifierProvider(roundId, holeIndex));
    final holeState = holeStateAsync.valueOrNull;

    // Parse current outcome from Drift
    HoleOutcome? currentOutcome;
    if (holeState?.outcome != null) {
      try {
        currentOutcome = HoleOutcome.values.byName(holeState!.outcome!);
      } catch (_) {
        currentOutcome = null;
      }
    }

    final int currentPutts = holeState?.putts ?? 0;
    final bool hasOutcome = currentOutcome != null;
    final bool isEagle = currentOutcome == HoleOutcome.eagle;

    // Max putts = total shots for this hole (outcome must be set first).
    int? maxPutts;
    if (currentOutcome != null) {
      final offset = switch (currentOutcome) {
        HoleOutcome.eagle => -2,
        HoleOutcome.birdie => -1,
        HoleOutcome.par => 0,
        HoleOutcome.bogey => 1,
        HoleOutcome.doubleBogey => 2,
        HoleOutcome.pickup => 2,
      };
      maxPutts = holePar + offset;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: DOUBLE, BOGEY, PAR, BIRDY
        Row(
          children: [
            // DOUBLE
            Expanded(
              child: _ButtonColumn(
                abbrev: 'DBL',
                label: 'DOUBLE',
                isActive: currentOutcome == HoleOutcome.doubleBogey,
                activeColor: const Color(0xFF535150),
                activeTextColor: Colors.white,
                dotActiveColor: const Color(0xFF535150),
                activeSvg: 'assets/images/btn_charcoal.svg',
                onTap: () => onOutcomeTapped(
                    HoleOutcome.doubleBogey, holePar, holeStrokeIndex),
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            // BOGEY
            Expanded(
              child: _ButtonColumn(
                abbrev: 'BGY',
                label: 'BOGEY',
                isActive: currentOutcome == HoleOutcome.bogey,
                activeColor: const Color(0xFFF3490E),
                activeTextColor: Colors.white,
                dotActiveColor: const Color(0xFFF3490E),
                activeSvg: 'assets/images/btn_charcoal.svg',
                onTap: () => onOutcomeTapped(
                    HoleOutcome.bogey, holePar, holeStrokeIndex),
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            // PAR
            Expanded(
              child: _ButtonColumn(
                abbrev: 'PAR',
                label: 'PAR',
                isActive: currentOutcome == HoleOutcome.par,
                activeColor: const Color(0xFF1F82B4),
                activeTextColor: Colors.white,
                dotActiveColor: const Color(0xFF1F82B4),
                activeSvg: 'assets/images/btn_par.svg',
                onTap: () => onOutcomeTapped(
                    HoleOutcome.par, holePar, holeStrokeIndex),
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            // BIRDY (with double-tap for EAGLE)
            Expanded(
              child: _BirdyButtonColumn(
                isEagle: isEagle,
                isBirdie: currentOutcome == HoleOutcome.birdie,
                onTap: () =>
                    onOutcomeTapped(HoleOutcome.birdie, holePar, holeStrokeIndex),
                onDoubleTap: () =>
                    onOutcomeTapped(HoleOutcome.eagle, holePar, holeStrokeIndex),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Row 2: PICKUP, PUTTS, NEXT
        Row(
          children: [
            // PICKUP
            Expanded(
              child: _ButtonColumn(
                abbrev: 'PKU',
                label: 'PICKUP',
                isActive: currentOutcome == HoleOutcome.pickup,
                activeColor: const Color(0xFF535150),
                activeTextColor: Colors.white,
                dotActiveColor: const Color(0xFF535150),
                activeSvg: 'assets/images/btn_charcoal.svg',
                onTap: () => onOutcomeTapped(
                    HoleOutcome.pickup, holePar, holeStrokeIndex),
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            // PUTTS counter
            Expanded(
              flex: 2,
              child: _PuttsCounter(
                count: currentPutts,
                maxPutts: maxPutts,
                onSub: currentPutts > 0
                    ? () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(holeScoreNotifierProvider(
                                    roundId, holeIndex)
                                .notifier)
                            .setPutts(currentPutts - 1, par: holePar);
                      }
                    : null,
                onAdd: (maxPutts != null && currentPutts < maxPutts)
                    ? () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(holeScoreNotifierProvider(roundId, holeIndex)
                                .notifier)
                            .setPutts(currentPutts + 1, par: holePar);
                      }
                    : null,
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            // NEXT
            Expanded(
              child: _NextButtonColumn(
                hasOutcome: hasOutcome,
                onNextTapped: onNextTapped,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── _ButtonColumn ──────────────────────────────────────────────────────────────

class _ButtonColumn extends StatefulWidget {
  final String abbrev;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeTextColor;
  final Color dotActiveColor;
  final VoidCallback? onTap;
  final String activeSvg;

  const _ButtonColumn({
    required this.abbrev,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeTextColor,
    required this.dotActiveColor,
    required this.onTap,
    this.activeSvg = 'assets/images/btn_charcoal.svg',
  });

  @override
  State<_ButtonColumn> createState() => _ButtonColumnState();
}

class _ButtonColumnState extends State<_ButtonColumn> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isActive ? widget.dotActiveColor : Colors.transparent,
                border: widget.isActive
                    ? null
                    : Border.all(color: widget.dotActiveColor, width: 1),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.abbrev,
              style: GoogleFonts.sometypeMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
        const SizedBox(height: BrdySpacing.xs),
        GestureDetector(
          onTapDown: (_) => setState(() => _pressing = true),
          onTapUp: (_) => setState(() => _pressing = false),
          onTapCancel: () => setState(() => _pressing = false),
          child: InkWell(
            splashColor: Colors.black.withOpacity(0.08),
            highlightColor: Colors.black.withOpacity(0.04),
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SvgPicture.asset(
                      widget.activeSvg,
                      fit: BoxFit.fill,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          widget.label,
                          style: GoogleFonts.sometypeMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: widget.isActive
                                ? widget.activeTextColor
                                : context.brdyColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(target: _pressing ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(0.95, 0.95),
                  duration: 80.ms,
                )
                .then()
                .scale(end: const Offset(1, 1), duration: 80.ms),
          ),
        ),
      ],
    );
  }
}

// ── _PuttsCounter ──────────────────────────────────────────────────────────────

class _PuttsCounter extends StatelessWidget {
  final int count;
  final int? maxPutts;
  final VoidCallback? onSub;
  final VoidCallback? onAdd;

  const _PuttsCounter({
    required this.count,
    required this.onSub,
    required this.onAdd,
    this.maxPutts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: count > 0 ? context.brdyColors.onSurface : Colors.transparent,
                border: count > 0
                    ? null
                    : Border.all(color: context.brdyColors.onSurfaceMuted, width: 1),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'PUTTS',
              style: GoogleFonts.sometypeMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
        const SizedBox(height: BrdySpacing.xs),
        Container(
          height: 76,
          decoration: BoxDecoration(
            color: context.brdyColors.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // SUB
              InkWell(
                onTap: onSub,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    '−',
                    style: GoogleFonts.sometypeMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: onSub != null
                          ? context.brdyColors.onSurface
                          : context.brdyColors.onSurfaceMuted,
                    ),
                  ),
                ),
              ),
              // Count
              Text(
                '$count',
                style: GoogleFonts.sometypeMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: context.brdyColors.onSurface,
                ),
              ),
              // ADD
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    '+',
                    style: GoogleFonts.sometypeMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.brdyColors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── _PuttsButtonColumn ──────────────────────────────────────────────────────────

class _PuttsButtonColumn extends StatefulWidget {
  final String abbrev;
  final String label;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _PuttsButtonColumn({
    required this.abbrev,
    required this.label,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<_PuttsButtonColumn> createState() => _PuttsButtonColumnState();
}

class _PuttsButtonColumnState extends State<_PuttsButtonColumn> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.abbrev,
          style: GoogleFonts.sometypeMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A4A4A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BrdySpacing.xs),
        // Neutral dot — no active state for putts controls
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: context.brdyColors.onSurfaceMuted, width: 1),
          ),
        ),
        const SizedBox(height: BrdySpacing.xs),
        GestureDetector(
          onTapDown: widget.onTap != null
              ? (_) => setState(() => _pressing = true)
              : null,
          onTapUp: widget.onTap != null
              ? (_) => setState(() => _pressing = false)
              : null,
          onTapCancel: widget.onTap != null
              ? () => setState(() => _pressing = false)
              : null,
          child: InkWell(
            splashColor: Colors.black.withOpacity(0.08),
            highlightColor: Colors.black.withOpacity(0.04),
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints:
                  const BoxConstraints(minWidth: 64, minHeight: 80),
              decoration: BoxDecoration(
                color: context.brdyColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                widget.label,
                style: GoogleFonts.sometypeMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.isEnabled
                      ? context.brdyColors.onSurface
                      : context.brdyColors.onSurfaceMuted,
                ),
                textAlign: TextAlign.center,
              ),
            )
                .animate(target: _pressing ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(0.95, 0.95),
                  duration: 80.ms,
                )
                .then()
                .scale(end: const Offset(1, 1), duration: 80.ms),
          ),
        ),
      ],
    );
  }
}

// ── _BirdyButtonColumn ─────────────────────────────────────────────────────────

class _BirdyButtonColumn extends StatefulWidget {
  final bool isEagle;
  final bool isBirdie;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const _BirdyButtonColumn({
    required this.isEagle,
    required this.isBirdie,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  State<_BirdyButtonColumn> createState() => _BirdyButtonColumnState();
}

class _BirdyButtonColumnState extends State<_BirdyButtonColumn> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    final bool isActiveAny = widget.isEagle || widget.isBirdie;
    final Color textColor = Colors.white;
    final String abbrev = widget.isEagle ? 'EGL' : 'BIR';
    final String label = widget.isEagle ? 'EAGLE' : 'BIRDY';
    final Color dotColor =
        widget.isEagle ? const Color(0xFFFFD700) : context.brdyColors.accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActiveAny ? dotColor : Colors.transparent,
                border: isActiveAny ? null : Border.all(color: dotColor, width: 1),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              abbrev,
              style: GoogleFonts.sometypeMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
        const SizedBox(height: BrdySpacing.xs),
        Semantics(
          label: widget.isEagle
              ? 'EAGLE RECORDED — TAP AGAIN TO CHANGE'
              : 'BIRDIE OUTCOME BUTTON — DOUBLE TAP FOR EAGLE',
          child: GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onTapDown: (_) => setState(() => _pressing = true),
            onTapUp: (_) => setState(() => _pressing = false),
            onTapCancel: () => setState(() => _pressing = false),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SvgPicture.asset(
                      'assets/images/btn_birdie.svg',
                      fit: BoxFit.fill,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          label,
                          style: GoogleFonts.sometypeMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(target: _pressing ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(0.95, 0.95),
                  duration: 80.ms,
                )
                .then()
                .scale(end: const Offset(1, 1), duration: 80.ms),
          ),
        ),
      ],
    );
  }
}

// ── _NextButtonColumn ──────────────────────────────────────────────────────────

class _NextButtonColumn extends StatefulWidget {
  final bool hasOutcome;
  final VoidCallback onNextTapped;

  const _NextButtonColumn({
    required this.hasOutcome,
    required this.onNextTapped,
  });

  @override
  State<_NextButtonColumn> createState() => _NextButtonColumnState();
}

class _NextButtonColumnState extends State<_NextButtonColumn> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.hasOutcome ? context.brdyColors.accent : Colors.transparent,
                border: widget.hasOutcome
                    ? null
                    : Border.all(color: context.brdyColors.accent, width: 1),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'HLE',
              style: GoogleFonts.sometypeMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
        const SizedBox(height: BrdySpacing.xs),
        Semantics(
          label: 'ADVANCE TO NEXT HOLE',
          child: GestureDetector(
            onTapDown: widget.hasOutcome
                ? (_) => setState(() => _pressing = true)
                : null,
            onTapUp: widget.hasOutcome
                ? (_) => setState(() => _pressing = false)
                : null,
            onTapCancel: widget.hasOutcome
                ? () => setState(() => _pressing = false)
                : null,
            child: InkWell(
              splashColor: Colors.black.withOpacity(0.08),
              highlightColor: Colors.black.withOpacity(0.04),
              onTap: widget.hasOutcome
                  ? () {
                      HapticFeedback.lightImpact();
                      widget.onNextTapped();
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Opacity(
                opacity: widget.hasOutcome ? 1.0 : 0.4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SvgPicture.asset(
                          'assets/images/btn_bogey.svg',
                          fit: BoxFit.fill,
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'NEXT',
                              style: GoogleFonts.sometypeMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(target: _pressing ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(0.95, 0.95),
                      duration: 80.ms,
                    )
                    .then()
                    .scale(end: const Offset(1, 1), duration: 80.ms),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


