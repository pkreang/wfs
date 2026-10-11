import 'dart:convert';
import 'package:http/http.dart' as http;

typedef Decoder<T> = T Function(Object json);

class ApiClient {
  ApiClient(this._baseUrl);

  final String _baseUrl;

  static ApiException _error({required String message, int? httpStatus, String? status, Object? body}) => ApiException(message: message, httpStatus: httpStatus, status: status, body: body);

  String? _responseStatus(Object raw) {
    if (raw is! Map) return null;
    return (raw['status'] ?? raw['Status'])?.toString();
  }

  String _extractErrorMessage(Object raw) {
    if (raw is Map) {
      final m = raw;
      final msg = m['error'] ?? m['message'] ?? m['msg'] ?? m['reason'] ?? m['detail'];
      if (msg != null) return msg.toString();
      if (m['errors'] != null) return m['errors'].toString();
    }
    return 'Request failed';
  }

  Future<T> get<T>({required String path, required Decoder<T> decode, Map<String, String>? query, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);

    final res = await http.get(uri, headers: {'Content-Type': 'application/json', if (headers != null) ...headers});

    print('uri: $uri');
    print('res: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw _error(message: 'HTTP ${res.statusCode}', httpStatus: res.statusCode, body: res.body);
    }

    print('res body: ${res.body}');

    if (res.body.isEmpty) throw Exception('Empty response body');

    final raw = jsonDecode(res.body);
    final status = _responseStatus(raw);
    if (raw is Map && status?.toLowerCase() != 'success') {
      final msg = _extractErrorMessage(raw);
      throw _error(message: msg, status: status, body: raw);
    }

    try {
      return decode(raw);
    } catch (e) {
      throw Exception('Decode error for $T: $e');
    }
  }

  Future<T> getOnly<T>({required String path, required Decoder<T> decode, Map<String, String>? query, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);

    final res = await http.get(uri, headers: {'Content-Type': 'application/json', if (headers != null) ...headers});

    print('uri: $uri');
    print('res: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw _error(message: 'HTTP ${res.statusCode}', httpStatus: res.statusCode, body: res.body);
    }

    print('res body: ${res.body}');

    if (res.body.isEmpty) throw Exception('Empty response body');

    final raw = jsonDecode(res.body);
    try {
      return decode(raw);
    } catch (e) {
      throw Exception('Decode error for $T: $e');
    }
  }

  Future<T> post<T>({required String path, required Map<String, dynamic> body, required Decoder<T> decode, Map<String, String>? headers, bool requireSuccessStatus = true}) async {
    final uri = Uri.parse('$_baseUrl$path');

    final res = await http.post(uri, headers: {'Content-Type': 'application/json', if (headers != null) ...headers}, body: jsonEncode(body));

    print('uri: $uri');
    print('code: ${res.statusCode}');
    print('body: ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      var message = 'HTTP ${res.statusCode}';

      if (res.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(res.body);
          final extractedMessage = _extractErrorMessage(errorBody);
          if (extractedMessage != 'Request failed') {
            message = extractedMessage;
          }
        } on FormatException {
          // Keep the existing HTTP status message for non-JSON responses.
        }
      }

      throw _error(message: message, httpStatus: res.statusCode, body: res.body);
    }

    if (res.body.isEmpty) {
      throw Exception('Empty response body');
    }

    final raw = jsonDecode(res.body);
    final status = _responseStatus(raw);
    if (raw is Map && (requireSuccessStatus || status != null) && status?.toLowerCase() != 'success') {
      final msg = _extractErrorMessage(raw);
      throw _error(message: msg, status: status, body: raw);
    }

    try {
      return decode(raw);
    } catch (e) {
      throw Exception('Decode error for $T: $e');
    }
  }

  Future<bool> put({required String path, required Map<String, dynamic> body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');

    print('data json: ${jsonEncode(body)}');

    final res = await http.put(uri, headers: {'Content-Type': 'application/json', if (headers != null) ...headers}, body: jsonEncode(body));

    print('statusCode: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw _error(message: 'HTTP ${res.statusCode}', httpStatus: res.statusCode, body: res.body);
    }

    if (res.body.isEmpty) {
      throw Exception('Empty response body');
    }

    print('res: ${res.body}');

    // final raw = jsonDecode(res.body);
    // if (raw is Map && raw['status']?.toString().toLowerCase() != 'success') {
    //   final msg = _extractErrorMessage(raw);
    //   throw _error(message: msg, status: raw['status']?.toString(), body: raw);
    // }

    return true;
  }

  Future<bool> delete({required String path, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');

    final res = await http.delete(uri, headers: {'Content-Type': 'application/json', if (headers != null) ...headers});

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _error(message: 'HTTP ${res.statusCode}', httpStatus: res.statusCode, body: res.body);
    }

    if (res.body.isEmpty) {
      return true;
    }

    final raw = jsonDecode(res.body);
    final status = _responseStatus(raw);
    if (raw is Map && status != null && status.toLowerCase() != 'success') {
      final msg = _extractErrorMessage(raw);
      throw _error(message: msg, status: status, body: raw);
    }

    return true;
  }
}

class ApiException implements Exception {
  final int? httpStatus;
  final String? status;
  final String message;
  final Object? body;
  ApiException({required this.message, this.httpStatus, this.status, this.body});
  @override
  String toString() => 'ApiException(${httpStatus ?? ''}, ${status ?? ''}): $message';
}
