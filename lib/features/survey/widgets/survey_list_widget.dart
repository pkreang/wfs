import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/pages/survey_detail_page.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class SurveyListWidget extends ConsumerWidget {
  const SurveyListWidget({
    super.key,
    this.isShowLink = true,
    this.isPreviewOnly = false,
    this.isSendEmailOnly = false,
    this.email,
    this.clientID,
    this.clientFirstName,
    this.clientLastName,
    this.appointmentID,
  });

  final bool isShowLink;
  final bool isPreviewOnly;
  final bool isSendEmailOnly;
  final String? email;
  final String? clientID;
  final String? clientFirstName;
  final String? clientLastName;
  final String? appointmentID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(surveyListProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(surveyListProvider.notifier).fetch(),
      child: state.surveys.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (surveys) {
          if (surveys.isEmpty) {
            return const Center(child: AppText(label: 'No surveys found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: surveys.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _SurveyListItem(
                survey: surveys[index],
                isShowLink: isShowLink,
                isPreviewOnly: isPreviewOnly,
                isSendEmailOnly: isSendEmailOnly,
                email: email,
                clientID: clientID,
                clientFirstName: clientFirstName,
                clientLastName: clientLastName,
                appointmentID: appointmentID,
              );
            },
          );
        },
      ),
    );
  }
}

class _SurveyListItem extends ConsumerWidget {
  const _SurveyListItem({
    required this.survey,
    required this.isShowLink,
    required this.isPreviewOnly,
    required this.isSendEmailOnly,
    this.email,
    this.clientID,
    this.clientFirstName,
    this.clientLastName,
    this.appointmentID,
  });

  final Survey survey;
  final bool isShowLink;
  final bool isPreviewOnly;
  final bool isSendEmailOnly;
  final String? email;
  final String? clientID;
  final String? clientFirstName;
  final String? clientLastName;
  final String? appointmentID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final link = ref.read(surveyListProvider.notifier).surveyLink(survey.refCode);

    return ListTile(
      tileColor: Colors.white,
      title: AppText(label: survey.title, fontWeight: FontWeight.w500),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: AppText(label: survey.status, fontSize: 12, textColor: AppUtility.colorPrimary),
      ),
      // trailing: isShowLink
      //     ? TextButton(
      //         onPressed: () async {
      //           await Clipboard.setData(ClipboardData(text: link));
      //           if (!context.mounted) return;
      //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Survey link copied')));
      //         },
      //         child: AppText(label: 'Copy Link', textColor: AppUtility.colorPrimary),
      //       )
      //     : null,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SurveyDetailPage(
            surveyID: survey.surveyID ?? '',
            isPreviewOnly: isPreviewOnly,
            isSendEmailOnly: isSendEmailOnly,
            email: email,
            clientID: clientID,
            clientFirstName: clientFirstName,
            clientLastName: clientLastName,
            appointmentID: appointmentID,
          ),
        ),
      ),
    );
  }
}
