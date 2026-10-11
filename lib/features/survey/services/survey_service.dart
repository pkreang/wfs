import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/survey/models/survey_recipient.dart';
import 'package:wfs/features/survey/models/survey_recipient_filter.dart';
import 'package:wfs/features/survey/models/survey_answer_model.dart';
import 'package:wfs/features/survey/models/survey_dashboard_model.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/models/survey_question_model.dart';
import 'package:wfs/features/survey/models/survey_question_type_model.dart';
import 'package:wfs/providers/auth_provider.dart';

class SurveyService {
  static const _databaseName = 'wfs_surveys.db';
  static const _databaseVersion = 1;
  static const _surveyTable = 'surveys';
  static const _submissionTable = 'survey_submissions';

  Database? _database;
  final apiClient = ApiClient('https://sfe-api-test.appnormalthink.com');

  Future<Database> get _db async {
    final existing = _database;
    if (existing != null) return existing;

    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$_databaseName';

    _database = await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_surveyTable (
        SurveyID TEXT PRIMARY KEY,
        Title TEXT NOT NULL,
        RefCode TEXT NOT NULL UNIQUE,
        Status TEXT NOT NULL,
        QuestionsJson TEXT NOT NULL,
        CreatedAt TEXT NOT NULL,
        UpdatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_submissionTable (
        SubmissionID TEXT PRIMARY KEY,
        SurveyID TEXT NOT NULL,
        RefCode TEXT NOT NULL,
        AnswersJson TEXT NOT NULL,
        SubmittedAt TEXT NOT NULL
      )
    ''');
  }

  Future<List<Survey>> fetchSurveys(Ref ref, {String sText = '', bool? isActive}) async {
    final accessToken = ref.read(authProvider).accessToken;
    final query = {if (sText.isNotEmpty) 'sText': sText, if (isActive != null) 'IsActive': isActive.toString()};

    return apiClient.getOnly(
      path: '/survey/admin/templates',
      query: query.isEmpty ? null : query,
      headers: {'Authorization': 'Bearer $accessToken'},
      decode: (json) {
        final templates = json as List;
        return templates.map((item) => Survey.fromJson(Map<String, dynamic>.from(item as Map))).toList();
      },
    );
  }

  Future<List<SurveyRecipient>> searchAnswers(Ref ref, String surveyTemplateID, {String sText = '', SurveyRecipientFilter filter = emptySurveyRecipientFilter}) async {
    final accessToken = ref.read(authProvider).accessToken;

    return apiClient.getOnly(
      path: '/survey/admin/search',
      query: {
        'SurveyTemplateID': surveyTemplateID,
        if (sText.isNotEmpty) 'sText': sText,
        if (filter.responStatus != null) 'ResponseStatus': filter.responStatus!,
        if (filter.type != null) 'type': filter.type!,
        if (filter.sendDateFrom != null) 'SentDateFrom': DateFormat('yyyy-MM-dd').format(filter.sendDateFrom!),
        if (filter.sendDateTo != null) 'SentDateTo': DateFormat('yyyy-MM-dd').format(filter.sendDateTo!),
      },
      headers: {'Authorization': 'Bearer $accessToken'},
      decode: (json) {
        final Object? records;
        if (json is List) {
          records = json;
        } else if (json is Map) {
          records = json['Data'] ?? json['data'] ?? json['Results'] ?? json['results'];
        } else {
          records = null;
        }
        if (records is! List) {
          throw const FormatException('Invalid survey search response');
        }
        return records
        // .where((record) {
        //   if (record is! Map) {
        //     throw const FormatException('Invalid survey answer record');
        //   }
        //   return record['IsAnswered'] == true || record['isAnswered'] == true;
        // })
        .map((record) {
          return SurveyRecipient.fromJson(Map<String, dynamic>.from(record as Map));
        }).toList();
      },
    );
  }

  Future<SurveyResponse> getResponseById(Ref ref, String surveyResponseID) async {
    if (surveyResponseID.trim().isEmpty) {
      throw ArgumentError('SurveyResponseID is required');
    }
    final accessToken = ref.read(authProvider).accessToken;

    return apiClient.getOnly(path: '/survey/admin/responses/${Uri.encodeComponent(surveyResponseID)}', headers: {'Authorization': 'Bearer $accessToken'}, decode: (json) => SurveyResponse.fromJson(Map<String, dynamic>.from(json as Map)));
  }

  Future<List<SurveyQuestionType>> getQuestionTypes(Ref ref) async {
    final accessToken = ref.read(authProvider).accessToken;

    return apiClient.getOnly(path: '/survey/admin/question-types', headers: {'Authorization': 'Bearer $accessToken'}, decode: (json) => SurveyQuestionType.listFromJson(json as List));
  }

  Future<Survey> getSurveyById(Object? ref, String surveyID) async {
    final accessToken = (ref as dynamic).read(authProvider).accessToken;

    return apiClient.getOnly(path: '/survey/admin/templates/${Uri.encodeComponent(surveyID)}', headers: {'Authorization': 'Bearer $accessToken'}, decode: (json) => Survey.fromJson(Map<String, dynamic>.from(json as Map)));
  }

  Future<Survey> getSurveyByRefCode(Object? ref, String refCode) async {
    final db = await _db;
    final rows = await db.query(_surveyTable, where: 'RefCode = ?', whereArgs: [refCode], limit: 1);

    if (rows.isEmpty) throw Exception('Survey not found');
    return _surveyFromRow(rows.first);
  }

  Future<bool> createSurvey(WidgetRef ref, Survey survey) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.post(
      path: "/survey/admin/templates",
      body: survey.toJson(),
      decode: (json) {
        final map = Map<String, dynamic>.from(json as Map);
        final status = map['Status'] ?? map['status'];

        return status?.toString().toLowerCase() == 'success';
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<String> createTicket(WidgetRef ref, {required String surveyTemplateID, required String clientID, String? appointmentID}) async {
    if (surveyTemplateID.trim().isEmpty || clientID.trim().isEmpty) {
      throw ArgumentError('SurveyTemplateID and ClientID are required');
    }
    final accessToken = ref.read(authProvider).accessToken;
    return apiClient.post(
      path: '/survey/admin/tickets',
      body: {'SurveyTemplateID': surveyTemplateID, 'ClientID': clientID, 'AppointmentID': appointmentID},
      headers: {'Authorization': 'Bearer $accessToken'},
      requireSuccessStatus: false,
      decode: (json) {
        final link = (json as Map)['SurveyLink']?.toString().trim() ?? '';
        final uri = Uri.tryParse(link);
        if (uri == null || !uri.hasAuthority || (uri.scheme != 'https' && uri.scheme != 'http')) {
          throw const FormatException('Invalid SurveyLink in ticket response');
        }
        return link;
      },
    );
  }

  Future<bool> updateSurvey(WidgetRef ref, Survey survey) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.put(path: "/survey/admin/templates/${survey.surveyID.toString()}", body: survey.toJson(), headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<bool> deleteSurvey(WidgetRef ref, String surveyID) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.delete(path: "/survey/admin/templates/${surveyID.toString()}", headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<bool> submitSurveyAnswer({required Object? ref, required String refCode, required List<SurveyQuestionAnswer> answers}) async {
    final survey = await getSurveyByRefCode(ref, refCode);
    final db = await _db;
    final now = DateTime.now();
    final submission = SurveySubmission(submissionID: 'submission_${now.microsecondsSinceEpoch}', surveyID: survey.surveyID ?? '', refCode: refCode, submittedAt: now, answers: answers);

    await db.insert(_submissionTable, {'SubmissionID': submission.submissionID, 'SurveyID': submission.surveyID, 'RefCode': submission.refCode, 'AnswersJson': jsonEncode(submission.answers.map((answer) => answer.toJson()).toList()), 'SubmittedAt': submission.submittedAt.toIso8601String()});

    return true;
  }

  String surveyLink(String refCode) => '/survey/answer?ref_code=$refCode';

  Survey _surveyFromRow(Map<String, Object?> row) {
    final rawQuestions = jsonDecode(row['QuestionsJson'].toString());
    final questions = rawQuestions is List ? rawQuestions.map((item) => SurveyQuestion.fromJson(item as Map<String, dynamic>)).toList() : const <SurveyQuestion>[];

    return Survey(
      surveyID: row['SurveyID']?.toString(),
      title: (row['Title'] ?? '').toString(),
      refCode: (row['RefCode'] ?? '').toString(),
      status: (row['Status'] ?? 'Active').toString(),
      questions: questions,
      createdAt: DateTime.tryParse(row['CreatedAt'].toString()),
      updatedAt: DateTime.tryParse(row['UpdatedAt'].toString()),
    );
  }

  Map<String, dynamic> _surveyToRow(Survey survey) {
    final now = DateTime.now();
    return {
      'SurveyID': survey.surveyID,
      'Title': survey.title,
      'RefCode': survey.refCode,
      'Status': survey.status,
      'QuestionsJson': jsonEncode(survey.questions.map((question) => question.toJson()).toList()),
      'CreatedAt': (survey.createdAt ?? now).toIso8601String(),
      'UpdatedAt': (survey.updatedAt ?? now).toIso8601String(),
    };
  }

  String _generateRefCode(DateTime now) {
    return 'SV${now.millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
  }
}
