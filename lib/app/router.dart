import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/setup/setup_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/shot_capture/shot_capture_screen.dart';
import '../features/round_review/round_review_screen.dart';
import '../features/round_history/round_history_screen.dart';
import '../features/setup/providers/app_startup_provider.dart';
import '../features/setup/providers/active_round_id_provider.dart';
import '../features/shot_capture/providers/round_complete_provider.dart';

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
            // If the round was completed in-session, appStartupProvider is
            // stale. Detect this via roundCompleteProvider and allow free
            // navigation so the user can start a new round.
            final isComplete = ref.read(roundCompleteProvider(incompleteRoundId));
            if (isComplete) {
              if (state.uri.path == '/splash') return '/setup';
              return null;
            }
            // Also allow /round-review/:id and /shot-capture/:otherId through.
            if (state.uri.path.startsWith('/round-review/$incompleteRoundId')) return null;
            if (state.uri.path.startsWith('/shot-capture/') &&
                state.uri.path != '/shot-capture/$incompleteRoundId') return null;
            // Allowlist: round history and read-only review are safe during an active round.
            if (state.uri.path == '/round-history') return null;
            if (state.uri.path.startsWith('/round-review/') &&
                state.uri.queryParameters['readOnly'] == 'true') return null;
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
          readOnly: state.uri.queryParameters['readOnly'] == 'true',
        ),
      ),
      GoRoute(
        path: '/round-history',
        builder: (_, __) => const RoundHistoryScreen(),
      ),
    ],
  );
}
