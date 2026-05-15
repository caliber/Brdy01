# Research Summary — BRDY.01

**Project:** BRDY.01 Flutter Golf Shot Tracking App
**Domain:** Mobile sports tracking, local-first, Wear OS companion
**Researched:** 2026-05-16
**Confidence:** HIGH (stack + architecture + pitfalls from codebase-confirmed sources); MEDIUM (wear_plus patterns, voice outdoor behaviour)

---

## Stack Recommendation

The locked stack is appropriate and well-matched to the domain. No package swaps are recommended. Version gotchas to act on before Phase 1:

| Package | Version | Gotcha |
|---|---|---|
| `flutter_riverpod` | 2.x | Use `@riverpod` code-gen throughout — never hand-write `Provider(...)` boilerplate |
| `drift` | 2.x | Requires `drift_dev` + `build_runner` as dev deps; commit `*.g.dart`; set up `MigrationStrategy` from v1 |
| `go_router` | 13.x | Use `context.go()` everywhere — `context.push()` creates a back-stack that allows invalid mid-round navigation |
| `dio` + `retrofit` | 5.x + 4.x | `connectTimeout`/`receiveTimeout` take `Duration` not `int`; retrofit version must match retrofit_generator exactly |
| `geolocator` | 12.x | `LocationSettings` replaces old `LocationAccuracy` API; behaviour changes frequently — verify against current changelog |
| `wear_plus` | 3.x | Pin to a tested version and upgrade deliberately; emulator Bluetooth pairing is unreliable |
| `flutter_map_tile_caching` | current | Dead dependency in scaffold — never imported or initialised; fix this in Phase 1 setup |
| `speech_to_text` | 6.x | Call `initialize()` once at app start; Android requires network on most devices |

**One mandatory fix before Phase 1:** `flutter_map_tile_caching` is in pubspec but never imported or initialised. Without it, all maps are grey on-course. Initialise in `main()` before `runApp()`.

---

## Table Stakes Features

Golfers will expect these whether or not they are in the current spec. All are low complexity:

- **Running total vs par on every hole screen** — every competitor shows +/- at all times; omitting it feels unfinished. Show on Shot Capture, not just Round Review.
- **Per-hole par display on Shot Capture** — golfers need the par to understand which outcome button to tap. One text widget, high value.
- **Front 9 / Back 9 subtotals in Round Review** — standard paper scorecard format; golfers scan for these automatically.
- **Net score display** — recreational golfers play off handicap; they want net alongside gross in Round Review.
- **Stroke Index (SI) display** — golfers know which holes their handicap strokes fall on; also required for correct WHS pickup scoring.

**Critical gap: The 5-button model cannot record eagles.** A 2 on a par 4 would be recorded as BIRDIE — permanently wrong data. The architecture research has already added `eagle` as ordinal 0 in `HoleOutcome`. Recommend adding an EAGLE button as part of Shot Capture screen design. This decision must be made before Shot Capture UI is implemented — a 6th button later requires a full layout rework.

---

## Differentiators

The BRDY.01 vision holds up strongly against competitor analysis. These are genuine differentiators:

| Differentiator | Verdict | Notes |
|---|---|---|
| Brutalist design (orange/black/JetBrains Mono) | Confirmed strong | No competitor uses this aesthetic; outdoor contrast is a functional advantage, not just style |
| No account required, ever | Confirmed strong | 18Birdies, Golfshot, Arccos all have account friction; genuinely rare |
| Zero subscription | Confirmed strong | Every major competitor has a premium tier |
| Voice score entry (fixed-vocabulary) | Confirmed viable with caveats | No major competitor does fixed-vocab voice; Android network dependency is the limiting risk |
| Wear OS on existing hardware | Confirmed strong | Shot Scope requires proprietary hardware; BRDY.01 works on any Wear OS watch |
| GPS pin cloud as round artefact | Confirmed novel | Not used for measurement — a visual story of the round; genuinely unique angle |
| WHS differential shown immediately | Confirmed | Competitors bury this or require posting via their platform |

