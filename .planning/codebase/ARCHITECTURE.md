<!-- refreshed: 2026-05-16 -->
# Architecture

**Analysis Date:** 2026-05-16

## System Overview

```text
┌─────────────────────────────────────────────────────────────────────┐
│                     Presentation Layer                              │
│   features/setup   features/shot_capture   features/round_review   │
│   `lib/features/`                                                   │
└────────────┬───────────────────┬───────────────────┬───────────────┘
             │  Riverpod          │  Riverpod          │  Riverpod
             ▼  providers         ▼  providers         ▼  providers
┌─────────────────────────────────────────────────────────────────────┐
│                       Domain Layer                                  │
│   models / enums / repository interfaces                            │
│   `lib/domain/`                                                     │
└────────────┬───────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Data Layer                                   │
│   local: Drift (SQLite) + Hive (key-value)                          │
│   remote: Dio + Retrofit → golfcourseapi.com                        │
│   `lib/data/`                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | Location |
|-----------|----------------|----------|
| `BrdyApp` | Root widget, MaterialApp, theme | `lib/app/app.dart` |
| `AppConstants` | Compile-time constants (API key, box names, WHS params) | `lib/app/constants.dart` |
| `SetupScreen` | Pre-round configuration (player, course, tees) | `lib/features/setup/setup_screen.dart` |
| `ShotCaptureScreen` | Per-hole shot entry (voice + GPS + manual) | `lib/features/shot_capture/shot_capture_screen.dart` |
| `RoundReviewScreen` | Post-round scorecard and handicap summary | `lib/features/round_review/round_review_screen.dart` |
| `lib/domain/models/` | Immutable domain entities (Freezed) — scaffolded, empty | `lib/domain/models/` |
| `lib/domain/repositories/` | Abstract repository contracts — scaffolded, empty | `lib/domain/repositories/` |
| `lib/domain/enums/` | Domain enums (shot type, club, etc.) — scaffolded, empty | `lib/domain/enums/` |
| `lib/data/local/database/` | Drift database, DAOs, table definitions — scaffolded, empty | `lib/data/local/database/` |
| `lib/data/local/preferences/` | Hive box wrappers for player prefs / course cache — scaffolded, empty | `lib/data/local/preferences/` |
| `lib/data/remote/api/` | Retrofit client for golfcourseapi.com — scaffolded, empty | `lib/data/remote/api/` |
| `lib/data/remote/dto/` | JSON DTOs (json_serializable / Freezed) — scaffolded, empty | `lib/data/remote/dto/` |
| `lib/core/` | Shared extensions, utilities, reusable widgets — scaffolded, empty | `lib/core/` |

## Pattern Overview

**Overall:** Clean Architecture with feature-first presentation organisation.

**Key Characteristics:**
- Domain layer defines abstract `Repository` interfaces; the data layer implements them.
- Riverpod (code-generated via `riverpod_annotation`) provides DI and reactive state throughout.
- Features are self-contained vertical slices (`setup`, `shot_capture`, `round_review`), each owning their own `widgets/` subfolder.
- The `core/` layer supplies cross-feature utilities (extensions, shared widgets) with no upward dependencies.
- All layers are scaffolded — directory skeletons are in place but most `.dart` files are not yet written.

## Layers

**Presentation (Features):**
- Purpose: Flutter screens and feature-local widgets
- Location: `lib/features/`
- Contains: Screen classes (`*Screen`), feature-scoped `widgets/` subfolders, Riverpod UI consumers
- Depends on: Domain models, Riverpod providers (to be added)
- Used by: `BrdyApp` via router (go_router — not yet wired)

**Domain:**
- Purpose: Business rules and data contracts — independent of Flutter/platform
- Location: `lib/domain/`
- Contains: Freezed entity models (`models/`), abstract repository interfaces (`repositories/`), enums (`enums/`)
- Depends on: Nothing (pure Dart)
- Used by: Presentation layer (via providers), Data layer (implements interfaces)

**Data:**
- Purpose: Concrete data access — local persistence and remote HTTP
- Location: `lib/data/`
- Contains:
  - `local/database/` — Drift `AppDatabase`, `daos/`, `tables/`
  - `local/preferences/` — Hive box wrappers
  - `remote/api/` — Retrofit API client + Dio interceptors
  - `remote/dto/` — JSON DTO classes
- Depends on: Domain interfaces (implements them)
- Used by: Riverpod providers (injected into presentation)

**Core:**
- Purpose: Cross-cutting shared code with no feature coupling
- Location: `lib/core/`
- Contains: `extensions/`, `utils/`, `widgets/`
- Depends on: Nothing (pure Flutter/Dart helpers)
- Used by: Any layer

**App bootstrap:**
- Purpose: DI root, app shell, constants
- Location: `lib/app/`, `lib/main.dart`
- Contains: `BrdyApp`, `AppConstants`, future router config
- Depends on: Presentation layer entry points

## Data Flow

### Planned Primary Request Path (not yet implemented)

1. `main()` initialises Hive boxes then wraps `BrdyApp` in `ProviderScope` (`lib/main.dart`)
2. go_router resolves the initial route → `SetupScreen` (`lib/features/setup/setup_screen.dart`)
3. Screen reads a Riverpod provider; provider calls a domain repository interface
4. Repository implementation in `lib/data/` fetches from Drift DB or Dio HTTP client
5. Result flows back as immutable Freezed domain model; Riverpod rebuilds the widget

### Current Actual Path (scaffold state)

1. `main()` opens Hive boxes, runs `ProviderScope(child: BrdyApp())` (`lib/main.dart`)
2. `BrdyApp.build()` returns `MaterialApp(home: SetupScreen())` — no router yet (`lib/app/app.dart`)
3. `SetupScreen` renders a static `Text('BRDY.01: SETUP')` placeholder

**State Management:**
- Riverpod (`flutter_riverpod: ^2.5.1` + `riverpod_annotation: ^2.3.5`) is declared and wired at the root (`ProviderScope` in `main.dart`).
- No providers have been created yet — all provider files are pending implementation.
- `BrdyApp` extends `ConsumerWidget`, establishing the pattern for Riverpod consumption.

## Key Abstractions

**Domain Models (planned):**
- Purpose: Immutable, equatable entities for Round, Hole, Shot, Player, Course
- Location: `lib/domain/models/` (directory exists, files pending)
- Pattern: Freezed (`freezed_annotation: ^2.4.4`) with `copyWith`, `==`, `hashCode`

**Repository Interfaces (planned):**
- Purpose: Abstract contracts separating domain from data
- Location: `lib/domain/repositories/` (directory exists, files pending)
- Pattern: Abstract Dart class; one concrete implementation per data source in `lib/data/`

**Drift Database (planned):**
- Purpose: SQLite persistence for rounds, holes, and shots
- Location: `lib/data/local/database/` (directory exists, files pending)
- Pattern: Drift `@DriftDatabase` class, typed DAOs in `daos/`, table definitions in `tables/`

**Retrofit API Client (planned):**
- Purpose: Type-safe HTTP client for `golfcourseapi.com`
- Location: `lib/data/remote/api/` (directory exists, files pending)
- Pattern: Retrofit `@RestApi` annotation + Dio + `json_serializable` DTOs

## Entry Points

**Flutter bootstrap:**
- Location: `lib/main.dart`
- Triggers: Flutter engine startup
- Responsibilities: Hive initialisation, open named boxes (`player_prefs`, `course_cache`), wrap app in `ProviderScope`

**Root widget:**
- Location: `lib/app/app.dart` (`BrdyApp`)
- Triggers: Called by `main()`
- Responsibilities: `MaterialApp` configuration, theme (Material 3, seed color `#E8520A`), home screen (temporarily `SetupScreen` — go_router not yet wired)

