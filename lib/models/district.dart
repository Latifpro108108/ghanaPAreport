enum DistrictStatus {
  outage,
  restored,
  normal,
}

class District {
  final String id;
  final String name;
  final String region;
  final DistrictStatus status;
  final String? lastReportedAt;
  final int activeReports;
  bool isMonitored;

  District({
    required this.id,
    required this.name,
    required this.region,
    required this.status,
    this.lastReportedAt,
    required this.activeReports,
    required this.isMonitored,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      status: DistrictStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DistrictStatus.normal,
      ),
      lastReportedAt: json['lastReportedAt'],
      activeReports: json['activeReports'] ?? 0,
      isMonitored: json['isMonitored'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'status': status.name,
      'lastReportedAt': lastReportedAt,
      'activeReports': activeReports,
      'isMonitored': isMonitored,
    };
  }
}
