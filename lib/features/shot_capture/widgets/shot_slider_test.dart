import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../providers/hole_score_notifier.dart';

// ── TE-inspired palette (light / inverted) ────────────────────────────────────

const _teBlack  = Color(0xFFF5F5F5);   // container bg — near white
const _teSurface = Color(0xFFE8E8E8);  // LCD display area
const _teBorder = Color(0xFFCCCCCC);   // hairline border
const _teYellow = Color(0xFFFFE600);   // TE signature yellow
const _teWhite  = Color(0xFF0A0A0A);   // primary text — near black
const _teMuted  = Color(0xFF888888);   // muted labels
const _teDim    = Color(0xFFE0E0E0);   // disabled button bg

// ── Shared helpers ─────────────────────────────────────────────────────────────

HoleOutcome? _offsetToOutcome(int offset) => switch (offset) {
      -3 || -2 => HoleOutcome.eagle,
      -1       => HoleOutcome.birdie,
      0        => HoleOutcome.par,
      1        => HoleOutcome.bogey,
      2        => HoleOutcome.doubleBogey,
      _        => HoleOutcome.pickup,
    };

String _outcomeLabel(HoleOutcome? o) => switch (o) {
      HoleOutcome.eagle       => 'EAGLE',
      HoleOutcome.birdie      => 'BIRDIE',
      HoleOutcome.par         => 'PAR',
      HoleOutcome.bogey       => 'BOGEY',
      HoleOutcome.doubleBogey => 'DOUBLE',
      HoleOutcome.pickup      => 'PICKUP',
      null                    => '---',
    };

Color _outcomeColor(HoleOutcome? o) => switch (o) {
      HoleOutcome.eagle       => const Color(0xFFFFD700),
      HoleOutcome.birdie      => _teYellow,
      HoleOutcome.par         => const Color(0xFF4A9FFF),
      HoleOutcome.bogey       => const Color(0xFF888888),
      HoleOutcome.doubleBogey => const Color(0xFFFF4444),
      HoleOutcome.pickup      => const Color(0xFFFF4444),
      null                    => _teMuted,
    };

// ── Shared: TE step button ─────────────────────────────────────────────────────

class _TeStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TeStepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _teDim,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: _teBorder, width: 1),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? _teWhite : _teMuted,
        ),
      ),
    );
  }
}

// ── Shared: TE section label ───────────────────────────────────────────────────

Widget _teLabel(String text) => Text(
      text,
      style: GoogleFonts.sometypeMono(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: _teMuted,
        letterSpacing: 1.5,
      ),
    );

// ── PuttStepper ────────────────────────────────────────────────────────────────

class PuttStepper extends ConsumerWidget {
  final int roundId;
  final int holeIndex;
  final int holePar;

  const PuttStepper({
    super.key,
    required this.roundId,
    required this.holeIndex,
    required this.holePar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holeState = ref
        .watch(holeScoreNotifierProvider(roundId, holeIndex))
        .valueOrNull;
    final putts = holeState?.putts ?? 0;

    int? maxPutts;
    if (holeState?.outcome != null) {
      try {
        final outcome = HoleOutcome.values.byName(holeState!.outcome!);
        final offset = switch (outcome) {
          HoleOutcome.eagle       => -2,
          HoleOutcome.birdie      => -1,
          HoleOutcome.par         => 0,
          HoleOutcome.bogey       => 1,
          HoleOutcome.doubleBogey => 2,
          HoleOutcome.pickup      => 2,
        };
        maxPutts = holePar + offset;
      } catch (_) {}
    }

    final canDecrement = putts > 0;
    final canIncrement = maxPutts == null || putts < maxPutts;

    return Container(
      decoration: BoxDecoration(
        color: _teBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: _teBorder, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _teLabel('PUTTS'),
          const SizedBox(height: 10),
          Row(
            children: [
              _TeStepButton(
                icon: Icons.remove,
                onTap: canDecrement
                    ? () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                            .setPutts(putts - 1, par: holePar);
                      }
                    : null,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    border: Border.all(color: _teBorder, width: 1),
                  ),
                  child: Text(
                    '$putts',
                    style: GoogleFonts.sometypeMono(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: _teWhite,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              _TeStepButton(
                icon: Icons.add,
                onTap: canIncrement
                    ? () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                            .setPutts(putts + 1, par: holePar);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── ScoreVsParSlider ───────────────────────────────────────────────────────────

class ScoreVsParSlider extends StatefulWidget {
  final int holePar;
  final int? holeStrokeIndex;
  final void Function(HoleOutcome outcome, int par, int? si) onOutcomeTapped;

  const ScoreVsParSlider({
    super.key,
    required this.holePar,
    required this.holeStrokeIndex,
    required this.onOutcomeTapped,
  });

  @override
  State<ScoreVsParSlider> createState() => _ScoreVsParSliderState();
}

class _ScoreVsParSliderState extends State<ScoreVsParSlider> {
  double _offset = 0;

  HoleOutcome? get _outcome => _offsetToOutcome(_offset.round());

  String get _offsetLabel {
    final v = _offset.round();
    if (v == 0) return 'E';
    return v > 0 ? '+$v' : '$v';
  }

  @override
  Widget build(BuildContext context) {
    final outcome = _outcome;
    final outcomeColor = _outcomeColor(outcome);
    final confirmed = outcome != null;

    return Container(
      decoration: BoxDecoration(
        color: _teBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: _teBorder, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _teLabel('SCORE VS PAR'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: outcomeColor, width: 1),
                ),
                child: Text(
                  _outcomeLabel(outcome),
                  style: GoogleFonts.sometypeMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: outcomeColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Slider row
          Row(
            children: [
              // Value display
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  border: Border.all(color: _teBorder, width: 1),
                ),
                child: Center(
                  child: Text(
                    _offsetLabel,
                    style: GoogleFonts.sometypeMono(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: outcomeColor,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: outcomeColor,
                    inactiveTrackColor: _teSurface,
                    thumbColor: outcomeColor,
                    overlayColor: outcomeColor.withOpacity(0.12),
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: _offset,
                    min: -3,
                    max: 4,
                    divisions: 7,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _offset = v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Confirm
              GestureDetector(
                onTap: confirmed
                    ? () => widget.onOutcomeTapped(
                        outcome!, widget.holePar, widget.holeStrokeIndex)
                    : null,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: confirmed ? _teYellow : _teDim,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: confirmed ? _teYellow : _teBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: confirmed ? Colors.black : _teMuted,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
