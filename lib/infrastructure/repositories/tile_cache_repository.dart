import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import '../../app/constants.dart';
import '../../domain/models/hole_model.dart';

class TileCacheRepository {
  /// Returns a progress stream for downloading tiles covering the course
  /// bounding box at Z14–17. Returns null if no hole has tee GPS data (D-08).
  Stream<DownloadProgress>? preCacheCourse(List<HoleModel> holes) {
    final coords = holes
        .where((h) => h.teeLat != null && h.teeLng != null)
        .map((h) => LatLng(h.teeLat!, h.teeLng!))
        .toList();

    if (coords.isEmpty) return null;

    final bounds = _deriveBounds(coords, bufferDegrees: 0.005);
    final region = RectangleRegion(bounds);
    final downloadable = region.toDownloadable(
      minZoom: 14,
      maxZoom: 17,
      options: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.brdy.brdy01',
      ),
    );

    return const FMTCStore(AppConstants.tileCacheStoreName)
        .download
        .startForeground(
          region: downloadable,
          parallelThreads: 3,
          skipSeaTiles: false,
        );
  }

  LatLngBounds _deriveBounds(
    List<LatLng> coords, {
    required double bufferDegrees,
  }) {
    var minLat = coords.first.latitude;
    var maxLat = coords.first.latitude;
    var minLng = coords.first.longitude;
    var maxLng = coords.first.longitude;

    for (final c in coords) {
      if (c.latitude < minLat) minLat = c.latitude;
      if (c.latitude > maxLat) maxLat = c.latitude;
      if (c.longitude < minLng) minLng = c.longitude;
      if (c.longitude > maxLng) maxLng = c.longitude;
    }

    return LatLngBounds(
      LatLng(minLat - bufferDegrees, minLng - bufferDegrees),
      LatLng(maxLat + bufferDegrees, maxLng + bufferDegrees),
    );
  }
}
