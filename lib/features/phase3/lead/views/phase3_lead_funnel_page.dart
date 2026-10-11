// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_funnel_model.dart';
// import 'package:wfs/features/phase3/lead/repositories/phase3_lead_repository.dart';
// import 'package:wfs/features/phase3/lead/services/phase3_lead_service.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_funnel_chart.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_funnel_item.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_funnel_summary_card.dart';
// import 'package:wfs/utility/app_utility.dart';
// import 'package:wfs/widgets/app_text.dart';

// class Phase3LeadFunnelPage extends StatefulWidget {
//   const Phase3LeadFunnelPage({super.key});

//   @override
//   State<Phase3LeadFunnelPage> createState() => _Phase3LeadFunnelPageState();
// }

// class _Phase3LeadFunnelPageState extends State<Phase3LeadFunnelPage> {
//   final Phase3LeadRepository _repository = Phase3LeadRepository(
//     service: Phase3LeadService(),
//   );
//   late Future<List<Phase3LeadFunnelModel>> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = _repository.getLeadFunnel();
//   }

//   Future<void> _refresh() async {
//     setState(() => _future = _repository.getLeadFunnel());
//     await _future;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F6F6),
//       appBar: AppBar(
//         centerTitle: true,
//         title: const AppText(
//           label: 'Lead Funnel',
//           fontSize: 17,
//           fontWeight: FontWeight.w600,
//         ),
//         shape: const Border(
//           bottom: BorderSide(
//             color: Color.fromRGBO(60, 60, 67, 0.36),
//             width: 0.5,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: _refresh,
//           child: FutureBuilder<List<Phase3LeadFunnelModel>>(
//             future: _future,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting &&
//                   !snapshot.hasData) {
//                 return const Center(
//                   child: CircularProgressIndicator(
//                     color: AppUtility.colorPrimary,
//                   ),
//                 );
//               }
//               if (snapshot.hasError) {
//                 return Center(
//                   child: AppText(
//                     label: snapshot.error.toString(),
//                     textColor: AppUtility.colorRed,
//                   ),
//                 );
//               }

//               final items = snapshot.data ?? const [];
//               return _buildContent(items);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(List<Phase3LeadFunnelModel> items) {
//     final totalLeads = items.fold<int>(0, (sum, item) => sum + item.leadCount);
//     final totalDealValue = items.fold<double>(
//       0,
//       (sum, item) => sum + item.totalDealValue,
//     );
//     final wonLeads = items
//         .where((item) => item.closeStatus == 'WON')
//         .fold<int>(0, (sum, item) => sum + item.leadCount);
//     final lostLeads = items
//         .where((item) => item.closeStatus == 'LOST')
//         .fold<int>(0, (sum, item) => sum + item.leadCount);

//     return SingleChildScrollView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _SummaryGrid(
//             totalLeads: totalLeads,
//             totalDealValue: totalDealValue,
//             wonLeads: wonLeads,
//             lostLeads: lostLeads,
//           ),
//           const SizedBox(height: 16),
//           Phase3LeadFunnelChart(items: items),
//           const SizedBox(height: 16),
//           const AppText(
//             label: 'Funnel Items',
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//           const SizedBox(height: 8),
//           Container(
//             clipBehavior: Clip.antiAlias,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(11),
//             ),
//             child: items.isEmpty
//                 ? const Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Center(
//                       child: AppText(
//                         label: 'No funnel data found.',
//                         textColor: AppUtility.textGray,
//                       ),
//                     ),
//                   )
//                 : ListView.separated(
//                     padding: EdgeInsets.zero,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: items.length,
//                     separatorBuilder: (context, index) => const Divider(
//                       height: 1,
//                       thickness: AppUtility.borderWidth,
//                       color: AppUtility.colorGray,
//                       indent: 34,
//                     ),
//                     itemBuilder: (context, index) => Phase3LeadFunnelItem(
//                       item: items[index],
//                       totalLeads: totalLeads,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SummaryGrid extends StatelessWidget {
//   final int totalLeads;
//   final double totalDealValue;
//   final int wonLeads;
//   final int lostLeads;

//   const _SummaryGrid({
//     required this.totalLeads,
//     required this.totalDealValue,
//     required this.wonLeads,
//     required this.lostLeads,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       Phase3LeadFunnelSummaryCard(
//         title: 'Total Leads',
//         value: totalLeads.toString(),
//         icon: Icons.people_outline,
//         color: AppUtility.colorPrimary,
//       ),
//       Phase3LeadFunnelSummaryCard(
//         title: 'Total Deal Value',
//         value: NumberFormat('#,##0.##').format(totalDealValue),
//         icon: Icons.payments_outlined,
//         color: const Color(0xFFFF9500),
//       ),
//       Phase3LeadFunnelSummaryCard(
//         title: 'Won Leads',
//         value: wonLeads.toString(),
//         icon: Icons.check_circle_outline,
//         color: const Color(0xFF34C759),
//       ),
//       Phase3LeadFunnelSummaryCard(
//         title: 'Lost Leads',
//         value: lostLeads.toString(),
//         icon: Icons.cancel_outlined,
//         color: AppUtility.colorRed,
//       ),
//     ];

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final crossAxisCount = constraints.maxWidth >= 680 ? 4 : 2;
//         return GridView.builder(
//           padding: EdgeInsets.zero,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: items.length,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             mainAxisExtent: 72,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           itemBuilder: (context, index) => items[index],
//         );
//       },
//     );
//   }
// }
