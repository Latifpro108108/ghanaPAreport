import '../models/report.dart';
import 'storage_service.dart';

/// Service to manage outage reports and crowd-sourced verifications
class ReportService {
  static const String _reportsKey = 'outage_reports';
  static const String _myVerificationsKey = 'my_verifications';

  /// Store a new report
  static Future<void> saveReport(Report report) async {
    final storage = StorageService();
    final reports = await getReports();
    reports.add(report);
    await storage.setString(_reportsKey, _encodeReports(reports));
  }

  /// Get all reports
  static Future<List<Report>> getReports() async {
    final storage = StorageService();
    final data = storage.getString(_reportsKey);
    if (data == null) return [];
    return _decodeReports(data);
  }

  /// Get reports for a specific area
  static Future<List<Report>> getReportsForArea(String areaId) async {
    final reports = await getReports();
    return reports.where((r) => r.areaId == areaId).toList();
  }

  /// Get active (pending) reports for an area
  static Future<List<Report>> getActiveReportsForArea(String areaId) async {
    final reports = await getReportsForArea(areaId);
    final now = DateTime.now();
    return reports.where((r) {
      // Only show reports from last 24 hours
      final age = now.difference(r.timestamp);
      if (age.inHours > 24) return false;
      // Only show pending or recently verified
      return r.isPending || (r.isVerified && age.inHours < 6);
    }).toList();
  }

  /// Confirm a report (user says "yes, power is off here too")
  static Future<void> confirmReport(String reportId, String userId) async {
    final storage = StorageService();
    final reports = await getReports();
    final index = reports.indexWhere((r) => r.id == reportId);
    
    if (index == -1) return;
    
    final report = reports[index];
    if (report.verifiedBy.contains(userId)) return; // Already verified
    
    reports[index] = report.copyWith(
      confirmCount: report.confirmCount + 1,
      verifiedBy: [...report.verifiedBy, userId],
      status: report.confirmCount + 1 >= 3 ? ReportStatus.confirmed : report.status,
    );
    
    await storage.setString(_reportsKey, _encodeReports(reports));
    await _recordMyVerification(userId, reportId, 'confirm');
  }

  /// Reject a report (user says "no, I have power")
  static Future<void> rejectReport(String reportId, String userId) async {
    final storage = StorageService();
    final reports = await getReports();
    final index = reports.indexWhere((r) => r.id == reportId);
    
    if (index == -1) return;
    
    final report = reports[index];
    if (report.verifiedBy.contains(userId)) return; // Already verified
    
    reports[index] = report.copyWith(
      rejectCount: report.rejectCount + 1,
      verifiedBy: [...report.verifiedBy, userId],
      status: report.rejectCount + 1 >= 3 ? ReportStatus.rejected : report.status,
    );
    
    await storage.setString(_reportsKey, _encodeReports(reports));
    await _recordMyVerification(userId, reportId, 'reject');
  }

  /// Check if user has already verified a report
  static Future<bool> hasUserVerified(String reportId, String userId) async {
    final myVerifications = await _getMyVerifications(userId);
    return myVerifications.containsKey(reportId);
  }

  /// Create a new outage report
  static Future<Report> createReport({
    required String areaId,
    required String areaName,
    required String reporterId,
    required String reporterName,
    required ReportType type,
    String? notes,
  }) async {
    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      areaId: areaId,
      areaName: areaName,
      reporterId: reporterId,
      reporterName: reporterName,
      type: type,
      timestamp: DateTime.now(),
      notes: notes,
    );
    await saveReport(report);
    return report;
  }

  // Private helpers
  static String _encodeReports(List<Report> reports) {
    return reports.map((r) => r.toJson()).toList().toString();
  }

  static List<Report> _decodeReports(String data) {
    try {
      final List<dynamic> list = [];
      return list.map((e) => Report.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _recordMyVerification(String userId, String reportId, String action) async {
    final storage = StorageService();
    final key = '${_myVerificationsKey}_$userId';
    final verifications = await _getMyVerifications(userId);
    verifications[reportId] = action;
    await storage.setString(key, verifications.toString());
  }

  static Future<Map<String, String>> _getMyVerifications(String userId) async {
    final storage = StorageService();
    final key = '${_myVerificationsKey}_$userId';
    final data = storage.getString(key);
    if (data == null) return {};
    try {
      return Map<String, String>.from({});
    } catch (e) {
      return {};
    }
  }
}