**What to de-risk:** Voice on Android. Most Android devices require network for speech recognition. Design the offline fallback (greyed mic, clear "Voice unavailable" message) alongside the feature — not as a follow-up.

---

## Key Architecture Decisions

The roadmapper must carry these five decisions into every phase:

1. **Active round providers must be `keepAlive: true`.**
   `activeRoundIdProvider`, `activeHoleIndexProvider`, and all infrastructure providers must never auto-dispose. Auto-dispose resets hole index and round ID on screen transitions — the round is lost. Screen-scoped providers auto-dispose normally.

2. **Write-through persistence — every score entry writes to Drift immediately.**
   Never accumulate round state in Riverpod alone. OS can kill the app at any time during a 4-hour round. The pattern: tap outcome → update provider optimistically → write to Drift in the same operation → Drift stream rebuilds UI. If Drift write is omitted, data loss on Android low-RAM devices is guaranteed.

3. **Hole navigation is internal state, not routes.**
   Shot Capture is a single `go_router` route. Navigating between holes 1–18 is a `StateProvider` change (`activeHoleIndexProvider`), not a `context.push()`. This avoids an 18-level back-stack. Back button on Shot Capture is intercepted by `PopScope` with an "abandon round?" dialog.

4. **Course data in Hive, round data in Drift — no mixing.**
   Course cache (API responses, search results) lives in Hive because courses are immutable reference data with no transactional requirements. Round data (scores, shot pins) lives in Drift because it is transactional and crash-safety is required. Rating/slope are denormalised onto the Round row to keep it self-contained for WHS calculation.

5. **Crash recovery via `appStartupProvider` + router redirect.**
   On cold start, `appStartupProvider` queries Drift for any round where `completedAt IS NULL`. If found, it rehydrates `activeRoundIdProvider` and advances `activeHoleIndexProvider` to the last scored hole + 1. The `go_router` redirect sends the golfer back to Shot Capture. Without this, any OS kill during a round drops the golfer on the Setup screen — feels like data loss even when no data is lost.

---

## Critical Pitfalls

Ranked by severity. Top four confirmed by codebase analysis.

1. **No Drift migrations boilerplate at v1 — crashes every existing install on first schema change.**
   Set up `MigrationStrategy` and `drift_schemas/` at v1, before writing the first table. Never change a `Table` class without bumping `schemaVersion` in the same commit. HIGH confidence.

2. **`flutter_map_tile_caching` is a dead dependency — maps will be grey on-course.**
   In pubspec but never imported or initialised. Without it, OSM tiles require network. Golf courses have poor connectivity. Initialise in `main()` and pre-cache course tiles on course selection. HIGH confidence (confirmed in CONCERNS.md).

3. **Riverpod state lost on OS kill — data loss during a 4-hour round.**
   Write-through to Drift on every score entry. No batching, no deferred writes. On any low-RAM Android device, the OS can reclaim memory within minutes of backgrounding. HIGH confidence (canonical Flutter lifecycle problem).

4. **iOS Info.plist missing all three privacy strings — app crashes on first launch.**
   `NSLocationWhenInUseUsageDescription`, `NSMicrophoneUsageDescription`, and `NSSpeechRecognitionUsageDescription` must be added in a single pass before any GPS or voice work. Missing one is enough to crash. HIGH confidence (confirmed in CONCERNS.md).

5. **Debug keystore in release builds — blocks Play Console, TestFlight, and Wear OS Data Layer.**
   `android/app/build.gradle` has two TODO entries pointing to the debug keystore. Generate a release keystore before any distribution attempt. Wear OS Data Layer requires matching signing keys — Wear OS cannot be implemented without this resolved first.

6. **WHS pickup formula wrong without Stroke Index (SI) per hole.**
   `pickup = par + 2 + handicap_strokes_on_hole` — not `par + 2`. Getting this wrong produces a systematically incorrect differential for every golfer who picks up. Verify Golf Course API returns SI before implementing pickup scoring. Define `calculateCourseHandicap()` and `calculateDifferential()` as domain functions with unit tests before any UI. HIGH confidence (WHS rules are precisely specified post-2020).

