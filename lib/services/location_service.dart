import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

import '../data/accra_areas.dart';

/// GPS + Accra-only neighborhood resolution (no map SDK).
class LocationService {
  static Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final permission = await requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        return null;
      }

      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      return null;
    }
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Picks the nearest [AccraNeighborhood] from GPS. Accra-only; no Ghana-wide list.
  static AccraLocationResult resolveAccraNeighborhood(Position? position) {
    if (position == null) {
      return AccraLocationUnavailable();
    }

    if (!AccraBounds.contains(position.latitude, position.longitude)) {
      return AccraLocationOutside();
    }

    AccraNeighborhood? nearest;
    double minKm = double.infinity;

    for (final n in kAccraNeighborhoods) {
      final d = calculateDistance(
        position.latitude,
        position.longitude,
        n.lat,
        n.lon,
      );
      if (d < minKm) {
        minKm = d;
        nearest = n;
      }
    }

    if (nearest == null) {
      return AccraLocationUnavailable();
    }

    return AccraLocationMatched(neighborhood: nearest, distanceKm: minKm);
  }
}
