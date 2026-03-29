import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

/// Service to handle GPS location and district detection
class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  static Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }

  /// Get current GPS position
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

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371; // km
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = 
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degreesToRadians(lat1)) *
      math.cos(_degreesToRadians(lat2)) *
      math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Get the nearest district based on user's location
  /// Returns district name and distance
  static Map<String, dynamic>? findNearestDistrict(
    Position userPosition,
    List<Map<String, dynamic>> districts,
  ) {
    if (districts.isEmpty) return null;

    Map<String, dynamic>? nearest;
    double minDistance = double.infinity;

    for (final district in districts) {
      final distance = calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        district['latitude'] as double,
        district['longitude'] as double,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = {
          'district': district,
          'distance': distance,
        };
      }
    }

    return nearest;
  }

  /// Mock districts data for Ghana with coordinates
  static List<Map<String, dynamic>> getGhanaDistricts() {
    return [
      {
        'id': 'acc-metro',
        'name': 'Accra Metro',
        'region': 'Greater Accra',
        'latitude': 5.6037,
        'longitude': -0.1870,
      },
      {
        'id': 'tema-metro',
        'name': 'Tema Metro',
        'region': 'Greater Accra',
        'latitude': 5.6698,
        'longitude': -0.0166,
      },
      {
        'id': 'kumasi-metro',
        'name': 'Kumasi Metro',
        'region': 'Ashanti',
        'latitude': 6.6666,
        'longitude': -1.6163,
      },
      {
        'id': 'tamale-metro',
        'name': 'Tamale Metro',
        'region': 'Northern',
        'latitude': 9.4008,
        'longitude': -0.8393,
      },
      {
        'id': 'sekondi-takoradi',
        'name': 'Sekondi-Takoradi',
        'region': 'Western',
        'latitude': 4.9262,
        'longitude': -1.7587,
      },
      {
        'id': 'cape-coast',
        'name': 'Cape Coast',
        'region': 'Central',
        'latitude': 5.1315,
        'longitude': -1.2793,
      },
      {
        'id': 'ho-municipal',
        'name': 'Ho Municipal',
        'region': 'Volta',
        'latitude': 6.6080,
        'longitude': 0.4710,
      },
      {
        'id': 'sunyani-municipal',
        'name': 'Sunyani Municipal',
        'region': 'Bono',
        'latitude': 7.3380,
        'longitude': -2.3266,
      },
      {
        'id': 'bolgatanga',
        'name': 'Bolgatanga',
        'region': 'Upper East',
        'latitude': 10.7856,
        'longitude': -0.8514,
      },
      {
        'id': 'wa-municipal',
        'name': 'Wa Municipal',
        'region': 'Upper West',
        'latitude': 10.0600,
        'longitude': -2.5000,
      },
    ];
  }
}
