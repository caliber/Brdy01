import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/brdy_colors.dart';
import '../providers/hole_score_notifier.dart';
import '../providers/voice_listening_provider.dart';

// ── Shared base ────────────────────────────────────────────────────────────────

abstract class _FairwayBase extends ConsumerWidget {
  final int roundId;
  final int holeIndex;
  final int holePar;
  final VoidCallback? onVoiceTapped;
  final VoidCallback? onExitTapped;

  const _FairwayBase({
    super.key,
    required this.roundId,
    required this.holeIndex,
    required this.holePar,
    this.onVoiceTapped,
    this.onExitTapped,
  });
}

// ── Option 1: Toggle switches ──────────────────────────────────────────────────

class FairwayToggleSwitches extends _FairwayBase {
  const FairwayToggleSwitches({
    super.key,
    required super.roundId,
    required super.holeIndex,
    required super.holePar,
    super.onVoiceTapped,
    super.onExitTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(holeScoreNotifierProvider(roundId, holeIndex)).valueOrNull;
    final isListening = ref.watch(voiceListeningProvider);
    final gir = state?.greenInRegulation ?? false;
    final fairway = state?.fairwayHit ?? false;

    return Container(
      decoration: BoxDecoration(
        color: context.brdyColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // EXIT
          _ExitButton(onTap: onExitTapped),
          const SizedBox(width: 8),
          // REG switch
          Expanded(child: _SwitchRow(
            label: 'REG',
            value: gir,
            onChanged: (_) {
              HapticFeedback.selectionClick();
              ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                  .setGir(!gir, par: holePar);
            },
          )),
          // FAIRWAY switch (par 4/5 only)
          if (holePar != 3) ...[
            const SizedBox(width: 4),
            Expanded(child: _SwitchRow(
              label: 'FAIRWAY',
              value: fairway,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                    .setFairwayHit(!fairway, par: holePar);
              },
            )),
          ],
          const SizedBox(width: 4),
          // VOICE switch
          Expanded(child: _SwitchRow(
            label: 'VOICE',
            value: isListening,
            onChanged: (_) => onVoiceTapped?.call(),
          )),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.sometypeMono(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: context.brdyColors.onSurfaceMuted,
        )),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: BrdyColors.accent,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

// ── Option 2: Pill toggle pairs ────────────────────────────────────────────────

class FairwayPillToggles extends _FairwayBase {
  const FairwayPillToggles({
    super.key,
    required super.roundId,
    required super.holeIndex,
    required super.holePar,
    super.onVoiceTapped,
    super.onExitTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(holeScoreNotifierProvider(roundId, holeIndex)).valueOrNull;
    final isListening = ref.watch(voiceListeningProvider);
    final gir = state?.greenInRegulation ?? false;
    final fairway = state?.fairwayHit ?? false;

    return Container(
      decoration: BoxDecoration(
        color: context.brdyColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _ExitButton(onTap: onExitTapped),
              const SizedBox(width: 8),
              Expanded(child: _PillPair(
                label: 'REG',
                leftLabel: 'HIT', rightLabel: 'MISS',
                isLeft: gir,
                onLeft: () {
                  HapticFeedback.selectionClick();
                  ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                      .setGir(true, par: holePar);
                },
                onRight: () {
                  HapticFeedback.selectionClick();
                  ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                      .setGir(false, par: holePar);
                },
              )),
              if (holePar != 3) ...[
                const SizedBox(width: 8),
                Expanded(child: _PillPair(
                  label: 'FAIRWAY',
                  leftLabel: 'HIT', rightLabel: 'MISS',
                  isLeft: fairway,
                  onLeft: () {
                    HapticFeedback.selectionClick();
                    ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                        .setFairwayHit(true, par: holePar);
                  },
                  onRight: () {
                    HapticFeedback.selectionClick();
                    ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                        .setFairwayHit(false, par: holePar);
                  },
                )),
              ],
              const SizedBox(width: 8),
              Expanded(child: _PillPair(
                label: 'VOICE',
                leftLabel: 'ON', rightLabel: 'OFF',
                isLeft: isListening,
                onLeft: () => onVoiceTapped?.call(),
                onRight: () => onVoiceTapped?.call(),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillPair extends StatelessWidget {
  final String label;
  final String leftLabel;
  final String rightLabel;
  final bool isLeft;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _PillPair({
    required this.label, required this.leftLabel, required this.rightLabel,
    required this.isLeft, required this.onLeft, required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.sometypeMono(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: context.brdyColors.onSurfaceMuted,
        )),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: GestureDetector(
              onTap: onLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isLeft ? BrdyColors.accent : context.brdyColors.background,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  border: Border.all(
                    color: isLeft ? BrdyColors.accent : context.brdyColors.divider,
                  ),
                ),
                child: Text(leftLabel,
                  style: GoogleFonts.sometypeMono(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: isLeft ? Colors.white : context.brdyColors.onSurfaceMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
            Expanded(child: GestureDetector(
              onTap: onRight,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: !isLeft ? context.brdyColors.surface : context.brdyColors.background,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                  border: Border.all(
                    color: !isLeft ? context.brdyColors.onSurfaceMuted : context.brdyColors.divider,
                  ),
                ),
                child: Text(rightLabel,
                  style: GoogleFonts.sometypeMono(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: !isLeft ? context.brdyColors.onSurface : context.brdyColors.onSurfaceMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
          ],
        ),
      ],
    );
  }
}

// ── Option 3: Icon stat cards ──────────────────────────────────────────────────

class FairwayIconCards extends _FairwayBase {
  const FairwayIconCards({
    super.key,
    required super.roundId,
    required super.holeIndex,
    required super.holePar,
    super.onVoiceTapped,
    super.onExitTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(holeScoreNotifierProvider(roundId, holeIndex)).valueOrNull;
    final isListening = ref.watch(voiceListeningProvider);
    final gir = state?.greenInRegulation ?? false;
    final fairway = state?.fairwayHit ?? false;

    return Container(
      decoration: BoxDecoration(
        color: context.brdyColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _ExitButton(onTap: onExitTapped),
          const SizedBox(width: 8),
          Expanded(child: _IconCard(
            icon: Icons.flag_outlined,
            label: 'REG',
            stateLabel: gir ? 'GREEN' : 'MISS',
            isActive: gir,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                  .setGir(!gir, par: holePar);
            },
          )),
          const SizedBox(width: 6),
          Opacity(
            opacity: holePar == 3 ? 0.25 : 1.0,
            child: Expanded(child: _IconCard(
              icon: Icons.grass_outlined,
              label: 'FAIRWAY',
              stateLabel: fairway ? 'HIT' : 'MISS',
              isActive: fairway,
              onTap: holePar == 3 ? null : () {
                HapticFeedback.selectionClick();
                ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                    .setFairwayHit(!fairway, par: holePar);
              },
            )),
          ),
          const SizedBox(width: 6),
          Expanded(child: _IconCard(
            icon: isListening ? Icons.mic : Icons.mic_off_outlined,
            label: 'VOICE',
            stateLabel: isListening ? 'ON' : 'OFF',
            isActive: isListening,
            onTap: () => onVoiceTapped?.call(),
          )),
        ],
      ),
    );
  }
}

class _IconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String stateLabel;
  final bool isActive;
  final VoidCallback? onTap;

  const _IconCard({
    required this.icon, required this.label,
    required this.stateLabel, required this.isActive, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? BrdyColors.accent : context.brdyColors.onSurfaceMuted;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? BrdyColors.accent.withOpacity(0.12) : context.brdyColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? BrdyColors.accent : context.brdyColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(stateLabel, style: GoogleFonts.sometypeMono(
              fontSize: 10, fontWeight: FontWeight.w700, color: color,
            )),
            Text(label, style: GoogleFonts.sometypeMono(
              fontSize: 8, color: context.brdyColors.onSurfaceMuted,
            )),
          ],
        ),
      ),
    );
  }
}

// ── Option 4: Compact checkbox row ────────────────────────────────────────────

class FairwayCheckboxRow extends _FairwayBase {
  const FairwayCheckboxRow({
    super.key,
    required super.roundId,
    required super.holeIndex,
    required super.holePar,
    super.onVoiceTapped,
    super.onExitTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(holeScoreNotifierProvider(roundId, holeIndex)).valueOrNull;
    final isListening = ref.watch(voiceListeningProvider);
    final gir = state?.greenInRegulation ?? false;
    final fairway = state?.fairwayHit ?? false;

    return Container(
      decoration: BoxDecoration(
        color: context.brdyColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _ExitButton(onTap: onExitTapped),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CheckRow(
                  label: 'GREEN IN REGULATION',
                  value: gir,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                        .setGir(!gir, par: holePar);
                  },
                ),
                _CheckRow(
                  label: 'FAIRWAY HIT',
                  value: fairway,
                  disabled: holePar == 3,
                  onTap: holePar == 3 ? null : () {
                    HapticFeedback.selectionClick();
                    ref.read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
                        .setFairwayHit(!fairway, par: holePar);
                  },
                ),
                _CheckRow(
                  label: 'VOICE CONTROL',
                  value: isListening,
                  onTap: () => onVoiceTapped?.call(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final bool disabled;
  final VoidCallback? onTap;

  const _CheckRow({
    required this.label, required this.value,
    this.disabled = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.25 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: value ? BrdyColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: value ? BrdyColors.accent : context.brdyColors.onSurfaceMuted,
                    width: 1.5,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.sometypeMono(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: value ? context.brdyColors.onSurface : context.brdyColors.onSurfaceMuted,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared exit button ─────────────────────────────────────────────────────────

class _ExitButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ExitButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: context.brdyColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: context.brdyColors.divider),
        ),
        child: Icon(Icons.exit_to_app,
          color: context.brdyColors.onSurfaceMuted, size: 18),
      ),
    );
  }
}
