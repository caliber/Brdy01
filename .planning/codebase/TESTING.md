# Testing Patterns

**Analysis Date:** 2026-05-16

## Test Framework & Tools

**Runner:** `flutter_test` (Flutter SDK built-in)
- No separate `jest.config`, `vitest.config`, or external runner
- Declared in `pubspec.yaml` under `dev_dependencies`:
  ```yaml
  flutter_test:
    sdk: flutter
  ```

**Assertion library:** `expect()` from `flutter_test` (standard Flutter test assertions)

**Widget testing utility:** `WidgetTester` from `flutter_test`

**Linting for tests:** `flutter_lints: ^4.0.0` — same ruleset applies to test files

**Run commands:**
```bash
flutter test                  # Run all tests
flutter test --coverage       # Run with coverage output (lcov)
flutter test test/widget_test.dart  # Run a single file
```

**No additional test packages are declared** — `mockito`, `mocktail`, `bloc_test`, or similar mocking/integration packages are not in `pubspec.yaml`.

## Test Types Present

**Widget tests:** Yes — one file exists: `test/widget_test.dart`

**Unit tests:** None — no unit test files found.

**Integration tests:** None — no `integration_test/` directory and `integration_test` package is not declared in `pubspec.yaml`.

**Golden/screenshot tests:** None.

**Current state:** The only test file is the Flutter project scaffold default — a counter smoke test that tests a widget (`MyApp`) which no longer reflects the actual app entry point (`BrdyApp`). The test references a counter widget that does not exist in the current codebase. **This test will fail against the current code.**

## Coverage

**Tooling:** `flutter test --coverage` generates `coverage/lcov.info` (standard Flutter output).

**Minimum coverage threshold:** Not enforced — no `lcov --fail-under-lines` or equivalent configured.

**Current coverage:** Effectively 0% of application code — the only test exercises a scaffold counter widget that is no longer the app's entry point.

**View coverage:**
```bash
flutter test --coverage
# Then open coverage/lcov.info with an lcov viewer or IDE plugin
```

## Test File Organization

**Location:** All tests are in the `/test/` directory at project root (standard Flutter convention).

**Current structure:**
```
test/
└── widget_test.dart    # Scaffold default — counter smoke test (stale)
```

**Naming convention observed:** `<subject>_test.dart` (Flutter convention).

**Expected future structure (follow Flutter conventions):**
```
test/
├── features/
│   ├── setup/
│   │   └── setup_screen_test.dart
│   ├── shot_capture/
│   │   └── shot_capture_screen_test.dart
│   └── round_review/
│       └── round_review_screen_test.dart
├── app/
│   └── constants_test.dart
└── widget_test.dart
```

Tests should mirror the `lib/` directory structure.

## Mocking Strategy

**No mocking framework is declared.** `mockito`, `mocktail`, and similar packages are absent from `pubspec.yaml`.

**No mocks exist in the codebase.**

**What to use when needed:** Add `mocktail` or `mockito` to `dev_dependencies`. Given that the project uses Riverpod, `ProviderContainer` overrides are the idiomatic way to inject test doubles for providers:
```dart
// Riverpod-idiomatic mock injection (no extra package needed)
final container = ProviderContainer(overrides: [
  myProvider.overrideWithValue(fakeValue),
]);
```

## CI/CD Integration

**No CI/CD pipeline exists.** There is no `.github/` directory, no `Makefile`, no `Dockerfile`, and no shell scripts at the project root.

**Tests are not automatically run** on commit or pull request.

## Gaps / Missing Coverage

**Critical gaps (current state is pre-implementation):**

1. **Stale scaffold test** — `test/widget_test.dart` tests a counter widget that does not exist in the app. The test imports `package:brdy01/main.dart` and calls `MyApp()`, which is not defined. This test will fail immediately.
   - File: `test/widget_test.dart`
   - Fix: Replace with a smoke test for `BrdyApp` from `lib/app/app.dart`

2. **Zero unit tests** — No business logic (handicap calculation, WHS differential computation, round scoring) is tested. These are the highest-value test targets once implemented.

3. **No provider/state tests** — Riverpod providers (`riverpod_generator`-generated) have no tests. Provider logic should be tested via `ProviderContainer` in isolation.

4. **No widget tests for feature screens** — `SetupScreen`, `ShotCaptureScreen`, and `RoundReviewScreen` are all untested.

5. **No integration tests** — Drift (SQLite) database operations, Hive persistence, and GPS/location flows have no integration test coverage. `integration_test` package is not declared.

6. **No CI gate** — Tests are never automatically run; broken tests can be committed without detection.

7. **No mocking infrastructure** — When network calls (via `dio`/`retrofit`) and platform channels (GPS, TTS, speech) need testing, there is no mock framework in place.

---

*Testing analysis: 2026-05-16*