**Android platform:**
- Location: `android/app/src/main/kotlin/com/brdy/brdy01/MainActivity.kt`
- Responsibilities: Extends `FlutterActivity` — no custom channel code yet

## Architectural Constraints

- **State management:** All reactive state must go through Riverpod providers. No `setState` outside of purely local UI concerns.
- **Immutability:** Domain entities must use Freezed; no mutable model classes.
- **Layer boundaries:** Domain layer must not import from `lib/data/` or Flutter SDK. Data layer must not import from `lib/features/`.
- **Global state:** Only two Hive boxes opened at startup (`player_prefs`, `course_cache`). No other module-level singletons at present.
- **Code generation:** Riverpod providers, Drift DAOs, Retrofit clients, and Freezed models all require `build_runner`. Generated files (`*.g.dart`, `*.freezed.dart`) are not yet committed.
- **Navigation:** go_router (`^14.2.0`) is declared but not yet configured. `BrdyApp` currently uses `MaterialApp(home:)` as a temporary bridge.
- **Connectivity:** `connectivity_plus` is included for offline detection — offline-first design is implied but not yet implemented.
- **Platform targets:** iOS, Android, and Web are all scaffolded. Wear OS companion channel (`wear_plus`) is declared.

## Anti-Patterns

### Temporary direct home navigation

**What happens:** `BrdyApp` uses `MaterialApp(home: SetupScreen())` — bypassing go_router entirely.
**Why it's wrong:** Prevents declarative deep-linking, back-stack management, and type-safe route parameters that go_router provides.
**Do this instead:** Configure a `GoRouter` instance in a Riverpod provider, pass it to `MaterialApp.router(routerConfig:)`, and define typed routes for `setup`, `shot_capture/:roundId/:hole`, and `round_review/:roundId`.

### Placeholder smoke test referencing non-existent widget

**What happens:** `test/widget_test.dart` imports `MyApp` which does not exist in the current codebase.
**Why it's wrong:** The test will fail to compile on first `flutter test` run, giving misleading CI feedback.
**Do this instead:** Update `test/widget_test.dart` to import and pump `BrdyApp` (wrapped in `ProviderScope`).

## Error Handling

**Strategy:** Not yet implemented. `logger: ^2.3.0` is declared as a dependency.

**Patterns:**
- No try/catch, error boundary, or `AsyncValue` error handling in place yet.
- Intended pattern (from dependencies): Riverpod `AsyncValue<T>` for async providers; `logger` for structured logging; `connectivity_plus` to gate remote calls.

## Cross-Cutting Concerns

**Logging:** `logger` package declared (`^2.3.0`); no logger instance created yet.
**Validation:** Not implemented.
**Authentication:** Not applicable — API key injected at compile-time via `--dart-define=GOLF_API_KEY=...` and accessed through `AppConstants.golfApiKey`.

---

*Architecture analysis: 2026-05-16*
