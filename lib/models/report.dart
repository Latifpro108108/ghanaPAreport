import 'dart:convert';

enum ReportType { outage, restored }
enum ReportStatus { pending, confirmed, rejected }

class Report {
  final String id;
  final String areaId;
  final String areaName;
  final String reporterId;
  final String reporterName;
  final ReportType type;
  final ReportStatus status;
  final DateTime timestamp;
  final int confirmCount;
  final int rejectCount;
  final List<String> verifiedBy;
  final String? notes;

  Report({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.reporterId,
    required this.reporterName,
    required this.type,
    this.status = ReportStatus.pending,
    required this.timestamp,
    this.confirmCount = 0,
    this.rejectCount = 0,
    this.verifiedBy = const [],
    this.notes,
  });

  bool get isVerified => confirmCount >= 3 || status == ReportStatus.confirmed;
  bool get isRejected => rejectCount >= 3 || status == ReportStatus.rejected;
  bool get isPending => !isVerified && !isRejected;

  Report copyWith({
    String? id,
    String? areaId,
    String? areaName,
    String? reporterId,
    String? reporterName,
    ReportType? type,
    ReportStatus? status,
    DateTime? timestamp,
    int? confirmCount,
    int? rejectCount,
    List<String>? verifiedBy,
    String? notes,
  }) {
    return Report(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      confirmCount: confirmCount ?? this.confirmCount,
      rejectCount: rejectCount ?? this.rejectCount,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'areaId': areaId,
      'areaName': areaName,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'confirmCount': confirmCount,
      'rejectCount': rejectCount,
      'verifiedBy': verifiedBy,
      'notes': notes,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      areaId: json['areaId'],
      areaName: json['areaName'],
      reporterId: json['reporterId'],
      reporterName: json['reporterName'],
      type: ReportType.values.firstWhere((e) => e.name == json['type']),
      status: ReportStatus.values.firstWhere((e) => e.name == json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      confirmCount: json['confirmCount'] ?? 0,
      rejectCount: json['rejectCount'] ?? 0,
      verifiedBy: List<String>.from(json['verifiedBy'] ?? []),
      notes: json['notes'],
    );
  }

  static String generateId() {
    return 'rpt_${DateTime.now().millisecondsSinceEpoch}_${(Math.random() * 1000).toInt()}';
  }
}

// Extension for math random
class Math {
  static double random() {
    return DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
  }
}
