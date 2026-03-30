import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  Future<void> markOnboardingCompleted() =>
      _prefs.setBool('hasCompletedOnboarding', true);

  bool isFirstLaunch() => _prefs.getBool('hasCompletedOnboarding') != true;

  // Authentication
  Future<void> saveToken(String token) => _prefs.setString('authToken', token);

  String? getToken() => _prefs.getString('authToken');

  Future<void> clearToken() => _prefs.remove('authToken');

  Future<void> setAuthenticated(bool value) =>
      _prefs.setBool('isAuthenticated', value);

  bool isAuthenticated() => _prefs.getBool('isAuthenticated') ?? false;

  // User data
  Future<void> saveUserName(String name) => _prefs.setString('userName', name);

  String? getUserName() => _prefs.getString('userName');

  Future<void> saveUserPhone(String phone) =>
      _prefs.setString('userPhone', phone);

  String? getUserPhone() => _prefs.getString('userPhone');

  Future<void> saveUserEmail(String email) =>
      _prefs.setString('userEmail', email);

  String? getUserEmail() => _prefs.getString('userEmail');

  // Monitored districts
  Future<void> saveMonitoredDistricts(List<String> districts) =>
      _prefs.setStringList('monitoredDistricts', districts);

  List<String> getMonitoredDistricts() {
    final stored = _prefs.getStringList('monitoredDistricts');
    // Default to some districts if not set
    return stored ?? ['acc-metro', 'tema-metro', 'kumasi-metro', 'tamale'];
  }

  Future<void> addMonitoredDistrict(String districtId) async {
    final districts = getMonitoredDistricts();
    if (!districts.contains(districtId)) {
      districts.add(districtId);
      await saveMonitoredDistricts(districts);
    }
  }

  Future<void> removeMonitoredDistrict(String districtId) async {
    final districts = getMonitoredDistricts();
    districts.remove(districtId);
    await saveMonitoredDistricts(districts);
  }

  // Notification preferences
  Future<void> setOutageAlertsEnabled(bool value) =>
      _prefs.setBool('outageAlertsEnabled', value);

  bool isOutageAlertsEnabled() => _prefs.getBool('outageAlertsEnabled') ?? true;

  Future<void> setRestoredAlertsEnabled(bool value) =>
      _prefs.setBool('restoredAlertsEnabled', value);

  bool isRestoredAlertsEnabled() =>
      _prefs.getBool('restoredAlertsEnabled') ?? true;

  Future<void> setPushNotificationsEnabled(bool value) =>
      _prefs.setBool('pushNotificationsEnabled', value);

  bool isPushNotificationsEnabled() =>
      _prefs.getBool('pushNotificationsEnabled') ?? true;

  Future<void> setEmailNotificationsEnabled(bool value) =>
      _prefs.setBool('emailNotificationsEnabled', value);

  bool isEmailNotificationsEnabled() =>
      _prefs.getBool('emailNotificationsEnabled') ?? false;

  // Clear all data (logout)
  Future<void> clearAll() => _prefs.clear();

  /// Clears session and profile fields but keeps onboarding and preferences.
  Future<void> logout() async {
    await clearToken();
    await setAuthenticated(false);
    await _prefs.remove('userName');
    await _prefs.remove('userPhone');
    await _prefs.remove('userEmail');
  }

  // Home Area - where user lives
  Future<void> saveHomeArea(String areaName, double lat, double lon) async {
    await _prefs.setString('homeAreaName', areaName);
    await _prefs.setDouble('homeAreaLat', lat);
    await _prefs.setDouble('homeAreaLon', lon);
  }

  String? getHomeAreaName() => _prefs.getString('homeAreaName');
  double? getHomeAreaLat() => _prefs.getDouble('homeAreaLat');
  double? getHomeAreaLon() => _prefs.getDouble('homeAreaLon');

  bool hasHomeArea() => _prefs.getString('homeAreaName') != null;

  Future<void> clearHomeArea() async {
    await _prefs.remove('homeAreaName');
    await _prefs.remove('homeAreaLat');
    await _prefs.remove('homeAreaLon');
  }
}
