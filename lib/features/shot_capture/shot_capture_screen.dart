import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/database/app_database_provider.dart';
import '../../domain/enums/hole_outcome.dart';
import '../../domain/models/course_model.dart';
import '../../theme/brdy_colors.dart';
import '../../theme/brdy_spacing.dart';
import 'providers/active_hole_index_provider.dart';
import 'providers/last_scored_outcome_provider.dart';
import 'providers/course_for_round_provider.dart';
import 'providers/highest_scored_hole_index_provider.dart';
import 'providers/hole_score_notifier.dart';
import 'providers/round_complete_provider.dart';
import 'providers/voice_listening_provider.dart';
import 'services/voice_service.dart';
import 'widgets/fairway_gir_toggles.dart';
import 'widgets/hole_header.dart';
import 'widgets/hole_nav_drawer.dart';
import 'widgets/map_overlay_widget.dart';
import 'widgets/outcome_button_grid.dart';

class ShotCaptureScreen extends ConsumerStatefulWidget {
  final int roundId;

  const ShotCaptureScreen({super.key, required this.roundId});

  @override
  ConsumerState<ShotCaptureScreen> createState() => _ShotCaptureScreenState();
}

class _ShotCaptureScreenState extends ConsumerState<ShotCaptureScreen> {
  int? _lastScoredHoleIndex;
  bool _navStripOpen = false;
  bool _voiceAvailable = false;
  String _voicePartialText = '';
  late final VoiceService _voiceService;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService(roundId: widget.roundId, ref: ref);
    _voiceService.onOutcomeRecorded = _handleVoiceOutcome;
    _initVoice();
  }

  Future<void> _initVoice() async {
    final available = await _voiceService.initialize();
    if (mounted) setState(() => _voiceAvailable = available);
  }

  Future<void> _toggleVoice() async {
    final isListening = ref.read(voiceListeningProvider);
    if (isListening) {
      await _voiceService.stopListening(
        onListeningChanged: (v) =>
            ref.read(voiceListeningProvider.notifier).set(v),
      );
    } else {
      await _voiceService.startListening(
        onListeningChanged: (v) =>
            ref.read(voiceListeningProvider.notifier).set(v),
        onPartialResult: (text) =>
            setState(() => _voicePartialText = text),
      );
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roundId = widget.roundId;
    final holeIndex = ref.watch(activeHoleIndexProvider);
    final highestIndex = ref.watch(highestScoredHoleIndexProvider(roundId));
    final courseAsync = ref.watch(courseForRoundProvider(roundId));
    final course = courseAsync.valueOrNull;
    final holeModel =
        (course != null && holeIndex < course.holes.length)
            ? course.holes[holeIndex]
            : null;
    final holePar = holeModel?.par ?? 4;
    final holeStrokeIndex = holeModel?.strokeIndex;

    ref.listen<bool>(roundCompleteProvider(roundId), (prev, next) {
      if (next == true) {
        context.go('/round-review/$roundId');
      }
    });

    return Scaffold(
      backgroundColor: BrdyColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.36,
              child: _TopZone(
                roundId: roundId,
                holeIndex: holeIndex,
                courseModel: course,
                highestScoredHoleIndex: highestIndex,
                navStripOpen: _navStripOpen,
                onHoleNumberTap: () =>
                    setState(() => _navStripOpen = !_navStripOpen),
                onMapTapped: _dropPinAtCurrentPosition,
              ),
            ),
            Container(height: 1, color: BrdyColors.divider),
            Expanded(child: ClipRect(child: _BottomZone(
                roundId: roundId,
                holeIndex: holeIndex,
                holePar: holePar,
                holeStrokeIndex: holeStrokeIndex,
                voiceAvailable: _voiceAvailable,
                voicePartialText: _voicePartialText,
                onOutcomeTapped: _handleOutcomeTapped,
                onNextTapped: _handleNext,
                onVoiceTapped: _voiceAvailable ? _toggleVoice : null,
              ))),
          ],
        ),
      ),
    );
  }

  Future<void> _dropPinAtCurrentPosition() async {
    // ── 1. Permission check ───────────────────────────────────────────────────
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'LOCATION PERMISSION REQUIRED',
              style: TextStyle(
                fontFamily: 'SometypeMono',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BrdyColors.accent,
              ),
            ),
            backgroundColor: BrdyColors.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
      return;
    }

    // ── 2. GPS fetch with timeout ─────────────────────────────────────────────
    Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'GPS UNAVAILABLE — TRY AGAIN',
              style: TextStyle(
                fontFamily: 'SometypeMono',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BrdyColors.accent,
              ),
            ),
            backgroundColor: BrdyColors.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'GPS UNAVAILABLE — TRY AGAIN',
              style: TextStyle(
                fontFamily: 'SometypeMono',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BrdyColors.accent,
              ),
            ),
            backgroundColor: BrdyColors.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    // ── 3. Persist pin to Drift ───────────────────────────────────────────────
    final db = ref.read(appDatabaseProvider);
    final holeIndex = ref.read(activeHoleIndexProvider);
    final holeNumber = holeIndex + 1;

    Hole? holeRow =
        await db.holeDao.getHoleByRoundAndNumber(widget.roundId, holeNumber);

    if (holeRow == null) {
      // Hole not yet scored — create a placeholder row to satisfy FK constraint.
      final courseAsync = ref.read(courseForRoundProvider(widget.roundId));
      final course = courseAsync.valueOrNull;
      final holePar =
          (course != null && holeIndex < course.holes.length)
              ? course.holes[holeIndex].par
              : 4;

      await db.holeDao.insertOrUpdateHole(
        HolesCompanion.insert(
          roundId: widget.roundId,
          holeNumber: holeNumber,
          par: holePar,
        ),
      );
      holeRow =
          await db.holeDao.getHoleByRoundAndNumber(widget.roundId, holeNumber);
    }

    if (holeRow == null) return; // Safety guard — should never happen.

    final shotNumber = await db.shotDao.getShotCountForHole(holeRow.id) + 1;
    await db.shotDao.insertShot(
      holeId: holeRow.id,
      latitude: pos.latitude,
      longitude: pos.longitude,
      shotNumber: shotNumber,
    );
  }

  Future<void> _handleOutcomeTapped(
      HoleOutcome outcome, int par, int? si) async {
    final holeIndex = ref.read(activeHoleIndexProvider);
    // Store BEFORE the Drift write — captures correct pre-advance index
    setState(() => _lastScoredHoleIndex = holeIndex);

    await Haptics.vibrate(switch (outcome) {
      HoleOutcome.eagle       => HapticsType.success,
      HoleOutcome.birdie      => HapticsType.heavy,
      HoleOutcome.par         => HapticsType.medium,
      HoleOutcome.bogey       => HapticsType.light,
      HoleOutcome.doubleBogey => HapticsType.warning,
      HoleOutcome.pickup      => HapticsType.rigid,
    });
    await ref
        .read(holeScoreNotifierProvider(widget.roundId, holeIndex).notifier)
        .recordOutcome(outcome: outcome, par: par, strokeIndex: si);

    // CRITICAL: Mark round complete in Drift when hole 18 is scored.
    // Must run BEFORE context.go() so Phase 3 and crash recovery see completedAt.
    if (holeIndex == 17) {
      await ref
          .read(appDatabaseProvider)
          .roundDao
          .completeRound(widget.roundId, DateTime.now());
    }

    ref.read(lastScoredOutcomeProvider(widget.roundId).notifier).set(outcome);

    if (!mounted) return;
    _showUndoToast(context, outcome, holeIndex + 1);
  }

  void _handleVoiceOutcome(HoleOutcome outcome, int holeIndex) {
    if (!mounted) return;
    setState(() => _lastScoredHoleIndex = holeIndex);
    _showUndoToast(context, outcome, holeIndex + 1);
    // Handle round completion when hole 18 is scored by voice.
    // VoiceService already wrote the outcome to Drift; we only need to call
    // completeRound so the roundCompleteProvider listener triggers context.go.
    if (holeIndex == 17) {
      ref
          .read(appDatabaseProvider)
          .roundDao
          .completeRound(widget.roundId, DateTime.now());
    }
    // No hole advancement here — user taps the NEXT button to advance,
    // matching the tap-scoring behavior in OutcomeButtonGrid.
  }

  Future<void> _handleNext() async {
    await HapticFeedback.lightImpact();
    final hi = ref.read(activeHoleIndexProvider);
    if (hi < 17) {
      ref.read(activeHoleIndexProvider.notifier).set(hi + 1);
    } else {
      if (mounted) context.go('/round-review/${widget.roundId}');
    }
  }

  void _showUndoToast(
      BuildContext context, HoleOutcome outcome, int holeNumber) {
    final outcomeLabel = const {
      'eagle': 'EAGLE',
      'birdie': 'BIRDIE',
      'par': 'PAR',
      'bogey': 'BOGEY',
      'doubleBogey': 'DOUBLE',
      'pickup': 'PICKUP',
    }[outcome.name] ??
        outcome.name.toUpperCase();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$outcomeLabel — HOLE $holeNumber',
            style: GoogleFonts.sometypeMono(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: BrdyColors.onSurface,
            ),
          ),
          backgroundColor: BrdyColors.surface,
          duration: const Duration(seconds: 4),
          // NOTE: Flutter 3.24.5 — SnackBar auto-dismisses with actions by default.
          // When upgrading to Flutter 3.38+, add persist: false here for explicit control.
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'UNDO',
            textColor: BrdyColors.accent,
            onPressed: _handleUndo,
          ),
        ),
      );
  }

  Future<void> _handleUndo() async {
    final last = _lastScoredHoleIndex;
    if (last == null) return;
    await HapticFeedback.lightImpact();
    await ref
        .read(holeScoreNotifierProvider(widget.roundId, last).notifier)
        .undoOutcome();
    ref.read(activeHoleIndexProvider.notifier).set(last);
    setState(() => _lastScoredHoleIndex = null);
  }
}

