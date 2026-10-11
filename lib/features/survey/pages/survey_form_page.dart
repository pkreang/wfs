import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_cupertino_option.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/models/survey_question_model.dart';
import 'package:wfs/features/survey/models/survey_question_type_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class SurveyFormPage extends ConsumerStatefulWidget {
  final Survey? survey;

  const SurveyFormPage({this.survey, super.key});

  @override
  ConsumerState<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends ConsumerState<SurveyFormPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late List<_QuestionFormState> questions;
  late final ProviderSubscription<AsyncValue<List<SurveyQuestionType>>>
  _questionTypesSubscription;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.survey?.title ?? '';
    descriptionController.text = widget.survey?.description ?? '';
    questions = (widget.survey?.questions ?? const [])
        .map(_QuestionFormState.fromQuestion)
        .toList();
    if (questions.isEmpty) questions.add(_QuestionFormState.empty());
    _questionTypesSubscription = ref.listenManual(
      surveyListProvider.select((state) => state.questionTypes),
      (_, questionTypes) {
        final types = questionTypes.valueOrNull;
        if (types == null || types.isEmpty) return;
        _setDefaultQuestionType(types.first);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _questionTypesSubscription.close();
    titleController.dispose();
    descriptionController.dispose();
    for (final question in questions) {
      question.dispose();
    }
    super.dispose();
  }

  Future<void> handleSave() async {
    if (Validator.required(titleController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Survey Title');
      return;
    }

    if (Validator.required(descriptionController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Survey Description');
      return;
    }

    if (questions.any(
      (question) => question.titleController.text.trim().isEmpty,
    )) {
      AppDialogs.error(context, message: 'กรุณากรอก Question');
      return;
    }

    setState(() => isLoading = true);
    final survey = Survey(
      surveyID: widget.survey?.surveyID,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      refCode: widget.survey?.refCode ?? '',
      status: widget.survey?.status ?? 'Active',
      createdAt: widget.survey?.createdAt,
      questions: questions.map((question) => question.toQuestion()).toList(),
    );

    try {
      final service = ref.read(surveyServiceProvider);
      final ok = widget.survey == null
          ? (await service.createSurvey(ref, survey))
          : await service.updateSurvey(ref, survey);
      if (!mounted) return;
      if (!ok) {
        AppDialogs.alert(
          context,
          title: 'ไม่สามารถดำเนินการได้',
          message: 'Request failed',
        );
        return;
      }

      ref.invalidate(surveyListProvider);
      AppDialogs.success(
        context,
        title: 'SUCCESS',
        message: 'Data saved successfully',
        btnOkOnPress: () => Navigator.pop(context, true),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionTypes =
        ref.watch(
          surveyListProvider.select((state) => state.questionTypes.valueOrNull),
        ) ??
        const <SurveyQuestionType>[];

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFEEEEEE),
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: const Color(0xFFEEEEEE),
              leadingWidth: 100,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: null,
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.all(
                          AppUtility.colorPrimary,
                        ),
                      ),
                    ),
                    AppText(label: 'Back', textColor: AppUtility.colorPrimary),
                  ],
                ),
              ),
              title: AppText(
                label: widget.survey == null ? 'Create Survey' : 'Edit Survey',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              actions: [
                TextButton(
                  onPressed: handleSave,
                  child: AppText(
                    label: 'Done',
                    textColor: AppUtility.colorPrimary,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  FormInfoTile(
                    label: 'Title',
                    value: AppTextFormField(controller: titleController),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Description',
                    value: AppTextFormField(controller: descriptionController),
                    isHideIcon: true,
                  ),
                  if (widget.survey?.refCode.isNotEmpty == true)
                    FormInfoTile(
                      label: 'ref_code',
                      value: AppText(label: widget.survey!.refCode),
                      isHideIcon: true,
                    ),
                  const SizedBox(height: 16),
                  ...questions.indexed.map((entry) {
                    final index = entry.$1;
                    final question = entry.$2;
                    return _QuestionEditor(
                      index: index,
                      state: question,
                      typeLabel: _questionTypeLabel(question, questionTypes),
                      onTypeTap: () => _openAnswerTypeSheet(question),
                      onRemove: questions.length == 1
                          ? null
                          : () => setState(() {
                              question.dispose();
                              questions.removeAt(index);
                            }),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      // child: OutlinedButton.icon(onPressed: () => setState(() => questions.add(_QuestionFormState.empty())), icon: const Icon(Icons.add), label: const Text('Add Question')),
                      child: GestureDetector(
                        onTap: () => setState(
                          () => questions.add(
                            _QuestionFormState.empty(
                              questionType: questionTypes.isEmpty
                                  ? null
                                  : questionTypes.first,
                            ),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: const AppText(
                            label: 'Add Question',
                            textColor: AppUtility.colorPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Future<void> _openAnswerTypeSheet(_QuestionFormState question) async {
    final selected = await CupertinoOptionsPicker.show<SurveyQuestionType>(
      context: context,
      title: 'Question Type',
      provider: surveyListProvider.select((state) => state.questionTypes),
      label: (type) => type.typeName,
      initialKey: (type) => type.questionTypeID,
      initialValue: question.questionTypeID ?? '',
    );
    if (selected == null) return;
    setState(() {
      question.questionTypeID = selected.questionTypeID;
      question.answerType = SurveyAnswerType.fromValue(selected.typeCode);
    });
  }

  String _questionTypeLabel(
    _QuestionFormState question,
    List<SurveyQuestionType> questionTypes,
  ) {
    for (final type in questionTypes) {
      if (type.questionTypeID.toLowerCase() ==
          question.questionTypeID?.toLowerCase()) {
        return type.typeName;
      }
    }
    return question.answerType.value;
  }

  void _setDefaultQuestionType(SurveyQuestionType questionType) {
    final questionsWithoutType = questions
        .where(
          (question) =>
              question.questionTypeID == null ||
              question.questionTypeID!.isEmpty,
        )
        .toList();
    if (questionsWithoutType.isEmpty || !mounted) return;

    setState(() {
      for (final question in questionsWithoutType) {
        question.questionTypeID = questionType.questionTypeID;
        question.answerType = SurveyAnswerType.fromValue(questionType.typeCode);
      }
    });
  }
}

class _QuestionEditor extends StatelessWidget {
  final int index;
  final _QuestionFormState state;
  final String typeLabel;
  final VoidCallback onTypeTap;
  final VoidCallback? onRemove;

  const _QuestionEditor({
    required this.index,
    required this.state,
    required this.typeLabel,
    required this.onTypeTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            // color: const Color(0xFFE5E5EA),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    label: 'Question ${index + 1}',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onRemove != null)
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppUtility.colorRed,
                    ),
                  ),
              ],
            ),
          ),
          FormInfoTile(
            label: 'Question',
            value: AppTextFormField(controller: state.titleController),
            isHideIcon: true,
          ),
          FormInfoTile(
            label: 'Type',
            value: AppText(label: typeLabel),
            onTap: onTypeTap,
          ),
          if (state.answerType == SurveyAnswerType.score)
            FormInfoTile(
              label: 'Score',
              value: Row(
                children: [
                  Expanded(
                    child: Container(
                      // width: 100,
                      // alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          end: const BorderSide(
                            color: AppUtility.colorGray,
                            width: AppUtility.borderWidth,
                          ),
                        ),
                      ),
                      child: AppText(label: state.scoreMinController.text),
                      // AppTextFormField(controller: state.scoreMinController, hintText: 'Min Score', isNumberOnly: true),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: AppText(label: state.scoreMaxController.text),
                    ),
                  ),
                  // Expanded(child: AppTextFormField(controller: state.scoreMinController, isNumberOnly: true)),
                  // const Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 8),
                  //   child: AppText(label: '-'),
                  // ),
                  // Expanded(child: AppTextFormField(controller: state.scoreMaxController, isNumberOnly: true)),
                ],
              ),
              isHideIcon: true,
              isShowBorderBottom: true,
            ),
        ],
      ),
    );
  }
}

