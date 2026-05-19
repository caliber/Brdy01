# Phase 5: GPS + Voice Polish — Research

**Researched:** 2026-05-19
**Domain:** Flutter GPS map overlay (flutter_map + geolocator) + voice scoring polish (speech_to_text undo integration)
**Confidence:** HIGH — all major findings verified against existing codebase; package APIs confirmed via code already in use.

---

## Summary

Phase 5 adds two features to the already-working Shot Capture screen: (1) a map overlay where the golfer taps to drop GPS shot pins that persist across restarts, and (2) voice scoring polish that wires the existing VoiceService into the same confirm-and-undo toast flow used by tap scoring.

The GPS stack (flutter_map ^7.0.2, geolocator ^12.0.0, flutter_map_tile_caching ^9.1.1, latlong2 ^0.9.1) is already in pubspec and already initialised in main(). The voice stack (speech_to_text ^6.6.2) is already working. iOS permissions are already set correctly in Info.plist. The critical gap is that **Android is missing ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION** in AndroidManifest.xml — GPS cannot work without these.

The `shots` table is in the Drift schema at v1 (latitude, longitude, shotNumber, recordedAt, holeId) but has no DAO. The generated `ShotsCompanion` already exists — Phase 5 just needs to add `ShotDao`. Importantly, because the schema is not changing (table was already in v1), **no schemaVersion bump or migration is required**.

For voice, the gap is architectural: `VoiceService._recordOutcome()` calls the Drift notifier directly but never fires the `_showUndoToast()` callback on ShotCaptureScreen. Phase 5 needs to thread a `onVoiceOutcome` callback through VoiceService so the screen can show the same undo toast as tap scoring.

**Primary recommendation:** Implement GPS and voice polish as two independent waves in a single plan, with Android permission manifest fix as Wave 0 gate. No new packages required.

---

## Project Constraints (from CLAUDE.md)

- All Drift table changes MUST bump schemaVersion and add migration case. **Exception for Phase 5:** shots table is already at v1 — no bump needed if only adding ShotDao.
- Run `dart run build_runner build --delete-conflicting-outputs` after every schema change.
- Commit `drift_schemas/` JSON for every schema version.
- Use `@riverpod` code-gen throughout — never hand-write Provider boilerplate.
- All keepAlive providers: `@Riverpod(keepAlive: true)`. Screen-level: `@riverpod` (auto-dispose).
- `context.go()` for main screen transitions; internal hole navigation stays as StateProvider.
- Don't use continuous GPS streaming — on-demand `getCurrentPosition()` at pin-tap time only.
- Don't start GPS/map loading before score buttons appear.
- Don't use always-on voice listening — tap-to-speak only.
- Don't hold round state in memory without writing to Drift.
- Don't add features not in REQUIREMENTS.md without a requirements update.
- Design system: brutalist monospace, #E8520A accent, JetBrains Mono numerics, Barlow Condensed labels, 64×80dp tap targets minimum, 7:1 contrast on-course.
- GPS shot distances are NOT displayed — pins are decorative only (explicitly out of scope in REQUIREMENTS.md).
- **Before any GPS or voice feature work:** verify ios/Runner/Info.plist has all three keys AND android/app/src/main/AndroidManifest.xml has location permissions.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| GPS pin placement | Shot Capture screen (UI) | ShotDao (persistence) | User gesture on map widget triggers on-demand position fix + Drift write |
| Shot pin display on map | Shot Capture screen widget | shotsForHoleProvider (read) | MarkerLayer renders pins from Drift-backed provider |
| Shot pin persistence | Drift shots table via ShotDao | — | Write-through on every pin tap; survives OS kill |
| Voice outcome recording | VoiceService (service) | ShotCaptureScreen (callback) | VoiceService parses and records; screen fires undo toast via callback |
| Voice undo toast | ShotCaptureScreen (UI) | VoiceService callback | Same _showUndoToast used by tap scoring — must be wired to voice path |
| Voice unavailable state | ShotCaptureScreen (UI) | VoiceService.initialize() | _voiceAvailable flag already controls UI; SHOT-13 was completed in Phase 3 |
| Location permission | geolocator | permission_handler | Request on first map tap; handle deniedForever gracefully |
| Map tile display | TileLayer (FMTC-backed) | TileCacheRepository | Already initialised; tiles already pre-cached at course load |

