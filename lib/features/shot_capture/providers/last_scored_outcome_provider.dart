import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/enums/hole_outcome.dart';

part 'last_scored_outcome_provider.g.dart';

@riverpod
class LastScoredOutcome extends _$LastScoredOutcome {
  @override
  HoleOutcome? build(int roundId) => null;

  void set(HoleOutcome? outcome) => state = outcome;
}
