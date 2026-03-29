import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../data/accra_areas.dart';
import '../data/mock_data.dart';
import '../models/district.dart';
import '../widgets/district_card.dart';
import '../widgets/neighborhood_visual.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMapView = false;
  String _userArea = 'Detecting location...';
  String? _userAreaSubtitle;
  List<ZoneStatus> _zones = [];
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _detectUserLocation();
  }

  Future<void> _detectUserLocation() async {
    setState(() => _isLoadingLocation = true);

    final position = await LocationService.getCurrentPosition();
    final result = LocationService.resolveAccraNeighborhood(position);

    if (!mounted) return;

    if (result is AccraLocationMatched) {
      final n = result.neighborhood;
      setState(() {
        _userArea = n.shortLabel;
        _userAreaSubtitle = n.description;
        _zones = NeighborhoodData.generateZonesForAccraArea(
          neighborhoodId: n.id,
          displayName: n.shortLabel,
        );
        _isLoadingLocation = false;
      });
      return;
    }

    if (result is AccraLocationOutside) {
      setState(() {
        _userArea = 'Accra (pick area)';
        _userAreaSubtitle = result.message;
        _zones = NeighborhoodData.generateZonesForAccraArea(
          neighborhoodId: 'central-ridge',
          displayName: _userArea,
        );
        _isLoadingLocation = false;
      });
      return;
    }

    setState(() {
      _userArea = 'Accra Metro (default)';
      _userAreaSubtitle = 'Turn on location for your Accra neighborhood';
      _zones = NeighborhoodData.generateZonesForAccraArea(
        neighborhoodId: 'central-ridge',
        displayName: _userArea,
      );
      _isLoadingLocation = false;
    });
  }

  Future<List<District>> _getMonitoredDistricts() async {
    final storage = context.read<StorageService>();
    final monitoredDistrictIds = storage.getMonitoredDistricts();
    return districts.where((d) => monitoredDistrictIds.contains(d.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: FutureBuilder<List<District>>(
        future: _getMonitoredDistricts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final monitoredDistricts = snapshot.data ?? [];
          final allDistricts = districts;
          final outageCount = allDistricts
              .where((d) => d.status == DistrictStatus.outage)
              .length;
          final restoredCount = allDistricts
              .where((d) => d.status == DistrictStatus.restored)
              .length;

          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Header - Matches React exactly
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        children: [
                          // Title row with notification
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PowerAlert GH',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Community Power Monitoring',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => context.go('/alerts'),
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        Icons.notifications_outlined,
                                        color: Color(0xFF4B5563),
                                        size: 24,
                                      ),
                                    ),
                                    // Red notification dot
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stats row - Matches React (red/green cards side by side)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFFEE2E2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        outageCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Active Outages',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFDCFCE7)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restoredCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Recently Restored',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // View Toggle - Matches React segmented control
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isMapView = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: !_isMapView
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: !_isMapView
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'My Districts',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: !_isMapView
                                              ? AppColors.primary
                                              : const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isMapView = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _isMapView
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: _isMapView
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 16,
                                            color: _isMapView
                                                ? AppColors.primary
                                                : const Color(0xFF4B5563),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Area view',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: _isMapView
                                                  ? AppColors.primary
                                                  : const Color(0xFF4B5563),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: !_isMapView
                          ? _buildDistrictsList(monitoredDistricts)
                          : _buildMapView(),
                    ),
                  ],
                ),
              ),
              // FAB - Positioned above bottom nav like React
              Positioned(
                bottom: 80,
                right: 24,
                child: GestureDetector(
                  onTap: () => _showReportModal(context),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDistrictsList(List<District> monitoredDistricts) {
    if (monitoredDistricts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No districts monitored yet',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.go('/districts'),
              child: const Text(
                'Browse Districts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: monitoredDistricts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DistrictCard(district: monitoredDistricts[index]),
        );
      },
    );
  }

  Widget _buildMapView() {
    if (_isLoadingLocation) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Location detection button
          if (_userArea == 'Detecting location...')
            GestureDetector(
              onTap: _detectUserLocation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_searching,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap to detect your location',
                        style: TextStyle(
                          color: Color(0xFF1E40AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
            )
          else
            NeighborhoodVisual(
              userArea: _userArea,
              areaSubtitle: _userAreaSubtitle,
              zones: _zones,
            ),
          const SizedBox(height: 16),
          // Refresh location button
          GestureDetector(
            onTap: _detectUserLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.my_location,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Refresh Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: currentPath == '/home',
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.map_outlined,
                label: 'Districts',
                isActive: currentPath == '/districts',
                onTap: () => context.go('/districts'),
              ),
              _buildNavItem(
                icon: Icons.notifications_outlined,
                label: 'Alerts',
                isActive: currentPath == '/alerts',
                onTap: () => context.go('/alerts'),
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isActive: currentPath == '/profile',
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : const Color(0xFF6B7280),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primary : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Power Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help your community by reporting power outages or restorations',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Outage reported!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flash_off,
                            color: AppColors.outageRed,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Report Outage',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.outageRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restoration reported!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flash_on,
                            color: AppColors.restoredGreen,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Power Restored',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.restoredGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Cancel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
