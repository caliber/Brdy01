import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/hole_score_notifier.dart';
import '../providers/voice_listening_provider.dart';

/// Bottom toggle strip: REG (left), FAIRWAY (par 4/5 only), VOICE (right).
class FairwayGirToggles extends ConsumerWidget {
  final int roundId;
  final int holeIndex;
  final int holePar;
  final void Function()? onVoiceTapped;
  final String voicePartialText;

  const FairwayGirToggles({
    super.key,
    required this.roundId,
    required this.holeIndex,
    required this.holePar,
    this.onVoiceTapped,
    this.voicePartialText = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holeState =
        ref.watch(holeScoreNotifierProvider(roundId, holeIndex)).valueOrNull;
    final bool? fairwayHit = holeState?.fairwayHit;
    final bool? gir = holeState?.greenInRegulation;
    final bool isListening = ref.watch(voiceListeningProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live STT partial text
        if (isListening || voicePartialText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: BrdySpacing.xs),
            child: Text(
              voicePartialText.isNotEmpty ? voicePartialText.toUpperCase() : '…',
              style: GoogleFonts.sometypeMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.brdyColors.background.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // Mirrors PICKUP(1) | PUTTS(2) | NEXT(1) — identical flex + gap structure
        Row(
          children: [
            // REG — same width as PICKUP
            Expanded(
              child: _CtrlButton(
                stateLabel: gir == true ? 'GREEN' : 'MISS',
                typeLabel: 'REG',
                isActive: gir == true,
                semanticLabel: 'GREEN IN REGULATION — ${gir == true ? "on" : "off"}',
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                      .setGir(!(gir ?? false), par: holePar);
                },
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            // Middle flex:2 — FAIRWAY on left, empty space on right
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  if (holePar != 3) ...[
                    Expanded(
                      child: _CtrlButton(
                        stateLabel: fairwayHit == true ? 'HIT' : 'MISS',
                        typeLabel: 'FAIRWAY',
                        isActive: fairwayHit == true,
                        semanticLabel: 'FAIRWAY HIT — ${fairwayHit == true ? "hit" : "missed"}',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                              .setFairwayHit(!(fairwayHit ?? false), par: holePar);
                        },
                      ),
                    ),
                    const SizedBox(width: BrdySpacing.xs),
                  ],
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            // VOICE — same width as NEXT
            Expanded(
              child: _CtrlButton(
                stateLabel: isListening ? 'ON' : 'OFF',
                typeLabel: 'VOICE',
                isActive: isListening,
                semanticLabel: 'VOICE — ${isListening ? "listening" : "off"}',
                onTap: onVoiceTapped,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── _CtrlButton ────────────────────────────────────────────────────────────────

class _CtrlButton extends StatelessWidget {
  final String stateLabel;
  final String typeLabel;
  final bool isActive;
  final String semanticLabel;
  final VoidCallback? onTap;

  const _CtrlButton({
    required this.stateLabel,
    required this.typeLabel,
    required this.isActive,
    required this.semanticLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final svg = isActive
        ? 'assets/images/buttonRightCntrls-hover.svg'
        : 'assets/images/buttonRightCntrls-default.svg';

    return Semantics(
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SvgPicture.asset(svg, fit: BoxFit.fill),
              // State text — top half
              Align(
                alignment: const Alignment(0, -0.3),
                child: Text(
                  stateLabel,
                  style: GoogleFonts.sometypeMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.brdyColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Type label — bottom half
              Align(
                alignment: const Alignment(0, 0.7),
                child: Text(
                  typeLabel,
                  style: GoogleFonts.sometypeMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: context.brdyColors.background,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
