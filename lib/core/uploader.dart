import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Change these to your backend endpoints
const String kBaseUrl = "https://example.com/api"; // <-- TODO: set your server

class Uploader {
  /// Upload from a [File] path (mobile) or raw [bytes] (web/mobile in-memory)
  static Future<http.StreamedResponse> uploadMedia({
    required String endpoint, // e.g. /upload/audio or /upload/video
    String? filePath,
    Uint8List? bytes,
    required String filename,
    required String fieldName, // e.g. 'file'
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('$kBaseUrl$endpoint');
    final req = http.MultipartRequest('POST', uri);
    if (fields != null) req.fields.addAll(fields);

    if (!kIsWeb && filePath != null) {
      req.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    } else if (bytes != null) {
      req.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: filename));
    } else {
      throw ArgumentError('Either filePath or bytes must be provided');
    }

    return req.send();
  }
}
