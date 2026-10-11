import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/widgets/app_text.dart';

class SurveyEmailClientListPage extends ConsumerStatefulWidget {
  final String surveyTemplateID;
  final String? clientID;
  final String? clientFirstName;
  final String? clientLastName;
  final String? appointmentID;
  final String? title;
  final String? email;
  final List<Client> initialSelected;
  final ValueChanged<List<Client>>? onSubmitSelected;
  final ValueChanged<List<String>>? onSubmitEmails;

  const SurveyEmailClientListPage({
    required this.surveyTemplateID,
    this.clientID,
    this.clientFirstName,
    this.clientLastName,
    this.appointmentID,
    this.title,
    this.email,
    this.initialSelected = const [],
    this.onSubmitSelected,
    this.onSubmitEmails,
    super.key,
  });

  @override
  ConsumerState<SurveyEmailClientListPage> createState() => _SurveyEmailClientListPageState();
}

class _SurveyEmailClientListPageState extends ConsumerState<SurveyEmailClientListPage> {
  final Map<String, Client> _selectedClients = <String, Client>{};
  final Set<String> _emails = <String>{};
  String _searchQuery = '';
  bool _isSubmitting = false;

  bool get _isBusy => _isSubmitting;

  bool get _isDirectEmailMode => (widget.email?.trim().isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    if (_isDirectEmailMode) {
      _emails.add(widget.email!.trim());
      return;
    }
    for (final client in _emailReadyClients(widget.initialSelected)) {
      final clientId = client.clientID;
      if (clientId != null && clientId.isNotEmpty) {
        _selectedClients[clientId] = client;
      }
    }
  }

  Future<void> _refreshClients() async {
    if (_isDirectEmailMode) return;
    final clientsFuture = ref.refresh(clientForLeadProvider.future);
    await clientsFuture;
  }

  void _toggleClient(Client client) {
    final clientId = client.clientID;
    if (clientId == null || clientId.isEmpty) return;
    setState(() {
      if (_selectedClients.containsKey(clientId)) {
        _selectedClients.remove(clientId);
      } else {
        _selectedClients[clientId] = client;
      }
    });
  }

  Future<void> _confirmAndSubmitSelection() async {
    final isConfirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Email Sending', textScaler: TextScaler.noScaling),
          content: const Text('Are you sure you want to send this email to the selected recipients?', textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: AppText(label: 'Confirm', textColor: AppUtility.colorPrimary),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      await _submitSelection();
    }
  }

  Future<void> _submitSelection() async {
    if (!mounted || _selectedClients.isEmpty || _isBusy) return;

    final selectedClients = _selectedClients.values.toList();
    final clientIds = selectedClients.map((client) => client.clientID!).toList();
    setState(() => _isSubmitting = true);
    try {
      final service = ref.read(surveyServiceProvider);
      for (var index = 0; index < clientIds.length; index++) {
        await service.createTicket(ref, surveyTemplateID: widget.surveyTemplateID, clientID: clientIds[index], appointmentID: widget.appointmentID);
        if (!mounted) return;
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to send survey emails: $error')));
      }
      return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) return;
    final count = selectedClients.length;
    AppDialogs.success(
      context,
      title: 'SUCCESS',
      message: 'Survey email sent successfully to $count ${count == 1 ? 'recipient' : 'recipients'}.',
      btnOkOnPress: () {
        if (!mounted) return;
        if (_isDirectEmailMode) {
          final emails = selectedClients.map((client) => client.email!.trim()).toList();
          widget.onSubmitEmails?.call(emails);
          if (mounted) Navigator.of(context).pop(emails);
          return;
        }
        widget.onSubmitSelected?.call(selectedClients);
        if (mounted) Navigator.of(context).pop(selectedClients);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isBusy,
      child: Stack(
        children: [
          _buildPage(),
          if (_isBusy)
            const Positioned.fill(
              child: Stack(
                children: [
                  ModalBarrier(dismissible: false, color: Colors.black26),
                  Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    final clients = _isDirectEmailMode
        ? AsyncValue<List<Client>>.data(_emails.map((email) => Client(clientID: widget.clientID, firstName: widget.clientFirstName, lastName: widget.clientLastName, email: email)).toList())
        : ref.watch(clientForLeadProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: AppUtility.borderWidth,
        iconTheme: const IconThemeData(color: AppUtility.colorPrimary),
        title: Text(
          'Clients',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: clients.maybeWhen(data: (_) => _selectedClients.isNotEmpty && !_isBusy ? _confirmAndSubmitSelection : null, orElse: () => null),
            tooltip: 'Send email',
            icon: Icon(Icons.email_outlined, color: _selectedClients.isNotEmpty ? AppUtility.colorPrimary : AppUtility.textGray),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: clients.when(
                data: (clients) {
                  final emailReadyClients = _searchClients(_emailReadyClients(clients));

                  if (emailReadyClients.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshClients,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                        children: const [
                          SizedBox(height: 240),
                          Center(child: AppText(label: 'No clients with email found.')),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshClients,
                    child: _SurveyEmailClientListView(
                      clients: emailReadyClients,
                      selectedClientIds: _selectedClients.keys.toSet(),
                      physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                      onToggleClient: _toggleClient,
                    ),
                  );
                },
                error: (err, _) => RefreshIndicator(
                  onRefresh: _refreshClients,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                    children: [
                      const SizedBox(height: 240),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AppText(label: err.toString(), textColor: AppUtility.colorRed, textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: (query) => setState(() => _searchQuery = query.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  List<Client> _searchClients(List<Client> clients) {
    if (_searchQuery.isEmpty) return clients;
    return clients.where((client) {
      final name = '${client.firstName ?? ''} ${client.lastName ?? ''}'.toLowerCase();
      final email = (client.email ?? '').toLowerCase();
      return name.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();
  }

  List<Client> _emailReadyClients(List<Client> clients) {
    return clients.where((client) {
      final email = client.email?.trim() ?? '';
      return email.isNotEmpty;
    }).toList();
  }
}

class _SurveyEmailClientListView extends StatelessWidget {
  final List<Client> clients;
  final ValueChanged<Client>? onToggleClient;
  final Set<String> selectedClientIds;
  final ScrollPhysics? physics;

  const _SurveyEmailClientListView({required this.clients, required this.selectedClientIds, this.onToggleClient, this.physics});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: physics,
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        final name = '${client.firstName ?? ''} ${client.lastName ?? ''}'.trim();
        final email = client.email?.trim() ?? '';
        final isSelected = selectedClientIds.contains(client.clientID);

        return InkWell(
          onTap: () => onToggleClient?.call(client),
          child: Container(
            color: isSelected ? const Color(0xFFE8F0FF) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(label: name.isEmpty ? email : name, fontSize: 15, fontWeight: FontWeight.w600, lineHeight: 20, maxLines: 2),
                      if (name.isNotEmpty) ...[const SizedBox(height: 2), AppText(label: email, fontSize: 13, textColor: const Color(0xFF6B7280), lineHeight: 18, maxLines: 2)],
                    ],
                  ),
                ),
                Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? AppUtility.colorPrimary : AppUtility.textGray, size: 20),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: AppUtility.borderWidth, color: AppUtility.colorGray),
    );
  }
}
