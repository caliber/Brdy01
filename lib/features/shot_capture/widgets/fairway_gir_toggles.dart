import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/hole_score_notifier.dart';
import '../providers/voice_listening_provider.dart';

/// Bottom toggle strip for fairway hit, GIR, and voice controls.
///
/// FAIRWAY toggle is absent from the widget tree (not hidden) when [holePar] == 3.
/// VOICE toggle is always inactive in Phase 2 (placeholder for Phase 5).
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
    final holeStateAsync =
        ref.watch(holeScoreNotifierProvider(roundId, holeIndex));
    final holeState = holeStateAsync.valueOrNull;

    final bool? fairwayHit = holeState?.fairwayHit;
    final bool? gir = holeState?.greenInRegulation;
    final bool isListening = ref.watch(voiceListeningProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live partial text — shows what STT is hearing in real time
        if (isListening || voicePartialText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: BrdySpacing.xs),
            child: Text(
              voicePartialText.isNotEmpty ? voicePartialText.toUpperCase() : '…',
              style: GoogleFonts.sometypeMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: BrdyColors.background.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Row(
      children: [
        // FAIRWAY — hidden on par 3s but slot kept to preserve alignment
        Expanded(
          child: holePar != 3
              ? _FairwayToggle(
                  fairwayHit: fairwayHit,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(holeScoreNotifierProvider(roundId, holeIndex)
                            .notifier)
                        .setFairwayHit(!(fairwayHit ?? false), par: holePar);
                  },
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: BrdySpacing.sm),
        // GIR
        Expanded(
          child: _GirToggle(
            gir: gir,
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                  .setGir(!(gir ?? false), par: holePar);
            },
          ),
        ),
        const SizedBox(width: BrdySpacing.xs),
        // Spacer — aligns with putts counter above
        const Expanded(child: SizedBox.shrink()),
        const SizedBox(width: BrdySpacing.xs),
        // VOICE — aligns under NEXT button
        Expanded(
          child: _VoiceToggle(
            isListening: isListening,
            onTap: onVoiceTapped,
          ),
        ),
      ],
        ),
      ],
    );
  }
}

// ── _FairwayToggle ─────────────────────────────────────────────────────────────

class _FairwayToggle extends StatelessWidget {
  final bool? fairwayHit;
  final VoidCallback onTap;

  const _FairwayToggle({
    required this.fairwayHit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = fairwayHit == true;
    final Color fill = isActive ? BrdyColors.accent : const Color(0xFFD0D0D0);
    final Color labelColor =
        isActive ? BrdyColors.onAccent : BrdyColors.background;

    return Semantics(
      label:
          'FAIRWAY HIT — currently ${fairwayHit == true ? "hit" : "missed"}',
      child: InkWell(
        splashColor: Colors.black.withOpacity(0.08),
        highlightColor: Colors.black.withOpacity(0.04),
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isActive ? 'HIT' : 'MISS',
                style: GoogleFonts.sometypeMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'FAIRWAY',
                style: GoogleFonts.sometypeMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: BrdyColors.background,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _GirToggle ─────────────────────────────────────────────────────────────────

class _GirToggle extends StatelessWidget {
  final bool? gir;
  final VoidCallback onTap;

  const _GirToggle({
    required this.gir,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = gir == true;
    final Color fill =
        isActive ? BrdyColors.background : const Color(0xFFD0D0D0);
    final Color labelColor =
        isActive ? BrdyColors.onSurface : BrdyColors.background;

    return Semantics(
      label:
          'GREEN IN REGULATION — currently ${gir == true ? "on" : "off"}',
      child: InkWell(
        splashColor: Colors.black.withOpacity(0.08),
        highlightColor: Colors.black.withOpacity(0.04),
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isActive ? 'GREEN' : 'MISS',
                style: GoogleFonts.sometypeMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'REG',
                style: GoogleFonts.sometypeMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: BrdyColors.background,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _VoiceToggle ───────────────────────────────────────────────────────────────

class _VoiceToggle extends StatelessWidget {
  final bool isListening;
  final VoidCallback? onTap;

  const _VoiceToggle({this.isListening = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color fill = isListening ? BrdyColors.accent : const Color(0xFFD0D0D0);
    final Color labelColor = isListening ? BrdyColors.onAccent : BrdyColors.background;

    return Semantics(
      label: 'VOICE — ${isListening ? "listening" : "off"}',
      child: InkWell(
        splashColor: Colors.black.withOpacity(0.08),
        highlightColor: Colors.black.withOpacity(0.04),
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isListening ? 'ON' : 'OFF',
                style: GoogleFonts.sometypeMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'VOICE',
                style: GoogleFonts.sometypeMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: labelColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
