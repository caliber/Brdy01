import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'tile_cache_repository.dart';

part 'tile_cache_provider.g.dart';

@Riverpod(keepAlive: true)
TileCacheRepository tileCache(Ref ref) => TileCacheRepository();
