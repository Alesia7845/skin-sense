import 'package:equatable/equatable.dart';
import 'package:skinsense/features/profile/domain/entities/user_profile.dart';
import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';

/// Satu entri riwayat. Rekomendasi dihitung ulang dari analisis + profil
/// (deterministik), sehingga cukup dua data ini yang disimpan.
class HistoryRecord extends Equatable {
  const HistoryRecord({required this.analysis, required this.profile});

  final SkinAnalysis analysis;
  final UserProfile profile;

  String get id => analysis.id;
  DateTime get createdAt => analysis.createdAt;

  Map<String, dynamic> toJson() => {
        'analysis': analysis.toJson(),
        'profile': profile.toJson(),
      };

  factory HistoryRecord.fromJson(Map<String, dynamic> json) => HistoryRecord(
        analysis: SkinAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
        profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      );

  @override
  List<Object?> get props => [analysis, profile];
}
