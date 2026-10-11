import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/services/client_service.dart';
import 'package:wfs/features/survey/pages/survey_email_client_list_page.dart';
import 'package:wfs/features/survey/services/survey_service.dart';

class _ClientService extends ClientService {
  final List<Client> clients = [
    Client(
      clientID: 'alice',
      firstName: 'Alice',
      lastName: 'Smith',
      phone: '0812345678',
      email: 'alice@example.com',
      addresses: [Address(address: 'Bangkok')],
    ),
    Client(
      clientID: 'bob',
      firstName: 'Bob',
      lastName: 'Jones',
      email: 'bob@example.com',
    ),
    Client(clientID: 'no-email', firstName: 'Alice', lastName: 'No Email'),
  ];
  int fetchCount = 0;

  @override
  Future<List<Client>> fetchTaskClients(Ref ref) async {
    fetchCount++;
    return clients;
  }
}

class _SurveyService extends SurveyService {
  _SurveyService({this.delayTickets = false, this.failingClient});

  final bool delayTickets;
  final String? failingClient;
  final List<String> recipients = [];
  final List<Completer<String>> pendingTickets = [];

  @override
  Future<String> createTicket(
    WidgetRef ref, {
    required String surveyTemplateID,
    required String clientID,
    String? appointmentID,
  }) async {
    expect(surveyTemplateID, 'template');
    expect(appointmentID, 'appointment');
    recipients.add(clientID);
    if (clientID == failingClient) throw Exception('Ticket creation failed');
    if (delayTickets) {
      final ticket = Completer<String>();
      pendingTickets.add(ticket);
      return ticket.future;
    }
    return 'https://example.com/survey/$clientID';
  }
}

