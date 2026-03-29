import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../models/district.dart';

class DistrictCard extends StatefulWidget {
  final District district;
  final bool showToggle;
  /// When [showToggle] is true, called after the user changes the switch.
  final ValueChanged<bool>? onMonitoredChanged;

  const DistrictCard({
    Key? key,
    required this.district,
    this.showToggle = false,
    this.onMonitoredChanged,
  }) : super(key: key);

  @override
  State<DistrictCard> createState() => _DistrictCardState();
}

class _DistrictCardState extends State<DistrictCard> {
  late bool isMonitored;

  @override
  void initState() {
    super.initState();
    isMonitored = widget.district.isMonitored;
  }

  @override
  void didUpdateWidget(DistrictCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.district.isMonitored != widget.district.isMonitored) {
      isMonitored = widget.district.isMonitored;
    }
  }

  Color _getStatusColor(DistrictStatus status) {
    switch (status) {
      case DistrictStatus.outage:
        return AppColors.outageRed;
      case DistrictStatus.restored:
        return AppColors.restoredGreen;
      case DistrictStatus.normal:
        return AppColors.outline;
    }
  }

  IconData _getStatusIcon(DistrictStatus status) {
    switch (status) {
      case DistrictStatus.outage:
        return Icons.error_outline;
      case DistrictStatus.restored:
        return Icons.check_circle_outline;
      case DistrictStatus.normal:
        return Icons.access_time;
    }
  }

  String _getStatusText(DistrictStatus status) {
    switch (status) {
      case DistrictStatus.outage:
        return 'Power Outage';
      case DistrictStatus.restored:
        return 'Recently Restored';
      case DistrictStatus.normal:
        return 'No Reports';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.district.status);

    return GestureDetector(
      onTap: widget.showToggle
          ? null
          : () => context.go('/district/${widget.district.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(widget.district.status),
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.district.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  if (widget.showToggle)
                    Switch.adaptive(
                      value: isMonitored,
                      onChanged: (value) {
                        setState(() => isMonitored = value);
                        widget.district.isMonitored = value;
                        widget.onMonitoredChanged?.call(value);
                      },
                      activeColor: AppColors.primary,
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.outline,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  widget.district.region,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Row(
                  children: [
                    Text(
                      _getStatusText(widget.district.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (widget.district.lastReportedAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.district.lastReportedAt!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.district.activeReports > 0) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    '${widget.district.activeReports} active report${widget.district.activeReports != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              if (!widget.showToggle && widget.district.activeReports > 0) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.go('/district/${widget.district.id}'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'View Reports',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
