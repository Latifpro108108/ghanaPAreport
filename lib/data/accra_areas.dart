/// Accra-only: approximate bounds (Greater Accra core). Outside → not matched.
class AccraBounds {
  static const double minLat = 5.48;
  static const double maxLat = 5.72;
  static const double minLon = -0.35;
  static const double maxLon = -0.02;

  static bool contains(double lat, double lon) {
    return lat >= minLat &&
        lat <= maxLat &&
        lon >= minLon &&
        lon <= maxLon;
  }
}

/// Known Accra neighborhoods — nearest centroid wins (no map; GPS only).
class AccraNeighborhood {
  final String id;
  final String shortLabel;
  final String description;
  final double lat;
  final double lon;

  const AccraNeighborhood({
    required this.id,
    required this.shortLabel,
    required this.description,
    required this.lat,
    required this.lon,
  });
}

const List<AccraNeighborhood> kAccraNeighborhoods = [
  AccraNeighborhood(
    id: 'central-ridge',
    shortLabel: 'Central / Ridge',
    description: 'CBD, Ministries, Ridge',
    lat: 5.5600,
    lon: -0.2050,
  ),
  AccraNeighborhood(
    id: 'osu-cantonments',
    shortLabel: 'Osu & Cantonments',
    description: 'Oxford St, Cantonments',
    lat: 5.5550,
    lon: -0.1740,
  ),
  AccraNeighborhood(
    id: 'airport-east',
    shortLabel: 'Airport & East Legon',
    description: 'Kotoka corridor, East Legon',
    lat: 5.6400,
    lon: -0.1650,
  ),
  AccraNeighborhood(
    id: 'madina-adenta',
    shortLabel: 'Madina–Adenta',
    description: 'Madina, Adenta corridor',
    lat: 5.6800,
    lon: -0.1550,
  ),
  AccraNeighborhood(
    id: 'teshie-nungua',
    shortLabel: 'Teshie & Nungua',
    description: 'Coastal east',
    lat: 5.6000,
    lon: -0.0950,
  ),
  AccraNeighborhood(
    id: 'tema-link',
    shortLabel: 'Ashaiman–Tema link',
    description: 'Tema Motorway side',
    lat: 5.6400,
    lon: -0.0550,
  ),
  AccraNeighborhood(
    id: 'lapaz-kaneshie',
    shortLabel: 'Lapaz & Kaneshie',
    description: 'Ring Road West',
    lat: 5.5900,
    lon: -0.2450,
  ),
  AccraNeighborhood(
    id: 'achimota-dome',
    shortLabel: 'Achimota & Dome',
    description: 'Achimota Forest side',
    lat: 5.6100,
    lon: -0.2250,
  ),
  AccraNeighborhood(
    id: 'kasoa-corridor',
    shortLabel: 'Mallam–Kasoa corridor',
    description: 'West motorway',
    lat: 5.5500,
    lon: -0.2850,
  ),
];

/// Result of resolving GPS to an Accra micro-area.
sealed class AccraLocationResult {}

class AccraLocationMatched extends AccraLocationResult {
  final AccraNeighborhood neighborhood;
  final double distanceKm;

  AccraLocationMatched({required this.neighborhood, required this.distanceKm});
}

class AccraLocationOutside extends AccraLocationResult {
  final String message;
  AccraLocationOutside({this.message = 'Your location looks outside the Accra area we cover.'});
}

class AccraLocationUnavailable extends AccraLocationResult {
  final String message;
  AccraLocationUnavailable({this.message = 'Location unavailable.'});
}