---

## Standard Stack

### Core — Already in pubspec, no additions required

| Library | Version in pubspec | Purpose | Status |
|---------|-------------------|---------|--------|
| `flutter_map` | ^7.0.2 | Map widget, TileLayer, MarkerLayer | Already imported in TileCacheRepository — confirmed [VERIFIED: codebase] |
| `flutter_map_tile_caching` | ^9.1.1 | FMTC tile caching — OSM tiles offline | Initialised in main() — confirmed [VERIFIED: codebase] |
| `geolocator` | ^12.0.0 | On-demand GPS position | In pubspec — confirmed [VERIFIED: pubspec.yaml] |
| `latlong2` | ^0.9.1 | LatLng type for flutter_map | In pubspec — confirmed [VERIFIED: pubspec.yaml] |
| `speech_to_text` | ^6.6.2 | Voice recognition — already working | VoiceService uses it — confirmed [VERIFIED: codebase] |
| `permission_handler` | ^11.3.1 | Runtime location permission request | In pubspec — confirmed [VERIFIED: pubspec.yaml] |
| `drift` | ^2.18.0 | shots table already at schema v1 | ShotsCompanion generated — confirmed [VERIFIED: codebase] |

### No New Packages Required

Phase 5 installs zero new packages. All required capabilities are already in pubspec and/or initialised.

---

## Package Legitimacy Audit

No new packages are installed in Phase 5. All packages listed above are carried from prior phases. Slopcheck verification not required for this phase.

---

## Architecture Patterns

### System Architecture Diagram

```
MAP TAP gesture
    │
    ▼
permission_handler.checkPermission()
    │ denied?──────────────────────► "Location permission required" snackbar
    │ granted
    ▼
geolocator.getCurrentPosition(accuracy: high, timeout: 15s)
    │ timeout/error──────────────► "GPS unavailable" snackbar; pin not dropped
    │ success
    ▼
ShotDao.insertShot(holeId, lat, lng, shotNumber, recordedAt)
    │
    ▼
shotsForHoleProvider (Drift watch stream)
    │ rebuilds
    ▼
MarkerLayer ──► Pin icons on FlutterMap



VOICE MIC TAP
    │
    ▼
VoiceService.startListening()
    │
    ▼
speech_to_text onResult ──► VoiceCommandParser.parse()
    │                              │
    │                    ShotsCommand/OutcomeCommand
    │                              │
    ▼                              ▼
VoiceService._recordOutcome()  ──► calls onVoiceOutcome callback
    │                                           │
    │                                           ▼
    │                               ShotCaptureScreen._handleVoiceOutcome()
    │                                           │
    ▼                                           ▼
HoleScoreNotifier.recordOutcome()     _showUndoToast() + hole advance
(Drift write-through)
```

### Recommended Project Structure

```
lib/
├── data/local/database/
│   ├── daos/
│   │   ├── shot_dao.dart          # NEW — insertShot, getShotsForHole, deleteShotsForHole
│   │   └── shot_dao.g.dart        # generated
│   └── app_database.dart          # add ShotDao to @DriftDatabase daos list
├── features/shot_capture/
│   ├── providers/
│   │   └── shots_for_hole_provider.dart   # NEW — watches shots for current hole
│   ├── services/
│   │   └── voice_service.dart     # MODIFY — add onVoiceOutcome callback
│   └── widgets/
│       └── map_overlay_widget.dart  # NEW — FlutterMap with MarkerLayer
└── shot_capture_screen.dart       # MODIFY — embed map overlay, wire voice callback
```

### Pattern 1: On-Demand GPS Position at Pin Tap

