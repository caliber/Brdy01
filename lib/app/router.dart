import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/setup/setup_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/shot_capture/shot_capture_screen.dart';
import '../features/round_review/round_review_screen.dart';
import '../features/setup/providers/app_startup_provider.dart';
import '../features/setup/providers/active_round_id_provider.dart';

part 'router.g.dart';

/// Bridge between Riverpod async state and GoRouter's Listenable-based
/// refresh mechanism. Calls [notifyListeners] whenever [appStartupProvider]
/// transitions between states so the redirect re-evaluates.
class _RouterListenable extends ChangeNotifier {
  _RouterListenable(Ref ref) {
    ref.listen<AsyncValue<int?>>(
      appStartupProvider,
      (_, __) => notifyListeners(),
    );
  }
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final notifier = _RouterListenable(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final startupState = ref.read(appStartupProvider);
      return startupState.when(
        loading: () => '/splash',
        error: (_, __) => '/setup',
        data: (incompleteRoundId) {
          if (incompleteRoundId != null) {
            ref.read(activeRoundIdProvider.notifier).set(incompleteRoundId);
            return '/shot-capture/$incompleteRoundId';
          }
          if (state.uri.path == '/splash') return '/setup';
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (_, __) => const SetupScreen(),
      ),
      GoRoute(
        path: '/shot-capture/:roundId',
        builder: (_, state) => ShotCaptureScreen(
          roundId: int.parse(state.pathParameters['roundId']!),
        ),
      ),
      GoRoute(
        path: '/round-review/:roundId',
        builder: (_, state) => RoundReviewScreen(
          roundId: int.parse(state.pathParameters['roundId']!),
        ),
      ),
    ],
  );
}
