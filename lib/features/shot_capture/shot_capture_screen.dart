import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'services/wear_bridge_service.dart';
import 'widgets/fairway_gir_alternatives.dart';
import 'widgets/hole_header.dart';
import 'widgets/shot_slider_test.dart';
import 'widgets/mini_scorecard_overlay.dart';
import 'widgets/outcome_button_grid.dart';

class ShotCaptureScreen extends ConsumerStatefulWidget {
  final int roundId;

  const ShotCaptureScreen({super.key, required this.roundId});

  @override
  ConsumerState<ShotCaptureScreen> createState() => _ShotCaptureScreenState();
}

class _ShotCaptureScreenState extends ConsumerState<ShotCaptureScreen> {
  int? _lastScoredHoleIndex;
  bool _overlayOpen = false;
  bool _voiceAvailable = false;
  String _voicePartialText = '';
  late final VoiceService _voiceService;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService(roundId: widget.roundId, ref: ref);
    _voiceService.onOutcomeRecorded = _handleVoiceOutcome;
    _initVoice();
    // Push initial hole state to watch on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) => _pushCurrentHoleState());
  }

  /// Pushes the currently active hole context to the watch via WearBridgeService.
  /// Called on init and on every hole index change so the watch stays in sync.
  void _pushCurrentHoleState() {
    if (!mounted) return;
    final holeIndex = ref.read(activeHoleIndexProvider);
    final courseAsync = ref.read(courseForRoundProvider(widget.roundId));
    final course = courseAsync.valueOrNull;
    final holeModel =
        (course != null && holeIndex < course.holes.length)
            ? course.holes[holeIndex]
            : null;
    final par = holeModel?.par ?? 4;
    final si = holeModel?.strokeIndex;
    ref.read(wearBridgeServiceProvider).pushHoleState(
          roundId: widget.roundId.toString(),
          holeIndex: holeIndex,
          par: par,
          si: si,
        );
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

    // Push updated hole state to watch on every hole change
    ref.listen<int>(activeHoleIndexProvider, (prev, next) {
      if (prev != next) _pushCurrentHoleState();
    });

    final topHeight = MediaQuery.of(context).size.height * 0.36 - 40;

    return Scaffold(
      backgroundColor: context.brdyColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // DisplayBK fills the entire dark top area (top zone + overlay + divider)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topHeight + 91 + 1, // top zone + max overlay + divider
              child: SvgPicture.asset(
                'assets/images/DisplayBK.svg',
                fit: BoxFit.fill,
              ),
            ),
            // Main content column on top of the background
            Column(
              children: [
                SizedBox(
                  height: topHeight,
                  child: _TopZone(
                    roundId: roundId,
                    holeIndex: holeIndex,
                    courseModel: course,
                    highestScoredHoleIndex: highestIndex,
                    onHoleNumberTap: () =>
                        setState(() => _overlayOpen = !_overlayOpen),
                    onMapTapped: _dropPinAtCurrentPosition,
                    voicePartialText: _voicePartialText,
                  ),
                ),
                MiniScorecardOverlay(
                  roundId: roundId,
                  isOpen: _overlayOpen,
                  onClose: () => setState(() => _overlayOpen = false),
                ),
                Container(height: 1, color: context.brdyColors.divider),
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
                onExitTapped: _handleExitRound,
              ))),
          ],
        ),
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
                color: context.brdyColors.accent,
              ),
            ),
            backgroundColor: context.brdyColors.surface,
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
                color: context.brdyColors.accent,
              ),
            ),
            backgroundColor: context.brdyColors.surface,
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
                color: context.brdyColors.accent,
              ),
            ),
            backgroundColor: context.brdyColors.surface,
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

  Future<void> _handleExitRound() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.brdyColors.surface,
        title: Text(
          'EXIT ROUND',
          style: GoogleFonts.sometypeMono(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.brdyColors.onSurface,
          ),
        ),
        content: Text(
          'Your progress is saved. You can resume this round later.',
          style: GoogleFonts.sometypeMono(
            fontSize: 13,
            color: context.brdyColors.onSurfaceMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.sometypeMono(
                color: context.brdyColors.onSurfaceMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'EXIT',
              style: GoogleFonts.sometypeMono(
                color: context.brdyColors.destructive,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.go('/round-review/${widget.roundId}');
    }
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
              color: context.brdyColors.onSurface,
            ),
          ),
          backgroundColor: context.brdyColors.surface,
          duration: const Duration(seconds: 4),
          // NOTE: Flutter 3.24.5 — SnackBar auto-dismisses with actions by default.
          // When upgrading to Flutter 3.38+, add persist: false here for explicit control.
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'UNDO',
            textColor: context.brdyColors.accent,
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
  final VoidCallback onHoleNumberTap;
  final VoidCallback onMapTapped;
  final String voicePartialText;

  const _TopZone({
    required this.roundId,
    required this.holeIndex,
    required this.courseModel,
    required this.highestScoredHoleIndex,
    required this.onHoleNumberTap,
    required this.onMapTapped,
    this.voicePartialText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
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
            const SizedBox(height: 10),
            HoleHeader(
              roundId: roundId,
              highestScoredHoleIndex: highestScoredHoleIndex,
              onHoleNumberTap: onHoleNumberTap,
              voicePartialText: voicePartialText,
            ),
          ],
        ),
      ],
    );
  }
}