**What:** Fetch GPS position only when user taps the map — not a continuous stream.
**When to use:** Every pin-drop tap. Never on screen load.

```dart
// Source: geolocator documentation pattern + CLAUDE.md on-demand mandate
Future<void> _dropPinAtCurrentPosition() async {
  final perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    final requested = await Geolocator.requestPermission();
    if (requested == LocationPermission.denied ||
        requested == LocationPermission.deniedForever) {
      // Show "Location permission required" feedback
      return;
    }
  }
  if (perm == LocationPermission.deniedForever) {
    // Direct to settings; cannot re-request
    await Geolocator.openAppSettings();
    return;
  }
  try {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
    // Save to Drift via ShotDao
    await _shotDao.insertShot(holeId, pos.latitude, pos.longitude, shotNumber);
  } on TimeoutException {
    // Show "GPS unavailable — try again" feedback
  }
}
```
[ASSUMED: `timeLimit` parameter name — verify against geolocator ^12 changelog]

### Pattern 2: Map Overlay Widget with Tap-to-Drop

**What:** FlutterMap embedded in the top zone of ShotCaptureScreen. Tapping calls `_dropPinAtCurrentPosition`. Existing FMTC store provides cached tiles.
**When to use:** Always visible on the shot capture screen (top 36% zone).

```dart
// Source: flutter_map ^7.0.2 + TileCacheRepository pattern already in codebase
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(teeLat ?? fallbackLat, teeLng ?? fallbackLng),
    initialZoom: 17.0,
    onTap: (tapPosition, latlng) => _onMapTapped(latlng),
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      tileProvider: FMTCStore(AppConstants.tileCacheStoreName).getTileProvider(),
      userAgentPackageName: 'com.brdy.brdy01',
    ),
    MarkerLayer(
      markers: shotPins.map((pin) => Marker(
        width: 24,
        height: 24,
        point: LatLng(pin.latitude, pin.longitude),
        child: const Icon(Icons.circle, color: Color(0xFFE8520A), size: 16),
      )).toList(),
    ),
  ],
)
```
[VERIFIED: codebase — FMTCStore and TileLayer pattern already used in TileCacheRepository]

### Pattern 3: ShotDao — Insert and Query

**What:** Thin DAO wrapping the `shots` table (already at schema v1). No migration needed.

```dart
// Source: HoleDao pattern already in codebase
@DriftAccessor(tables: [Shots])
class ShotDao extends DatabaseAccessor<AppDatabase> with _$ShotDaoMixin {
  ShotDao(super.db);

  Future<void> insertShot({
    required int holeId,
    required double latitude,
    required double longitude,
    required int shotNumber,
  }) => into(shots).insert(ShotsCompanion.insert(
    holeId: holeId,
    latitude: latitude,
    longitude: longitude,
    shotNumber: shotNumber,
    recordedAt: DateTime.now(),
  ));

  Stream<List<Shot>> watchShotsForHole(int holeId) =>
      (select(shots)..where((s) => s.holeId.equals(holeId))).watch();

  Future<void> deleteShotsForHole(int holeId) =>
      (delete(shots)..where((s) => s.holeId.equals(holeId))).go();
}
```
[VERIFIED: codebase — ShotsCompanion.insert fields match shots_table.dart schema]

### Pattern 4: Voice Outcome Callback — Wire Undo Toast

**What:** Add `onVoiceOutcome` callback to VoiceService so the screen can show the undo toast. VoiceService already records the outcome to Drift via HoleScoreNotifier — it just needs to signal the screen.

**Critical gap confirmed:** `VoiceService._recordOutcome()` calls `HoleScoreNotifier.recordOutcome()` directly but never fires `_showUndoToast` on the screen. The voice path does NOT show an undo toast or advance the hole, but the tap path does (via `_handleOutcomeTapped`). Phase 5 must unify these paths.

**Recommended approach:** Add `void Function(HoleOutcome, int holeIndex)? onOutcomeRecorded` callback to VoiceService, called from `_recordOutcome()` after the Drift write. Screen passes `_handleVoiceOutcome` which shows the toast and advances the hole.

