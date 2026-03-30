import 'dart:convert';
import 'package:http/http.dart' as http;

/// OpenStreetMap Nominatim geocoding service - FREE, no API key required
/// Rate limit: 1 request per second
class OpenStreetMapService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  /// Get place name from GPS coordinates (reverse geocoding)
  static Future<OSMPlace?> reverseGeocode(double lat, double lon) async {
    try {
      final url = '$_baseUrl/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'PowerAlertGH/1.0 (poweralert.gh@app.com)', // Required by OSM
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OSMPlace.fromJson(data);
      }
      return null;
    } catch (e) {
      print('OSM Geocoding error: $e');
      return null;
    }
  }
  
  /// Search for places by name (forward geocoding)
  static Future<List<OSMPlace>> searchPlace(String query, {String? countryCode = 'gh'}) async {
    try {
      final url = '$_baseUrl/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&countrycodes=$countryCode&limit=5';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'PowerAlertGH/1.0 (poweralert.gh@app.com)',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        return results.map((e) => OSMPlace.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('OSM Search error: $e');
      return [];
    }
  }
}

/// Represents a place from OpenStreetMap
class OSMPlace {
  final String placeId;
  final String displayName;
  final String? road;
  final String? suburb;
  final String? neighbourhood;
  final String? district;
  final String? city;
  final String? state;
  final String? country;
  final double lat;
  final double lon;
  final String? type;
  final String? category;
  
  OSMPlace({
    required this.placeId,
    required this.displayName,
    this.road,
    this.suburb,
    this.neighbourhood,
    this.district,
    this.city,
    this.state,
    this.country,
    required this.lat,
    required this.lon,
    this.type,
    this.category,
  });
  
  /// Get the most specific name for this place
  String get shortName {
    // Try to get the most specific local name
    if (neighbourhood != null && neighbourhood!.isNotEmpty) {
      return neighbourhood!;
    }
    if (suburb != null && suburb!.isNotEmpty) {
      return suburb!;
    }
    if (road != null && road!.isNotEmpty) {
      return road!;
    }
    if (district != null && district!.isNotEmpty) {
      return district!;
    }
    // Fallback to first part of display name
    final parts = displayName.split(',');
    return parts.first.trim();
  }
  
  /// Get area context (parent area)
  String get areaContext {
    final parts = <String>[];
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    
    return parts.isNotEmpty ? parts.join(' • ') : 'Greater Accra';
  }
  
  factory OSMPlace.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    
    return OSMPlace(
      placeId: json['place_id']?.toString() ?? '',
      displayName: json['display_name'] ?? 'Unknown location',
      road: address['road'],
      suburb: address['suburb'],
      neighbourhood: address['neighbourhood'],
      district: address['district'] ?? address['county'],
      city: address['city'] ?? address['town'] ?? address['village'],
      state: address['state'],
      country: address['country'],
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
      type: json['type'],
      category: json['category'],
    );
  }
}
