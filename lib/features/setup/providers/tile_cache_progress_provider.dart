import 'dart:async';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/hole_model.dart';
import '../../../infrastructure/repositories/tile_cache_provider.dart';

part 'tile_cache_progress_provider.g.dart';

@riverpod
class TileCacheProgress extends _$TileCacheProgress {
  StreamSubscription<DownloadProgress>? _sub;

  @override
  DownloadProgress? build() {
    ref.onDispose(() => _sub?.cancel());
    return null;
  }

  void start(List<HoleModel> holes) {
    _sub?.cancel();
    final stream = ref.read(tileCacheProvider).preCacheCourse(holes);
    if (stream == null) {
      state = null;
      return;
    }
    _sub = stream.listen(
      (progress) {
        state = progress;
        if (progress.percentageProgress >= 100) {
          state = null;
          _sub?.cancel();
        }
      },
      onError: (e) {
        state = null;
        _sub?.cancel();
      },
    );
  }
}
