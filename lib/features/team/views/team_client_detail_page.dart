import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/views/client_detail_page.dart';
import 'package:wfs/features/client/widgets/client_list_item.dart';

class TeamClientDetailPage extends ConsumerStatefulWidget {
  final String saleName;
  final List<String> clientIDs;

  const TeamClientDetailPage({super.key, required this.saleName, required this.clientIDs});

  @override
  ConsumerState<TeamClientDetailPage> createState() => _TeamClientDetailPageState();
}

class _TeamClientDetailPageState extends ConsumerState<TeamClientDetailPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamClientDetailProvider(widget.clientIDs));
    final clientList = state;
    final countText = clientList.when(data: (clients) => '${widget.clientIDs.length} clients', loading: () => 'Loading...', error: (err, stack) => 'Error');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            AppText(label: widget.saleName, fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: clientList.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (clients) {
            if (clients.isEmpty) {
              return const Center(child: AppText(label: 'No clients found.'));
            }
            return _buildClientList(clients);
          },
        ),
      ),
    );
  }

  Widget _buildClientList(List<Client> clients) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: clients.length,
      itemBuilder: (context, itemIndex) {
        final client = clients[itemIndex];
        return ClientListItem(
          client: client,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientDetailPage(clientID: client.clientID ?? ''))),
        );
      },
    );
  }
}
