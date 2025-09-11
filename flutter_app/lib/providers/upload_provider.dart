import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_client.dart';

class UploadProvider extends ChangeNotifier {
  Future<String?> uploadImage(String token) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return 'No image selected';
      final api = ApiClient();
      final res = await api.upload('/api/media/upload/image/', File(picked.path), token: token);
      return res['success'] == true ? null : (res['message']?.toString() ?? 'Upload failed');
    } catch (e) {
      return _extractMessage(e) ?? 'Upload failed';
    }
  }

  Future<String?> uploadAudio(String token) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result == null || result.files.single.path == null) return 'No audio selected';
      final file = File(result.files.single.path!);
      final api = ApiClient();
      final res = await api.upload('/api/media/upload/audio/', file, token: token);
      return res['success'] == true ? null : (res['message']?.toString() ?? 'Upload failed');
    } catch (e) {
      return _extractMessage(e) ?? 'Upload failed';
    }
  }

  String? _extractMessage(Object e) {
    final s = e.toString();
    try {
      final map = jsonDecode(s);
      if (map is Map && map['message'] is String) return map['message'] as String;
      if (map is Map && map['detail'] is String) return map['detail'] as String;
    } catch (_) {
      final start = s.indexOf('{');
      final end = s.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final jsonPart = s.substring(start, end + 1);
        try {
          final map = jsonDecode(jsonPart);
          if (map is Map && map['message'] is String) return map['message'] as String;
          if (map is Map && map['detail'] is String) return map['detail'] as String;
        } catch (_) {}
      }
    }
    return null;
  }
}


