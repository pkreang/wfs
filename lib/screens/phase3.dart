import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/client/views/client_list_page.dart';
import 'package:wfs/features/lead/views/lead_list_page.dart';
import 'package:wfs/features/leaddashboard/pages/lead_dashboard_page.dart';
import 'package:wfs/features/leaddashboard2/pages/lead_dashboard2_page.dart';
import 'package:wfs/features/phase3/lead/views/phase3_lead_list_page.dart';
import 'package:wfs/features/phase3/lead_workflow/views/lead_workflow_page.dart';
import 'package:wfs/features/salepepeline/views/sales_pipeline_page.dart';
import 'package:wfs/features/salesconversionfunnel/models/sales_conversion_funnel_item.dart';
import 'package:wfs/features/survey/pages/survey_list_page.dart';
import 'package:wfs/features/task/views/task_list_page.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase3Screen extends StatefulWidget {
  const Phase3Screen({super.key});

  @override
  State<Phase3Screen> createState() => _Phase3ScreenState();
}

class _Phase3ScreenState extends State<Phase3Screen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [const LeadWorkflowPage(), const LeadWorkflowPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppUtility.colorPrimary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Lead Workflow'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Lead'),
        ],
      ),
    );
  }
}

class SalesConversionRateScreen extends ConsumerWidget {
  const SalesConversionRateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesConversionFunnelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        title: const AppText(label: 'Sales Conversion Rate', fontSize: 17, fontWeight: FontWeight.w600),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(salesConversionFunnelProvider),
          child: state.items.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
            error: (_, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [
                SizedBox(height: 220),
                Center(
                  child: AppText(label: 'Unable to load conversion rate', textColor: AppUtility.colorRed),
                ),
              ],
            ),
            data: (items) {
              if (items.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 220),
                    Center(
                      child: AppText(label: 'No lead status data found.', textColor: Colors.grey),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: _LeadStatusFunnelCard(items: items),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LeadStatusFunnelCard extends StatelessWidget {
  final List<SalesConversionFunnelItem> items;

  const _LeadStatusFunnelCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (sum, item) => sum + item.dealCount);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: AppUtility.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(label: 'Lead Status Funnel', fontSize: 18, fontWeight: FontWeight.w700),
          const SizedBox(height: 4),
          AppText(label: '$total total leads', fontSize: 13, textColor: AppUtility.textGray),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 420;
              final labelWidth = isCompact ? 124.0 : 176.0;
              final connectorWidth = isCompact ? 34.0 : 62.0;
              final chartWidth = (constraints.maxWidth - labelWidth - connectorWidth).clamp(160.0, constraints.maxWidth);
              final rowHeight = isCompact ? 76.0 : 86.0;
              final minWidthFactor = items.length <= 3 ? 0.34 : 0.24;

              return Column(
                children: items.indexed.map((entry) {
                  final index = entry.$1;
                  final item = entry.$2;
                  final previousCount = index == 0 ? null : items[index - 1].dealCount;
                  final stageColor = item.stage.color ?? AppUtility.colorPrimary;
                  final topFactor = _widthFactor(index, items.length, minWidthFactor);
                  final bottomFactor = _widthFactor(index + 1, items.length, minWidthFactor);

                  return SizedBox(
                    height: rowHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: chartWidth,
                          child: Align(
                            alignment: Alignment.center,
                            child: _FunnelSegment(
                              width: chartWidth,
                              height: rowHeight - 8,
                              topWidthFactor: topFactor,
                              bottomWidthFactor: bottomFactor,
                              color: stageColor,
                              count: item.dealCount,
                              percentText: _metricText(item, total, previousCount),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: connectorWidth,
                          height: 20,
                          child: CustomPaint(painter: _DottedConnectorPainter(color: stageColor)),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            width: labelWidth,
                            child: AppText(label: item.stage.name, fontSize: isCompact ? 14 : 16, fontWeight: FontWeight.w600, lineHeight: isCompact ? 18 : 21, maxLines: 1),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  double _widthFactor(int position, int itemCount, double minWidthFactor) {
    if (itemCount <= 1) return 1;
    final progress = position / itemCount;
    return 1 - ((1 - minWidthFactor) * progress);
  }

  String _metricText(SalesConversionFunnelItem item, int total, int? previousCount) {
    if (total == 0) return '0%';
    if (previousCount == null) {
      return '${(item.dealCount / total * 100).round()}%';
    }
    if (previousCount == 0) return '0%';

    final dropRate = ((previousCount - item.dealCount).clamp(0, previousCount) / previousCount * 100).round();
    return '$dropRate%';
  }
}

class _FunnelSegment extends StatelessWidget {
  final double width;
  final double height;
  final double topWidthFactor;
  final double bottomWidthFactor;
  final Color color;
  final int count;
  final String percentText;

  const _FunnelSegment({required this.width, required this.height, required this.topWidthFactor, required this.bottomWidthFactor, required this.color, required this.count, required this.percentText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipPath(
        clipper: _FunnelSegmentClipper(topWidth: width * topWidthFactor, bottomWidth: width * bottomWidthFactor),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(color, Colors.white, 0.16) ?? color, color]),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(label: '$count', fontSize: 22, fontWeight: FontWeight.w800, textColor: Colors.white, lineHeight: 24),
                AppText(label: percentText, fontSize: 12, fontWeight: FontWeight.w600, textColor: Colors.white, lineHeight: 16),
              ],
            ),
          ),
        ),
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

class _DottedConnectorPainter extends CustomPainter {
  final Color color;

  const _DottedConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    const dotRadius = 2.0;
    const gap = 8.0;
    final y = size.height / 2;
    var x = 0.0;

    while (x < size.width - 10) {
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
      x += gap;
    }

    canvas.drawCircle(Offset(size.width - 5, y), 5, paint);
  }

  @override
  bool shouldRepaint(covariant _DottedConnectorPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
