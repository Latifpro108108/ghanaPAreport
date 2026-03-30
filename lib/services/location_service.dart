import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

import 'openstreetmap_service.dart';

/// GPS + OpenStreetMap geocoding for accurate place names
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
      // First check if location services are enabled
      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        return null;
      }

      // Then request/check permission
      final permission = await requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get position with timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      return null;
    }
  }

  /// Stream of location updates for continuous tracking
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update when moved 50 meters
      ),
    );
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

  /// Get real place name from OpenStreetMap using GPS coordinates
  static Future<LocationResult> resolveLocation(Position? position) async {
    if (position == null) {
      return LocationUnavailable();
    }

    // Check if in Ghana roughly (4-12°N, 4°W-1°E)
    if (position.latitude < 4.0 ||
        position.latitude > 12.0 ||
        position.longitude < -4.0 ||
        position.longitude > 1.0) {
      return LocationOutsideGhana();
    }

    // Call OpenStreetMap API for real place name
    final place = await OpenStreetMapService.reverseGeocode(
      position.latitude,
      position.longitude,
    );

    if (place == null) {
      return LocationUnavailable();
    }

    return LocationMatched(
      placeName: place.shortName,
      areaContext: place.areaContext,
      fullAddress: place.displayName,
      lat: position.latitude,
      lon: position.longitude,
      accuracy: position.accuracy,
    );
  }
}

/// Result of location resolution
sealed class LocationResult {}

class LocationMatched extends LocationResult {
  final String placeName;
  final String areaContext;
  final String fullAddress;
  final double lat;
  final double lon;
  final double accuracy;

  LocationMatched({
    required this.placeName,
    required this.areaContext,
    required this.fullAddress,
    required this.lat,
    required this.lon,
    required this.accuracy,
  });
}

class LocationOutsideGhana extends LocationResult {
  final String message;
  LocationOutsideGhana(
      {this.message = 'Your location appears to be outside Ghana.'});
}

class LocationUnavailable extends LocationResult {
  final String message;
  LocationUnavailable({this.message = 'Unable to determine your location.'});
}
