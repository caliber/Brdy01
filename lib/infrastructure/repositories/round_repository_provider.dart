import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/round_repository.dart';
import '../../data/local/database/app_database_provider.dart';
import 'round_repository_impl.dart';

part 'round_repository_provider.g.dart';

@Riverpod(keepAlive: true)
RoundRepository roundRepository(Ref ref) =>
    RoundRepositoryImpl(ref.watch(appDatabaseProvider));