// ── _BottomZone ────────────────────────────────────────────────────────────────

class _BottomZone extends StatefulWidget {
  final int roundId;
  final int holeIndex;
  final int holePar;
  final int? holeStrokeIndex;
  final bool voiceAvailable;
  final String voicePartialText;
  final void Function(HoleOutcome, int, int?) onOutcomeTapped;
  final void Function() onNextTapped;
  final void Function()? onVoiceTapped;
  final void Function()? onExitTapped;

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
    this.onExitTapped,
  });

  @override
  State<_BottomZone> createState() => _BottomZoneState();
}

class _BottomZoneState extends State<_BottomZone> {
  late final PageController _pageController;
  late final ValueNotifier<int> _pageNotifier;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageNotifier = ValueNotifier(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  Widget _altLabel(BuildContext context, String text) => Text(
    text,
    style: GoogleFonts.sometypeMono(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: context.brdyColors.onSurfaceMuted,
      letterSpacing: 0.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final roundId = widget.roundId;
    final holeIndex = widget.holeIndex;
    final holePar = widget.holePar;
    final holeStrokeIndex = widget.holeStrokeIndex;
    final voiceAvailable = widget.voiceAvailable;
    final voicePartialText = widget.voicePartialText;
    final onOutcomeTapped = widget.onOutcomeTapped;
    final onNextTapped = widget.onNextTapped;
    final onVoiceTapped = widget.onVoiceTapped;
    final onExitTapped = widget.onExitTapped;
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
              'assets/images/bk.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Expanded(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(BrdySpacing.md, 0, BrdySpacing.md, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            const Gap(BrdySpacing.sm + 15),
            // BRDY.01 wordmark rule
            Row(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'BRD',
                        style: GoogleFonts.sometypeMono(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          color: context.brdyColors.background,
                        ),
                      ),
                      // letterSpacing on Y controls gap before '.' — subtract 4px
                      TextSpan(
                        text: 'Y',
                        style: GoogleFonts.sometypeMono(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -5.5,
                          color: context.brdyColors.background,
                        ),
                      ),
                      // letterSpacing on '.' controls gap before hole number — subtract 8px
                      TextSpan(
                        text: '.',
                        style: GoogleFonts.sometypeMono(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -3.5,
                          color: context.brdyColors.background,
                        ),
                      ),
                      TextSpan(
                        text: (holeIndex + 1).toString().padLeft(2, '0'),
                        style: GoogleFonts.sometypeMono(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          color: context.brdyColors.background,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(BrdySpacing.sm),
                Expanded(
                  child: Divider(
                    color: context.brdyColors.divider.withOpacity(0.1),
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
                    color: context.brdyColors.onSurfaceMuted,
                  ),
                ),
              ),
            // ── Swipeable pages ─────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => _pageNotifier.value = i,
                children: [
                  // Page 1: Classic outcome buttons (toggles embedded inside)
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: OutcomeButtonGrid(
                      roundId: roundId,
                      holeIndex: holeIndex,
                      holePar: holePar,
                      holeStrokeIndex: holeStrokeIndex,
                      onOutcomeTapped: onOutcomeTapped,
                      onNextTapped: onNextTapped,
                      onVoiceTapped: onVoiceTapped,
                      onExitTapped: onExitTapped,
                      voicePartialText: voicePartialText,
                    ),
                  ),
                  // Page 2: Stepper interface + 4 alternative controls
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ScoreVsParSlider(
                          holePar: holePar,
                          holeStrokeIndex: holeStrokeIndex,
                          onOutcomeTapped: onOutcomeTapped,
                        ),
                        const Gap(BrdySpacing.sm),
                        PuttStepper(
                          roundId: roundId,
                          holeIndex: holeIndex,
                          holePar: holePar,
                        ),
                        const Gap(BrdySpacing.md),
                        // ── Alt 1: Toggle switches
                        _altLabel(context, '1 · TOGGLE SWITCHES'),
                        const Gap(BrdySpacing.xs),
                        FairwayToggleSwitches(
                          roundId: roundId, holeIndex: holeIndex, holePar: holePar,
                          onVoiceTapped: onVoiceTapped, onExitTapped: onExitTapped,
                        ),
                        const Gap(BrdySpacing.md),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Page indicator ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ValueListenableBuilder<int>(
                valueListenable: _pageNotifier,
                builder: (context, page, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: page == i ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: page == i
                          ? context.brdyColors.onSurface
                          : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),
              ),
            ),
                ],
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
