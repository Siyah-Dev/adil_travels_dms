import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageService._();

  static const String _bucket = 'driver-documents';

  static SupabaseClient get _client => Supabase.instance.client;

  static bool isAllowedImageExtension(String fileName) {
    final ext = p.extension(fileName).toLowerCase();
    return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
  }

  static String contentTypeFromFileName(String fileName) {
    final ext = p.extension(fileName).toLowerCase();
    if (ext == '.png') return 'image/png';
    return 'image/jpeg';
  }

  static Future<String> uploadDriverDocument({
    required String driverId,
    required String type,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ext = p.extension(fileName).toLowerCase();
    final path = 'drivers/$driverId/$type$ext';

    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentTypeFromFileName(fileName),
          ),
        );

    return path;
  }

  static Future<String> createSignedUrl(String path, {int expiresInSeconds = 3600}) {
    return _client.storage.from(_bucket).createSignedUrl(path, expiresInSeconds);
  }
}
