import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data,
      {String? token}) async {
    final client = http.Client();
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Connection': 'close',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode >= 400) {
        String fallback = 'Request failed (${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          if (body is Map) {
            if (body['message'] != null) throw Exception(body['message'].toString());
            if (body['detail'] != null) throw Exception(body['detail'].toString());
          }
        } catch (_) {
          // not JSON, use raw (strip HTML if present)
          final raw = response.body;
          final stripped = raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          throw Exception(stripped.isNotEmpty ? stripped : fallback);
        }
        throw Exception(fallback);
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> upload(String path, File file,
      {String? token}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    request.headers['Accept'] = 'application/json';
    request.headers['Connection'] = 'close';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 400) {
      String fallback = 'Request failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map) {
          if (body['message'] != null) throw Exception(body['message'].toString());
          if (body['detail'] != null) throw Exception(body['detail'].toString());
        }
      } catch (_) {
        final raw = response.body;
        final stripped = raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        throw Exception(stripped.isNotEmpty ? stripped : fallback);
      }
      throw Exception(fallback);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}



