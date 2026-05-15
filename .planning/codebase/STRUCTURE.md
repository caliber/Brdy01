# Structure

## Directory Layout

```
brdy01/
├── lib/                        # All Dart source code
│   ├── main.dart               # App entry point
│   ├── app/
│   │   ├── app.dart            # Root MaterialApp widget
│   │   └── constants.dart      # App-wide constants (API keys, URLs)
│   ├── core/                   # Shared utilities (all empty)
│   │   ├── extensions/         # Dart extension methods (empty)
│   │   ├── utils/              # Utility functions (empty)
│   │   └── widgets/            # Shared/reusable widgets (empty)
│   ├── data/                   # Data layer (scaffolded, not implemented)
│   │   ├── local/
│   │   │   ├── database/       # Drift SQLite setup
│   │   │   │   ├── daos/       # Data access objects (empty)
│   │   │   │   └── tables/     # Table definitions (empty)
│   │   │   └── preferences/    # Hive key-value storage (empty)
│   │   └── remote/
│   │       ├── api/            # Retrofit API client (empty)
│   │       │   └── interceptors/ # Dio interceptors (empty)
│   │       └── dto/            # API response DTOs (empty)
│   ├── domain/                 # Domain layer (all empty)
│   │   ├── enums/              # Domain enums (empty)
│   │   ├── models/             # Domain models (empty)
│   │   └── repositories/       # Repository interfaces (empty)
│   ├── features/               # Feature screens (3 implemented)
│   │   ├── round_review/
│   │   │   ├── round_review_screen.dart
│   │   │   └── widgets/        # (empty)
│   │   ├── setup/
│   │   │   ├── setup_screen.dart
│   │   │   └── widgets/        # (empty)
│   │   ├── shot_capture/
│   │   │   ├── shot_capture_screen.dart
│   │   │   └── widgets/        # (empty)
│   │   └── wearable/           # Wearable feature (empty)
│   ├── infrastructure/         # Infrastructure implementations (empty)
│   │   ├── handicap/           # Handicap calculation (empty)
│   │   └── repositories/       # Repository implementations (empty)
│   ├── services/               # Platform services (all empty)
│   │   ├── gps/                # GPS/location service (empty)
│   │   ├── share/              # Share/export service (empty)
│   │   └── voice/              # Speech-to-text service (empty)
│   └── theme/                  # App theme (empty)
├── test/
│   └── widget_test.dart        # Default Flutter widget test (stub only)
├── assets/                     # Static assets (empty)
├── android/                    # Android platform project
├── ios/                        # iOS platform project
├── web/                        # Web platform project
├── pubspec.yaml                # Dart/Flutter dependencies
├── analysis_options.yaml       # Dart linting config
└── README.md                   # Default Flutter template README
```

## Entry Points

- **`lib/main.dart`** — app entry point; initialises Flutter binding, wraps app in `ProviderScope` (Riverpod)
- **`lib/app/app.dart`** — root `MaterialApp` widget; defines initial route

## Core Modules / Features

Three screen-level features are implemented as skeletal scaffolds:

| Feature | File | Purpose |
|---|---|---|
| Setup | `lib/features/setup/setup_screen.dart` | Course/player setup before a round |
| Shot Capture | `lib/features/shot_capture/shot_capture_screen.dart` | In-round shot tracking UI |
| Round Review | `lib/features/round_review/round_review_screen.dart` | Post-round summary/review |

All remaining feature directories (`wearable/`) and service directories (`gps/`, `voice/`, `share/`) are empty placeholders.

## Shared / Common Code

- `lib/app/constants.dart` — central constants file (API base URL, API key)
- `lib/core/` — intended location for shared widgets, utils, and extensions; currently all empty
- `lib/theme/` — intended app theme definition; currently empty

## Assets & Resources

- `assets/` directory declared in project but contains no files

## Configuration Files

| File | Purpose |
|---|---|
| `pubspec.yaml` | Dart/Flutter dependencies and asset declarations |
| `analysis_options.yaml` | Dart linter rules (extends `flutter_lints`) |
| `android/app/build.gradle` | Android build config (currently using debug signing for release) |
| `brdy01.iml` | IntelliJ module file |
