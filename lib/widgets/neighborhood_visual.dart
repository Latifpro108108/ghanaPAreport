import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Design-only “power halo”: shows nearby micro-zones as colored arcs (no map SDK).
class NeighborhoodVisual extends StatefulWidget {
  final String userArea;
  final String? areaSubtitle;
  final List<ZoneStatus> zones;
  final VoidCallback? onZoneTap;

  const NeighborhoodVisual({
    super.key,
    required this.userArea,
    this.areaSubtitle,
    required this.zones,
    this.onZoneTap,
  });

  @override
  State<NeighborhoodVisual> createState() => _NeighborhoodVisualState();
}

class _NeighborhoodVisualState extends State<NeighborhoodVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A5F),
            Color(0xFF172554),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.near_me, color: Color(0xFF93C5FD), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live area snapshot',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        color: Colors.blue.shade100.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userArea,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.areaSubtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.areaSubtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                return CustomPaint(
                  painter: _PowerHaloPainter(
                    zones: widget.zones,
                    pulse: _pulse.value,
                  ),
                  child: child,
                );
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_pin_circle, color: Color(0xFFBFDBFE), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'You',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Abstract blocks near you',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsSummary(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _legendRow(const Color(0xFF22C55E), 'Power on'),
        const SizedBox(height: 6),
        _legendRow(const Color(0xFFEF4444), 'Outage'),
      ],
    );
  }

  Widget _legendRow(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: c.withOpacity(0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.75)),
        ),
      ],
    );
  }

  Widget _buildStatsSummary() {
    final total = widget.zones.length;
    final outages = widget.zones.where((z) => z.hasOutage).length;
    final ok = total - outages;
    final pct = total > 0 ? (outages / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Blocks', '$total', Icons.grid_4x4_rounded),
          _stat('Stable', '$ok', Icons.bolt, color: const Color(0xFF86EFAC)),
          _stat('Out', '$outages ($pct%)', Icons.offline_bolt, color: const Color(0xFFFCA5A5)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color ?? Colors.white70),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
        ),
      ],
    );
  }
}

class _PowerHaloPainter extends CustomPainter {
  final List<ZoneStatus> zones;
  final double pulse;

  _PowerHaloPainter({required this.zones, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.42;
    final stroke = radius * 0.28;

    if (zones.isEmpty) return;

    final n = zones.length;
    final sweep = 2 * math.pi / n;
    final start = -math.pi / 2;

    for (var i = 0; i < n; i++) {
      final z = zones[i];
      final a0 = start + i * sweep;
      final a1 = a0 + sweep * 0.92;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = z.isUserLocation ? stroke * 1.15 : stroke
        ..strokeCap = StrokeCap.round
        ..color = z.hasOutage ? const Color(0xFFEF4444) : const Color(0xFF22C55E);

      canvas.drawArc(
        Rect.fromCircle(center: c, radius: radius),
        a0,
        a1 - a0,
        false,
        paint,
      );

      if (z.isUserLocation) {
        final glow = (math.sin(pulse * math.pi * 2) * 0.5 + 0.5) * 6;
        final hl = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFBFDBFE).withOpacity(0.35 + glow * 0.05);
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: radius + 2),
          a0,
          a1 - a0,
          false,
          hl,
        );
      }

      final mid = (a0 + a1) / 2;
      final labelR = radius + stroke * 0.85;
      final lp = Offset(
        c.dx + labelR * math.cos(mid),
        c.dy + labelR * math.sin(mid),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lp.dx - tp.width / 2, lp.dy - tp.height / 2));
    }

    final inner = Paint()
      ..color = const Color(0xFF0F172A).withOpacity(0.92);
    canvas.drawCircle(c, radius - stroke * 1.2, inner);
  }

  @override
  bool shouldRepaint(covariant _PowerHaloPainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.zones.length != zones.length;
  }
}

class ZoneStatus {
  final String id;
  final String name;
  final bool hasOutage;
  final bool isUserLocation;

  const ZoneStatus({
    required this.id,
    required this.name,
    required this.hasOutage,
    this.isUserLocation = false,
  });
}

/// Mock micro-blocks for the halo (replace with API later).
class NeighborhoodData {
  static List<ZoneStatus> generateZonesForAccraArea({
    required String neighborhoodId,
    required String displayName,
  }) {
    final rnd = math.Random(neighborhoodId.hashCode ^ displayName.hashCode);
    final labels = _labelsFor(neighborhoodId);
    const count = 8;
    final userIndex = 3 + rnd.nextInt(2);

    return List.generate(count, (i) {
      final isUser = i == userIndex;
      final hasOutage = !isUser && rnd.nextDouble() > 0.62;
      return ZoneStatus(
        id: '${neighborhoodId}_z$i',
        name: labels[i % labels.length],
        hasOutage: hasOutage,
        isUserLocation: isUser,
      );
    });
  }

  static List<String> _labelsFor(String id) {
    return switch (id) {
      'osu-cantonments' => [
          'Oxford strip', 'Ring adj', 'Side A', 'Side B', 'Cluster 1',
          'Cluster 2', 'Lane E', 'Lane W',
        ],
      'airport-east' => [
          'Motorway N', 'Motorway S', 'Ring E', 'Ring W', 'Block 1',
          'Block 2', 'Strip A', 'Strip B',
        ],
      _ => [
          'North strip', 'South strip', 'East cluster', 'West cluster',
          'Block α', 'Block β', 'Lane 1', 'Lane 2',
        ],
    };
  }
}
