import 'package:brdy01/domain/enums/hole_outcome.dart';

/// Parses a [HoleOutcome] from its string name (as used in DataItem payloads).
/// Throws [ArgumentError] on unknown values — callers must handle or skip.
HoleOutcome holeOutcomeFromString(String s) {
  return switch (s) {
    'eagle' => HoleOutcome.eagle,
    'birdie' => HoleOutcome.birdie,
    'par' => HoleOutcome.par,
    'bogey' => HoleOutcome.bogey,
    'doubleBogey' => HoleOutcome.doubleBogey,
    'pickup' => HoleOutcome.pickup,
    _ => throw ArgumentError('Unknown HoleOutcome: $s'),
  };
}

/// An immutable event received from the Wear OS watch via the WearDataBridgePlugin
/// EventChannel. Represents a score recorded on the watch.
class WearScoreEvent {
  final int holeIndex;
  final HoleOutcome outcome;
  final DateTime timestamp;

  const WearScoreEvent({
    required this.holeIndex,
    required this.outcome,
    required this.timestamp,
  });

  @override
  String toString() =>
      'WearScoreEvent(holeIndex: $holeIndex, outcome: $outcome, timestamp: $timestamp)';
}