// ── _TopZone ───────────────────────────────────────────────────────────────────

class _TopZone extends StatelessWidget {
  final int roundId;
  final int holeIndex;
  final CourseModel? courseModel;
  final int highestScoredHoleIndex;
  final bool navStripOpen;
  final VoidCallback onHoleNumberTap;
  final VoidCallback onMapTapped;

  const _TopZone({
    required this.roundId,
    required this.holeIndex,
    required this.courseModel,
    required this.highestScoredHoleIndex,
    required this.navStripOpen,
    required this.onHoleNumberTap,
    required this.onMapTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // GPS map overlay — disabled until Phase 5 GPS is re-enabled
        // Positioned.fill(
        //   child: MapOverlayWidget(
        //     roundId: roundId,
        //     holeIndex: holeIndex,
        //     course: courseModel,
        //     onMapTapped: onMapTapped,
        //   ),
        // ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            HoleHeader(
              roundId: roundId,
              highestScoredHoleIndex: highestScoredHoleIndex,
              onHoleNumberTap: onHoleNumberTap,
            ),
            HoleNavDrawer(
              roundId: roundId,
              isOpen: navStripOpen,
            ),
          ],
        ),
      ],
    );
  }
}

// ── _BottomZone ────────────────────────────────────────────────────────────────

