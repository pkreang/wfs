import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/salesconversionfunnel/models/sales_conversion_funnel_item.dart';
import 'package:wfs/utility/app_utility.dart';

class SalesConversionFunnelChart extends ConsumerWidget {
  const SalesConversionFunnelChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesConversionFunnelProvider);

    return state.items.when(
      loading: () => _ChartContainer(
        child: const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
      ),
      error: (_, _) => _ChartContainer(
        child: const AppText(label: 'Unable to load conversion rate', textColor: AppUtility.colorRed),
      ),
      data: (items) => _SalesConversionFunnelChartContent(items: items),
    );
  }
}

class _SalesConversionFunnelChartContent extends StatelessWidget {
  final List<SalesConversionFunnelItem> items;

  const _SalesConversionFunnelChartContent({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return _ChartContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // const AppText(
          //   label: 'Sales Conversion Rate',
          //   fontSize: 16,
          //   fontWeight: FontWeight.w600,
          // ),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final itemCount = items.length;
              const minBottomWidthFactor = 0.12;

              return Column(
                spacing: 2,
                children: items.indexed.map((entry) {
                  final index = entry.$1;
                  final item = entry.$2;
                  final percent = (item.conversionRate * 100).round();
                  final currentPosition = itemCount <= 1 ? 0.0 : index / itemCount;
                  final nextPosition = itemCount <= 1 ? 1.0 : (index + 1) / itemCount;
                  final topWidth = maxWidth * (1 - ((1 - minBottomWidthFactor) * currentPosition));
                  final bottomWidth = maxWidth * (1 - ((1 - minBottomWidthFactor) * nextPosition));

                  return Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    message: '${item.stage.name}: $percent%',
                    child: SizedBox(
                      width: maxWidth,
                      height: 54,
                      child: ClipPath(
                        clipper: _FunnelSegmentClipper(topWidth: topWidth, bottomWidth: bottomWidth),
                        child: ColoredBox(
                          color: item.stage.color ?? AppUtility.colorPrimary,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(label: item.stage.name, fontSize: 13, textColor: Colors.white, fontWeight: FontWeight.w600),
                                AppText(label: '${item.dealCount} deals', fontSize: 12, textColor: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
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
  bool shouldReclip(_FunnelSegmentClipper oldClipper) {
    return topWidth != oldClipper.topWidth || bottomWidth != oldClipper.bottomWidth;
  }
}

class _ChartContainer extends StatelessWidget {
  final Widget child;

  const _ChartContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(12),
      // decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
      child: child,
    );
  }
}
