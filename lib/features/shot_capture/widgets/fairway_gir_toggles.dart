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
  final void Function()? onExitTapped;
  final String voicePartialText;

  const FairwayGirToggles({
    super.key,
    required this.roundId,
    required this.holeIndex,
    required this.holePar,
    this.onVoiceTapped,
    this.onExitTapped,
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
        Row(
          children: [
            // EXIT
            Expanded(child: _CtrlButton(
              stateLabel: 'EXIT',
              typeLabel: 'ROUND',
              isActive: false,
              semanticLabel: 'EXIT ROUND',
              onTap: onExitTapped,
            )),
            const SizedBox(width: BrdySpacing.xs),
            // REG
            Expanded(child: _CtrlButton(
              stateLabel: gir == true ? 'GREEN' : 'MISS',
              typeLabel: 'REG',
              isActive: gir == true,
              defaultSvg: 'assets/images/SmallDarkGrey-BTN.svg',
              semanticLabel: 'GREEN IN REGULATION — ${gir == true ? "on" : "off"}',
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                    .setGir(!(gir ?? false), par: holePar);
              },
            )),
            const SizedBox(width: BrdySpacing.xs),
            // FAIRWAY — always visible, 25% opacity + disabled on par 3
            Expanded(child: Opacity(
              opacity: holePar == 3 ? 0.25 : 1.0,
              child: _CtrlButton(
                stateLabel: fairwayHit == true ? 'HIT' : 'MISS',
                typeLabel: 'FAIRWAY',
                isActive: fairwayHit == true,
                defaultSvg: 'assets/images/SmallDarkGrey-BTN.svg',
                semanticLabel: 'FAIRWAY HIT — ${fairwayHit == true ? "hit" : "missed"}',
                onTap: holePar == 3 ? null : () {
                  HapticFeedback.selectionClick();
                  ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                      .setFairwayHit(!(fairwayHit ?? false), par: holePar);
                },
              ),
            )),
            const SizedBox(width: BrdySpacing.xs),
            // VOICE
            Expanded(child: _CtrlButton(
              stateLabel: isListening ? 'ON' : 'OFF',
              typeLabel: 'VOICE',
              isActive: isListening,
              semanticLabel: 'VOICE — ${isListening ? "listening" : "off"}',
              onTap: onVoiceTapped,
            )),
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
  final String defaultSvg;
  final VoidCallback? onTap;

  const _CtrlButton({
    required this.stateLabel,
    required this.typeLabel,
    required this.isActive,
    required this.semanticLabel,
    this.defaultSvg = 'assets/images/SmallDarkGrey-BTN.svg',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final svg = isActive
        ? 'assets/images/SmallOrange-BTN.svg'
        : defaultSvg;

    return Semantics(
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type label — dot + abbrev, matching outcome button style
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? BrdyColors.accent : Colors.transparent,
                    border: isActive
                        ? null
                        : Border.all(color: const Color(0xFF4A4A4A), width: 1),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  typeLabel,
                  style: GoogleFonts.sometypeMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BrdySpacing.xs),
            // SVG button with state text inside
            DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: SvgPicture.asset(svg, fit: BoxFit.fill),
                    ),
                    Center(
                      child: Text(
                        stateLabel,
                        style: GoogleFonts.sometypeMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.brdyColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
