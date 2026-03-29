import 'package:poweralert_gh_flutter/models/district.dart';
import 'package:poweralert_gh_flutter/models/alert.dart';
import 'package:poweralert_gh_flutter/models/user.dart';

// Current user data
final User currentUser = User(
  id: '1',
  name: 'Kwame Mensah',
  phone: '+233 24 123 4567',
  email: 'kwame@example.com',
  joinedDate: 'March 2026',
  reportsSubmitted: 12,
  helpfulVotes: 45,
);

// Ghana districts data
final List<District> districts = [
  District(
    id: 'acc-metro',
    name: 'Accra Metropolitan',
    region: 'Greater Accra',
    status: DistrictStatus.outage,
    lastReportedAt: '2 hours ago',
    activeReports: 24,
    isMonitored: true,
  ),
  District(
    id: 'tema-metro',
    name: 'Tema Metropolitan',
    region: 'Greater Accra',
    status: DistrictStatus.normal,
    activeReports: 0,
    isMonitored: true,
  ),
  District(
    id: 'kumasi-metro',
    name: 'Kumasi Metropolitan',
    region: 'Ashanti',
    status: DistrictStatus.restored,
    lastReportedAt: '30 mins ago',
    activeReports: 5,
    isMonitored: true,
  ),
  District(
    id: 'cape-coast',
    name: 'Cape Coast',
    region: 'Central',
    status: DistrictStatus.normal,
    activeReports: 0,
    isMonitored: false,
  ),
  District(
    id: 'takoradi',
    name: 'Sekondi-Takoradi',
    region: 'Western',
    status: DistrictStatus.outage,
    lastReportedAt: '1 hour ago',
    activeReports: 12,
    isMonitored: false,
  ),
  District(
    id: 'tamale',
    name: 'Tamale Metropolitan',
    region: 'Northern',
    status: DistrictStatus.normal,
    activeReports: 0,
    isMonitored: true,
  ),
  District(
    id: 'wa',
    name: 'Wa Municipal',
    region: 'Upper West',
    status: DistrictStatus.normal,
    activeReports: 0,
    isMonitored: false,
  ),
  District(
    id: 'bolgatanga',
    name: 'Bolgatanga Municipal',
    region: 'Upper East',
    status: DistrictStatus.normal,
    activeReports: 0,
    isMonitored: false,
  ),
  District(
    id: 'ho',
    name: 'Ho Municipal',
    region: 'Volta',
    status: DistrictStatus.restored,
    lastReportedAt: '45 mins ago',
    activeReports: 3,
    isMonitored: false,
  ),
  District(
    id: 'koforidua',
    name: 'New Juaben',
    region: 'Eastern',
    status: DistrictStatus.normal,
    activeReports: 0,
    isMonitored: false,
  ),
  District(
    id: 'sunyani',
    name: 'Sunyani Municipal',
    region: 'Bono',
    status: DistrictStatus.normal,
    activeReports: 0,
    isMonitored: false,
  ),
  District(
    id: 'techiman',
    name: 'Techiman Municipal',
    region: 'Bono East',
    status: DistrictStatus.normal,
    activeReports: 0,
    isMonitored: false,
  ),
];

// Mock reports
final List<Report> reports = [
  Report(
    id: 'r1',
    districtId: 'acc-metro',
    districtName: 'Accra Metropolitan',
    type: ReportType.outage,
    timestamp: '2 hours ago',
    upvotes: 18,
    downvotes: 2,
    reportedBy: 'Kwame A.',
  ),
  Report(
    id: 'r2',
    districtId: 'acc-metro',
    districtName: 'Accra Metropolitan',
    type: ReportType.outage,
    timestamp: '2 hours ago',
    upvotes: 15,
    downvotes: 1,
    reportedBy: 'Ama K.',
  ),
  Report(
    id: 'r3',
    districtId: 'kumasi-metro',
    districtName: 'Kumasi Metropolitan',
    type: ReportType.restored,
    timestamp: '30 mins ago',
    upvotes: 8,
    downvotes: 0,
    reportedBy: 'Kofi M.',
  ),
  Report(
    id: 'r4',
    districtId: 'takoradi',
    districtName: 'Sekondi-Takoradi',
    type: ReportType.outage,
    timestamp: '1 hour ago',
    upvotes: 10,
    downvotes: 1,
    reportedBy: 'Abena S.',
  ),
];

// Mock alerts
final List<Alert> alerts = [
  Alert(
    id: 'a1',
    districtName: 'Accra Metropolitan',
    message: 'Power outage reported in your monitored district',
    timestamp: '2 hours ago',
    type: AlertType.outage,
    read: false,
  ),
  Alert(
    id: 'a2',
    districtName: 'Kumasi Metropolitan',
    message: 'Power has been restored',
    timestamp: '30 mins ago',
    type: AlertType.restored,
    read: false,
  ),
  Alert(
    id: 'a3',
    districtName: 'System',
    message:
        'Welcome to PowerAlert GH! Start monitoring districts to receive alerts.',
    timestamp: '1 day ago',
    type: AlertType.info,
    read: true,
  ),
];
