# BRDY.01

## What This Is

BRDY.01 is a Flutter golf shot-tracking app for strokeplay rounds. A golfer sets up a round by entering their handicap index and loading a course from the Golf Course API, records outcomes hole by hole on the Shot Capture screen (with per-hole stats, GPS shot pinning, and voice commands), then reviews a full scorecard and stat summary on Round Review. Local-only, no accounts, no sync. Wear OS companion shows score buttons on the wrist.

## Core Value

A golfer finishes a hole, taps one button, and the round stays accurate — frictionless hole-by-hole scoring on the course.

## Requirements

### Validated

(None yet — scaffold only; architecture and tech stack established but no features shipped)

### Active

**Setup**
- [ ] User can enter handicap index (numeric input, stored in Hive)
- [ ] User can search for a golf course by name via golfcourseapi.com API
- [ ] User can load a course (stores: name, Course Rating, Slope, hole-by-hole par, GPS layout, metadata)
- [ ] Loaded course is cached locally in Hive for offline use

**Shot Capture**
- [ ] User can record hole outcome per hole: BIRDIE / PAR / BOGEY / DOUBLE / PICKUP
- [ ] User can record putts per hole (counter)
- [ ] User can toggle fairway hit per hole (N/A on par 3s)
- [ ] User can toggle GIR (Green in Regulation) per hole
- [ ] User can drop GPS shot pins on the map overlay (stored, not used in scoring)
- [ ] User can record hole outcome by voice command ("birdie", "par", "bogey", "double", "pickup")
- [ ] Round progresses hole by hole (1–18); current hole is always visible
- [ ] User can navigate back to a previous hole to correct an entry

**Round Review**
- [ ] User sees a full scorecard (all 18 holes, outcome + putts per hole)
- [ ] User sees stat cards: total strokes, score vs par, birdies, eagles, pars, bogeys, doubles, triples, pickups, total putts, GIR count, fairways hit
- [ ] User sees WHS differential for this round: (Adjusted Gross Score − Course Rating) × 113 ÷ Slope
- [ ] User can share/export the scorecard (native share sheet)
- [ ] User can start a new round (returns to Setup, clears current round)

**Wear OS**
- [ ] Wear OS companion shows score buttons (BIRDIE / PAR / BOGEY / DOUBLE / PICKUP) for the current hole
- [ ] Score entry on watch syncs outcome to phone

### Out of Scope

- User accounts / authentication — local-only by design; no server needed
- Cloud sync or backup — local data only; simplicity over continuity
- Round history / past-round review — single round at a time; no list screen
- Multi-round WHS handicap projection — uses manual handicap index; no stored differentials
- Shot-by-shot stroke counting as primary model — outcome buttons are primary; GPS pins are optional
- Stableford or match play — strokeplay only
- Multiplayer / group scoring — solo golfer tool
- Full voice dictation (stats, navigation) — voice is score entry only
- Wear OS GPS, voice, or stat toggles — watch is score buttons only

## Context

**Existing scaffold**: Three screen classes exist (`setup_screen.dart`, `shot_capture_screen.dart`, `round_review_screen.dart`) with correct Clean Architecture directory layout (features / domain / data / infrastructure / services). All layers are empty — no models, no repositories, no providers, no API client implementation. Architecture intent is established but nothing is wired up.

**GPS and maps**: `geolocator` for device location, `flutter_map` (OpenStreetMap) for the map overlay. Golf Course API provides hole GPS coordinates for the overlay. Shot pins are user-placed, stored in Drift, not used in scoring.

**Voice input**: `speech_to_text` package. Commands are a fixed vocabulary: "birdie", "par", "bogey", "double", "pickup". No NLP — direct token match.

**WHS differential**: Requires Course Rating and Slope from the Golf Course API. Formula: (Adjusted Gross Score − Course Rating) × 113 ÷ Slope. Adjustments for pickups follow ESC (Equitable Stroke Control) rules — pickup holes are counted as net double bogey for the differential calculation.

**Wear OS**: `wear_plus` is already declared. Companion app shows current hole score buttons only; syncs to phone via `wear_plus` data layer.

**Design system**: Brutalist monospace aesthetic. Orange `#E8520A` accent, black/off-white surfaces. JetBrains Mono for all numerics (scores, stats, distances). Barlow Condensed for labels and buttons. High contrast, minimal chrome.

**Course caching**: Courses loaded from the API are cached in Hive with a `course_cache` box. API key passed via `--dart-define=GOLF_API_KEY=<value>` at build time.

## Constraints

- **Tech Stack**: Flutter, Dart, Riverpod (state), Drift/SQLite (round data), Hive (prefs + course cache), go_router (navigation), Dio + Retrofit (API), flutter_map (map), geolocator, speech_to_text, wear_plus — no additions without explicit decision
- **Data**: Local only — no Firebase, no Supabase, no REST backend. Data lives on device.
- **Platforms**: iOS and Android primary. Wear OS companion (Android only).
- **Strokeplay only**: No other game formats. Keeps scoring model simple.
- **Single active round**: No round history stored. No list screen. Simplifies data model and UX surface.
- **Build config**: `GOLF_API_KEY` must be passed via `--dart-define`. No `.env` file.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Outcome buttons as primary recording model | Fastest interaction on the course; most golfers think in outcomes not stroke counts | — Pending |
| Manual handicap index, single-round differential only | No account required; no history needed; simpler data model | — Pending |
| GPS shot pins optional / not used in scoring | Adds visual richness without complicating the core scoring model | — Pending |
| Voice commands: fixed vocabulary only | Reliable on-course recognition; avoids NLP complexity and mis-fires | — Pending |
| Wear OS: score buttons only | Most useful watch action is quick score entry; GPS + voice on watch = complexity without gain | — Pending |
| Course data cached in Hive | Courses don't change; offline-first for on-course use | — Pending |
| ESC-adjusted score for WHS differential | Pickup holes need a score for the differential; net double bogey is WHS standard | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-16 after initialization*
