import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../data/mock_data.dart';
import '../models/alert.dart';
class DistrictDetailScreen extends StatelessWidget {
  final String districtId;

  const DistrictDetailScreen({super.key, required this.districtId});

  @override
  Widget build(BuildContext context) {
    final found =
        districts.where((d) => d.id == districtId).toList();
    if (found.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('District')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('District not found'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final district = found.first;
    final districtReports =
        reports.where((r) => r.districtId == districtId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(district.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            district.region,
            style: AppTextStyles.body.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${district.activeReports} active report${district.activeReports == 1 ? '' : 's'}',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 24),
          const Text(
            'Community reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (districtReports.isEmpty)
            Text(
              'No reports for this district yet.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            ...districtReports.map((r) => _ReportTile(report: r)),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final Report report;

  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final isOutage = report.type == ReportType.outage;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isOutage ? Icons.flash_off : Icons.flash_on,
          color: isOutage ? AppColors.outageRed : AppColors.restoredGreen,
        ),
        title: Text(
          isOutage ? 'Outage' : 'Restored',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${report.timestamp} · ${report.reportedBy}\n↑ ${report.upvotes}  ↓ ${report.downvotes}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
