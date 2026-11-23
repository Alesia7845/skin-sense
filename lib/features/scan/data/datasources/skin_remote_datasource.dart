import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:skinsense/core/constants/app_constants.dart';
import 'package:skinsense/core/errors/failures.dart';
import 'package:skinsense/shared/models/skin_type.dart';

/// Klien REST ke backend FastAPI.
///
/// Kontrak: POST {baseUrl}/api/v1/classify (multipart, field `file`)
/// Respons: {"probabilities": {"normal": 0.1, "oily": 0.8, "dry": 0.1}}
class SkinRemoteDataSource {
  Future<Map<SkinType, double>> classify({
    required String baseUrl,
    required String imagePath,
  }) async {
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanBase${AppConstants.classifyPath}');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final streamed = await request.send().timeout(AppConstants.requestTimeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Failure('Server menolak permintaan (kode ${response.statusCode}).');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = (json['probabilities'] as Map?)?.cast<String, dynamic>();
    if (raw == null) {
      throw const Failure('Format respons server tidak dikenali.');
    }

    final result = <SkinType, double>{};
    for (final entry in raw.entries) {
      final type = SkinType.fromName(entry.key);
      if (type != null) result[type] = (entry.value as num).toDouble();
    }
    if (result.isEmpty) throw const Failure('Respons server tidak berisi probabilitas.');
    return result;
  }
}
