import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/survey/models/survey_recipient.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class SurveyRecipientTile extends StatelessWidget {
  final SurveyRecipient recipient;

  const SurveyRecipientTile({required this.recipient, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label: _displayText(recipient.companyName),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          AppText(
            label: _displayText(recipient.clientName),
            fontSize: 14,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          AppText(
            label: _displayText(recipient.email),
            fontSize: 14,
            textColor: AppUtility.textGray,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          AppText(
            label: 'Sales: ${_displayText(recipient.salesName)}',
            fontSize: 14,
            textColor: AppUtility.textGray,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          AppText(
            label: 'Sent Date: ${_formatDate(recipient.sentDate)}',
            fontSize: 12,
            textColor: AppUtility.textGray,
          ),
          const SizedBox(height: 6),
          AppText(
            label: 'Responded Date: ${_formatDate(recipient.respondedDate)}',
            fontSize: 12,
            textColor: AppUtility.textGray,
          ),
          const SizedBox(height: 6),
          AppText(
            label: _displayText(recipient.responseStatus),
            fontSize: 12,
            textColor: AppUtility.textGray,
          ),
        ],
      ),
    );
  }

  String _displayText(String value) => value.trim().isEmpty ? '-' : value;

  String _formatDate(DateTime? date) => date == null
      ? '-'
      : DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
}
