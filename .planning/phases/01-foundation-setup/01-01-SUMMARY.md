# Plan 01-01 Summary — Theme, Shell, Router, Providers

**Phase:** 01-foundation-setup  
**Plan:** 01-01  
**Wave:** 1  
**Status:** Complete  
**Completed:** 2026-05-17

## Files Created

| File | Purpose |
|------|---------|
| `lib/theme/brdy_colors.dart` | `abstract final class BrdyColors` — 9 locked color tokens |
| `lib/theme/brdy_spacing.dart` | `abstract final class BrdySpacing` — xs/sm/md/lg/xl/x2l/x3l scale |
| `lib/theme/brdy_text_theme.dart` | `abstract final class BrdyTextTheme` — JetBrains Mono + Barlow Condensed via google_fonts |
| `lib/theme/brdy_theme.dart` | `abstract final class BrdyTheme` — ThemeData factory with brutalist 0dp radius |
| `lib/app/router.dart` | `routerProvider` (keepAlive) + `_RouterListenable` bridge + 4 GoRoutes |
| `lib/features/splash/splash_screen.dart` | SplashScreen with BRDY.01 wordmark on background |
| `lib/features/setup/providers/app_startup_provider.dart` | `Future<int?> appStartup` stub returning null |
| `lib/features/setup/providers/active_round_id_provider.dart` | `ActiveRoundId` keepAlive notifier |
| `lib/features/shot_capture/providers/active_hole_index_provider.dart` | `ActiveHoleIndex` keepAlive notifier |

## Files Modified

| File | Change |
|------|--------|
| `lib/app/app.dart` | Switched to `MaterialApp.router(routerConfig: ref.watch(routerProvider))` with `BrdyTheme.themeData` |
| `lib/features/shot_capture/shot_capture_screen.dart` | `roundId: int` (was String); `holeNumber` removed |
| `lib/features/round_review/round_review_screen.dart` | `roundId: int` (was String) |
| `test/widget_test.dart` | Replaced broken `MyApp` test with `BrdyApp` smoke test in `ProviderScope` |

## Generated Files

| File | Lines |
|------|-------|
| `lib/app/router.g.dart` | 26 |
| `lib/features/setup/providers/app_startup_provider.g.dart` | 26 |
| `lib/features/setup/providers/active_round_id_provider.g.dart` | 25 |
| `lib/features/shot_capture/providers/active_hole_index_provider.g.dart` | 25 |

## Test Results

- `dart run build_runner build --delete-conflicting-outputs` — exit 0, 4 files generated
- `flutter test` — 1 passing (`BrdyApp renders without crashing`)
- `flutter analyze` — No issues found

## Key Notes

- `appStartupProvider` returns `null` pending Plan 02 Drift wiring
- Router redirect handles loading→/splash, error→/setup, data with null→/setup, data with roundId→crash recovery
- All providers use code-gen annotations; no hand-written boilerplate
