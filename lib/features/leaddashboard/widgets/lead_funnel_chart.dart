import 'package:flutter/material.dart';
import 'package:wfs/features/leaddashboard/models/lead_dashboard_metric.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadFunnelChart extends StatelessWidget {
  final List<LeadDashboardFunnelStage> stages;
  final LeadDashboardFunnelStage closedWon;
  final LeadDashboardFunnelStage closedLost;

  const LeadFunnelChart({
    required this.stages,
    required this.closedWon,
    required this.closedLost,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: AppUtility.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            label: 'Sales Pipeline Funnel',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final funnelWidth = maxWidth.clamp(260.0, 540.0);
              final segmentHeight = maxWidth < 360 ? 68.0 : 76.0;

              return Center(
                child: SizedBox(
                  width: funnelWidth,
                  child: Column(
                    children: [
                      ...stages.indexed.map((entry) {
                        final index = entry.$1;
                        final stage = entry.$2;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == stages.length - 1 ? 0 : 8,
                          ),
                          child: _FunnelSegment(
                            stage: stage,
                            width: funnelWidth,
                            height: segmentHeight,
                            topWidthFactor: _widthFactor(index),
                            bottomWidthFactor: _widthFactor(index + 1),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: funnelWidth,
                        height: 42,
                        child: CustomPaint(
                          painter: _SplitConnectorPainter(
                            color: AppUtility.textGray.withValues(alpha: 0.36),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(child: _ClosedResultCard(stage: closedWon)),
                          const SizedBox(width: 12),
                          Expanded(child: _ClosedResultCard(stage: closedLost)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const AppText(
              label: 'เปอร์เซ็นต์แสดงสัดส่วนเมื่อเทียบกับจำนวน Lead ทั้งหมด',
              fontSize: 12,
              textColor: AppUtility.textGray,
              lineHeight: 16,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  double _widthFactor(int position) {
    const minWidthFactor = 0.46;
    final itemCount = stages.length;
    if (itemCount <= 1) return 1;
    final progress = position / itemCount;
    return 1 - ((1 - minWidthFactor) * progress);
  }
}

class _FunnelSegment extends StatelessWidget {
  final LeadDashboardFunnelStage stage;
  final double width;
  final double height;
  final double topWidthFactor;
  final double bottomWidthFactor;

  const _FunnelSegment({
    required this.stage,
    required this.width,
    required this.height,
    required this.topWidthFactor,
    required this.bottomWidthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipPath(
        clipper: _FunnelSegmentClipper(
          topWidth: width * topWidthFactor,
          bottomWidth: width * bottomWidthFactor,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(stage.color, Colors.white, 0.14) ?? stage.color,
                stage.color,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  label: stage.title,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  textColor: Colors.white,
                  lineHeight: 18,
                ),
                const SizedBox(height: 2),
                AppText(
                  label: '${stage.value} (${_formatPercent(stage.percent)})',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  textColor: Colors.white,
                  lineHeight: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPercent(double value) => '${value.toStringAsFixed(1)}%';
}

class _ClosedResultCard extends StatelessWidget {
  final LeadDashboardFunnelStage stage;

  const _ClosedResultCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.lerp(stage.color, Colors.white, 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Color.lerp(stage.color, Colors.white, 0.56) ?? stage.color,
          width: AppUtility.borderWidth,
        ),
      ),
      child: Column(
        children: [
          Icon(
            stage.title == 'Closed Won'
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: stage.color,
            size: 24,
          ),
          const SizedBox(height: 8),
          AppText(
            label: stage.title,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            lineHeight: 17,
          ),
          const SizedBox(height: 4),
          AppText(
            label: '${stage.value} (${stage.percent.toStringAsFixed(1)}%)',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            textColor: stage.color,
            lineHeight: 19,
          ),
        ],
      ),
    );
  }
}

class _FunnelSegmentClipper extends CustomClipper<Path> {
  final double topWidth;
  final double bottomWidth;

  const _FunnelSegmentClipper({
    required this.topWidth,
    required this.bottomWidth,
  });

  @override
  Path getClip(Size size) {
    final topInset = (size.width - topWidth).clamp(0.0, size.width) / 2;
    final bottomInset = (size.width - bottomWidth).clamp(0.0, size.width) / 2;

    return Path()
      ..moveTo(topInset, 0)
      ..lineTo(size.width - topInset, 0)
      ..lineTo(size.width - bottomInset, size.height)
      ..lineTo(bottomInset, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _FunnelSegmentClipper oldClipper) {
    return topWidth != oldClipper.topWidth ||
        bottomWidth != oldClipper.bottomWidth;
  }
}

class _SplitConnectorPainter extends CustomPainter {
  final Color color;

  const _SplitConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, size.height * 0.44)
      ..lineTo(size.width * 0.25, size.height)
      ..moveTo(size.width / 2, size.height * 0.44)
      ..lineTo(size.width * 0.75, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SplitConnectorPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
