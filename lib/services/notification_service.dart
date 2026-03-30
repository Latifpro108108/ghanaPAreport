import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for handling Firebase Cloud Messaging notifications
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controllers for notification handling
  final StreamController<String> _crowdAlertController =
      StreamController<String>.broadcast();
  final StreamController<String> _powerBackController =
      StreamController<String>.broadcast();

  Stream<String> get onCrowdAlert => _crowdAlertController.stream;
  Stream<String> get onPowerBackCheck => _powerBackController.stream;

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification permission granted');
    }

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _createNotificationChannels();

    // Set up message handlers
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Get FCM token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const crowdChannel = AndroidNotificationChannel(
      'crowd_alerts',
      'Crowd Alerts',
      description:
          'Notifications when many users report power status in your area',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const powerCheckChannel = AndroidNotificationChannel(
      'power_check',
      'Power Status Check',
      description: 'Reminders to check if power is back',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(crowdChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(powerCheckChannel);
  }

  /// Handle foreground messages
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show local notification
      _showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? 'PowerAlert',
        body: notification.body ?? '',
        payload: data['areaId'] ?? '',
        channelId:
            data['type'] == 'crowd_alert' ? 'crowd_alerts' : 'power_check',
      );

      // Handle specific notification types
      if (data['type'] == 'crowd_alert') {
        _crowdAlertController.add(data['areaId'] ?? '');
      } else if (data['type'] == 'power_check') {
        _powerBackController.add(data['areaId'] ?? '');
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required String channelId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'crowd_alerts' ? 'Crowd Alerts' : 'Power Status Check',
      channelDescription: channelId == 'crowd_alerts'
          ? 'Notifications when many users report power status'
          : 'Reminders to check if power is back',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Navigate to specific area if needed
  }

  /// Handle app opened from notification
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.notification?.title}');
  }

  /// Subscribe to area topic for notifications
  Future<void> subscribeToArea(String areaId) async {
    await _messaging.subscribeToTopic('area_$areaId');
    debugPrint('Subscribed to area: $areaId');
  }

  /// Unsubscribe from area topic
  Future<void> unsubscribeFromArea(String areaId) async {
    await _messaging.unsubscribeFromTopic('area_$areaId');
    debugPrint('Unsubscribed from area: $areaId');
  }

  /// Send crowd alert - simplified client-side only version
  /// No Cloud Functions needed - each client detects crowds locally
  Future<void> sendCrowdAlertToTopic(
    String areaId,
    String areaName,
    String message,
  ) async {
    // Client-side only: Show notification locally
    // Each user's app detects the crowd independently
    debugPrint('🔔 Crowd Alert: $message in $areaName');
    await showCrowdAlertNotification(areaId, areaName, message);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Update FCM token in Firestore
  Future<void> updateToken(String userId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      // Update token in Firestore
      debugPrint('Updating FCM token for user: $userId');
    }
  }

  /// Schedule power check notification (local)
  Future<void> schedulePowerCheckNotification(
    String areaId,
    String areaName,
    DateTime scheduledTime,
  ) async {
    // This would typically be handled by a Cloud Function
    // For now, we'll show an immediate notification for testing
    await _showLocalNotification(
      id: scheduledTime.millisecondsSinceEpoch ~/ 1000,
      title: 'Power Update?',
      body: 'Is the power back in $areaName?',
      payload: areaId,
      channelId: 'power_check',
    );
  }

  /// Show crowd alert notification
  Future<void> showCrowdAlertNotification(
    String areaId,
    String areaName,
    String message,
  ) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Community Alert - $areaName',
      body: message,
      payload: areaId,
      channelId: 'crowd_alerts',
    );
  }

  void dispose() {
    _crowdAlertController.close();
    _powerBackController.close();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
  // Handle background message if needed
}
