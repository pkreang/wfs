import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/lead/views/lead_list_page.dart';
import 'package:wfs/features/leaddashboard2/models/lead_dashboard2_metric.dart';
import 'package:wfs/features/leaddashboard2/providers/lead_dashboard2_date_range_provider.dart';
import 'package:wfs/providers/lead_filter_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

String _valueLabel(LeadDashboard2FunnelStage stage) {
  final percent = stage.percent;
  return '${stage.value} (${(percent ?? 0).toStringAsFixed(1)}%)';
}

class LeadDashboard2FunnelChart extends ConsumerWidget {
  final List<LeadDashboard2FunnelStage> stages;
  final LeadDashboard2FunnelStage closedWon;
  final LeadDashboard2FunnelStage closedLost;

  const LeadDashboard2FunnelChart({required this.stages, required this.closedWon, required this.closedLost, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const AppText(
          //   label: 'Sales Pipeline Funnel',
          //   fontSize: 16,
          //   fontWeight: FontWeight.w600,
          // ),
          // const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth.clamp(260.0, 480.0);
              final segmentHeight = constraints.maxWidth < 360 ? 58.0 : 66.0;

              return Center(
                child: SizedBox(
                  width: chartWidth,
                  child: Column(
                    children: [
                      ...stages.indexed.map((entry) {
                        final index = entry.$1;
                        final stage = entry.$2;

                        return Padding(
                          padding: EdgeInsets.only(bottom: index == stages.length - 1 ? 0 : 6),
                          child: _FunnelSegment(stage: stage, width: chartWidth, height: segmentHeight, topWidthFactor: _widthFactor(index), bottomWidthFactor: _widthFactor(index + 1), onTap: () {}),
                        );
                      }),
                      SizedBox(
                        width: chartWidth,
                        height: 34,
                        child: CustomPaint(painter: const _SplitConnectorPainter()),
                      ),
                      Row(
                        children: [
                          Expanded(child: _ClosedResultCard(stage: closedWon)),
                          const SizedBox(width: 10),
                          Expanded(child: _ClosedResultCard(stage: closedLost)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // const SizedBox(height: 12),
          // const Divider(height: 1, thickness: AppUtility.borderWidth, color: AppUtility.colorGray),
          // const SizedBox(height: 10),
          // const AppText(label: 'เปอร์เซ็นต์แสดงสัดส่วนเมื่อเทียบกับจำนวน Lead ทั้งหมด', fontSize: 12, textColor: AppUtility.textGray, lineHeight: 16, maxLines: 2),
        ],
      ),
    );
  }

  double _widthFactor(int position) {
    const minWidthFactor = 0.46;
    if (stages.length <= 1) return 1;
    final progress = position / stages.length;
    return 1 - ((1 - minWidthFactor) * progress);
  }
}

class _FunnelSegment extends StatelessWidget {
  final LeadDashboard2FunnelStage stage;
  final double width;
  final double height;
  final double topWidthFactor;
  final double bottomWidthFactor;
  final VoidCallback onTap;

  const _FunnelSegment({required this.stage, required this.width, required this.height, required this.topWidthFactor, required this.bottomWidthFactor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipPath(
        clipper: _FunnelSegmentClipper(topWidth: width * topWidthFactor, bottomWidth: width * bottomWidthFactor),
        child: GestureDetector(
          onTap: onTap,
          child: ColoredBox(
            color: stage.color,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(label: stage.title, fontSize: 13, fontWeight: FontWeight.w600, textColor: Colors.white, lineHeight: 17),
                  const SizedBox(height: 2),
                  AppText(label: _valueLabel(stage), fontSize: 17, fontWeight: FontWeight.w600, textColor: Colors.white, lineHeight: 21),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClosedResultCard extends StatelessWidget {
  final LeadDashboard2FunnelStage stage;

  const _ClosedResultCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: stage.color, width: AppUtility.borderWidth),
      ),
      child: Column(
        children: [
          Icon(stage.title == 'Closed Won' ? Icons.check_circle_outline : Icons.cancel_outlined, color: stage.color, size: 22),
          const SizedBox(height: 6),
          AppText(label: stage.title, fontSize: 12, fontWeight: FontWeight.w600, lineHeight: 16),
          const SizedBox(height: 2),
          AppText(label: _valueLabel(stage), fontSize: 13, textColor: stage.color, fontWeight: FontWeight.w600, lineHeight: 17),
        ],
      ),
    );
  }
}

class _FunnelSegmentClipper extends CustomClipper<Path> {
  final double topWidth;
  final double bottomWidth;

  const _FunnelSegmentClipper({required this.topWidth, required this.bottomWidth});

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
    return topWidth != oldClipper.topWidth || bottomWidth != oldClipper.bottomWidth;
  }
}

class _SplitConnectorPainter extends CustomPainter {
  const _SplitConnectorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppUtility.colorGray
      ..strokeWidth = AppUtility.borderWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, size.height * 0.46)
      ..lineTo(size.width * 0.25, size.height)
      ..moveTo(size.width / 2, size.height * 0.46)
      ..lineTo(size.width * 0.75, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SplitConnectorPainter oldDelegate) => false;
}
