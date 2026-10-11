import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/client/views/client_list_page.dart';
import 'package:wfs/features/company/views/company_list_page.dart';
import 'package:wfs/features/lead/views/lead_list_page.dart';
import 'package:wfs/features/leaddashboard2/pages/lead_dashboard2_page.dart';
import 'package:wfs/features/phase3/lead_workflow/views/lead_workflow_page.dart';
import 'package:wfs/features/salepepeline/views/sales_pipeline_page.dart';
import 'package:wfs/features/sales/views/sales_screen.dart';
import 'package:wfs/features/salesconversionfunnel/models/sales_conversion_funnel_item.dart';
import 'package:wfs/features/survey/pages/survey_list_page.dart';
import 'package:wfs/features/task/views/task_list_page.dart';
import 'package:wfs/features/team/views/team_screen.dart';
import 'package:wfs/features/territory/views/territory_screen.dart';
import 'package:wfs/models/auth_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/notification_provider.dart';
import 'package:wfs/screens/appointment_screen.dart';
import 'package:wfs/screens/dashboard_screen.dart';
import 'package:wfs/screens/setting_screen.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase2Screen extends ConsumerStatefulWidget {
  const Phase2Screen({super.key});

  @override
  ConsumerState<Phase2Screen> createState() => _Phase2ScreenState();
}

class _Phase2ScreenState extends ConsumerState<Phase2Screen> {
  _AppDestination _currentDestination = _AppDestination.dashboard;

  late final Map<_AppDestination, Widget> _screens = {
    _AppDestination.dashboard: const DashboardScreen(),
    _AppDestination.conversion: LeadDashboard2Page(onOpenLeads: _openLeads),
    _AppDestination.leads: const LeadScreen(),
    _AppDestination.pipeline: const SalesPipelinePage(),
    _AppDestination.appointments: const AppointmentScreen(),
    _AppDestination.tasks: const TaskScreen(),
    _AppDestination.surveys: const SurveyListPage(),
    _AppDestination.clients: const ClientScreen(),
    _AppDestination.companies: const CompanyScreen(),
    _AppDestination.leadWorkflow: LeadWorkflowPage(),
    _AppDestination.users: const SalesScreen(),
    _AppDestination.teams: const TeamScreen(),
    _AppDestination.territories: const TerritoryScreen(),
    _AppDestination.accounts: const SettingScreen(),
  };

  @override
  void initState() {
    super.initState();
    _fetchClientNotifications();
    _fetchAppointmentNotifications();
  }

  Future<void> _fetchClientNotifications() async {
    try {
      final clientService = ref.read(clientServiceProvider);
      final clients = await clientService.getNotifications(ref);
      if (!mounted) return;

      final notificationService = ref.read(notificationServiceProvider);
      for (var i = 0; i < clients.length; i++) {
        final client = clients[i];
        await notificationService.showNotification(id: i + 1000, title: 'มี Client ใหม่สำหรับคุณ', body: 'Client ใหม่ ชื่อ ${client.firstName} ${client.lastName}');
      }
    } catch (e) {
      debugPrint('Error fetching client notifications: $e');
    }
  }

  Future<void> _fetchAppointmentNotifications() async {
    try {
      final appointmentService = ref.read(appointmentServiceProvider);
      final appointments = await appointmentService.getNotifications(ref);
      if (!mounted) return;

      final notificationService = ref.read(notificationServiceProvider);
      for (var i = 0; i < appointments.length; i++) {
        final appointment = appointments[i];
        await notificationService.showNotification(id: i + 1000, title: 'นัดหมายทีกำลังจะมาถึง', body: 'Client ชื่อ ${appointment.clientName} บริษัทชื่อ ${appointment.companyName}');
      }
    } catch (e) {
      debugPrint('Error fetching appointment notifications: $e');
    }
  }

