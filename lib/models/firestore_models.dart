import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/home_screen.dart';

/// Vote model for Firestore
class Vote {
  final String id;
  final String areaId;
  final PowerStatus status;
  final String userId;
  final DateTime timestamp;
  final String? deviceId;

  Vote({
    required this.id,
    required this.areaId,
    required this.status,
    required this.userId,
    required this.timestamp,
    this.deviceId,
  });

  factory Vote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vote(
      id: doc.id,
      areaId: data['areaId'] as String,
      status: data['status'] == 'on' ? PowerStatus.on : PowerStatus.off,
      userId: data['userId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      deviceId: data['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'areaId': areaId,
      'status': status == PowerStatus.on ? 'on' : 'off',
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'deviceId': deviceId,
    };
  }
}

/// Area model for Firestore
class Area {
  final String id;
  final String name;
  final String? context;
  final double? latitude;
  final double? longitude;
  final DateTime lastUpdated;
  final PowerStatus currentStatus;

  Area({
    required this.id,
    required this.name,
    this.context,
    this.latitude,
    this.longitude,
    required this.lastUpdated,
    this.currentStatus = PowerStatus.unknown,
  });

  factory Area.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Area(
      id: doc.id,
      name: data['name'] as String,
      context: data['context'] as String?,
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      currentStatus: _parseStatus(data['currentStatus'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'context': context,
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'currentStatus': currentStatus == PowerStatus.on
          ? 'on'
          : currentStatus == PowerStatus.off
              ? 'off'
              : 'unknown',
    };
  }

  static PowerStatus _parseStatus(String? status) {
    switch (status) {
      case 'on':
        return PowerStatus.on;
      case 'off':
        return PowerStatus.off;
      default:
        return PowerStatus.unknown;
    }
  }
}

/// Crowd alert model for notifications
class CrowdAlert {
  final String id;
  final String areaId;
  final String areaName;
  final String message;
  final PowerStatus detectedStatus;
  final int voteCount;
  final DateTime timestamp;

  CrowdAlert({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.message,
    required this.detectedStatus,
    required this.voteCount,
    required this.timestamp,
  });

  factory CrowdAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrowdAlert(
      id: doc.id,
      areaId: data['areaId'] as String,
      areaName: data['areaName'] as String,
      message: data['message'] as String,
      detectedStatus: data['detectedStatus'] == 'on' ? PowerStatus.on : PowerStatus.off,
      voteCount: data['voteCount'] as int,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'areaId': areaId,
      'areaName': areaName,
      'message': message,
      'detectedStatus': detectedStatus == PowerStatus.on ? 'on' : 'off',
      'voteCount': voteCount,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

/// Power status check reminder model
class PowerCheckReminder {
  final String id;
  final String userId;
  final String areaId;
  final DateTime scheduledFor;
  final bool isSent;
  final String? fcmToken;

  PowerCheckReminder({
    required this.id,
    required this.userId,
    required this.areaId,
    required this.scheduledFor,
    this.isSent = false,
    this.fcmToken,
  });

  factory PowerCheckReminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PowerCheckReminder(
      id: doc.id,
      userId: data['userId'] as String,
      areaId: data['areaId'] as String,
      scheduledFor: (data['scheduledFor'] as Timestamp).toDate(),
      isSent: data['isSent'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'areaId': areaId,
      'scheduledFor': Timestamp.fromDate(scheduledFor),
      'isSent': isSent,
      'fcmToken': fcmToken,
    };
  }
}