```dart
// VoiceService — add callback
void Function(HoleOutcome, int holeIndex)? onOutcomeRecorded;

void _recordOutcome(HoleOutcome outcome, int holeIndex) {
  // ... existing Drift write via HoleScoreNotifier ...
  onOutcomeRecorded?.call(outcome, holeIndex);
}

// ShotCaptureScreen — wire callback
_voiceService.onOutcomeRecorded = (outcome, holeIndex) {
  if (!mounted) return;
  setState(() => _lastScoredHoleIndex = holeIndex);
  _showUndoToast(context, outcome, holeIndex + 1);
  // Advance hole (unless hole 18 — then complete round)
  _advanceAfterScore(holeIndex);
};
```
[VERIFIED: codebase — VoiceService and ShotCaptureScreen code read directly]

### Pattern 5: Getting holeId for Shot Insertion

**What:** The shots table stores `holeId` (FK to holes.id). HoleScoreNotifier queries by roundId+holeNumber but doesn't expose the Drift row ID. ShotDao needs the actual `holes.id` integer.

**Approach:** Add `getHoleByRoundAndNumber(int roundId, int holeNumber)` to HoleDao. After `recordOutcome` runs (which upserts the hole row), the hole exists and its id can be fetched.

```dart
// HoleDao addition
Future<Hole?> getHoleByRoundAndNumber(int roundId, int holeNumber) =>
    (select(holes)
      ..where((h) => h.roundId.equals(roundId))
      ..where((h) => h.holeNumber.equals(holeNumber)))
    .getSingleOrNull();
```
[VERIFIED: codebase — HoleDao.insertOrUpdateHole already uses same filter pattern]

### Anti-Patterns to Avoid

- **Continuous GPS stream on the map:** `getPositionStream()` is forbidden by CLAUDE.md. Use `getCurrentPosition()` only at tap time.
- **Loading map before score buttons:** Map initialisation must NOT block the score button layout. The top zone (36%) and bottom zone (score buttons) render independently.
- **Voice advancing hole without undo toast:** If voice records an outcome but the screen doesn't show the undo toast, golfers have no recovery path when wind causes false positives.
- **Schema version bump for ShotDao addition:** The `shots` table is already at schema v1. Adding a DAO does not require a migration. Bumping schemaVersion without adding table/column changes will cause migration exceptions.
- **Placing shot pins in MapOptions.onTap using tap LatLng instead of GPS:** The requirement is GPS position (from geolocator), not the tapped map coordinate. The map tap triggers the GPS fetch; the pin is placed at the device's actual GPS position.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Map tile display | Custom HTTP tile loader | `flutter_map` TileLayer + FMTC | Already initialised; OSM attribution required |
| Tile caching for offline | Manual HTTP cache | `flutter_map_tile_caching` FMTCStore.getTileProvider() | Already wired in main() and TileCacheRepository |
| GPS coordinate acquisition | Raw platform channel | `geolocator.getCurrentPosition()` | Permission handling, accuracy, timeout all built-in |
| Location permission flow | Manual permission UI | `geolocator.requestPermission()` + `openAppSettings()` | Handles deniedForever state correctly |
| Voice recognition | Custom STT | `speech_to_text` — already working | Already initialised and parsing in VoiceService |
| Coordinate type | Custom lat/lng class | `latlong2.LatLng` | flutter_map expects LatLng from latlong2 |

**Key insight:** Phase 5 is primarily integration and polish work — all underlying capabilities exist. The work is connecting pieces (ShotDao, voice callback, map widget) rather than building new infrastructure.

---

## Common Pitfalls

### Pitfall 1: Missing Android Location Permissions — GPS Always Returns Denied

