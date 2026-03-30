import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';

/// ECG Announcements Page - Official power company updates
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ghanaGold,
        foregroundColor: AppColors.ghanaBlack,
        elevation: 0,
        title: const Text(
          'ECG Updates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ghanaGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ghanaGold.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.ghanaGold),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Official announcements from the Electricity Company of Ghana (ECG)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Announcements list
          _buildAnnouncementCard(
            title: 'Scheduled Maintenance - Accra East',
            content:
                'There will be a planned maintenance exercise in the Accra East region on Saturday, 30th March 2024 from 9:00 AM to 3:00 PM. Areas affected include: Haatso, Madina, Adenta, and surrounding communities.',
            date: '2 hours ago',
            type: 'Maintenance',
            isImportant: true,
          ),
          const SizedBox(height: 12),

          _buildAnnouncementCard(
            title: 'Power restored to Tema Metropolitan',
            content:
                'Power has been fully restored to all areas in Tema Metropolitan District after the earlier outage caused by a transformer fault.',
            date: '5 hours ago',
            type: 'Restoration',
            isImportant: false,
          ),
          const SizedBox(height: 12),

          _buildAnnouncementCard(
            title: 'System Upgrade Notice',
            content:
                'ECG is upgrading its billing system. Online payments may experience intermittent connectivity between 11:00 PM and 2:00 AM daily until April 15th.',
            date: '1 day ago',
            type: 'System',
            isImportant: false,
          ),
          const SizedBox(height: 12),

          _buildAnnouncementCard(
            title: 'Load Shedding Schedule Update',
            content:
                'Updated load shedding schedule now available. Please check the ECG website or mobile app for your specific area schedule.',
            date: '2 days ago',
            type: 'Schedule',
            isImportant: true,
          ),
          const SizedBox(height: 12),

          _buildAnnouncementCard(
            title: 'Public Holiday Service Hours',
            content:
                'All ECG customer service centers will operate reduced hours on Independence Day (6th March). Emergency services remain available 24/7.',
            date: '3 days ago',
            type: 'Holiday',
            isImportant: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String content,
    required String date,
    required String type,
    required bool isImportant,
  }) {
    Color typeColor;
    switch (type) {
      case 'Maintenance':
        typeColor = AppColors.ghanaRed;
        break;
      case 'Restoration':
        typeColor = AppColors.ghanaGreen;
        break;
      case 'Schedule':
        typeColor = AppColors.ghanaGold;
        break;
      default:
        typeColor = AppColors.onSurfaceVariant;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isImportant ? AppColors.ghanaGold : AppColors.outlineVariant,
          width: isImportant ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (isImportant)
                  const Icon(
                    Icons.priority_high,
                    color: AppColors.ghanaGold,
                    size: 20,
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'ECG Official',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ghanaGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
