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

/// Specific area within Accra with precise coordinates
class AccraMicroArea {
  final String id;
  final String name;
  final String parentArea;
  final double lat;
  final double lon;
  final String description;

  const AccraMicroArea({
    required this.id,
    required this.name,
    required this.parentArea,
    required this.lat,
    required this.lon,
    this.description = '',
  });
}

/// 40+ specific micro-areas across Accra for precise location
const List<AccraMicroArea> kAccraMicroAreas = [
  // Madina - Adenta Corridor (8 areas)
  AccraMicroArea(
    id: 'haatso-boohye',
    name: 'Haatso Boohye',
    parentArea: 'Madina–Adenta',
    lat: 5.6785,
    lon: -0.1823,
    description: 'Near Pentecost University, Haatso market area',
  ),
  AccraMicroArea(
    id: 'haatso-agbogba',
    name: 'Haatso Agbogba',
    parentArea: 'Madina–Adenta',
    lat: 5.6820,
    lon: -0.1780,
    description: 'Agbogba junction area',
  ),
  AccraMicroArea(
    id: 'adenta-frafraha',
    name: 'Adenta Frafraha',
    parentArea: 'Madina–Adenta',
    lat: 5.7050,
    lon: -0.1480,
    description: 'Frafraha, near Adenta barrier',
  ),
  AccraMicroArea(
    id: 'adenta-new-site',
    name: 'Adenta New Site',
    parentArea: 'Madina–Adenta',
    lat: 5.6950,
    lon: -0.1520,
    description: 'New Site residential area',
  ),
  AccraMicroArea(
    id: 'madina-market',
    name: 'Madina Market',
    parentArea: 'Madina–Adenta',
    lat: 5.6820,
    lon: -0.1620,
    description: 'Madina central market area',
  ),
  AccraMicroArea(
    id: 'madina-zongo',
    name: 'Madina Zongo',
    parentArea: 'Madina–Adenta',
    lat: 5.6780,
    lon: -0.1580,
    description: 'Madina Zongo, near Islamic University',
  ),
  AccraMicroArea(
    id: 'ashaley-botiwe',
    name: 'Ashaley Botiwe',
    parentArea: 'Madina–Adenta',
    lat: 5.6720,
    lon: -0.1680,
    description: 'Ashaley Botiwe estate',
  ),
  AccraMicroArea(
    id: 'west-land',
    name: 'West Land Estate',
    parentArea: 'Madina–Adenta',
    lat: 5.6850,
    lon: -0.1650,
    description: 'West Land residential estate',
  ),

  // East Legon / Airport (6 areas)
  AccraMicroArea(
    id: 'east-legon-proper',
    name: 'East Legon Proper',
    parentArea: 'Airport & East Legon',
    lat: 5.6350,
    lon: -0.1650,
    description: 'East Legon residential',
  ),
  AccraMicroArea(
    id: 'trassaco',
    name: 'Trassaco Estate',
    parentArea: 'Airport & East Legon',
    lat: 5.6450,
    lon: -0.1750,
    description: 'Trassaco Valley',
  ),
  AccraMicroArea(
    id: 'a-and-c-mall',
    name: 'A&C Mall Area',
    parentArea: 'Airport & East Legon',
    lat: 5.6380,
    lon: -0.1600,
    description: 'Near A&C Mall, Jungle Avenue',
  ),
  AccraMicroArea(
    id: 'american-house',
    name: 'American House',
    parentArea: 'Airport & East Legon',
    lat: 5.6300,
    lon: -0.1550,
    description: 'American House area',
  ),
  AccraMicroArea(
    id: 'kotoka-airport',
    name: 'Kotoka Airport',
    parentArea: 'Airport & East Legon',
    lat: 5.6050,
    lon: -0.1680,
    description: 'Airport residential',
  ),
  AccraMicroArea(
    id: 'cantonments',
    name: 'Cantonments',
    parentArea: 'Osu & Cantonments',
    lat: 5.5700,
    lon: -0.1800,
    description: 'Cantonments diplomatic area',
  ),

  // Osu (4 areas)
  AccraMicroArea(
    id: 'osu-oxford',
    name: 'Osu Oxford St',
    parentArea: 'Osu & Cantonments',
    lat: 5.5550,
    lon: -0.1750,
    description: 'Oxford Street, Osu nightlife',
  ),
  AccraMicroArea(
    id: 'labone',
    name: 'Labone',
    parentArea: 'Osu & Cantonments',
    lat: 5.5650,
    lon: -0.1720,
    description: 'Labone junction area',
  ),
  AccraMicroArea(
    id: 'labadi',
    name: 'Labadi',
    parentArea: 'Osu & Cantonments',
    lat: 5.5600,
    lon: -0.1650,
    description: 'Labadi beach area',
  ),
  AccraMicroArea(
    id: 'south-la',
    name: 'South La',
    parentArea: 'Osu & Cantonments',
    lat: 5.5500,
    lon: -0.1700,
    description: 'South La, near La General Hospital',
  ),

  // Central / Ridge (4 areas)
  AccraMicroArea(
    id: 'cbd-high-street',
    name: 'CBD High Street',
    parentArea: 'Central / Ridge',
    lat: 5.5450,
    lon: -0.2050,
    description: 'High Street, Makola area',
  ),
  AccraMicroArea(
    id: 'ministries',
    name: 'The Ministries',
    parentArea: 'Central / Ridge',
    lat: 5.5550,
    lon: -0.2100,
    description: 'Government ministries area',
  ),
  AccraMicroArea(
    id: 'ridge-hospital',
    name: 'Ridge Hospital',
    parentArea: 'Central / Ridge',
    lat: 5.5600,
    lon: -0.2000,
    description: 'Ridge Hospital area',
  ),
  AccraMicroArea(
    id: 'tudu',
    name: 'Tudu',
    parentArea: 'Central / Ridge',
    lat: 5.5400,
    lon: -0.2080,
    description: 'Tudu lorry station area',
  ),

  // Lapaz - Kaneshie (4 areas)
  AccraMicroArea(
    id: 'lapaz-main',
    name: 'Lapaz Main',
    parentArea: 'Lapaz & Kaneshie',
    lat: 5.5950,
    lon: -0.2500,
    description: 'Lapaz central, Abrantie spot',
  ),
  AccraMicroArea(
    id: 'north-kaneshie',
    name: 'North Kaneshie',
    parentArea: 'Lapaz & Kaneshie',
    lat: 5.5850,
    lon: -0.2450,
    description: 'North Kaneshie residential',
  ),
  AccraMicroArea(
    id: 'kaneshie-market',
    name: 'Kaneshie Market',
    parentArea: 'Lapaz & Kaneshie',
    lat: 5.5750,
    lon: -0.2400,
    description: 'Kaneshie market complex',
  ),
  AccraMicroArea(
    id: 'awudome',
    name: 'Awudome Estate',
    parentArea: 'Lapaz & Kaneshie',
    lat: 5.5900,
    lon: -0.2550,
    description: 'Awudome estate area',
  ),

  // Achimota - Dome (4 areas)
  AccraMicroArea(
    id: 'achimota-school',
    name: 'Achimota School',
    parentArea: 'Achimota & Dome',
    lat: 5.6200,
    lon: -0.2200,
    description: 'Achimota School area',
  ),
  AccraMicroArea(
    id: 'dome-pillar2',
    name: 'Dome Pillar 2',
    parentArea: 'Achimota & Dome',
    lat: 5.6350,
    lon: -0.2300,
    description: 'Dome, near Pillar 2',
  ),
  AccraMicroArea(
    id: 'taifa',
    name: 'Taifa',
    parentArea: 'Achimota & Dome',
    lat: 5.6400,
    lon: -0.2350,
    description: 'Taifa, near Dome market',
  ),
  AccraMicroArea(
    id: 'blohum',
    name: 'Blohum Estate',
    parentArea: 'Achimota & Dome',
    lat: 5.6250,
    lon: -0.2250,
    description: 'Blohum residential',
  ),

  // Teshie - Nungua (3 areas)
  AccraMicroArea(
    id: 'teshie-estate',
    name: 'Teshie Estate',
    parentArea: 'Teshie & Nungua',
    lat: 5.5900,
    lon: -0.0950,
    description: 'Teshie Labbadi estate',
  ),
  AccraMicroArea(
    id: 'nungua-central',
    name: 'Nungua Central',
    parentArea: 'Teshie & Nungua',
    lat: 5.6050,
    lon: -0.0850,
    description: 'Nungua town center',
  ),
  AccraMicroArea(
    id: 'sakumono',
    name: 'Sakumono',
    parentArea: 'Teshie & Nungua',
    lat: 5.6150,
    lon: -0.0700,
    description: 'Sakumono estate area',
  ),

  // Ashaiman - Tema (3 areas)
  AccraMicroArea(
    id: 'ashaiman-main',
    name: 'Ashaiman Main',
    parentArea: 'Ashaiman–Tema link',
    lat: 5.7050,
    lon: -0.0350,
    description: 'Ashaiman main town',
  ),
  AccraMicroArea(
    id: 'tema-community1',
    name: 'Tema C1',
    parentArea: 'Ashaiman–Tema link',
    lat: 5.6300,
    lon: -0.0150,
    description: 'Tema Community 1',
  ),
  AccraMicroArea(
    id: 'motorway',
    name: 'Tema Motorway',
    parentArea: 'Ashaiman–Tema link',
    lat: 5.6650,
    lon: -0.0450,
    description: 'Motorway toll booth area',
  ),

  // Kasoa Corridor (4 areas)
  AccraMicroArea(
    id: 'kasoa-main',
    name: 'Kasoa Main',
    parentArea: 'Mallam–Kasoa corridor',
    lat: 5.5300,
    lon: -0.3000,
    description: 'Kasoa central market',
  ),
  AccraMicroArea(
    id: 'mallam-gbawe',
    name: 'Mallam Gbawe',
    parentArea: 'Mallam–Kasoa corridor',
    lat: 5.5600,
    lon: -0.2750,
    description: 'Mallam, Gbawe junction',
  ),
  AccraMicroArea(
    id: 'weija',
    name: 'Weija',
    parentArea: 'Mallam–Kasoa corridor',
    lat: 5.5700,
    lon: -0.2650,
    description: 'Weija dam area',
  ),
  AccraMicroArea(
    id: 'oblogo',
    name: 'Oblogo',
    parentArea: 'Mallam–Kasoa corridor',
    lat: 5.5800,
    lon: -0.2550,
    description: 'Oblogo, near McCarthy Hill',
  ),
];

/// Result of resolving GPS to a specific micro-area.
sealed class AccraLocationResult {}

class AccraLocationMatched extends AccraLocationResult {
  final AccraMicroArea microArea;
  final double distanceKm;

  AccraLocationMatched({required this.microArea, required this.distanceKm});
}

class AccraLocationOutside extends AccraLocationResult {
  final String message;
  AccraLocationOutside({this.message = 'Your location looks outside the Accra area we cover.'});
}

class AccraLocationUnavailable extends AccraLocationResult {
  final String message;
  AccraLocationUnavailable({this.message = 'Location unavailable.'});
}
