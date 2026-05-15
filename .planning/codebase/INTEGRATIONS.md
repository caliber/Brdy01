# Integrations

## External APIs & Services

- **Golf Course API** — `https://api.golfcourseapi.com/v1`
  - Authenticated via compile-time `--dart-define=GOLF_API_KEY=<value>`
  - Client located in `lib/data/remote/api/`
  - HTTP transport via Dio + Retrofit code generation

## Authentication Providers

- None — no Firebase Auth, Supabase, or OAuth integration present

## Database / Storage

- **Drift (SQLite)** — `lib/data/local/database/`
  - Stores rounds, holes, and shots (relational local data)
- **Hive** — key-value boxes for:
  - `player_prefs` — user preferences
  - `course_cache` — cached course data

## Analytics & Monitoring

- None — only local `logger` package for debug logging; no crash reporting or analytics SDK

## Cloud Infrastructure

- None — fully client-side app with no backend infrastructure

## Third-party SDKs

- `OpenStreetMap` tiles — map rendering, no API key required
- `geolocator` — device GPS location
- `speech_to_text` — voice input
- `flutter_tts` — text-to-speech output
- `haptic_feedback` — device haptics
- `wear_plus` — Wear OS / watchOS companion support
- `share_plus` — native share sheet
- `screenshot` — capture widget as image
- `permission_handler` — runtime permission management
- `google_fonts` — font loading

## Environment Variables / Config

- `GOLF_API_KEY` — passed at build time via `--dart-define`; not stored in `.env`
- All other configuration hardcoded in `lib/app/constants.dart`
- No `.env` file present
