import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/openstreetmap_service.dart';
import '../services/firebase_vote_service.dart';
import '../services/notification_service.dart';
import '../models/firestore_models.dart';

/// IMPROVED Home Screen - Time-based voting with visual comparison
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _homeAreaName;
  String _currentAreaName = 'Detecting...';
  String? _currentAreaContext;
  bool _isLoadingLocation = true;
  StreamSubscription<Position>? _locationStream;

  // Firebase services
  final FirebaseVoteService _voteService = FirebaseVoteService();
  final NotificationService _notificationService = NotificationService();

  // Current user
  User? _currentUser;
  String? _currentAreaIdSubscribed;

  // Store votes with timestamps per area: areaId -> list of votes
  Map<String, List<VoteData>> _areaVotes = {};
  StreamSubscription? _votesSubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadHomeArea();
    _startLocationTracking();
    _startNotificationTimer();
  }

  Future<void> _initializeServices() async {
    // Initialize notification service
    await _notificationService.initialize();

    // Get current user
    _currentUser = FirebaseAuth.instance.currentUser;

    // Listen to auth changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() => _currentUser = user);
    });
  }

  void _startNotificationTimer() {
    // Check every 30 minutes if power is back
    Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkAndNotifyPowerStatus();
    });
  }

  void _checkAndNotifyPowerStatus() {
    final currentAreaId = _currentAreaName.toLowerCase().replaceAll(' ', '_');
    final recentVotes = _getRecentVotes(currentAreaId);

    // If user voted OFF in last 30 min, ask if power is back
    final thirtyMinutesAgo =
        DateTime.now().subtract(const Duration(minutes: 30));
    final userRecentOffVote = recentVotes.any((v) =>
        v.status == PowerStatus.off && v.timestamp.isAfter(thirtyMinutesAgo));

    if (userRecentOffVote) {
      _showPowerBackNotification();
    }
  }

  void _showPowerBackNotification() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Power Update?'),
        content: const Text(
            'You reported no power 30 minutes ago. Is the power back now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final currentAreaId =
                  _currentAreaName.toLowerCase().replaceAll(' ', '_');
              _votePowerStatus(currentAreaId, PowerStatus.off);
            },
            child: const Text('Still No Power',
                style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final currentAreaId =
                  _currentAreaName.toLowerCase().replaceAll(' ', '_');
              _votePowerStatus(currentAreaId, PowerStatus.on);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Power is Back!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationStream?.cancel();
    _votesSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }

  void _loadHomeArea() {
    final storage = context.read<StorageService>();
    setState(() {
      _homeAreaName = storage.getHomeAreaName();
    });
  }

  void _startLocationTracking() {
    _updateCurrentLocation();
    _locationStream = LocationService.getLocationStream().listen((position) {
      _updateCurrentLocationFromPosition(position);
    });
  }

  void _subscribeToAreaVotes(String areaId) {
    _votesSubscription?.cancel();
    _votesSubscription = _voteService.getRecentVotes(areaId).listen((votes) {
      setState(() {
        _areaVotes[areaId] = votes;
      });
    });
  }

  Future<void> _updateCurrentLocation() async {
    final position = await LocationService.getCurrentPosition();
    await _updateCurrentLocationFromPosition(position);
  }

  Future<void> _updateCurrentLocationFromPosition(Position? position) async {
    if (!mounted) return;
    if (position == null) {
      setState(() {
        _currentAreaName = 'Location unavailable';
        _isLoadingLocation = false;
      });
      return;
    }

    final place = await OpenStreetMapService.reverseGeocode(
      position.latitude,
      position.longitude,
    );

    if (place != null) {
      setState(() {
        _currentAreaName = place.shortName;
        _currentAreaContext = place.areaContext;
        _isLoadingLocation = false;
      });
      // Subscribe to real-time votes for this area
      final areaId = place.shortName.toLowerCase().replaceAll(' ', '_');
      _subscribeToAreaVotes(areaId);
      // Subscribe to area notifications
      _notificationService.subscribeToArea(areaId);
    }
  }

  void _setCurrentLocationAsHome() async {
    if (_currentAreaName == 'Detecting...' ||
        _currentAreaName == 'Location unavailable') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please wait for location to be detected')),
      );
      return;
    }
    final storage = context.read<StorageService>();
    await storage.saveHomeArea(_currentAreaName, 0, 0);
    setState(() {
      _homeAreaName = _currentAreaName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Home area set to: $_currentAreaName')),
    );
  }

  void _showHomeAreaOptions() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Home Area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isLoadingLocation &&
                _currentAreaName != 'Location unavailable')
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.ghanaGold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location, color: Colors.black87),
                ),
                title: const Text('Use Current Location'),
                subtitle: Text(_currentAreaName),
                onTap: () => Navigator.pop(context, 'current'),
              ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, color: Colors.black54),
              ),
              title: const Text('Search for Area'),
              subtitle: const Text('Find a specific neighborhood or area'),
              onTap: () => Navigator.pop(context, 'search'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result == 'current') {
      _setCurrentLocationAsHome();
    } else if (result == 'search') {
      _setOrChangeHomeArea();
    }
  }

  void _setOrChangeHomeArea() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SetHomeAreaDialog(
        currentArea: _homeAreaName,
      ),
    );
    if (result != null && result.isNotEmpty) {
      final storage = context.read<StorageService>();
      await storage.saveHomeArea(result, 0, 0);
      setState(() {
        _homeAreaName = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Home area updated to: $result')),
      );
    }
  }

  // Track if current user has voted in an area
  Map<String, bool> _userHasVoted = {};

  void _votePowerStatus(String areaId, PowerStatus status) async {
    // Check if user already voted in this area
    if (_userHasVoted[areaId] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('You already voted in this area. Remove your vote first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final now = DateTime.now();

    // Save to local state for immediate UI update
    setState(() {
      if (!_areaVotes.containsKey(areaId)) {
        _areaVotes[areaId] = [];
      }
      _areaVotes[areaId]!.add(VoteData(status: status, timestamp: now));
      _userHasVoted[areaId] = true;
    });

    // Save to Firebase
    await _voteService.submitVote(areaId, status, _currentUser?.uid);

    // Subscribe to area notifications
    await _notificationService.subscribeToArea(areaId);
    _currentAreaIdSubscribed = areaId;

    // Check for crowd detection
    await _checkForCrowdAlert(areaId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your report has been recorded.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _checkForCrowdAlert(String areaId) async {
    // Get votes from local state for crowd detection
    final recentVotes = _getRecentVotes(areaId);

    // Only check if we have 3+ total votes in this area
    if (recentVotes.length >= 3) {
      final onCount =
          recentVotes.where((v) => v.status == PowerStatus.on).length;
      final offCount =
          recentVotes.where((v) => v.status == PowerStatus.off).length;

      // If 70% or more agree on one status
      if (onCount >= recentVotes.length * 0.7) {
        await _showCrowdNotification(
            areaId, 'Power is likely ON', PowerStatus.on);
      } else if (offCount >= recentVotes.length * 0.7) {
        await _showCrowdNotification(
            areaId, 'Power outage likely in this area', PowerStatus.off);
      }
    }
  }

  Future<void> _showCrowdNotification(
      String areaId, String message, PowerStatus status) async {
    // Show local notification
    await _notificationService.showCrowdAlertNotification(
      areaId,
      _currentAreaName,
      message,
    );

    // Show dialog for immediate feedback
    if (mounted) {
      _showCrowdAlert(areaId, message);
    }
  }

  void _removeLastVote(String areaId) async {
    // Remove from Firebase
    await _voteService.removeLastVote(areaId, _currentUser?.uid);

    // Remove from local state
    setState(() {
      if (_areaVotes.containsKey(areaId) && _areaVotes[areaId]!.isNotEmpty) {
        _areaVotes[areaId]!.removeLast();
        if (_areaVotes[areaId]!.isEmpty) {
          _areaVotes.remove(areaId);
        }
      }
      _userHasVoted[areaId] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Your vote has been removed. You can now vote again.')),
    );
  }

  void _showCrowdAlert(String areaId, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Community Alert'),
        content: Text('Many users are reporting: $message'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Get recent votes only (last 6 hours) for accurate status
  List<VoteData> _getRecentVotes(String areaId) {
    final allVotes = _areaVotes[areaId] ?? [];
    final cutoff = DateTime.now().subtract(const Duration(hours: 6));
    return allVotes.where((v) => v.timestamp.isAfter(cutoff)).toList();
  }

  // Calculate current status based on most recent votes
  PowerStatus _getCurrentStatus(String areaId) {
    final recentVotes = _getRecentVotes(areaId);
    if (recentVotes.isEmpty) return PowerStatus.unknown;

    // Sort by timestamp (newest first)
    recentVotes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Get votes from last 30 minutes only for current status
    final veryRecent = recentVotes
        .where(
          (v) => v.timestamp
              .isAfter(DateTime.now().subtract(const Duration(minutes: 30))),
        )
        .toList();

    if (veryRecent.isNotEmpty) {
      // Count ON vs OFF in last 30 min
      final onCount =
          veryRecent.where((v) => v.status == PowerStatus.on).length;
      final offCount =
          veryRecent.where((v) => v.status == PowerStatus.off).length;
      return onCount >= offCount ? PowerStatus.on : PowerStatus.off;
    }

    // If no votes in 30 min, use most recent single vote
    return recentVotes.first.status;
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final isAtHome = _homeAreaName == _currentAreaName;
    final homeAreaId = _homeAreaName?.toLowerCase().replaceAll(' ', '_') ?? '';
    final currentAreaId = _currentAreaName.toLowerCase().replaceAll(' ', '_');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              // VISUAL: Power ON vs OFF vote comparison for current area
              if (!_isLoadingLocation) _buildVoteComparisonCard(currentAreaId),
              const SizedBox(height: 20),

              // My Home Area Card with Change button
              _buildSectionTitle('My Home Area'),
              const SizedBox(height: 8),
              _homeAreaName != null
                  ? _buildHomeAreaCard(homeAreaId, isAtHome)
                  : _buildSetHomeAreaPrompt(),
              const SizedBox(height: 20),

              // Current Location Card with voting
              _buildSectionTitle('Where I Am Now'),
              const SizedBox(height: 10),
              _buildCurrentLocationCard(currentAreaId, isAtHome),
              const SizedBox(height: 20),

              // ECG News
              _buildSectionTitle('ECG News'),
              const SizedBox(height: 8),
              _buildAnnouncementPreview(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ghanaGold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: Colors.black87, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PowerAlert GH',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text('Community Power Monitoring',
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isLoadingLocation ? '...' : _currentAreaName.split(' ').first,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  // NEW: Visual vote comparison bar chart
  Widget _buildVoteComparisonCard(String areaId) {
    final recentVotes = _getRecentVotes(areaId);
    final onCount = recentVotes.where((v) => v.status == PowerStatus.on).length;
    final offCount =
        recentVotes.where((v) => v.status == PowerStatus.off).length;
    final total = onCount + offCount;

    final onPercent = total > 0 ? (onCount / total * 100) : 0;
    final offPercent = total > 0 ? (offCount / total * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_currentAreaName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              if (total > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: onCount >= offCount
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : const Color(0xFFE53935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: onCount >= offCount
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                    ),
                  ),
                  child: Text(
                    onCount >= offCount ? 'LIKELY ON' : 'LIKELY OFF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: onCount >= offCount
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Power Status Votes (last 6 hours):',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),

          // Bar chart
          Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
            ),
            child: total > 0
                ? Row(
                    children: [
                      // Green bar for ON votes
                      Expanded(
                        flex: onCount,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              bottomLeft: const Radius.circular(16),
                              topRight: offCount == 0
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomRight: offCount == 0
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                            ),
                          ),
                          child: onCount > 0
                              ? Center(
                                  child: Text(
                                    '$onCount ON',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      // Red bar for OFF votes
                      Expanded(
                        flex: offCount,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(16),
                              bottomRight: const Radius.circular(16),
                              topLeft: onCount == 0
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomLeft: onCount == 0
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                            ),
                          ),
                          child: offCount > 0
                              ? Center(
                                  child: Text(
                                    '$offCount OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'No reports yet - be the first!',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
          ),
          if (total > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${onPercent.toInt()}% say Power ON',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF4CAF50))),
                  Text('${offPercent.toInt()}% say No Power',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFE53935))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeAreaCard(String homeAreaId, bool isAtHome) {
    final homeStatus = _getCurrentStatus(homeAreaId);
    final recentVotes = _getRecentVotes(homeAreaId);
    final lastReport = recentVotes.isNotEmpty ? recentVotes.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAtHome ? AppColors.ghanaGold : Colors.grey.shade300,
          width: isAtHome ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isAtHome
                      ? AppColors.ghanaGold.withOpacity(0.2)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.home,
                    color: isAtHome ? Colors.black87 : Colors.grey, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_homeAreaName!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    if (isAtHome)
                      const Text('You are currently here',
                          style: TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
              ),
              _buildStatusBadge(homeStatus),
            ],
          ),
          if (lastReport != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 46),
              child: Text(
                'Last report: ${_getTimeAgo(lastReport.timestamp)}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
          const SizedBox(height: 12),
          // Change Home Area button
          GestureDetector(
            onTap: _showHomeAreaOptions,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_location, size: 16, color: Colors.black54),
                  SizedBox(width: 4),
                  Text('Change Home Area',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetHomeAreaPrompt() {
    return GestureDetector(
      onTap: _showHomeAreaOptions,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ghanaGold, width: 2),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_location, color: Colors.black87),
            SizedBox(width: 12),
            Expanded(
                child: Text('Set your home area',
                    style: TextStyle(fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationCard(String areaId, bool isAtHome) {
    final status = _getCurrentStatus(areaId);
    final recentVotes = _getRecentVotes(areaId);
    final lastReport = recentVotes.isNotEmpty ? recentVotes.first : null;

    return GestureDetector(
      onTap: _homeAreaName == null ? _setCurrentLocationAsHome : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingLocation)
              const Row(
                children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Finding your location...'),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_currentAreaName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      if (_currentAreaContext != null)
                        Text(_currentAreaContext!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  _buildStatusBadge(status),
                ],
              ),
            if (!_isLoadingLocation) ...[
              if (lastReport != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Last report: ${_getTimeAgo(lastReport.timestamp)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Report current power status:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              // Show voting buttons OR already voted message
              if (_userHasVoted[areaId] == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2196F3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF2196F3), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You have already voted in this area',
                          style: TextStyle(
                            color: const Color(0xFF1976D2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _removeLastVote(areaId),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.undo, size: 16, color: Colors.black54),
                        SizedBox(width: 4),
                        Text('Remove my vote to vote again',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _votePowerStatus(areaId, PowerStatus.on),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF4CAF50)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flash_on,
                                  color: Color(0xFF4CAF50), size: 18),
                              SizedBox(width: 4),
                              Text('Power ON',
                                  style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _votePowerStatus(areaId, PowerStatus.off),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE53935)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flash_off,
                                  color: Color(0xFFE53935), size: 18),
                              SizedBox(width: 4),
                              Text('No Power',
                                  style: TextStyle(
                                      color: Color(0xFFE53935),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTimeline(String areaId) {
    final recentVotes = _getRecentVotes(areaId);
    // Show last 5 votes
    final displayVotes = recentVotes.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: displayVotes.map((vote) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  vote.status == PowerStatus.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: vote.status == PowerStatus.on
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  vote.status == PowerStatus.on ? 'Power ON' : 'No Power',
                  style: TextStyle(
                    fontSize: 13,
                    color: vote.status == PowerStatus.on
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                  ),
                ),
                const Spacer(),
                Text(
                  _getTimeAgo(vote.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(PowerStatus status) {
    Color color;
    String text;
    switch (status) {
      case PowerStatus.on:
        color = const Color(0xFF4CAF50);
        text = 'ON';
        break;
      case PowerStatus.off:
        color = const Color(0xFFE53935);
        text = 'OFF';
        break;
      case PowerStatus.unknown:
        color = Colors.grey;
        text = '?';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildAnnouncementPreview() {
    return GestureDetector(
      onTap: () => context.go('/announcements'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.ghanaGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.campaign, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scheduled Maintenance',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('ECG • 2 hours ago',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.notifications, 'Alerts', false,
                  () => context.go('/alerts')),
              _buildNavItem(Icons.campaign, 'News', false,
                  () => context.go('/announcements')),
              _buildNavItem(
                  Icons.person, 'Profile', false, () => context.go('/profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive,
      [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.black87 : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.black87 : Colors.grey,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }
}

enum PowerStatus { on, off, unknown }

class VoteData {
  final PowerStatus status;
  final DateTime timestamp;

  VoteData({required this.status, required this.timestamp});
}

class SetHomeAreaDialog extends StatefulWidget {
  final String? currentArea;

  const SetHomeAreaDialog({super.key, this.currentArea});

  @override
  State<SetHomeAreaDialog> createState() => _SetHomeAreaDialogState();
}

class _SetHomeAreaDialogState extends State<SetHomeAreaDialog> {
  final _controller = TextEditingController();
  List<OSMPlace> _results = [];
  bool _searching = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.currentArea != null) {
      _controller.text = widget.currentArea!;
    }
  }

  Future<void> _search(String query) async {
    if (query.length < 3) {
      setState(() {
        _results = [];
        _errorMessage = null;
      });
      return;
    }
    setState(() {
      _searching = true;
      _errorMessage = null;
    });

    debugPrint('Searching for: $query');

    try {
      final results =
          await OpenStreetMapService.searchPlace(query, countryCode: 'gh');

      debugPrint('Search results: ${results.length} found');

      if (mounted) {
        setState(() {
          _results = results;
          _searching = false;
          if (results.isEmpty) {
            _errorMessage = 'No areas found. Try: Accra, Kumasi, Takoradi';
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Search error: $e');
      debugPrint('Stack: $stackTrace');
      if (mounted) {
        setState(() {
          _searching = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.currentArea == null ? 'Set Home Area' : 'Change Home Area'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search area (e.g., Cantonments)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            if (_searching)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Text(_errorMessage!,
                  style: TextStyle(color: Colors.red.shade600, fontSize: 12))
            else if (_results.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (ctx, i) => ListTile(
                    title: Text(_results[i].shortName),
                    subtitle: Text(_results[i].areaContext,
                        style: const TextStyle(fontSize: 11)),
                    onTap: () => Navigator.pop(context, _results[i].shortName),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