7. **Android voice requires network; no user feedback when unavailable.**
   On most non-Pixel Android devices, `speech_to_text` delegates to Google cloud. On-course with poor signal, the recogniser fires `SpeechStatus.done` with empty result — no error, no feedback, silent failure. Show a clear "Voice unavailable" state. Outcome buttons must always be the primary path. MEDIUM confidence.

---

## Build Order Recommendation

Six phases from architecture research. The ordering is dependency-driven and should be adopted as-is.

**Phase 1 — Foundation (no UI)**
Domain models (Freezed), Drift schema + DAO, Hive wrappers, Retrofit client + DTOs, repository implementations, infrastructure providers, go_router with crash-recovery redirect, `appStartupProvider`, `flutter_map_tile_caching` initialisation, Drift migration boilerplate.
_Why first:_ Write-through persistence and crash recovery are architecture decisions — not retrofits. Everything downstream depends on this.
_Research flag:_ Verify Golf Course API SI response schema with a live API call before implementing pickup scoring.

**Phase 2 — Setup Screen**
Course search UI, handicap input, course selection, round creation, tile pre-caching trigger.
_Why second:_ Simplest screen; exercises API integration, Hive caching, and provider graph end-to-end. De-risks API data quality (missing Rating/Slope, missing SI) before Shot Capture depends on it.
_Research flag:_ Verify golfcourseapi.com rate limits; test with NZ courses specifically to confirm data completeness.

**Phase 3 — Shot Capture Screen**
Outcome buttons (eagle/5-button decision finalised first), putts + toggles, hole navigation, auto-advance, undo toast, GPS shot pins, flutter_map overlay, voice commands.
_Why third:_ Core value screen; most complex; must be built on stable foundation from Phases 1-2. GPS, voice, and map are independent sub-features that can be added incrementally.
_Pitfall gates:_ Add all AndroidManifest + Info.plist permissions before first GPS or voice line. Design offline voice fallback alongside the feature. Undo toast is non-optional for outdoor reliability.

**Phase 4 — Round Review Screen**
`roundSummaryProvider`, `whsDifferentialProvider`, scorecard grid, stat cards, share/export, new round reset.
_Why fourth:_ Consumes data from Phases 1-3; no new infrastructure. WHS domain functions should have been unit-tested in Phase 1.
_Pitfall gate:_ Validate all 18 holes recorded before computing differential. Guard against missing/zero Rating or Slope (display "N/A" with explanation).

**Phase 5 — Wear OS Companion**
Release signing (prerequisite, must be done first), WearSyncService, message protocol, watch-side Flutter entry point, score button UI, physical hardware end-to-end test.
_Why fifth:_ Highest-risk integration; must not block shipping the phone app. Release keystore is a gate — cannot start without it.
_Research flag:_ Verify `wear_plus` version compatibility with current Flutter before starting. Physical Wear OS hardware required — emulator pairing is unreliable.

**Phase 6 — Polish**
Offline detection gate in Setup, FMTC download progress UX, error states on all `AsyncValue` providers, haptic feedback, micro-animations, outdoor sunlight physical device testing.
_Why last:_ Assumes all features stable; focuses on edge cases and sensory quality.

**Eagle/5-button decision:** Must be made at the start of Phase 3. The Drift schema already supports eagle (ordinal 0 in `HoleOutcome`). The Shot Capture UI must be designed for 6 buttons from the start — adding one later requires a full layout rework.

---

## Open Questions

Unresolved items that affect planning decisions:

1. **Does golfcourseapi.com return Stroke Index per hole?** Required for correct pickup scoring and net score display. Verify with a live API test in Phase 1. If absent, design a manual SI fallback or document the limitation clearly.

2. **Eagle button — 5 or 6 outcomes?** The 5-button model silently records eagles as birdies (permanent data loss). The schema already supports eagle. Recommendation: add EAGLE button. Decide before Phase 3 begins.

3. **Android offline voice — ship as first-class or with caveat?** Test with airplane mode on a non-Pixel Android device before committing. If offline recognition is unreliable, ship with prominent "Voice unavailable" state.

4. **Net score display in Round Review?** Not in spec but golfers expect it. Low complexity. Recommend adding to Phase 4 scope.