class _QuestionFormState {
  final String id;
  String? questionTypeID;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController scoreMinController;
  final TextEditingController scoreMaxController;
  SurveyAnswerType answerType;

  _QuestionFormState({
    required this.id,
    this.questionTypeID,
    required this.titleController,
    required this.descriptionController,
    required this.scoreMinController,
    required this.scoreMaxController,
    required this.answerType,
  });

  factory _QuestionFormState.empty({SurveyQuestionType? questionType}) {
    final now = DateTime.now();
    return _QuestionFormState(
      id: 'question_${now.microsecondsSinceEpoch}',
      questionTypeID: questionType?.questionTypeID,
      titleController: TextEditingController(),
      descriptionController: TextEditingController(),
      scoreMinController: TextEditingController(text: '1'),
      scoreMaxController: TextEditingController(text: '5'),
      answerType: SurveyAnswerType.fromValue(questionType?.typeCode),
    );
  }

  factory _QuestionFormState.fromQuestion(SurveyQuestion question) {
    return _QuestionFormState(
      id: question.id,
      questionTypeID: question.questionTypeID,
      titleController: TextEditingController(text: question.title),
      descriptionController: TextEditingController(text: question.description),
      scoreMinController: TextEditingController(
        text: question.scoreMin.toString(),
      ),
      scoreMaxController: TextEditingController(
        text: question.scoreMax.toString(),
      ),
      answerType: question.answerType,
    );
  }

  SurveyQuestion toQuestion() {
    final scoreMin = int.tryParse(scoreMinController.text) ?? 1;
    final scoreMax = int.tryParse(scoreMaxController.text) ?? 5;

    return SurveyQuestion(
      id: id,
      questionTypeID: questionTypeID,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      answerType: answerType,
      scoreMin: scoreMin,
      scoreMax: scoreMax < scoreMin ? scoreMin : scoreMax,
    );
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    scoreMinController.dispose();
    scoreMaxController.dispose();
  }
}