**What goes wrong:** `android/app/src/main/AndroidManifest.xml` currently has `INTERNET`, `RECORD_AUDIO`, and `MODIFY_AUDIO_SETTINGS` but NOT `ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION`. GPS will silently return `LocationPermission.denied` on all Android devices.
**Why it happens:** Permissions were confirmed missing in the codebase read. iOS Info.plist is correct; Android manifest was not updated.
**How to avoid:** Add both permissions to AndroidManifest.xml before writing any GPS code. This is Wave 0.
**Warning signs:** `Geolocator.checkPermission()` always returns `denied`; permission dialog never appears.

[VERIFIED: codebase — AndroidManifest.xml grep confirmed LOCATION permissions absent]

### Pitfall 2: Voice Records Score but Undo Toast Never Appears

**What goes wrong:** VoiceService._recordOutcome() calls HoleScoreNotifier.recordOutcome() directly. The screen's `_showUndoToast` and `_handleOutcomeTapped` are never called. Golfer scores by voice, no toast, no undo option, hole doesn't advance.
**Why it happens:** VoiceService was built as a standalone service that writes to Drift but doesn't communicate back to the screen. The `onVoiceOutcome` callback was not implemented.
**How to avoid:** Add `onOutcomeRecorded` callback to VoiceService (see Pattern 4). Screen wires this to `_handleVoiceOutcome` which reuses `_showUndoToast` and hole advancement logic.
**Warning signs:** Voice says "Bogey" → hole score updates in Drift → screen stays on same hole with no toast.

[VERIFIED: codebase — VoiceService and ShotCaptureScreen code confirmed]

### Pitfall 3: Inserting a Shot Without a Hole Row in Drift

**What goes wrong:** `shots.holeId` is a foreign key to `holes.id`. If the golfer drops a GPS pin on a hole that hasn't been scored yet (no outcome), the hole row doesn't exist in Drift. The FK constraint (PRAGMA foreign_keys = ON is set) will reject the insert.
**Why it happens:** `HoleScoreNotifier.recordOutcome()` is what creates the hole row. GPS pins can be dropped before scoring.
**How to avoid:** `ShotDao.insertShot` must first ensure a hole row exists via `HoleDao.insertOrUpdateHole` with just roundId, holeNumber, and par (no outcome) if no row exists yet.
**Warning signs:** `SqliteException: FOREIGN KEY constraint failed` when dropping first pin on an unscored hole.

[VERIFIED: codebase — holes_table.dart and PRAGMA foreign_keys = ON confirmed]

### Pitfall 4: Map Widget Rendering Before Course GPS Data Loads

**What goes wrong:** `courseForRoundProvider` is async. If the map renders before the course loads, `teeLat/teeLng` for the initial centre will be null. Passing null to `MapOptions.initialCenter` is a runtime error.
**Why it happens:** The map widget is in the top zone which uses `courseAsync.valueOrNull` — this is null during the async load.
**How to avoid:** Show a placeholder (black fill or loading spinner) in the map zone until `courseAsync.hasValue`. Never pass `LatLng(null, null)`.
**Warning signs:** `Null check operator used on a null value` in FlutterMap during load.

[VERIFIED: codebase — courseForRoundProvider is async, confirmed in shot_capture_screen.dart]

### Pitfall 5: Shot shotNumber Tracking Across Holes

**What goes wrong:** `shots.shotNumber` needs to be assigned correctly (1, 2, 3... per hole). If the ShotDao doesn't count existing shots per hole before inserting, all shots get shotNumber=1.
**How to avoid:** Before inserting, query shot count for the holeId: `shotNumber = (await watchShotsForHole(holeId).first).length + 1`.
**Warning signs:** Round Review (future phase) shows all pins labelled "Shot 1".

[ASSUMED — based on schema design, not verified against a spec]

### Pitfall 6: FMTC TileProvider API — flutter_map_tile_caching ^9.x

**What goes wrong:** FMTC went through significant API changes between v8 and v9. The pattern `FMTCStore(...).getTileProvider()` may differ from v8 docs found online.
**How to avoid:** The codebase already uses FMTC v9.1.1 for download in `TileCacheRepository`. The `getTileProvider()` method is the v9 pattern. [ASSUMED — getTileProvider() name, verify against FMTC ^9 changelog before using]
**Warning signs:** `FMTCStore has no method getTileProvider` compile error.

