import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/alert.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Alert> _mockAlerts = [
    Alert(
      id: '1',
      districtName: 'Accra Metro',
      message:
          'Scheduled maintenance: Power will be cut off from 10 PM to 6 AM',
      timestamp: '2024-01-15 22:00',
      type: AlertType.info,
      read: false,
    ),
    Alert(
      id: '2',
      districtName: 'Kumasi Central',
      message: 'Transformer failure reported in the area',
      timestamp: '2024-01-15 14:30',
      type: AlertType.outage,
      read: false,
    ),
    Alert(
      id: '3',
      districtName: 'Takoradi',
      message: 'Power restoration completed successfully',
      timestamp: '2024-01-15 10:00',
      type: AlertType.restored,
      read: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Alert> _getFilteredAlerts(AlertType type) {
    return _mockAlerts.where((alert) => alert.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Outages'),
            Tab(text: 'Restored'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertsList(_mockAlerts),
          _buildAlertsList(_getFilteredAlerts(AlertType.outage)),
          _buildAlertsList(_getFilteredAlerts(AlertType.restored)),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<Alert> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No alerts',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(alerts[index]);
      },
    );
  }

  Widget _buildAlertCard(Alert alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    alert.districtName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getAlertTypeColor(alert.type),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    alert.type.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  alert.timestamp,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (!alert.read)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getAlertTypeColor(AlertType type) {
    switch (type) {
      case AlertType.outage:
        return AppColors.error;
      case AlertType.restored:
        return AppColors.success;
      case AlertType.info:
        return AppColors.info;
    }
  }
}
