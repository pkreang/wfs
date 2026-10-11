import 'package:flutter/material.dart';
import 'package:wfs/features/survey/widgets/survey_list_widget.dart';
import 'package:wfs/widgets/app_text.dart';

class SurveyListPicker extends StatelessWidget {
  const SurveyListPicker({super.key, this.isPreviewOnly = false, this.isSendEmailOnly = false, this.email, this.clientID, this.clientFirstName, this.clientLastName, this.appointmentID});

  final bool isPreviewOnly;
  final bool isSendEmailOnly;
  final String? email;
  final String? clientID;
  final String? clientFirstName;
  final String? clientLastName;
  final String? appointmentID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        title: const AppText(label: 'Survey', fontSize: 17, fontWeight: FontWeight.w600),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: SurveyListWidget(
          isShowLink: false,
          isPreviewOnly: isPreviewOnly,
          isSendEmailOnly: isSendEmailOnly,
          email: email,
          clientID: clientID,
          clientFirstName: clientFirstName,
          clientLastName: clientLastName,
          appointmentID: appointmentID,
        ),
      ),
    );
  }
}
