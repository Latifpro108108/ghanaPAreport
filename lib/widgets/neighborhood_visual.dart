import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A visual representation of the user's neighborhood showing
/// power status across different zones (streets/blocks)
class NeighborhoodVisual extends StatelessWidget {
  final String userArea;
  final List<ZoneStatus> zones;
  final VoidCallback? onZoneTap;

  const NeighborhoodVisual({
    super.key,
    required this.userArea,
    required this.zones,
    this.onZoneTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with area name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Area',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      userArea,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 20),
          
          // Visual neighborhood grid
          _buildNeighborhoodGrid(),
          
          const SizedBox(height: 16),
          
          // Stats summary
          _buildStatsSummary(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendItem(Colors.green, 'Power On'),
        const SizedBox(width: 12),
        _legendItem(Colors.red, 'Outage'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNeighborhoodGrid() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Stack(
        children: [
          // Grid of streets and blocks
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main road indicator at top
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'Main Road',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Streets and blocks
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: zones.length,
                    itemBuilder: (context, index) {
                      return _buildZoneCard(zones[index], index);
                    },
                  ),
                ),
                
                // You are here indicator
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'You are here',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Pulsing effect for current location
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: _buildPulseEffect(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(ZoneStatus zone, int index) {
    final isUserZone = zone.isUserLocation;
    final hasOutage = zone.hasOutage;
    
    return GestureDetector(
      onTap: onZoneTap != null ? () => onZoneTap!() : null,
      child: Container(
        decoration: BoxDecoration(
          color: hasOutage ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUserZone
                ? const Color(0xFF2563EB)
                : hasOutage
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF86EFAC),
            width: isUserZone ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasOutage ? Icons.flash_off : Icons.flash_on,
              color: hasOutage ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              zone.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: hasOutage ? const Color(0xFFDC2626) : const Color(0xFF166534),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUserZone) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPulseEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Container(
          width: 40 + (value * 20),
          height: 40 + (value * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2563EB).withOpacity(0.3 * (1 - value)),
          ),
        );
      },
      onEnd: () {
        // Loop handled by parent rebuild
      },
    );
  }

  Widget _buildStatsSummary() {
    final totalZones = zones.length;
    final outageZones = zones.where((z) => z.hasOutage).length;
    final normalZones = totalZones - outageZones;
    final outagePercentage = totalZones > 0 ? (outageZones / totalZones * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Blocks', totalZones.toString(), Icons.grid_view),
          _buildStatItem('With Power', normalZones.toString(), Icons.flash_on, color: Colors.green),
          _buildStatItem('Outages', '$outageZones ($outagePercentage%)', Icons.flash_off, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? Colors.grey),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Represents a zone (street/block) in the neighborhood
class ZoneStatus {
  final String id;
  final String name;
  final bool hasOutage;
  final bool isUserLocation;
  final String? lastUpdated;
  final int? affectedHouses;

  const ZoneStatus({
    required this.id,
    required this.name,
    required this.hasOutage,
    this.isUserLocation = false,
    this.lastUpdated,
    this.affectedHouses,
  });
}

/// Mock data generator for neighborhood zones
class NeighborhoodData {
  static List<ZoneStatus> generateMockZones(String areaName) {
    final random = math.Random();
    final zones = [
      'Block A',
      'Block B',
      'Block C',
      'Block D',
      'Block E',
      'Block F',
      'Block G',
      'Block H',
      'Block I',
    ];
    
    return zones.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      // Center block is user location
      final isUser = index == 4;
      // Random outage for some blocks
      final hasOutage = !isUser && random.nextBool() && random.nextDouble() > 0.6;
      
      return ZoneStatus(
        id: 'zone_$index',
        name: name,
        hasOutage: hasOutage,
        isUserLocation: isUser,
        lastUpdated: hasOutage ? '2 hours ago' : null,
        affectedHouses: hasOutage ? random.nextInt(20) + 5 : null,
      );
    }).toList();
  }
}
