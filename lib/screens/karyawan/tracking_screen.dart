// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// lib/screens/karyawan/tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/status_badge.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with TickerProviderStateMixin {
  // Animasi bus berjalan di sepanjang jalur mock
  late AnimationController _busController;
  late Animation<double> _busProgress;

  // Animasi pulse pada marker bus
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Jalur rute mock (normalized 0..1 x dan y dalam canvas)
  static const List<Offset> _routePoints = [
    Offset(0.08, 0.75),
    Offset(0.18, 0.62),
    Offset(0.28, 0.55),
    Offset(0.38, 0.48),
    Offset(0.50, 0.42),
    Offset(0.60, 0.38),
    Offset(0.72, 0.32),
    Offset(0.82, 0.28),
    Offset(0.90, 0.22),
  ];

  // Titik jemput (stop)
  static const List<_MockStop> _stops = [
    _MockStop('Pool Bus', Offset(0.08, 0.75), true),
    _MockStop('Jl. Sudirman', Offset(0.28, 0.55), false),
    _MockStop('Bundaran HI', Offset(0.50, 0.42), false),
    _MockStop('Thamrin City', Offset(0.72, 0.32), false),
    _MockStop('Kantor Pusat', Offset(0.90, 0.22), false),
  ];

  @override
  void initState() {
    super.initState();

    _busController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _busProgress = CurvedAnimation(
      parent: _busController,
      curve: Curves.linear,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _busController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final busId = user?.busId ?? 'bus_001';
    final trackingAsync = ref.watch(busTrackingStreamProvider(busId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // â”€â”€ Mock Map Canvas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_busProgress, _pulseAnim]),
              builder: (context, _) {
                return CustomPaint(
                  painter: _MockMapPainter(
                    busProgress: _busProgress.value,
                    routePoints: _routePoints,
                    stops: _stops,
                    pulseScale: _pulseAnim.value,
                  ),
                );
              },
            ),
          ),

          // â”€â”€ Top bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const GlassCard(
                      padding: EdgeInsets.all(10),
                      borderRadius: 12,
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: GlassCard(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            Icon(Icons.gps_fixed,
                                color: AppColors.accent, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Live Tracking Bus',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const GlassCard(
                      padding: EdgeInsets.all(10),
                      borderRadius: 12,
                      child: Icon(Icons.layers_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // â”€â”€ Label "PROTOTYPE / DEMO" watermark â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusMacet.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.statusMacet.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'TAMPILAN DEMO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.statusMacet,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // â”€â”€ Bottom info card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: trackingAsync.when(
              loading: () => const GlassCard(
                margin: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent),
                    ),
                    SizedBox(width: 12),
                    Text('Mencari lokasi bus...',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              error: (_, __) => _buildDemoCard(),
              data: (tracking) =>
                  tracking == null ? _buildDemoCard() : _buildLiveCard(tracking),
            ),
          ),

          // â”€â”€ Zoom controls (gimmik) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                _buildMapControl(Icons.add, () {}),
                const SizedBox(height: 8),
                _buildMapControl(Icons.remove, () {}),
                const SizedBox(height: 8),
                _buildMapControl(Icons.my_location, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard() {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.directions_bus_rounded,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bus A-01',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Text('B 1234 ABC',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ),
              AnimatedStatusBadge(status: 'Dalam Perjalanan'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(Icons.speed_rounded, '42 km/h', 'Kecepatan',
                  AppColors.secondary),
              _buildStatItem(Icons.social_distance_rounded, '1.2 km',
                  'Jarak', AppColors.statusMendekati),
              _buildStatItem(Icons.timer_rounded, '5 menit', 'ETA',
                  AppColors.statusTiba),
              _buildStatItem(Icons.update_rounded, 'Baru saja', 'Update',
                  AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(tracking) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.directions_bus_rounded,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bus A-01',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Text('B 1234 ABC',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ),
              AnimatedStatusBadge(status: tracking.statusPerjalanan),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                  Icons.speed_rounded,
                  '${tracking.kecepatan.toStringAsFixed(0)} km/h',
                  'Kecepatan',
                  AppColors.secondary),
              _buildStatItem(Icons.social_distance_rounded, '1.2 km',
                  'Jarak', AppColors.statusMendekati),
              _buildStatItem(Icons.timer_rounded, '5 menit', 'ETA',
                  AppColors.statusTiba),
              _buildStatItem(
                  Icons.update_rounded,
                  AppHelpers.formatTime(tracking.timestamp),
                  'Update',
                  AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Inter',
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textTertiary,
                  fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Data class untuk stop
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MockStop {
  final String name;
  final Offset position; // normalized 0..1
  final bool isStart;
  const _MockStop(this.name, this.position, this.isStart);
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// CustomPainter: menggambar peta gimmik
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MockMapPainter extends CustomPainter {
  final double busProgress; // 0..1
  final List<Offset> routePoints;
  final List<_MockStop> stops;
  final double pulseScale;

  const _MockMapPainter({
    required this.busProgress,
    required this.routePoints,
    required this.stops,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGridLines(canvas, size);
    _drawBlockBuildings(canvas, size);
    _drawRoads(canvas, size);
    _drawRoute(canvas, size);
    _drawStops(canvas, size);
    _drawBus(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0C1420);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2535)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawBlockBuildings(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF131F2E);
    final borderPaint = Paint()
      ..color = const Color(0xFF1E3A5F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final blocks = [
      const Rect.fromLTWH(20, 180, 70, 50),
      const Rect.fromLTWH(100, 140, 90, 60),
      const Rect.fromLTWH(200, 160, 60, 45),
      const Rect.fromLTWH(280, 120, 80, 70),
      const Rect.fromLTWH(360, 150, 65, 55),
      const Rect.fromLTWH(30, 280, 80, 60),
      const Rect.fromLTWH(130, 300, 100, 50),
      const Rect.fromLTWH(260, 270, 70, 65),
      const Rect.fromLTWH(360, 260, 50, 45),
      const Rect.fromLTWH(50, 380, 90, 55),
      const Rect.fromLTWH(160, 370, 75, 60),
      const Rect.fromLTWH(270, 360, 85, 50),
      const Rect.fromLTWH(60, 480, 70, 50),
      const Rect.fromLTWH(160, 460, 80, 60),
      const Rect.fromLTWH(280, 500, 100, 45),
      const Rect.fromLTWH(400, 420, 60, 70),
      const Rect.fromLTWH(30, 560, 85, 50),
      const Rect.fromLTWH(150, 580, 70, 55),
      const Rect.fromLTWH(260, 560, 80, 60),
      const Rect.fromLTWH(380, 540, 65, 50),
    ];

    for (final block in blocks) {
      final rr = RRect.fromRectAndRadius(block, const Radius.circular(3));
      canvas.drawRRect(rr, paint);
      canvas.drawRRect(rr, borderPaint);
    }
  }

  void _drawRoads(Canvas canvas, Size size) {
    // Horizontal roads
    final hRoadPaint = Paint()
      ..color = const Color(0xFF1A2A40)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt;
    final hLinePaint = Paint()
      ..color = const Color(0xFF2A3D55)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt;

    const hRoads = [160.0, 330.0, 500.0, 660.0];
    for (final y in hRoads) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hRoadPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hLinePaint);
    }

    // Vertical roads
    const vRoads = [90.0, 230.0, 360.0, 480.0];
    for (final x in vRoads) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hRoadPaint);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hLinePaint);
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    if (routePoints.isEmpty) return;

    // Glow route
    final glowPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.2)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Main route
    final routePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Travelled route (brighter)
    final travelledPaint = Paint()
      ..color = const Color(0xFF60A5FA)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fullPath = Path();
    final travelledPath = Path();

    final pts = routePoints.map((p) => _toCanvas(p, size)).toList();
    fullPath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final ctrl = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      fullPath.quadraticBezierTo(
          pts[i - 1].dx, pts[i - 1].dy, ctrl.dx, ctrl.dy);
    }
    fullPath.lineTo(pts.last.dx, pts.last.dy);

    // Travelled portion
    final busPos = _busPositionOnRoute(size);
    final busIdx = (busProgress * (pts.length - 1)).floor();
    travelledPath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i <= busIdx && i < pts.length; i++) {
      final ctrl = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      travelledPath.quadraticBezierTo(
          pts[i - 1].dx, pts[i - 1].dy, ctrl.dx, ctrl.dy);
    }
    if (busIdx < pts.length - 1) {
      travelledPath.lineTo(busPos.dx, busPos.dy);
    }

    canvas.drawPath(fullPath, glowPaint);
    canvas.drawPath(fullPath, routePaint);
    canvas.drawPath(travelledPath, travelledPaint);
  }

  void _drawStops(Canvas canvas, Size size) {
    for (final stop in stops) {
      final pos = _toCanvas(stop.position, size);
      final isStart = stop.isStart;

      // Outer ring
      canvas.drawCircle(
        pos,
        isStart ? 14 : 10,
        Paint()
          ..color = (isStart ? AppColors.statusTiba : AppColors.accent)
              .withOpacity(0.2),
      );

      // Inner circle
      canvas.drawCircle(
        pos,
        isStart ? 8 : 6,
        Paint()
          ..color = isStart ? AppColors.statusTiba : AppColors.accent,
      );

      // White center
      canvas.drawCircle(
        pos,
        isStart ? 3 : 2.5,
        Paint()..color = Colors.white,
      );

      // Stop name label
      final tp = TextPainter(
        text: TextSpan(
          text: stop.name,
          style: TextStyle(
            color: isStart ? AppColors.statusTiba : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos.translate(-tp.width / 2, isStart ? 16 : 12));
    }
  }

  void _drawBus(Canvas canvas, Size size) {
    final pos = _busPositionOnRoute(size);

    // Pulse ring
    canvas.drawCircle(
      pos,
      22 * pulseScale,
      Paint()
        ..color = AppColors.accent.withOpacity(0.15 * (2 - pulseScale)),
    );
    canvas.drawCircle(
      pos,
      16 * pulseScale,
      Paint()
        ..color = AppColors.accent.withOpacity(0.2),
    );

    // Shadow
    canvas.drawCircle(
      pos + const Offset(0, 3),
      14,
      Paint()..color = Colors.black.withOpacity(0.4),
    );

    // Main bus circle
    canvas.drawCircle(
      pos,
      14,
      Paint()..color = AppColors.accent,
    );

    // Bus icon (simple rectangle)
    final busRect = Rect.fromCenter(center: pos, width: 14, height: 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(busRect, const Radius.circular(2)),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromCenter(center: pos + const Offset(-2, 0), width: 4, height: 7),
      Paint()..color = AppColors.accent,
    );
    canvas.drawRect(
      Rect.fromCenter(center: pos + const Offset(3, 0), width: 4, height: 7),
      Paint()..color = AppColors.accent,
    );
  }

  Offset _busPositionOnRoute(Size size) {
    final pts = routePoints.map((p) => _toCanvas(p, size)).toList();
    if (pts.length < 2) return pts.first;

    final totalSegs = pts.length - 1;
    final t = busProgress * totalSegs;
    final seg = t.floor().clamp(0, totalSegs - 1);
    final frac = t - seg;

    return Offset.lerp(pts[seg], pts[seg + 1], frac)!;
  }

  Offset _toCanvas(Offset normalized, Size size) {
    return Offset(normalized.dx * size.width, normalized.dy * size.height);
  }

  @override
  bool shouldRepaint(_MockMapPainter old) =>
      old.busProgress != busProgress || old.pulseScale != pulseScale;
}