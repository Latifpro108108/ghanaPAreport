enum AlertType {
  outage,
  restored,
  info,
}

class Alert {
  final String id;
  final String districtName;
  final String message;
  final String timestamp;
  final AlertType type;
  bool read;

  Alert({
    required this.id,
    required this.districtName,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.read,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] ?? '',
      districtName: json['districtName'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.info,
      ),
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'districtName': districtName,
      'message': message,
      'timestamp': timestamp,
      'type': type.name,
      'read': read,
    };
  }
}

class Report {
  final String id;
  final String districtId;
  final String districtName;
  final ReportType type;
  final String timestamp;
  final int upvotes;
  final int downvotes;
  final String? userVote;
  final String reportedBy;

  Report({
    required this.id,
    required this.districtId,
    required this.districtName,
    required this.type,
    required this.timestamp,
    required this.upvotes,
    required this.downvotes,
    this.userVote,
    required this.reportedBy,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      districtId: json['districtId'] ?? '',
      districtName: json['districtName'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.outage,
      ),
      timestamp: json['timestamp'] ?? '',
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      userVote: json['userVote'],
      reportedBy: json['reportedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'districtId': districtId,
      'districtName': districtName,
      'type': type.name,
      'timestamp': timestamp,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'userVote': userVote,
      'reportedBy': reportedBy,
    };
  }
}

enum ReportType {
  outage,
  restored,
}
