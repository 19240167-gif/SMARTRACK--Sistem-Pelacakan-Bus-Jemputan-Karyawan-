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
  double _mapZoom = 1.0;

  // Jalur rute mock (normalized 0..1 x dan y dalam canvas)
  static const List<Offset> _routePoints = [
    Offset(0.09, 0.74),
    Offset(0.09, 0.54),
    Offset(0.23, 0.54),
    Offset(0.23, 0.32),
    Offset(0.47, 0.32),
    Offset(0.47, 0.22),
    Offset(0.72, 0.22),
    Offset(0.90, 0.22),
  ];

  // Titik jemput (stop)
  static const List<_MockStop> _stops = [
    _MockStop('', Offset(0.09, 0.74), true),
    _MockStop('', Offset(0.23, 0.54), false),
    _MockStop('', Offset(0.47, 0.32), false),
    _MockStop('', Offset(0.72, 0.22), false),
    _MockStop('', Offset(0.90, 0.22), false),
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
                return Transform.scale(
                  scale: _mapZoom,
                  child: CustomPaint(
                    painter: _MockMapPainter(
                      busProgress: _busProgress.value,
                      routePoints: _routePoints,
                      stops: _stops,
                      pulseScale: _pulseAnim.value,
                      zoom: _mapZoom,
                    ),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_rounded,
                          color: AppColors.primary, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'LIVE ROUTE VIEW',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
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
              data: (tracking) => tracking == null
                  ? _buildDemoCard()
                  : _buildLiveCard(tracking),
            ),
          ),

          // â”€â”€ Zoom controls (gimmik) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                _buildMapControl(Icons.add, () {
                  setState(() => _mapZoom = (_mapZoom + 0.08).clamp(1.0, 1.32));
                }),
                const SizedBox(height: 8),
                _buildMapControl(Icons.remove, () {
                  setState(() => _mapZoom = (_mapZoom - 0.08).clamp(1.0, 1.32));
                }),
                const SizedBox(height: 8),
                _buildMapControl(Icons.my_location, () {
                  setState(() => _mapZoom = 1.0);
                }),
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
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3)),
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
                    Text('Koridor Jemput Pagi',
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
              _buildStatItem(Icons.speed_rounded, '42 km/j', 'Kecepatan',
                  AppColors.secondary),
              _buildStatItem(Icons.social_distance_rounded, '1.2 km', 'Jarak',
                  AppColors.statusMendekati),
              _buildStatItem(
                  Icons.timer_rounded, '5 menit', 'ETA', AppColors.statusTiba),
              _buildStatItem(Icons.update_rounded, 'Baru saja', 'Update',
                  AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(tracking) {
    final coordinate =
        '${tracking.latitude.toStringAsFixed(5)}, ${tracking.longitude.toStringAsFixed(5)}';

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
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.directions_bus_rounded,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bus A-01',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Text(coordinate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
                  '${tracking.kecepatan.toStringAsFixed(0)} km/j',
                  'Kecepatan',
                  AppColors.secondary),
              _buildStatItem(Icons.social_distance_rounded, '1.2 km', 'Jarak',
                  AppColors.statusMendekati),
              _buildStatItem(
                  Icons.timer_rounded, '5 menit', 'ETA', AppColors.statusTiba),
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
              color: Colors.black.withValues(alpha: 0.3),
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
  final double zoom;
  static const Offset passengerPos =
      Offset(0.23, 0.54); // Posisi karyawan di titik jemput

  const _MockMapPainter({
    required this.busProgress,
    required this.routePoints,
    required this.stops,
    required this.pulseScale,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawBlockBuildings(canvas, size);
    _drawParks(canvas, size);
    _drawRoads(canvas, size);
    _drawRoute(canvas, size);
    _drawStops(canvas, size);
    _drawBus(canvas, size);
    _drawPassenger(canvas, size);
    _drawMapHud(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF4F3F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawBlockBuildings(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFECEBE6);
    final borderPaint = Paint()
      ..color = const Color(0xFFD9D7D2)
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

  void _drawParks(Canvas canvas, Size size) {
    final parkPaint = Paint()..color = const Color(0xFFD2F0D2);
    final borderPaint = Paint()
      ..color = const Color(0xFFAADDAA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final parks = [
      Rect.fromLTWH(size.width * 0.58, size.height * 0.09, 92, 54),
      Rect.fromLTWH(size.width * 0.06, size.height * 0.43, 84, 58),
      Rect.fromLTWH(size.width * 0.68, size.height * 0.66, 104, 64),
    ];

    for (final park in parks) {
      final rr = RRect.fromRectAndRadius(park, const Radius.circular(16));
      canvas.drawRRect(rr, parkPaint);
      canvas.drawRRect(rr, borderPaint);
    }
  }

  void _drawRoads(Canvas canvas, Size size) {
    // Horizontal roads
    final hRoadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt;
    final hLinePaint = Paint()
      ..color = const Color(0xFFD9D7D2)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt;

    final hRoads = [
      size.height * 0.22,
      size.height * 0.32,
      size.height * 0.54,
      size.height * 0.74,
    ];
    for (final y in hRoads) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hRoadPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hLinePaint);
    }

    // Vertical roads
    final vRoads = [
      size.width * 0.09,
      size.width * 0.23,
      size.width * 0.47,
      size.width * 0.72,
      size.width * 0.90,
    ];
    for (final x in vRoads) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hRoadPaint);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hLinePaint);
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    if (routePoints.isEmpty) return;

    // Glow route
    final glowPaint = Paint()
      ..color = const Color(0xFF1A73E8).withValues(alpha: 0.15)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Main route
    final routePaint = Paint()
      ..color = const Color(0xFF1A73E8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Travelled route (brighter)
    final travelledPaint = Paint()
      ..color = const Color(0xFF1557B0)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fullPath = Path();
    final travelledPath = Path();

    final pts = routePoints.map((p) => _toCanvas(p, size)).toList();
    fullPath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      fullPath.lineTo(pts[i].dx, pts[i].dy);
    }

    // Travelled portion
    final busPos = _busPositionOnRoute(size);
    final busIdx = (busProgress * (pts.length - 1)).floor();
    travelledPath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i <= busIdx && i < pts.length; i++) {
      travelledPath.lineTo(pts[i].dx, pts[i].dy);
    }
    if (busIdx < pts.length - 1) {
      travelledPath.lineTo(busPos.dx, busPos.dy);
    }

    canvas.drawPath(fullPath, glowPaint);
    canvas.drawPath(fullPath, routePaint);
    canvas.drawPath(travelledPath, travelledPaint);

    for (int i = 0; i < pts.length - 1; i++) {
      final mid = Offset.lerp(pts[i], pts[i + 1], 0.5)!;
      canvas.drawCircle(mid, 2.2,
          Paint()..color = const Color(0xFF1A73E8).withValues(alpha: 0.35));
    }
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
          ..color =
              (isStart ? const Color(0xFFEA4335) : const Color(0xFF4285F4))
                  .withValues(alpha: 0.2),
      );

      // Inner circle
      canvas.drawCircle(
        pos,
        isStart ? 8 : 6,
        Paint()
          ..color = isStart ? const Color(0xFFEA4335) : const Color(0xFF4285F4),
      );

      // White center
      canvas.drawCircle(
        pos,
        isStart ? 3 : 2.5,
        Paint()..color = Colors.white,
      );

      // Label lokasi sengaja dikosongkan agar tidak terlihat seperti Jakarta.
    }
  }

  void _drawBus(Canvas canvas, Size size) {
    final pos = _busPositionOnRoute(size);

    // Pulse ring
    canvas.drawCircle(
      pos,
      22 * pulseScale,
      Paint()
        ..color =
            const Color(0xFFEA4335).withValues(alpha: 0.14 * (2 - pulseScale)),
    );
    canvas.drawCircle(
      pos,
      16 * pulseScale,
      Paint()..color = const Color(0xFFEA4335).withValues(alpha: 0.18),
    );

    // Shadow
    canvas.drawCircle(
      pos + const Offset(0, 3),
      14,
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );

    // Main bus circle
    canvas.drawCircle(
      pos,
      14,
      Paint()..color = const Color(0xFFEA4335),
    );

    // Bus icon (simple rectangle)
    final busRect = Rect.fromCenter(center: pos, width: 14, height: 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(busRect, const Radius.circular(2)),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromCenter(center: pos + const Offset(-2, 0), width: 4, height: 7),
      Paint()..color = const Color(0xFFEA4335),
    );
    canvas.drawRect(
      Rect.fromCenter(center: pos + const Offset(3, 0), width: 4, height: 7),
      Paint()..color = const Color(0xFFEA4335),
    );

    final label = TextPainter(
      text: const TextSpan(
        text: 'BUS A-01',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          pos.dx - label.width / 2 - 8, pos.dy - 42, label.width + 16, 22),
      const Radius.circular(12),
    );
    canvas.drawRRect(bubble,
        Paint()..color = const Color(0xFFEA4335).withValues(alpha: 0.92));
    label.paint(canvas, Offset(pos.dx - label.width / 2, pos.dy - 36));
  }

  void _drawPassenger(Canvas canvas, Size size) {
    final pos = _toCanvas(passengerPos, size);

    canvas.drawCircle(
      pos,
      20 * pulseScale,
      Paint()
        ..color =
            const Color(0xFF4285F4).withValues(alpha: 0.18 * (2 - pulseScale)),
    );
    canvas.drawCircle(pos, 10, Paint()..color = Colors.white);
    canvas.drawCircle(pos, 7, Paint()..color = const Color(0xFF4285F4));
    canvas.drawCircle(pos, 2.5, Paint()..color = Colors.white);

    final label = TextPainter(
      text: const TextSpan(
        text: 'Anda',
        style: TextStyle(
          color: Color(0xFF202124),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          pos.dx - label.width / 2 - 8, pos.dy + 14, label.width + 16, 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(
        rect, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    label.paint(canvas, Offset(pos.dx - label.width / 2, pos.dy + 18));
  }

  void _drawMapHud(Canvas canvas, Size size) {
    final zoomText = TextPainter(
      text: TextSpan(
        text: 'SMARTRACK  •  ${zoom.toStringAsFixed(2)}x',
        style: TextStyle(
          color: const Color(0xFF5F6368).withValues(alpha: 0.75),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    zoomText.paint(canvas, Offset(18, size.height - 150));

    final compassCenter = Offset(size.width - 42, 140);
    canvas.drawCircle(
      compassCenter,
      19,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawCircle(
      compassCenter,
      19,
      Paint()
        ..color = const Color(0xFFDADCE0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final north = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          color: Color(0xFFEA4335),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    north.paint(
        canvas, compassCenter.translate(-north.width / 2, -north.height / 2));
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
      old.busProgress != busProgress ||
      old.pulseScale != pulseScale ||
      old.zoom != zoom;
}
