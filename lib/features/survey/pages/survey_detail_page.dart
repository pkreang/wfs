import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/components/survey_status_capsule.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/pages/survey_recipient_list_page.dart';
import 'package:wfs/features/survey/pages/survey_dashboard_page.dart';
import 'package:wfs/features/survey/pages/survey_email_client_list_page.dart';
import 'package:wfs/features/survey/pages/survey_form_page.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_action_tile.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';
import 'package:wfs/widgets/app_text.dart';

class SurveyDetailPage extends ConsumerWidget {
  final String surveyID;
  final bool isPreviewOnly;
  final bool isSendEmailOnly;
  final String? email;
  final String? clientID;
  final String? clientFirstName;
  final String? clientLastName;
  final String? appointmentID;

  const SurveyDetailPage({
    required this.surveyID,
    this.isPreviewOnly = false,
    this.isSendEmailOnly = false,
    this.email,
    this.clientID,
    this.clientFirstName,
    this.clientLastName,
    this.appointmentID,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(surveyDetailProvider(surveyID));

    return state.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
      ),
      error: (error, stackTrace) => const Scaffold(
        body: Center(
          child: AppText(label: 'Survey Not Found', textColor: Colors.red),
        ),
      ),
      data: (survey) => Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFEEEEEE),
          leadingWidth: 80,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                IconButton(
                  icon: Row(
                    children: [
                      const Icon(Icons.chevron_left),
                      AppText(label: 'Back', textColor: AppUtility.colorPrimary),
                    ],
                  ),
                  onPressed: null,
                  style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                ),
              ],
            ),
          ),
          title: const AppText(label: 'Survey Detail', fontSize: 17, fontWeight: FontWeight.w600),
          actions: [
            if (!isPreviewOnly)
              TextButton(
                onPressed: () async {
                  final didSave = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (context) => SurveyFormPage(survey: survey)));
                  if (!context.mounted || didSave != true) return;

                  // Refresh the exact family instance watched by this page.
                  ref.invalidate(surveyDetailProvider(surveyID));
                },
                child: AppText(label: 'Edit', textColor: AppUtility.colorPrimary),
              ),
          ],
        ),
        body: _SurveyDetailContent(
          survey: survey,
          isSendEmailOnly: isSendEmailOnly,
          email: email,
          clientID: clientID,
          clientFirstName: clientFirstName,
          clientLastName: clientLastName,
          appointmentID: appointmentID,
          onDelete: isPreviewOnly ? null : () => _confirmDelete(context, ref, survey),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Survey survey) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete Survey', textScaler: TextScaler.noScaling),
          content: const Text('Are you sure you want to delete this survey?', textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final result = await ref.read(surveyServiceProvider).deleteSurvey(ref, survey.surveyID ?? '');
                  if (!context.mounted) return;

                  if (!result) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to delete survey')));
                    return;
                  }

                  ref.invalidate(surveyListProvider);
                  Navigator.of(context).pop(true);
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to delete survey: $error')));
                }
              },
              child: const AppText(label: 'Delete', textColor: AppUtility.colorRed),
            ),
          ],
        );
      },
    );
  }
}

class _SurveyDetailContent extends ConsumerWidget {
  final Survey survey;
  final VoidCallback? onDelete;
  final bool isSendEmailOnly;
  final String? email;
  final String? clientID;
  final String? clientFirstName;
  final String? clientLastName;
  final String? appointmentID;

  const _SurveyDetailContent({required this.survey, required this.onDelete, required this.isSendEmailOnly, this.email, this.clientID, this.clientFirstName, this.clientLastName, this.appointmentID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    final questionTypes = ref.watch(surveyListProvider).questionTypes.valueOrNull ?? const [];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        spacing: 16,
        children: [
          Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 24,
            children: [
              AppText(label: survey.title, fontSize: 18, maxLines: null, textAlign: TextAlign.center),
              Wrap(
                runSpacing: 8,
                alignment: WrapAlignment.center,
                spacing: 6,
                children: [SurveyStatusCapsule(isActive: survey.status)],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              if (!isSendEmailOnly)
                AppActionTile(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SurveyDashboardPage(surveyID: survey.surveyID ?? '', title: survey.title),
                    ),
                  ),
                  width: 78,
                ),
              AppActionTile(
                icon: Icons.email_rounded,
                title: 'Email',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SurveyEmailClientListPage(
                      surveyTemplateID: survey.surveyTemplateID ?? '',
                      title: survey.title,
                      email: email,
                      clientID: clientID,
                      clientFirstName: clientFirstName,
                      clientLastName: clientLastName,
                      appointmentID: appointmentID,
                    ),
                  ),
                ),
              ),
              if (!auth.isSales)
                AppActionTile(
                  icon: Icons.library_books_outlined,
                  title: 'Recipient',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SurveyRecipientListPage(surveyTemplateID: survey.surveyTemplateID ?? '', title: survey.title),
                    ),
                  ),
                ),
            ],
          ),
          AppDetailSectionCard(
            title: 'Detail',
            descWidget: AppText(label: survey.description, maxLines: null),
            fullWidth: true,
          ),
          // AppDetailSectionCard(
          //   title: 'survey link',
          //   descWidget: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     spacing: 12,
          //     children: [
          //       SelectableText(link),
          //       Row(
          //         children: [
          //           TextButton(
          //             onPressed: () async {
          //               await Clipboard.setData(ClipboardData(text: link));
          //               if (!context.mounted) return;
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(content: Text('Survey link copied')),
          //               );
          //             },
          //             child: AppText(
          //               label: 'Copy Link',
          //               textColor: AppUtility.colorPrimary,
          //             ),
          //           ),
          //           TextButton(
          //             onPressed: () => Navigator.of(context).push(
          //               MaterialPageRoute(
          //                 builder: (context) => SurveyDashboardPage(
          //                   refCode: survey.refCode,
          //                   title: survey.title,
          //                 ),
          //               ),
          //             ),
          //             child: AppText(
          //               label: 'Dashboard',
          //               textColor: AppUtility.colorPrimary,
          //             ),
          //           ),
          //         ],
          //       ),
          //       _QrPlaceholder(refCode: survey.refCode),
          //     ],
          //   ),
          //   fullWidth: true,
          // ),
          AppDetailSectionCard(
            title: 'Questions',
            descWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: survey.questions.map((question) {
                final type = questionTypes.where((item) => item.questionTypeID.toLowerCase() == question.questionTypeID?.toLowerCase()).firstOrNull;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(label: question.title),
                      AppText(label: type?.typeDescription ?? question.answerType.value, fontSize: 12, textColor: AppUtility.textLight),
                    ],
                  ),
                );
              }).toList(),
            ),
            fullWidth: true,
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
                alignment: Alignment.center,
                child: const AppText(label: 'Delete Survey', textColor: AppUtility.colorRed, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
