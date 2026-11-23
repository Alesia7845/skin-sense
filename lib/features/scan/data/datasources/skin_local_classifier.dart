import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:skinsense/core/errors/failures.dart';
import 'package:skinsense/shared/models/skin_type.dart';

/// Pengklasifikasi cadangan (mode demo) yang berjalan di perangkat.
///
/// Memakai fitur pengolahan citra sederhana (kecerahan, rasio highlight
/// speküler, dan tekstur gradien) pada area tengah wajah. Ini BUKAN model CNN;
/// hanya agar aplikasi tetap bisa dicoba tanpa backend. Hasil akurat didapat
/// dari backend FastAPI + MobileNetV2.
class SkinLocalClassifier {
  Future<Map<SkinType, double>> classify(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final scores = await compute(estimateSkinScores, bytes);
    return {
      SkinType.normal: scores['normal']!,
      SkinType.oily: scores['oily']!,
      SkinType.dry: scores['dry']!,
    };
  }
}

/// Fungsi top-level agar bisa dijalankan di isolate lewat `compute`.
Map<String, double> estimateSkinScores(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const Failure('Foto tidak dapat dibaca. Coba ambil ulang.');
  }
  final small = img.copyResize(decoded, width: 160);
  final w = small.width;
  final h = small.height;

  final x0 = (w * 0.2).round(), x1 = (w * 0.8).round();
  final y0 = (h * 0.2).round(), y1 = (h * 0.8).round();

  double sumL = 0;
  int count = 0;
  int shiny = 0;
  double gradSum = 0;
  int gradCount = 0;

  for (var y = y0; y < y1; y++) {
    double? prev;
    for (var x = x0; x < x1; x++) {
      final p = small.getPixel(x, y);
      final r = p.r.toDouble() / 255.0;
      final g = p.g.toDouble() / 255.0;
      final b = p.b.toDouble() / 255.0;
      final lum = 0.299 * r + 0.587 * g + 0.114 * b;
      final maxC = math.max(r, math.max(g, b));
      final minC = math.min(r, math.min(g, b));
      final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;

      sumL += lum;
      count++;
      if (lum > 0.85 && sat < 0.30) shiny++;
      if (prev != null) {
        gradSum += (lum - prev).abs();
        gradCount++;
      }
      prev = lum;
    }
  }

  final meanL = count == 0 ? 0.5 : sumL / count;
  final shinyRatio = count == 0 ? 0.0 : shiny / count;
  final texture = gradCount == 0 ? 0.0 : gradSum / gradCount;

  final oilyScore = shinyRatio * 14 + (meanL - 0.5) * 1.5;
  final dryScore = (texture - 0.03) * 25 + (0.55 - meanL) * 1.2;
  const normalScore = 0.35;

  final exps = [normalScore, oilyScore, dryScore].map(math.exp).toList();
  final total = exps.fold<double>(0, (a, b) => a + b);
  return {
    'normal': exps[0] / total,
    'oily': exps[1] / total,
    'dry': exps[2] / total,
  };
}
