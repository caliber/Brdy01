import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database/app_database.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../../round_review/providers/stats_provider.dart';

class RoundHistoryTile extends ConsumerWidget {
  const RoundHistoryTile({super.key, required this.round});

  final Round round;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider(round.id));
    final dateStr = round.completedAt != null
        ? DateFormat('d MMM yyyy').format(round.completedAt!)
        : '';

    return Dismissible(
      key: ValueKey(round.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: context.brdyColors.destructive,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: BrdySpacing.md),
        child: Icon(
          Icons.delete_outline,
          color: context.brdyColors.onDestructive,
        ),
      ),
      confirmDismiss: (direction) async {
        final result = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.brdyColors.surface,
            title: Text(
              'DELETE ROUND?',
              style: GoogleFonts.sometypeMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.brdyColors.onSurface,
              ),
            ),
            content: Text(
              round.courseName,
              style: GoogleFonts.sometypeMono(
                fontSize: 14,
                color: context.brdyColors.onSurfaceMuted,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.sometypeMono(
                    color: context.brdyColors.onSurfaceMuted,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'DELETE',
                  style: GoogleFonts.sometypeMono(
                    color: context.brdyColors.destructive,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      onDismissed: (_) {
        ref.read(appDatabaseProvider).roundDao.deleteRound(round.id);
      },
      child: InkWell(
        onTap: () => context.push('/round-review/${round.id}?readOnly=true'),
        child: Container(
          color: context.brdyColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: BrdySpacing.md,
            vertical: BrdySpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      round.courseName.toUpperCase(),
                      style: GoogleFonts.sometypeMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.brdyColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: GoogleFonts.sometypeMono(
                        fontSize: 12,
                        color: context.brdyColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BrdySpacing.sm),
              statsAsync.when(
                data: (stats) {
                  if (stats == null) {
                    return Text(
                      '--',
                      style: GoogleFonts.sometypeMono(
                        fontSize: 14,
                        color: context.brdyColors.onSurfaceMuted,
                      ),
                    );
                  }
                  final scoreColor = stats.scoreToPar < 0
                      ? context.brdyColors.accent
                      : stats.scoreToPar > 0
                          ? context.brdyColors.destructive
                          : context.brdyColors.onSurfaceMuted;
                  final scoreStr =
                      '${stats.scoreToPar >= 0 ? '+' : ''}${stats.scoreToPar}';
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${stats.totalStrokes} shots  ',
                          style: GoogleFonts.sometypeMono(
                            fontSize: 14,
                            color: context.brdyColors.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: scoreStr,
                          style: GoogleFonts.sometypeMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Text(
                  '--',
                  style: GoogleFonts.sometypeMono(
                    fontSize: 14,
                    color: context.brdyColors.onSurfaceMuted,
                  ),
                ),
                error: (_, __) => Text(
                  '--',
                  style: GoogleFonts.sometypeMono(
                    fontSize: 14,
                    color: context.brdyColors.onSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