5. **Incomplete round differential — block or label?** WHS requires 7+ holes for official posting. Recommendation: display indicative differential with "7+ completed holes required for official WHS posting" label. Do not block scorecard sharing.

6. **golfcourseapi.com rate limits?** Not publicly documented. Verify before shipping search UI. Hive search caching (already designed) acts as a buffer.

---

## Watch Out For

The three most likely project killers:

**1. Data loss on Android mid-round.**
The OS kills backgrounded apps on low-RAM devices. If a single score entry ever lives in Riverpod without being flushed to Drift, a golfer will lose their round. Write-through persistence is an architecture decision — build it in Phase 1 or spend Phase 3-4 retrofitting it under pressure.

**2. Grey maps on-course because tile caching was never wired up.**
`flutter_map_tile_caching` is in the pubspec and appears solved. It is not — it has never been imported or initialised. Pre-caching tiles on course selection is the only way to guarantee a visible map mid-round. Without it, the GPS pin feature (a key differentiator) is invisible on most courses.

**3. Wrong WHS handicap differential shipped to users.**
The pickup formula, Course Handicap vs Handicap Index distinction, and the net double bogey cap are precisely specified by USGA/R&A post-2020. "ESC" referenced in some project docs is a pre-2020 concept — do not use it in code or UI labels. Write unit tests for the domain functions before building any UI. Getting any one piece wrong produces a systematically incorrect differential for every round.

---

## Confidence Assessment

| Area | Confidence | Notes |
|---|---|---|
| Stack | HIGH | All packages confirmed in codebase; version gotchas well-documented |
| Features | HIGH | WHS rules are USGA/R&A published; competitor UX from training data (Aug 2025 cutoff) |
| Architecture | HIGH | Riverpod 2.x + Drift 2.x + go_router 13.x patterns are stable and well-documented |
| Pitfalls (platform) | HIGH | Confirmed by codebase CONCERNS.md references |
| Pitfalls (runtime) | MEDIUM | Voice/GPS outdoor behaviour from community reports; test on physical hardware |
| Wear OS | MEDIUM | `wear_plus` API patterns inferred; verify against current pub.dev before Phase 5 |

**Overall confidence: HIGH for Phases 1-4; MEDIUM for Phase 5 (Wear OS)**

### Gaps to Address

- **Golf Course API SI field:** Verify in Phase 1 before pickup scoring is implemented.
- **Android offline speech:** Test on physical non-Pixel Android with airplane mode before shipping voice.
- **`flutter_map_tile_caching` current API:** Verify initialisation pattern against current pub.dev before Phase 3.
- **`wear_plus` Flutter compatibility:** Check before Phase 5 begins. Pin to a tested version.
- **NZ course data quality:** Developer is based in New Zealand. Test several NZ courses in Phase 2 for Rating, Slope, and SI completeness — NZ Golf is R&A-affiliated but individual course submission to third-party APIs is inconsistent.

---

## Sources

### Primary (HIGH confidence)
- USGA Rules of Handicapping (2020, current) — WHS differential formula, net double bogey cap, Course Handicap calculation
- Riverpod 2.x official documentation — code-gen patterns, keepAlive semantics, auto-dispose behaviour
- Drift 2.x official documentation — schema design, DAO patterns, MigrationStrategy, SchemaVerifier
- go_router 13.x official documentation — redirect callbacks, GoRoute, context.go() vs context.push()

### Secondary (MEDIUM confidence)
- flutter_map + geolocator community patterns — GPS distanceFilter, tile caching, permission flows
- speech_to_text community reports — Android network dependency, confidence threshold, hold-to-speak pattern
- Competitor UX analysis (18Birdies, Arccos, Golfshot, Shot Scope) — training data, cutoff Aug 2025

### Tertiary (verify before use)
- golfcourseapi.com response schema — SI per hole, rate limits; verify with live API test in Phase 1
- wear_plus 3.x message API — verify against current pub.dev before Phase 5
- flutter_map_tile_caching initialisation API — verify against current pub.dev before Phase 3

---

*Research completed: 2026-05-16*
*Ready for roadmap: yes*
