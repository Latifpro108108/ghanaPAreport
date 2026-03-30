/// User model for Firebase Auth
class AppUser {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final String? homeAreaId;
  final DateTime createdAt;
  final List<String> notificationAreas; // Areas user wants notifications for

  AppUser({
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    this.homeAreaId,
    required this.createdAt,
    this.notificationAreas = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String,
      homeAreaId: json['homeAreaId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notificationAreas: List<String>.from(json['notificationAreas'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'homeAreaId': homeAreaId,
      'createdAt': createdAt.toIso8601String(),
      'notificationAreas': notificationAreas,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? homeAreaId,
    DateTime? createdAt,
    List<String>? notificationAreas,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      homeAreaId: homeAreaId ?? this.homeAreaId,
      createdAt: createdAt ?? this.createdAt,
      notificationAreas: notificationAreas ?? this.notificationAreas,
    );
  }
}
