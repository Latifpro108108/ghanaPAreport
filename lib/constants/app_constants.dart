import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Blue theme
  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryDark = Color(0xFF1E40AF); // Blue 800
  static const Color primaryLight = Color(0xFFEFF6FF); // Blue 50

  // Secondary Colors - Green
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFDCFCE7);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA); // Gray 50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Gray 100
  static const Color outlineVariant = Color(0xFFE5E7EB); // Gray 200
  static const Color outline = Color(0xFF9CA3AF); // Gray 400
  static const Color onSurface = Color(0xFF111827); // Gray 900
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Gray 500

  // Status-specific colors
  static const Color outageRed = Color(0xFFDC2626); // Red 600
  static const Color outageRedLight = Color(0xFFFEE2E2); // Red 100
  static const Color restoredGreen = Color(0xFF059669); // Green 600
  static const Color restoredGreenLight = Color(0xFFD1FAE5); // Green 100
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class AppTextStyles {
  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );
}

class AppStrings {
  // App
  static const String appName = 'PowerAlert GH';
  static const String subtitle = 'Community Power Monitoring';

  // Common
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String submit = 'Submit';
  static const String skip = 'Skip';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String joinCommunity = 'Join the community';
  static const String welcomeBack = 'Welcome back!';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String enterOTP = 'Verification Code';
  static const String verificationCodeSent = 'Verification code sent!';
  static const String didNotReceiveCode = 'Didn\'t receive code?';
  static const String resend = 'Resend';

  // Home
  static const String homeTitle = 'Home';
  static const String activeOutages = 'Active Outages';
  static const String recentlyRestored = 'Recently Restored';
  static const String myDistricts = 'My Districts';
  static const String mapView = 'Map View';
  static const String noDistrictsMonitored = 'No districts monitored yet';
  static const String browseDistricts = 'Browse Districts';

  // Districts
  static const String allDistricts = 'All Districts';
  static const String searchDistricts = 'Search districts...';
  static const String noDistrictsFound = 'No districts found';
  static const String monitoringDistrict = 'Now monitoring';
  static const String stoppedMonitoring = 'Stopped monitoring';

  // Reports
  static const String reportOutage = 'Report Outage';
  static const String powerRestored = 'Power Restored';
  static const String activeReports = 'active reports';
  static const String powerOutage = 'Power Outage';
  static const String recentlyRestored_status = 'Recently Restored';
  static const String noReports = 'No Reports';

  // Alerts
  static const String notifications = 'Notifications';
  static const String markAllRead = 'Mark all read';
  static const String unread = 'unread';
  static const String notificationPreferences = 'Notification Preferences';

  // Profile
  static const String accountInformation = 'Account Information';
  static const String settings = 'Settings';
  static const String myReports = 'My Reports';
  static const String privacySecurity = 'Privacy & Security';
  static const String helpSupport = 'Help & Support';
  static const String logout = 'Logout';
  static const String loggedOutSuccessfully = 'Logged out successfully';
  static const String memberSince = 'Member Since';
  static const String reportsSubmitted = 'Reports';
  static const String helpfulVotes = 'Helpful Votes';
  static const String monitoredDistricts = 'Districts';
}