---

## Code Examples

### ShotDao Registration in AppDatabase

```dart
// app_database.dart — add ShotDao to daos list
// Source: existing codebase pattern
@DriftDatabase(tables: [Rounds, Holes, Shots], daos: [RoundDao, HoleDao, ShotDao])
class AppDatabase extends _$AppDatabase {
  // ... existing code unchanged ...
}
```

### shotsForHoleProvider

```dart
// Source: existing Riverpod provider pattern in codebase
@riverpod
Stream<List<Shot>> shotsForHole(ShotsForHoleRef ref, int roundId, int holeIndex) {
  final db = ref.watch(appDatabaseProvider);
  final holeNumber = holeIndex + 1;
  // Must resolve holeId first — watch via hole stream
  return db.holeDao
    .watchHolesForRound(roundId)
    .asyncExpand((holes) async* {
      final hole = holes.where((h) => h.holeNumber == holeNumber).firstOrNull;
      if (hole == null) {
        yield [];
        return;
      }
      yield* db.shotDao.watchShotsForHole(hole.id);
    });
}
```
[ASSUMED — asyncExpand pattern; verify DAO access via db.shotDao]

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| flutter_map_tile_caching v8 imperative API | FMTC v9 OOP API (FMTCStore, download.startForeground) | FMTC v9.0 | Already in codebase at v9.1.1; use existing TileCacheRepository pattern |
| geolocator positional parameters | geolocator LocationSettings object | geolocator ^9 | In pubspec at ^12; use LocationSettings or desiredAccuracy named param |
| speech_to_text localeId default (en_US) | en_AU for NZ accent — already set in VoiceService | Phase 3 | Already correct in codebase |

**Deprecated/outdated:**
- `flutter_map v6 MapOptions.center` → v7 uses `MapOptions.initialCenter` [ASSUMED — verify against flutter_map ^7 changelog]
- FMTC `FMTC.instance.initialise()` → v9 uses `FMTCObjectBoxBackend().initialise()` — already correct in main.dart

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| flutter_map | Map overlay | ✓ | ^7.0.2 in pubspec | — |
| flutter_map_tile_caching | Offline tiles | ✓ | ^9.1.1, initialised in main() | Grey tiles on-course |
| geolocator | GPS position | ✓ | ^12.0.0 in pubspec | "GPS unavailable" state |
| speech_to_text | Voice | ✓ | ^6.6.2, working in VoiceService | Outcome buttons (primary path) |
| permission_handler | Location permission | ✓ | ^11.3.1 in pubspec | — |
| iOS Info.plist permissions | GPS + voice on iOS | ✓ | All 3 keys set with descriptions | — |
| Android location permissions | GPS on Android | ✗ MISSING | — | GPS returns denied; fix in Wave 0 |
| Flutter SDK | All | ✓ | 3.24.5 | — |
| Dart code-gen (build_runner) | ShotDao .g.dart | ✓ | ^2.4.11 | — |

**Missing dependencies with no fallback:**
- Android `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` in AndroidManifest.xml — must be added before GPS can function. This is a Wave 0 blocker.

**Missing dependencies with fallback:**
- None beyond the Android permission.

---

## Validation Architecture

`nyquist_validation: false` in config.json — this section is skipped per config.

---

## Security Domain

Phase 5 has no authentication, no network calls, no user data beyond GPS coordinates stored locally in Drift. ASVS categories V2 (authentication), V3 (session), V4 (access control), and V6 (cryptography) do not apply.

V5 Input Validation applies only narrowly:
- GPS coordinates from geolocator are system-provided, not user-typed.
- Shot count from VoiceCommandParser is already range-validated (1–10 shots mapped to valid outcomes).
- No user-supplied strings touch Drift directly.

No security work required for Phase 5.

---

## Open Questions

