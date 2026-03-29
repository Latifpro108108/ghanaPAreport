import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../data/mock_data.dart';
import '../models/district.dart';
import '../widgets/district_card.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';

class DistrictsScreen extends StatefulWidget {
  const DistrictsScreen({Key? key}) : super(key: key);

  @override
  State<DistrictsScreen> createState() => _DistrictsScreenState();
}

class _DistrictsScreenState extends State<DistrictsScreen> {
  late TextEditingController _searchController;
  String _filterStatus = 'all'; // all, outage, restored, normal

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<District> _getFilteredDistricts() {
    final query = _searchController.text.toLowerCase();

    return districts.where((district) {
      final matchesSearch = district.name.toLowerCase().contains(query) ||
          district.region.toLowerCase().contains(query);
      final matchesFilter =
          _filterStatus == 'all' || district.status.name == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _toggleDistrict(District district) async {
    final storageService = context.read<StorageService>();

    setState(() {
      district.isMonitored = !district.isMonitored;
    });

    if (district.isMonitored) {
      await storageService.addMonitoredDistrict(district.id);
      _showMessage('Now monitoring ${district.name}');
    } else {
      await storageService.removeMonitoredDistrict(district.id);
      _showMessage('Stopped monitoring ${district.name}');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDistricts = _getFilteredDistricts();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header - Matches React
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Districts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                // Search - Matches React styling
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search districts...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips - Matches React
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('outage', 'Outage'),
                      const SizedBox(width: 8),
                      _buildFilterChip('restored', 'Restored'),
                      const SizedBox(width: 8),
                      _buildFilterChip('normal', 'Normal'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider like React
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          // Districts List
          Expanded(
            child: filteredDistricts.isEmpty
                ? Center(
                    child: Text(
                      'No districts found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDistricts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DistrictCard(
                          district: filteredDistricts[index],
                          showToggle: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isActive = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
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
                onTap: () => context.go('/home'),
              ),
              _buildNavItem(
                icon: Icons.map_outlined,
                label: 'Districts',
                isActive: currentPath == '/districts',
                onTap: () {},
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
}
