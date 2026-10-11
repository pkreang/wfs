import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/models/survey_answer_model.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/models/survey_question_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class SurveyAnswerPage extends ConsumerStatefulWidget {
  final String refCode;

  const SurveyAnswerPage({required this.refCode, super.key});

  @override
  ConsumerState<SurveyAnswerPage> createState() => _SurveyAnswerPageState();
}

class _SurveyAnswerPageState extends ConsumerState<SurveyAnswerPage> {
  final Map<String, TextEditingController> textControllers = {};
  final Map<String, int> scoreAnswers = {};
  bool isLoading = false;

  @override
  void dispose() {
    for (final controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> submit(Survey survey) async {
    final answers = <SurveyQuestionAnswer>[];
    for (final question in survey.questions) {
      if (question.answerType == SurveyAnswerType.text) {
        final text = textControllers[question.id]?.text.trim() ?? '';
        if (question.isRequired && text.isEmpty) {
          AppDialogs.error(context, message: 'กรุณาตอบคำถามให้ครบ');
          return;
        }
        answers.add(
          SurveyQuestionAnswer(questionID: question.id, textAnswer: text),
        );
      } else {
        final score = scoreAnswers[question.id];
        if (question.isRequired && score == null) {
          AppDialogs.error(context, message: 'กรุณาเลือกคะแนนให้ครบ');
          return;
        }
        answers.add(
          SurveyQuestionAnswer(questionID: question.id, scoreAnswer: score),
        );
      }
    }

    setState(() => isLoading = true);
    try {
      final result = await ref
          .read(surveyServiceProvider)
          .submitSurveyAnswer(
            ref: ref,
            refCode: widget.refCode,
            answers: answers,
          );
      if (!mounted) return;
      if (!result) {
        AppDialogs.alert(context, message: 'Submit failed');
        return;
      }
      ref.invalidate(surveyDashboardProvider(widget.refCode));
      AppDialogs.success(
        context,
        title: 'Thank you',
        message: 'Survey submitted successfully',
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(surveyByRefCodeProvider(widget.refCode));

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          appBar: AppBar(
            centerTitle: true,
            title: const AppText(
              label: 'Survey',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          body: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(
              child: AppText(label: 'Survey Not Found', textColor: Colors.red),
            ),
            data: (survey) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  AppText(
                    label: survey.title,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  ...survey.questions.map(_buildQuestion),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => submit(survey),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading) ...[
          const ModalBarrier(color: Color(0x66000000), dismissible: false),
          const Center(
            child: CircularProgressIndicator(color: AppUtility.colorPrimary),
          ),
        ],
      ],
    );
  }

  Widget _buildQuestion(SurveyQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          AppText(label: question.title, fontWeight: FontWeight.w600),
          if (question.answerType == SurveyAnswerType.text)
            AppTextFormField(
              controller: textControllers.putIfAbsent(
                question.id,
                TextEditingController.new,
              ),
              maxLines: 3,
              isShowBorder: true,
            )
          else
            Wrap(
              spacing: 8,
              children: List.generate(
                question.scoreMax - question.scoreMin + 1,
                (index) {
                  final score = question.scoreMin + index;
                  final selected = scoreAnswers[question.id] == score;
                  return ChoiceChip(
                    label: Text(score.toString()),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => scoreAnswers[question.id] = score),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
