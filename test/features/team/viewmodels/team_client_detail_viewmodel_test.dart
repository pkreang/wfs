import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/client/models/client.dart';

Map<String, dynamic> _clientJson(String id) => {
  'ClientID': id,
  'FirstName': id,
  'ClientLevel': {'ClientLevelID': 'level', 'ClientLevelName': 'Gold'},
  'ClientStatus': {'ClientStatusID': 'status', 'ClientStatusName': 'Active'},
};

Future<AsyncValue<List<Client>>> _loadClients(List<String> ids) async {
  final container = ProviderContainer();
  final completed = Completer<AsyncValue<List<Client>>>();
  final subscription = container.listen(teamClientDetailProvider(ids), (
    previous,
    next,
  ) {
    if (!next.isLoading && !completed.isCompleted) {
      completed.complete(next);
    }
  }, fireImmediately: true);
  try {
    return await completed.future;
  } finally {
    subscription.close();
    container.dispose();
  }
}

void main() {
  test('skips null clients and continues loading subsequent clients', () async {
    final requested = <String>[];
    final result = await http.runWithClient(
      () => _loadClients(['first', 'missing', 'last']),
      () => MockClient((request) async {
        final id = request.url.pathSegments[2];
        requested.add(id);
        return http.Response(
          jsonEncode({
            'status': 'success',
            'client': id == 'missing' ? null : _clientJson(id),
          }),
          200,
        );
      }),
    );

    expect(result.hasError, isFalse);
    expect(result.requireValue.map((client) => client.clientID), [
      'first',
      'last',
    ]);
    expect(requested, ['first', 'missing', 'last']);
  });

  test('returns an empty list when all client responses are null', () async {
    final result = await http.runWithClient(
      () => _loadClients(['missing-first', 'missing-last']),
      () => MockClient(
        (_) async => http.Response(
          jsonEncode({'status': 'success', 'client': null}),
          200,
        ),
      ),
    );

    expect(result.hasError, isFalse);
    expect(result.requireValue, isEmpty);
  });

  test('still reports HTTP failures after a null client response', () async {
    final result = await http.runWithClient(
      () => _loadClients(['missing', 'failed']),
      () => MockClient((request) async {
        if (request.url.pathSegments[2] == 'missing') {
          return http.Response(
            jsonEncode({'status': 'success', 'client': null}),
            200,
          );
        }
        return http.Response('Server error', 500);
      }),
    );

    expect(result.hasError, isTrue);
    expect(result.error, isA<ApiException>());
    expect((result.error as ApiException).httpStatus, 500);
  });
}
