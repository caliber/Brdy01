import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/constants.dart';
import '../../../domain/models/course_model.dart';
import '../../../theme/brdy_colors.dart';
import '../providers/shots_for_hole_provider.dart';

/// Displays a FlutterMap for the given [holeIndex] with FMTC tile caching and
/// shot-pin markers sourced from [shotsForHoleProvider].
///
/// When [course] is null (async load in progress), renders a black placeholder
/// to prevent a null LatLng crash (RESEARCH Pitfall 4).
class MapOverlayWidget extends ConsumerStatefulWidget {
  final int roundId;
  final int holeIndex;

  /// Nullable — null while courseForRoundProvider is still loading.
  final CourseModel? course;

  /// Called when the user taps anywhere on the map. The screen then triggers
  /// a GPS position fetch (NOT the tap coordinate).
  final VoidCallback onMapTapped;

  const MapOverlayWidget({
    super.key,
    required this.roundId,
    required this.holeIndex,
    required this.course,
    required this.onMapTapped,
  });

  @override
  ConsumerState<MapOverlayWidget> createState() => _MapOverlayWidgetState();
}

class _MapOverlayWidgetState extends ConsumerState<MapOverlayWidget> {
  static const LatLng _fallbackCenter = LatLng(-36.86, 174.76); // Auckland

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    // Null guard — show black placeholder until course resolves (Pitfall 4).
    if (course == null) {
      return Container(color: BrdyColors.background);
    }

    // Derive initial center from hole tee coordinates with Auckland fallback.
    final hole =
        widget.holeIndex < course.holes.length
            ? course.holes[widget.holeIndex]
            : null;

    final LatLng center =
        (hole?.teeLat != null && hole?.teeLng != null)
            ? LatLng(hole!.teeLat!, hole.teeLng!)
            : _fallbackCenter;

    // Watch shot pins from Drift.
    final shotsAsync =
        ref.watch(shotsForHoleProvider(widget.roundId, widget.holeIndex));

    final markers = shotsAsync.valueOrNull
            ?.map(
              (shot) => Marker(
                point: LatLng(shot.latitude, shot.longitude),
                width: 24,
                height: 24,
                child: const Icon(
                  Icons.circle,
                  color: BrdyColors.accent,
                  size: 16,
                ),
              ),
            )
            .toList() ??
        [];

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 17.0,
        onTap: (tapPosition, latlng) => widget.onMapTapped(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.brdy.brdy01',
          tileProvider: const FMTCStore(AppConstants.tileCacheStoreName)
              .getTileProvider(),
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
