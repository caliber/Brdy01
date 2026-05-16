import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_hole_index_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveHoleIndex extends _$ActiveHoleIndex {
  @override
  int build() => 0;

  void set(int index) => state = index;
}
