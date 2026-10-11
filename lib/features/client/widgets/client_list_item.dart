import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/widgets/client_level_capsule.dart';
import 'package:wfs/features/client/widgets/client_status_capsule.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class ClientListItem extends StatelessWidget {
  final Client client;
  final bool isEdit;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ClientListItem({super.key, required this.client, this.isEdit = false, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Row(
        children: [
          if (isEdit)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  if (client.clientType?.trim().isNotEmpty == true)
                                    CapsuleWidget(
                                      label: client.clientType!.trim(),
                                      capsuleStyle: client.clientType == 'Client'
                                          ? CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2))
                                          : CapsuleStyle(const Color(0xFF2F80ED), const Color.fromRGBO(47, 128, 237, 0.2)),
                                    ),
                                  Flexible(child: AppText(label: '${client.firstName ?? ''} ${client.lastName ?? ''}', fontSize: 17)),
                                  ClientStatusCapsule(clientStatusName: client.clientStatus?.clientStatusName ?? ''),
                                  ClientLevelCapsule(clientLevelName: client.clientLevel?.clientLevelName ?? ''),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (client.phone != null && client.phone!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Icon(Icons.phone, color: Colors.grey.shade600, size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppText(label: client.phone.toString(), fontSize: 14, textColor: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              if (client.addresses?.isNotEmpty == true && client.addresses!.first.address != null && client.addresses!.first.address!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppText(label: client.addresses!.first.address!, fontSize: 14, textColor: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, indent: 16, color: Color(0xFFEFEFEF)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