class _BottomZone extends StatelessWidget {
  final int roundId;
  final int holeIndex;
  final int holePar;
  final int? holeStrokeIndex;
  final bool voiceAvailable;
  final String voicePartialText;
  final void Function(HoleOutcome, int, int?) onOutcomeTapped;
  final void Function() onNextTapped;
  final void Function()? onVoiceTapped;

  const _BottomZone({
    required this.roundId,
    required this.holeIndex,
    required this.holePar,
    required this.holeStrokeIndex,
    required this.voiceAvailable,
    required this.voicePartialText,
    required this.onOutcomeTapped,
    required this.onNextTapped,
    this.onVoiceTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE5E0DE), Color(0xFF8E8C8A)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image on top of gradient
          Positioned.fill(
            child: Image.asset(
              'assets/images/bk.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
        padding: const EdgeInsets.fromLTRB(BrdySpacing.md, 0, BrdySpacing.md, BrdySpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(BrdySpacing.sm + 15),
            // BRDY.01 wordmark rule
            Row(
              children: [
                Text(
                  'BRDY.${(holeIndex + 1).toString().padLeft(2, '0')}',
                  style: GoogleFonts.sometypeMono(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: BrdyColors.background,
                  ),
                ),
                const Gap(BrdySpacing.sm),
                Expanded(
                  child: Divider(
                    color: BrdyColors.divider.withOpacity(0.1),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const Gap(BrdySpacing.sm),
            if (!voiceAvailable)
              Padding(
                padding: const EdgeInsets.only(bottom: BrdySpacing.xs),
                child: Text(
                  'VOICE UNAVAILABLE',
                  style: GoogleFonts.sometypeMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: BrdyColors.onSurfaceMuted,
                  ),
                ),
              ),
            OutcomeButtonGrid(
              roundId: roundId,
              holeIndex: holeIndex,
              holePar: holePar,
              holeStrokeIndex: holeStrokeIndex,
              onOutcomeTapped: onOutcomeTapped,
              onNextTapped: onNextTapped,
            ),
            const Gap(BrdySpacing.md),
            FairwayGirToggles(
              roundId: roundId,
              holeIndex: holeIndex,
              holePar: holePar,
              onVoiceTapped: onVoiceTapped,
              voicePartialText: voicePartialText,
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }
}
