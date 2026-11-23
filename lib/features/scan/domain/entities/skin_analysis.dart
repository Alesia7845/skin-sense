import 'package:equatable/equatable.dart';
import 'package:skinsense/shared/models/skin_type.dart';

enum AnalysisSource {
  server,
  onDevice;

  String get label => this == AnalysisSource.server
      ? 'Model CNN (server)'
      : 'Estimasi demo di perangkat';
}

class SkinAnalysis extends Equatable {
  const SkinAnalysis({
    required this.id,
    required this.imagePath,
    required this.skinType,
    required this.confidence,
    required this.probabilities,
    required this.createdAt,
    required this.source,
  });

  final String id;
  final String imagePath;
  final SkinType skinType;
  final double confidence;
  final Map<SkinType, double> probabilities;
  final DateTime createdAt;
  final AnalysisSource source;

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_path': imagePath,
        'skin_type': skinType.name,
        'confidence': confidence,
        'probabilities': {
          for (final e in probabilities.entries) e.key.name: e.value,
        },
        'created_at': createdAt.toIso8601String(),
        'source': source.name,
      };

  factory SkinAnalysis.fromJson(Map<String, dynamic> json) {
    final rawProbs = (json['probabilities'] as Map).cast<String, dynamic>();
    return SkinAnalysis(
      id: json['id'] as String,
      imagePath: json['image_path'] as String,
      skinType: SkinType.fromName(json['skin_type'] as String) ?? SkinType.normal,
      confidence: (json['confidence'] as num).toDouble(),
      probabilities: {
        for (final e in rawProbs.entries)
          if (SkinType.fromName(e.key) != null)
            SkinType.fromName(e.key)!: (e.value as num).toDouble(),
      },
      createdAt: DateTime.parse(json['created_at'] as String),
      source: AnalysisSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => AnalysisSource.onDevice,
      ),
    );
  }

  @override
  List<Object?> get props =>
      [id, imagePath, skinType, confidence, probabilities, createdAt, source];
}
