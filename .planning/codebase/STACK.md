# Technology Stack

**Analysis Date:** 2026-05-16

## Runtime & Language

**Primary:**
- Dart 3.5.4 (stable) — all application code
- Kotlin (Android host layer) — JVM target 1.8, via `kotlin-android` plugin

**SDK Constraint:** `>=3.3.0 <4.0.0` (pubspec.yaml)

## Runtime

**Environment:**
- Flutter 3.24.5, channel stable (`dec2ee5c1f98`)

**Target Platforms:**
- Android (via `com.android.application` + `dev.flutter.flutter-gradle-plugin`)
- iOS (Runner.xcworkspace present)
- Web (index.html + manifest.json present, Flutter web renderer)
- Wear OS (companion channel via `wear_plus`)

## Frameworks & Libraries

**State Management:**
- `flutter_riverpod` 2.6.1 — reactive state with `ProviderScope` at root (`lib/main.dart`)
- `riverpod_annotation` 2.6.1 — annotation-driven provider generation

**Navigation:**
- `go_router` 14.8.1 — declarative routing (not yet wired in `app.dart`; `SetupScreen` used directly)

**Local Storage:**
- `hive_flutter` 1.1.0 — key-value boxes: `player_prefs`, `course_cache` (initialised in `lib/main.dart`)
- `drift` 2.19.1+1 — SQLite ORM for relational round/hole/shot data; tables in `lib/data/local/database/tables/`, DAOs in `lib/data/local/database/daos/`
- `sqlite3_flutter_libs` 0.5.42 — native SQLite bindings for Drift

**GPS & Maps:**
- `geolocator` 12.0.0 — device GPS positioning
- `permission_handler` 11.4.0 — runtime permissions (location, microphone)
- `flutter_map` 7.0.2 — OpenStreetMap tile rendering
- `latlong2` 0.9.1 — coordinate types for map/GPS
- `flutter_map_tile_caching` 9.1.4 — offline tile caching (no API key required for OSM base tiles)

**Voice:**
- `speech_to_text` 6.6.2 — on-device speech recognition for shot logging
- `flutter_tts` 4.2.5 — text-to-speech voice confirmations

**Networking / API:**
- `dio` 5.9.2 — HTTP client for `golfcourseapi.com` requests; interceptors in `lib/data/remote/api/interceptors/`
- `retrofit` 4.5.0 — type-safe REST API client generation
- `json_annotation` 4.9.0 — JSON serialisation annotations

**Wearable:**
- `wear_plus` 1.2.4 — Wear OS companion data channel; feature in `lib/features/wearable/`

**UI Helpers:**
- `google_fonts` 6.3.0 — JetBrains Mono for numeric displays
- `gap` 3.0.1 — semantic spacing widget
- `flutter_animate` 4.5.2 — micro-animations (pulse dot, toasts)
- `haptic_feedback` 0.5.1+2 — haptic response on shot record
- `share_plus` 9.0.0 — share round summary card
- `screenshot` 2.5.0 — capture round summary as image

**Utilities:**
- `freezed_annotation` 2.4.4 — immutable data class generation
- `equatable` 2.0.8 — value equality for domain models
- `collection` 1.18.0 — collection utilities
- `intl` 0.19.0 — date/number formatting
- `logger` 2.7.0 — structured console logging
- `connectivity_plus` 6.1.5 — offline detection

## Build & Tooling

**Linting / Analysis:**
- `flutter_lints` 4.0.0 — recommended Flutter lint ruleset
- Config: `analysis_options.yaml` (extends `package:flutter_lints/flutter.yaml`)

**Android Build:**
- Gradle with `com.android.application`, `kotlin-android`, `dev.flutter.flutter-gradle-plugin`
- App ID: `com.brdy.brdy01`
- Compile/min/target SDK: deferred to Flutter Gradle plugin defaults

**Code Generation (build_runner):**
- `build_runner` 2.4.13 — orchestrates all generators
- `riverpod_generator` 2.6.3 — generates Riverpod providers from annotations
- `drift_dev` 2.19.1 — generates Drift query code from table definitions
- `retrofit_generator` 8.2.1 — generates Retrofit API client implementations
- `freezed` 2.5.7 — generates immutable data classes
- `json_serializable` 6.9.0 — generates `fromJson`/`toJson` methods

**Run codegen:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Package Manager

- **Tool:** `pub` (Dart's built-in package manager, invoked via `flutter pub`)
- **Manifest:** `pubspec.yaml`
- **Lockfile:** `pubspec.lock` (present and committed)

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | 2.6.1 | App-wide reactive state management |
| `go_router` | 14.8.1 | Declarative navigation / deep-linking |
| `drift` | 2.19.1+1 | Relational SQLite ORM for rounds/holes/shots |
| `hive_flutter` | 1.1.0 | Key-value cache for player prefs and courses |
| `dio` | 5.9.2 | HTTP client for Golf Course API |
| `geolocator` | 12.0.0 | Real-time GPS positioning |
| `flutter_map` | 7.0.2 | Offline-capable OSM map display |
| `speech_to_text` | 6.6.2 | Voice shot input |
| `wear_plus` | 1.2.4 | Wear OS companion channel |
| `freezed_annotation` | 2.4.4 | Immutable domain model generation |

## Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | 2.4.13 | Code generation orchestration |
| `riverpod_generator` | 2.6.3 | Provider codegen from annotations |
| `drift_dev` | 2.19.1 | Drift SQL codegen |
| `retrofit_generator` | 8.2.1 | REST client codegen |
| `freezed` | 2.5.7 | Immutable class codegen |
| `json_serializable` | 6.9.0 | JSON serialisation codegen |
| `flutter_lints` | 4.0.0 | Static analysis rules |
| `flutter_test` | SDK | Unit and widget testing |

## Configuration

**Environment:**
- API key injected at compile time via `--dart-define=GOLF_API_KEY=<value>`
- Accessed in code: `const String.fromEnvironment('GOLF_API_KEY')` in `lib/app/constants.dart`
- No `.env` file present — no runtime dotenv loader used

**Assets:**
- `assets/images/` — image assets
- `assets/fonts/` — font assets (registered in `pubspec.yaml`)

---

*Stack analysis: 2026-05-16*
