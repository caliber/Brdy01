import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/scorecard_provider.dart';

class ScorecardTable extends ConsumerWidget {
  const ScorecardTable({super.key, required this.roundId});

  final int roundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scorecardAsync = ref.watch(scorecardProvider(roundId));

    if (scorecardAsync == null) {
      return Center(
        child: CircularProgressIndicator(color: context.brdyColors.accent),
      );
    }

    final data = scorecardAsync;

    // Build all TableRows: header, holes 1-9, front9 subtotal, holes 10-18, back9 subtotal.
    final total = data.rows.length;
    final front9End = total.clamp(0, 9);
    final back9End = total.clamp(9, 18);
    final rows = <TableRow>[
      ...data.rows.sublist(0, front9End).map((r) => _buildHoleRow(context, r)),
      _buildSubtotalRow(context, data.front9),
      ...data.rows.sublist(front9End.clamp(0, total), back9End).map((r) => _buildHoleRow(context, r)),
      _buildSubtotalRow(context, data.back9),
    ];

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(48),  // HOLE
        1: FixedColumnWidth(36),  // PAR
        2: FlexColumnWidth(1),    // OUTCOME
        3: FixedColumnWidth(48),  // PUTTS
      },
      children: rows,
    );
  }

  TableRow _buildHoleRow(BuildContext context, HoleRow row) {
    // Alternate backgrounds: odd hole numbers get surface, even get background.
    final isOdd = row.holeNumber % 2 == 1;
    final bgColor = isOdd ? context.brdyColors.background : context.brdyColors.surface;

    final numericStyle = GoogleFonts.sometypeMono(
      fontSize: 14,
      color: context.brdyColors.onSurface,
    );

    // Outcome text style — coloured, with underline only for bogey (+1).
    final outcomeBogey = row.outcomeAbbr == '+1';
    final outcomeStyle = GoogleFonts.sometypeMono(
      fontSize: 14,
      color: row.outcomeColor ?? context.brdyColors.onSurfaceMuted,
      decoration: outcomeBogey ? TextDecoration.underline : TextDecoration.none,
      decorationColor: row.outcomeColor ?? context.brdyColors.onSurfaceMuted,
    );

    return TableRow(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: context.brdyColors.divider, width: 0.5),
        ),
      ),
      children: [
        _dataCell(Text(row.holeNumber.toString(), style: numericStyle)),
        _dataCell(Text(row.par.toString(), style: numericStyle), align: TextAlign.center),
        _dataCell(
          Text(row.outcomeAbbr ?? '–', style: outcomeStyle, textAlign: TextAlign.center),
          align: TextAlign.center,
        ),
        _dataCell(
          Text(row.putts?.toString() ?? '', style: numericStyle),
          align: TextAlign.center,
        ),
      ],
    );
  }

  TableRow _buildSubtotalRow(BuildContext context, ScorecardSubtotal subtotal) {
    final labelStyle = GoogleFonts.sometypeMono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: context.brdyColors.onSurfaceMuted,
    );

    final strokesStyle = GoogleFonts.sometypeMono(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: context.brdyColors.onSurface,
    );

    final mutedStyle = GoogleFonts.sometypeMono(
      fontSize: 11,
      color: context.brdyColors.onSurfaceMuted,
    );

    final scoreToParStr = subtotal.scoreToPar == 0
        ? 'E'
        : subtotal.scoreToPar > 0
            ? '+${subtotal.scoreToPar}'
            : '${subtotal.scoreToPar}';

    return TableRow(
      decoration: BoxDecoration(
        color: context.brdyColors.surface,
        border: Border(
          top: BorderSide(color: context.brdyColors.divider, width: 1),
        ),
      ),
      children: [
        // HOLE column: show label
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BrdySpacing.sm,
            vertical: BrdySpacing.xs,
          ),
          child: Text(subtotal.label, style: labelStyle, softWrap: false, overflow: TextOverflow.clip),
        ),
        // PAR column: empty
        const SizedBox.shrink(),
        // OUTCOME column: show total strokes + score-to-par suffix
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BrdySpacing.sm,
            vertical: BrdySpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(subtotal.totalStrokes.toString(), style: strokesStyle),
              const SizedBox(width: 4),
              Text(scoreToParStr, style: mutedStyle),
            ],
          ),
        ),
        // PUTTS column: empty
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _dataCell(Widget child, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BrdySpacing.sm,
        vertical: BrdySpacing.xs + 2,
      ),
      child: align == TextAlign.center
          ? Align(alignment: Alignment.center, child: child)
          : child,
    );
  }
}
