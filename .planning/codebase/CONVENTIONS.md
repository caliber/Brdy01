# Coding Conventions

**Analysis Date:** 2026-05-16

## Naming Conventions

**Classes:**
- PascalCase for all class names
- Screens are named `<Feature>Screen` (e.g., `SetupScreen`, `ShotCaptureScreen`, `RoundReviewScreen`)
- The root app widget is named after the app: `BrdyApp`
- Abstract constant holders use `abstract class <Name>Constants` pattern: `AppConstants` (`lib/app/constants.dart`)

**Files:**
- `snake_case` for all Dart filenames (e.g., `setup_screen.dart`, `shot_capture_screen.dart`)
- Feature screens are named `<feature>_screen.dart`

**Variables and Parameters:**
- `camelCase` for local variables and parameters (e.g., `roundId`, `holeNumber`)
- Constructor parameters use named required syntax: `required this.roundId`

**Constants:**
- Defined as `static const` on abstract classes, not as top-level variables
- Names are `camelCase` within the class: `golfApiBaseUrl`, `playerPrefsBox`
- Example: `lib/app/constants.dart`

**Widgets:**
- Prefer `const` constructors throughout — all screens use `const` constructors
- `super.key` is used consistently in all widget constructors

## File Organization Patterns

**Directory structure:**
```
lib/
├── app/            # App-wide config: app widget, constants, routing (future)
│   ├── app.dart
│   └── constants.dart
├── features/       # Feature-first directory layout
│   ├── round_review/
│   │   └── round_review_screen.dart
│   ├── setup/
│   │   └── setup_screen.dart
│   └── shot_capture/
│       └── shot_capture_screen.dart
└── main.dart       # Entry point only — wires up Hive and ProviderScope
```

**Principles observed:**
- Feature-first organisation: each feature has its own subdirectory under `lib/features/`
- `lib/app/` holds app-wide concerns (theme, constants, routing)
- `main.dart` is intentionally thin — only bootstrapping logic (Hive init, `runApp`)
- No barrel files (`index.dart`) yet — direct imports by path

## Code Style (Linting, Formatting)

**Linter:**
- `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`
- No custom rules added or disabled — default Flutter recommended ruleset is in effect
- `dart format` (included with Flutter SDK) is the implicit formatter

**Key enforced rules (from flutter_lints):**
- Prefer `const` constructors where possible
- Avoid `print()` in production code (`avoid_print` rule — active by default)
- Prefer single quotes (not yet explicitly enabled in `analysis_options.yaml` — currently commented out)
- Line-level and file-level suppress syntax available: `// ignore: rule_name`

**Run analysis:**
```bash
flutter analyze        # Static analysis
dart format lib/ test/ # Auto-format
```

## State Management Patterns

**Framework:** Riverpod (`flutter_riverpod: ^2.5.1`)

**Setup:** `ProviderScope` wraps the entire widget tree at the root in `lib/main.dart`:
```dart
runApp(const ProviderScope(child: BrdyApp()));
```

**Widget base class:**
- Widgets that consume Riverpod state must extend `ConsumerWidget` and accept `WidgetRef ref` in `build`
- Example: `BrdyApp` in `lib/app/app.dart` extends `ConsumerWidget`
- Screens that do not yet consume providers use plain `StatelessWidget`

**Code generation:**
- `riverpod_generator` and `riverpod_annotation` are in place for annotation-driven provider generation
- Generated files will use `build_runner` (`dart run build_runner build`)
- No generated providers exist yet — the pattern is declared but not yet implemented

**Immutable data:**
- `freezed_annotation` + `freezed` are declared as dependencies for immutable data classes
- `equatable` is also present as an alternative for value equality

## Error Handling Approach

No error handling patterns are implemented in current source files. The codebase is at a skeleton/scaffold stage.

**Declared intent from dependencies:**
- `connectivity_plus` is included for offline detection, suggesting error states for network failures are planned
- `dio` is included with exception-based HTTP error handling expected
- `logger` package (`^2.3.0`) is declared for structured logging

**What to follow when implementing:**
- Use `logger` (already in `pubspec.yaml`) rather than `print()` — `avoid_print` lint rule is active
- Wrap Drift/SQLite calls in try/catch; surface errors through Riverpod `AsyncValue` states
- Network errors from `retrofit`/`dio` should propagate as typed exceptions

## Logging / Debugging Patterns

**Declared tool:** `logger: ^2.3.0` is in `pubspec.yaml`

**Current usage:** No logging calls exist in source files yet — the codebase is pre-implementation.

**Intended pattern (infer from dependency choice):**
- Use `Logger` from the `logger` package rather than `print()` or `debugPrint()`
- `avoid_print` lint rule is active, which will flag bare `print()` calls

**Secrets:**
- API keys use `String.fromEnvironment('GOLF_API_KEY')` compile-time injection (`lib/app/constants.dart`) — never hardcoded

## Documentation Standards

**Observed patterns:**
- No `///` doc comments present in any source file yet
- Constants in `lib/app/constants.dart` rely on naming clarity rather than doc comments
- `pubspec.yaml` uses inline comments (`#`) to group and explain dependency sections

**No formal doc standard is enforced by tooling** — `flutter_lints` does not require doc comments by default.

**Recommendation when adding code:** Add `///` doc comments to public classes and non-obvious constants, consistent with Dart conventions.

## Import Organization

**Style observed across all source files:**

1. Dart SDK imports — not present yet (no `dart:` imports used)
2. Flutter/package imports using `package:` scheme
3. Relative local imports for intra-project files

**Examples:**
```dart
// External packages first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Then local relative imports
import 'app/app.dart';
import 'app/constants.dart';
```

**Path aliases:** None — standard relative import paths are used throughout.

**No import sorting tool** is configured. The Dart formatter does not reorder imports automatically. Manual ordering follows the pattern above.

---

*Convention analysis: 2026-05-16*