void main() {
  Future<void> showPage(
    WidgetTester tester,
    _ClientService clients, {
    _SurveyService? surveys,
    String? email,
    String? clientID,
    String? clientFirstName,
    String? clientLastName,
    ValueChanged<List<Client>>? onSubmitSelected,
    ValueChanged<List<String>>? onSubmitEmails,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientServiceProvider.overrideWithValue(clients),
          if (surveys != null) surveyServiceProvider.overrideWithValue(surveys),
        ],
        child: MaterialApp(
          home: SurveyEmailClientListPage(
            surveyTemplateID: 'template',
            appointmentID: 'appointment',
            email: email,
            clientID: clientID,
            clientFirstName: clientFirstName,
            clientLastName: clientLastName,
            onSubmitSelected: onSubmitSelected,
            onSubmitEmails: onSubmitEmails,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders direct emails without fetching clients', (tester) async {
    final clients = _ClientService();
    final surveys = _SurveyService(delayTickets: true);
    List<String>? submittedEmails;
    await showPage(
      tester,
      clients,
      surveys: surveys,
      email: '  direct@example.com  ',
      clientID: 'direct-client',
      onSubmitEmails: (emails) => submittedEmails = emails,
    );

    expect(find.text('direct@example.com'), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    expect(find.text('Alice Smith'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(clients.fetchCount, 0);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('direct@example.com'), findsNothing);
    expect(find.text('No clients with email found.'), findsOneWidget);
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  DIRECT@EXAMPLE.COM  ');
    await tester.pumpAndSettle();
    expect(find.text('direct@example.com'), findsOneWidget);

    await tester.tap(find.text('direct@example.com'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    await tester.tap(find.byTooltip('Send email'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(surveys.recipients, ['direct-client']);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    surveys.pendingTickets.single.complete(
      'https://example.com/survey/direct-client',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Survey email sent successfully to 1 recipient.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(submittedEmails, ['direct@example.com']);
    expect(clients.fetchCount, 0);
  });

  for (final names in [
    (firstName: 'Alice', lastName: 'Smith', display: 'Alice Smith'),
    (firstName: 'Alice', lastName: null, display: 'Alice'),
    (firstName: null, lastName: 'Smith', display: 'Smith'),
  ]) {
    testWidgets('renders and searches direct client name ${names.display}', (
      tester,
    ) async {
      final clients = _ClientService();
      await showPage(
        tester,
        clients,
        email: 'direct@example.com',
        clientID: 'direct-client',
        clientFirstName: names.firstName,
        clientLastName: names.lastName,
      );

      expect(find.text(names.display), findsOneWidget);
      expect(find.text('direct@example.com'), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
      await tester.enterText(
        find.byType(TextField),
        names.display.toUpperCase(),
      );
      await tester.pumpAndSettle();
      expect(find.text(names.display), findsOneWidget);
      expect(find.text('direct@example.com'), findsOneWidget);
      expect(clients.fetchCount, 0);
    });
  }

  testWidgets('searches only name and email and keeps the query on refresh', (
    tester,
  ) async {
    final clients = _ClientService();
    await showPage(tester, clients);
    expect(find.text('Alice No Email'), findsNothing);

    for (final query in ['  ALICE SMITH  ', 'SMITH', '  ALICE@EXAMPLE.COM  ']) {
      await tester.enterText(find.byType(TextField), query);
      await tester.pumpAndSettle();
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Bob Jones'), findsNothing);
    }

    final refresh = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    await refresh.onRefresh();
    await tester.pumpAndSettle();
    expect(clients.fetchCount, 2);
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsNothing);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '  ALICE@EXAMPLE.COM  ',
    );

    for (final query in ['081234', 'BANGKOK', 'missing']) {
      await tester.enterText(find.byType(TextField), query);
      await tester.pumpAndSettle();
      expect(find.text('Alice Smith'), findsNothing);
      expect(find.text('Bob Jones'), findsNothing);
      expect(find.text('No clients with email found.'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    }

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsOneWidget);
  });

  testWidgets(
    'keeps and submits recipients selected across different searches',
    (tester) async {
      final surveys = _SurveyService(delayTickets: true);
      List<Client>? submitted;
      var emailAppLaunches = 0;
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        _,
      ) async {
        emailAppLaunches++;
        return true;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await showPage(
        tester,
        _ClientService(),
        surveys: surveys,
        onSubmitSelected: (clients) => submitted = clients,
      );

      await tester.enterText(find.byType(TextField), 'Alice');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alice Smith'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bob');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bob Jones'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsNWidgets(2));

      await tester.enterText(find.byType(TextField), 'missing');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Send email'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(surveys.recipients, ['alice']);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<PopScope>(find.byType(PopScope).first).canPop,
        isFalse,
      );
      expect(find.text('SUCCESS'), findsNothing);
      expect(submitted, isNull);

      surveys.pendingTickets[0].complete('https://example.com/survey/alice');
      await tester.pump();
      expect(surveys.recipients, ['alice', 'bob']);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SUCCESS'), findsNothing);

      surveys.pendingTickets[1].complete('https://example.com/survey/bob');
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('SUCCESS'), findsOneWidget);
      expect(
        find.text('Survey email sent successfully to 2 recipients.'),
        findsOneWidget,
      );
      expect(submitted, isNull);
      expect(emailAppLaunches, 0);
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      expect(surveys.recipients, ['alice', 'bob']);
      expect(submitted?.map((client) => client.clientID).toList(), [
        'alice',
        'bob',
      ]);
    },
  );

  testWidgets('shows a singular recipient count after sending to one client', (
    tester,
  ) async {
    final surveys = _SurveyService();
    await showPage(tester, _ClientService(), surveys: surveys);
    await tester.tap(find.text('Alice Smith'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Send email'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(surveys.recipients, ['alice']);
    expect(
      find.text('Survey email sent successfully to 1 recipient.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'stops on API failure and clears loading without showing success',
    (tester) async {
      final surveys = _SurveyService(failingClient: 'alice');
      List<Client>? submitted;
      await showPage(
        tester,
        _ClientService(),
        surveys: surveys,
        onSubmitSelected: (clients) => submitted = clients,
      );
      await tester.tap(find.text('Alice Smith'));
      await tester.tap(find.text('Bob Jones'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Send email'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(surveys.recipients, ['alice']);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('SUCCESS'), findsNothing);
      expect(
        find.textContaining('Unable to send survey emails:'),
        findsOneWidget,
      );
      expect(
        tester.widget<PopScope>(find.byType(PopScope).first).canPop,
        isTrue,
      );
      expect(
        tester.widget<IconButton>(find.byType(IconButton).last).onPressed,
        isNotNull,
      );
      expect(submitted, isNull);
    },
  );
}
