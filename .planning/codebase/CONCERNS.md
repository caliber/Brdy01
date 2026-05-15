# Concerns

## Security Concerns

- **Debug signing in release builds** — `android/app/build.gradle` uses debug keystore for release; app should never ship this way
- **Silent API key failure** — `GOLF_API_KEY` in `lib/app/constants.dart` is empty string if `--dart-define` is omitted at build time; no guard or validation present
- **Missing Android permissions** — GPS and microphone runtime permissions not declared in `AndroidManifest.xml` despite `geolocator` and `speech_to_text` being dependencies
- **Missing iOS `Info.plist` usage descriptions** — required privacy strings for location and microphone access not present; app will crash on iOS when requesting these permissions

## Performance Risks

- No caching strategy for Golf Course API responses beyond Hive `course_cache` box (no TTL or invalidation logic visible)
- `flutter_map_tile_caching` declared as dependency but never used — map tiles fetched fresh on every load

## Technical Debt

- `go_router` declared but `MaterialApp.router` not wired up — navigation package unused
- Riverpod declared and `ProviderScope` likely wrapping app, but zero providers implemented
- README is default Flutter template text — no project-specific documentation
- Two TODOs in `android/app/build.gradle`
- `.flutter-plugins` and `.flutter-plugins-dependencies` files committed to git despite being listed in `.gitignore`

## Dependency Risks

- `equatable` and `freezed` both declared — duplicate equality/value-semantics libraries; likely only one needed
- `flutter_map_tile_caching` declared but never imported or used anywhere in source
- `wear_plus` has a thin ecosystem and limited community support; Wear OS / watchOS support may lag Flutter updates
- Hive boxes opened but no `TypeAdapter` registrations visible — will fail at runtime for any non-primitive stored type

## Architectural Concerns

- Almost all architectural layers are scaffolded but empty:
  - GPS service — declared, not implemented
  - Voice service — declared, not implemented
  - Share service — declared, not implemented
  - Wear integration — declared, not implemented
  - Drift database — dependency present, no tables defined
  - Retrofit API client — dependency present, no endpoints defined
  - Domain models — directory present, no model files
  - Repositories — directory present, no implementations
  - Theme system — directory present, no theme defined
- App is effectively a skeleton; the majority of declared architecture is placeholder only

## Scalability Issues

- No pagination or lazy loading strategy for course/round list queries
- All data local — no sync mechanism if multi-device support is ever needed

## Missing Error Handling

- No global error boundary or crash handler (no Sentry, Firebase Crashlytics, or equivalent)
- API client (Dio + Retrofit) has no visible interceptor for retry, timeout, or error normalization

## Code Smells

- Declared dependencies with no usage in source (`flutter_map_tile_caching`, potentially `equatable` + `freezed` overlap)
- Committed generated/derived files (`.flutter-plugins`) that should be gitignored

## Incomplete Features / TODOs

- GPS shot tracking — not implemented
- Voice input for score entry — not implemented
- Wearable companion app — not implemented
- Round sharing / export — not implemented
- Offline course caching with TTL — not implemented
- All 6 test directories empty — no tests written

## Infrastructure / DevOps Gaps

- No CI/CD pipeline (no `.github/workflows/`, `bitrise.yml`, `codemagic.yaml`, etc.)
- No iOS `Podfile` present — iOS build may not be reproducible
- No automated test runs or lint checks on commit or PR
- No release signing configuration beyond placeholder debug keystore