  void _openLeads() {
    setState(() => _currentDestination = _AppDestination.leads);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final groups = _buildNavigationGroups(authState);
    final destinations = groups.expand((group) => group.destinations).toList();
    final currentDestination = destinations.contains(_currentDestination) ? _currentDestination : _AppDestination.dashboard;
    final currentScreenIndex = destinations.indexOf(currentDestination);
    final currentGroupIndex = groups.indexWhere((group) => group.destinations.contains(currentDestination));

    return Scaffold(
      body: IndexedStack(index: currentScreenIndex, children: destinations.map((destination) => _screens[destination]!).toList()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentGroupIndex,
        selectedItemColor: AppUtility.colorPrimary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          _fetchClientNotifications();
          _fetchAppointmentNotifications();
          _selectGroup(groups[index]);
        },
        items: groups.map((group) => BottomNavigationBarItem(icon: Icon(group.icon), activeIcon: Icon(group.activeIcon), label: group.label)).toList(),
      ),
    );
  }

  List<_NavigationGroupData> _buildNavigationGroups(AuthState authState) {
    final canViewCompanies = authState.isSuperAdmin || authState.isSales;
    final canManageOrganization = authState.isSuperAdmin || authState.isSupervisor;

    return [
      const _NavigationGroupData(group: _NavigationGroup.home, label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home, destinations: [_AppDestination.dashboard, _AppDestination.conversion]),
      const _NavigationGroupData(
        group: _NavigationGroup.work,
        label: 'Task',
        icon: Icons.checklist_outlined,
        activeIcon: Icons.checklist,
        destinations: [_AppDestination.appointments, _AppDestination.surveys],
      ),
      _NavigationGroupData(
        group: _NavigationGroup.leads,
        label: 'Lead',
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        destinations: [if (canViewCompanies) _AppDestination.companies, _AppDestination.leads, _AppDestination.clients],
      ),
      const _NavigationGroupData(group: _NavigationGroup.sales, label: 'Sales Pipeline', icon: Icons.account_tree_outlined, activeIcon: Icons.account_tree, destinations: [_AppDestination.pipeline]),
      _NavigationGroupData(
        group: _NavigationGroup.more,
        label: 'Setting',
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
        destinations: [
          if (canManageOrganization) _AppDestination.territories,
          if (canManageOrganization) ...[_AppDestination.users, _AppDestination.teams],
          _AppDestination.leadWorkflow,
          _AppDestination.accounts,
        ],
      ),
    ];
  }

  Future<void> _selectGroup(_NavigationGroupData group) async {
    if (group.destinations.length == 1) {
      setState(() => _currentDestination = group.destinations.first);
      return;
    }

    final destination = await showModalBottomSheet<_AppDestination>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final sections = _buildSections(group);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Text(group.label, style: Theme.of(sheetContext).textTheme.titleLarge),
                ),
                for (final section in sections) ...[
                  for (final item in section.destinations)
                    ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.label),
                      trailing: item == _currentDestination ? const Icon(Icons.check, color: AppUtility.colorPrimary) : null,
                      selected: item == _currentDestination,
                      selectedColor: AppUtility.colorPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () => Navigator.of(sheetContext).pop(item),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (destination != null && mounted) {
      setState(() => _currentDestination = destination);
    }
  }

  List<_DestinationSection> _buildSections(_NavigationGroupData group) {
    return [_DestinationSection(destinations: group.destinations)];
  }
}

enum _NavigationGroup { home, sales, work, leads, more }

enum _AppDestination {
  dashboard('Dashboard', Icons.dashboard_outlined),
  conversion('Conversion', Icons.analytics_outlined),
  leads('Leads', Icons.person_search_outlined),
  pipeline('Sales Pipeline', Icons.account_tree_outlined),
  appointments('Tasks', Icons.calendar_today_outlined),
  tasks('Tasks', Icons.checklist_outlined),
  surveys('Surveys', Icons.assignment_outlined),
  clients('Clients', Icons.people_outline),
  companies('Companies', Icons.business_center_outlined),
  leadWorkflow('Lead Workflow', Icons.schema_outlined),
  users('Users', Icons.person_outline),
  teams('Teams', Icons.groups_2_outlined),
  territories('Territories', Icons.map_outlined),
  accounts('Accounts', Icons.settings_outlined);

  final String label;
  final IconData icon;

  const _AppDestination(this.label, this.icon);
}

class _NavigationGroupData {
  final _NavigationGroup group;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final List<_AppDestination> destinations;

  const _NavigationGroupData({required this.group, required this.label, required this.icon, required this.activeIcon, required this.destinations});
}

class _DestinationSection {
  final List<_AppDestination> destinations;

  const _DestinationSection({required this.destinations});
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
