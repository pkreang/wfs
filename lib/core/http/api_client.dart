import 'dart:convert';
import 'package:http/http.dart' as http;

typedef Decoder<T> = T Function(Object json);

class ApiClient {
  ApiClient(this._baseUrl);

  final String _baseUrl;

  Future<T> get<T>({required String path, required Decoder<T> decode, Map<String, String>? query, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);

    final res = await http.get(uri, headers: {'Content-Type': 'application/json', if (headers != null) ...headers});

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    if (res.body.isEmpty) throw Exception('Empty response body');

    final raw = jsonDecode(res.body);
    if (raw is Map && raw['status']?.toString().toLowerCase() != 'success') {
      throw Exception("API returned status != success: ${raw['status']}");
    }

    try {
      return decode(raw);
    } catch (e) {
      throw Exception('Decode error for $T: $e');
    }
  }

  Future<T> post<T>({required String path, required Map<String, dynamic> body, required Decoder<T> decode, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');

    final res = await http.post(uri, headers: {'Content-Type': 'application/json', if (headers != null) ...headers}, body: jsonEncode(body));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    if (res.body.isEmpty) {
      throw Exception('Empty response body');
    }

    final raw = jsonDecode(res.body);
    if (raw is Map && raw['status']?.toString().toLowerCase() != 'success') {
      throw Exception("API returned status != success: ${raw['status']}");
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

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    if (res.body.isEmpty) {
      throw Exception('Empty response body');
    }

    print('res: ${res.body}');

    final raw = jsonDecode(res.body);
    if (raw is Map && raw['status']?.toString().toLowerCase() != 'success') {
      throw Exception("API returned status != success: ${raw['status']}");
    }

    return true;
  }

  Future<bool> delete({required String path, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');

    final res = await http.delete(uri, headers: {'Content-Type': 'application/json', if (headers != null) ...headers});

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    if (res.body.isEmpty) {
      throw Exception('Empty response body');
    }

    print('res: ${res.body}');

    final raw = jsonDecode(res.body);
    if (raw is Map && raw['status']?.toString().toLowerCase() != 'success') {
      throw Exception("API returned status != success: ${raw['status']}");
    }

    return true;
  }
}