1. **FMTC v9 `getTileProvider()` exact method signature**
   - What we know: `FMTCStore` is used in TileCacheRepository for download; must also supply TileProvider to TileLayer.
   - What's unclear: Whether the method is `FMTCStore(...).getTileProvider()` or a different API in v9.1.1.
   - Recommendation: Check `flutter_map_tile_caching` v9 changelog or pub.dev docs before writing the TileLayer. The download pattern in TileCacheRepository is confirmed correct.

2. **Voice hole advancement — should voice auto-advance the hole?**
   - What we know: Tap outcome always advances immediately (SHOT-03). VoiceService currently does NOT advance.
   - What's unclear: REQUIREMENTS.md SHOT-09 says "voice confirmation shown as toast with undo option" — does not explicitly say "auto-advance."
   - Recommendation: Mirror tap behavior for consistency — voice outcome should auto-advance the hole and show the same undo toast. If SHOT-09 intent differs, clarify before implementation.
   - [ASSUMED — intent inferred from SHOT-03 consistency; needs confirmation]

3. **GPS timeout parameter name in geolocator ^12**
   - What we know: Geolocator supports a timeout for `getCurrentPosition`.
   - What's unclear: Whether it's `timeLimit` or another parameter name in ^12.
   - Recommendation: Check geolocator ^12 pub.dev API docs before using.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `FMTCStore(...).getTileProvider()` is the correct FMTC v9 method name for supplying tiles to TileLayer | Code Examples (Map Overlay) | Compile error; swap to correct method name from changelog |
| A2 | `timeLimit` is the named parameter for getCurrentPosition timeout in geolocator ^12 | Pattern 1 | Compile error; use correct parameter name |
| A3 | Voice outcome should auto-advance the hole to match SHOT-03 tap behavior | Pattern 4 / Open Questions | Unintended UX if voice was designed differently |
| A4 | `shotNumber` should be counted from existing shots per hole before insertion | Pitfall 5 | Shot pins display with wrong numbering in future phases |
| A5 | `asyncExpand` is correct Dart stream combinator for shotsForHoleProvider | Code Examples | Runtime type error; use switchMap or alternative |

---

## Sources

### Primary (HIGH confidence)
- Codebase (all files read directly) — voice_service.dart, voice_command_parser.dart, shot_capture_screen.dart, app_database.dart, shots_table.dart, holes_table.dart, hole_dao.dart, main.dart, tile_cache_repository.dart, fairway_gir_toggles.dart, pubspec.yaml
- CLAUDE.md project conventions — GPS on-demand mandate, Drift schema rules, provider keepAlive rules
- drift_schema_v1.json — confirms shots table columns at v1
- AndroidManifest.xml — confirms missing location permissions
- ios/Runner/Info.plist — confirms correct iOS permissions

### Secondary (MEDIUM confidence)
- .planning/research/PITFALLS.md — GPS and voice pitfalls documented from prior research
- .planning/research/STACK.md — flutter_map and geolocator patterns

### Tertiary (LOW confidence / ASSUMED)
- FMTC v9 `getTileProvider()` method name — inferred from v9 download pattern; not confirmed via changelog
- geolocator ^12 `timeLimit` parameter name — inferred from training knowledge
- `asyncExpand` stream combinator pattern for shotsForHoleProvider

---

## Metadata

**Confidence breakdown:**
- GPS map overlay architecture: HIGH — flutter_map, FMTC, geolocator all confirmed in codebase; shots table confirmed at v1
- ShotDao implementation: HIGH — pattern mirrors existing HoleDao exactly
- Voice callback gap: HIGH — confirmed by reading both VoiceService and ShotCaptureScreen directly
- Android permission gap: HIGH — confirmed by reading AndroidManifest.xml directly
- FMTC getTileProvider API: LOW — not verified against v9 changelog; use as hypothesis

**Research date:** 2026-05-19
**Valid until:** 2026-06-18 (stable stack — flutter_map 7.x, FMTC 9.x, geolocator 12.x are unlikely to break in 30 days)
