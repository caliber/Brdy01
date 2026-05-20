import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/share/share_service.dart';
import '../../theme/brdy_colors.dart';
import '../../theme/brdy_spacing.dart';
import 'widgets/scorecard_table.dart';
import 'widgets/stats_section.dart';

class RoundReviewScreen extends ConsumerStatefulWidget {
  final int roundId;
  final bool readOnly;

  const RoundReviewScreen({super.key, required this.roundId, this.readOnly = false});

  @override
  ConsumerState<RoundReviewScreen> createState() => _RoundReviewScreenState();
}

class _RoundReviewScreenState extends ConsumerState<RoundReviewScreen> {
  final GlobalKey _screenshotKey = GlobalKey();
  final ShareService _shareService = ShareService();

  Future<void> _handleShare() async {
    await _shareService.shareScorecard(context, _screenshotKey);
  }

  void _handleStartNewRound() {
    context.go('/setup');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.readOnly,
      child: Scaffold(
        backgroundColor: context.brdyColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(BrdySpacing.md),
                  child: StatsSection(roundId: widget.roundId),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _ScorecardHeaderDelegate(),
              ),
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  key: _screenshotKey,
                  child: ScorecardTable(roundId: widget.roundId),
                ),
              ),
              SliverToBoxAdapter(
                child: widget.readOnly
                    ? const _BackButton()
                    : _ActionButtons(
                        onShare: _handleShare,
                        onStartNewRound: _handleStartNewRound,
                      ),
              ),
              const SliverToBoxAdapter(child: Gap(BrdySpacing.xl)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _ScorecardHeaderDelegate ──────────────────────────────────────────────────

class _ScorecardHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double _height = 36.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(covariant _ScorecardHeaderDelegate oldDelegate) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final style = GoogleFonts.sometypeMono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: context.brdyColors.onSurfaceMuted,
    );

    return Container(
      height: _height,
      color: context.brdyColors.surface,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(48), // HOLE
          1: FixedColumnWidth(36), // PAR
          2: FlexColumnWidth(1),   // OUTCOME
          3: FixedColumnWidth(48), // PUTTS
        },
        children: [
          TableRow(
            children: [
              _headerCell('HOLE', style, TextAlign.left),
              _headerCell('PAR', style, TextAlign.center),
              _headerCell('OUTCOME', style, TextAlign.center),
              _headerCell('PUTTS', style, TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, TextStyle style, TextAlign align) {
    return SizedBox(
      height: 36,
      child: Align(
        alignment:
            align == TextAlign.left ? Alignment.centerLeft : Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.xs),
          child: Text(text, style: style, textAlign: align, softWrap: false, overflow: TextOverflow.clip),
        ),
      ),
    );
  }
}

// ── _ActionButtons ─────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onStartNewRound;

  const _ActionButtons({
    required this.onShare,
    required this.onStartNewRound,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BrdySpacing.md,
        vertical: BrdySpacing.lg,
      ),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: onShare,
            icon: Icon(Icons.share_outlined, color: context.brdyColors.onAccent),
            label: Text(
              'SHARE SCORECARD',
              style: GoogleFonts.sometypeMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.brdyColors.onAccent,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.brdyColors.accent,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const Gap(BrdySpacing.sm),
          OutlinedButton(
            onPressed: onStartNewRound,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.brdyColors.divider),
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              'START NEW ROUND',
              style: GoogleFonts.sometypeMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.brdyColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _BackButton ────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BrdySpacing.md,
        vertical: BrdySpacing.lg,
      ),
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.brdyColors.divider),
          minimumSize: const Size.fromHeight(52),
        ),
        child: Text(
          'BACK',
          style: GoogleFonts.sometypeMono(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.brdyColors.onSurface,
          ),
        ),
      ),
    );
  }
}
