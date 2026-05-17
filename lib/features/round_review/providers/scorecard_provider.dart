import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/enums/hole_outcome.dart';
import '../../../theme/brdy_colors.dart';
import '../../shot_capture/providers/hole_list_provider.dart';

part 'scorecard_provider.g.dart';

// ── View-model classes ──────────────────────────────────────────────────────

class HoleRow {
  const HoleRow({
    required this.holeNumber,
    required this.par,
    this.outcomeAbbr,
    this.outcomeColor,
    this.putts,
  });

  final int holeNumber;
  final int par;
  final String? outcomeAbbr;
  final Color? outcomeColor;
  final int? putts;
}

class ScorecardSubtotal {
  const ScorecardSubtotal({
    required this.label,
    required this.totalStrokes,
    required this.scoreToPar,
  });

  final String label;
  final int totalStrokes;
  final int scoreToPar;
}

class ScorecardData {
  const ScorecardData({
    required this.rows,
    required this.front9,
    required this.back9,
  });

  final List<HoleRow> rows;
  final ScorecardSubtotal front9;
  final ScorecardSubtotal back9;
}

// ── Outcome mapping ─────────────────────────────────────────────────────────

String? _abbr(HoleOutcome outcome) => switch (outcome) {
      HoleOutcome.eagle => 'E',
      HoleOutcome.birdie => 'B',
      HoleOutcome.par => '–',
      HoleOutcome.bogey => '+1',
      HoleOutcome.doubleBogey => '+2',
      HoleOutcome.pickup => 'P',
    };

Color? _color(HoleOutcome outcome) => switch (outcome) {
      HoleOutcome.eagle => const Color(0xFFFFD700), // Gold — not in BrdyColors
      HoleOutcome.birdie => BrdyColors.accent,
      HoleOutcome.par => BrdyColors.onSurface,
      HoleOutcome.bogey => BrdyColors.onSurfaceMuted,
      HoleOutcome.doubleBogey => BrdyColors.destructive,
      HoleOutcome.pickup => BrdyColors.destructive,
    };

/// Score offset for stroke-total computation.
/// Eagle=-2, Birdie=-1, Par=0, Bogey=+1, DoubleBogey=+2, Pickup=+2.
int _offset(HoleOutcome outcome) => switch (outcome) {
      HoleOutcome.eagle => -2,
      HoleOutcome.birdie => -1,
      HoleOutcome.par => 0,
      HoleOutcome.bogey => 1,
      HoleOutcome.doubleBogey => 2,
      HoleOutcome.pickup => 2,
    };

// ── Provider ────────────────────────────────────────────────────────────────

@riverpod
ScorecardData? scorecard(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));

  return holesAsync.whenData((holes) {
    // Sort by hole number ascending.
    final sorted = [...holes]..sort((a, b) => a.holeNumber.compareTo(b.holeNumber));

    // Build HoleRow list.
    final rows = sorted.map((h) {
      String? outcomeAbbr;
      Color? outcomeColor;

      if (h.outcome != null) {
        try {
          final outcome = HoleOutcome.values.byName(h.outcome!);
          outcomeAbbr = _abbr(outcome);
          outcomeColor = _color(outcome);
        } catch (_) {
          // Unknown outcome string — leave abbr/color as null.
        }
      }

      return HoleRow(
        holeNumber: h.holeNumber,
        par: h.par,
        outcomeAbbr: outcomeAbbr,
        outcomeColor: outcomeColor,
        putts: h.putts,
      );
    }).toList();

    // Helper: compute subtotal for a slice of rows.
    ScorecardSubtotal _subtotal(List<HoleRow> slice, String label) {
      int totalStrokes = 0;
      int scoreToPar = 0;

      for (final row in slice) {
        if (row.outcomeAbbr == null) continue;
        // Resolve offset from the original hole to compute strokes and par delta.
        final holeIdx = rows.indexOf(row);
        final h = sorted[holeIdx];
        try {
          final outcome = HoleOutcome.values.byName(h.outcome!);
          final off = _offset(outcome);
          totalStrokes += h.par + off;
          scoreToPar += off;
        } catch (_) {
          // Skip unrecognised outcomes.
        }
      }

      return ScorecardSubtotal(
        label: label,
        totalStrokes: totalStrokes,
        scoreToPar: scoreToPar,
      );
    }

    final front9 = _subtotal(rows.take(9).toList(), 'FRONT 9');
    final back9 = _subtotal(rows.skip(9).toList(), 'BACK 9');

    return ScorecardData(rows: rows, front9: front9, back9: back9);
  }).value;
}
