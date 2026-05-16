import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_round_id_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveRoundId extends _$ActiveRoundId {
  @override
  int? build() => null;

  void set(int id) => state = id;
  void clear() => state = null;
}
