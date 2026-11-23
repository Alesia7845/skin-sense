import 'package:skinsense/features/profile/domain/entities/user_profile.dart';
import 'package:skinsense/features/recommendation/domain/entities/need_profile.dart';
import 'package:skinsense/features/recommendation/domain/entities/recommendation.dart';

/// Menerjemahkan profil kebutuhan menjadi rutinitas dan saran bahan aktif.
class RoutineBuilder {
  const RoutineBuilder();

  List<RoutineStep> morning(NeedProfile n) => [
        RoutineStep(
          'Cleanser',
          n.oilControl >= 65
              ? 'Gel atau foam cleanser lembut untuk mengangkat minyak berlebih.'
              : 'Cleanser lembut non-foaming atau berbasis krim agar kelembapan terjaga.',
        ),
        RoutineStep(
          'Serum',
          n.hydration >= n.oilControl && n.hydration >= 60
              ? 'Serum hidrasi dengan hyaluronic acid atau panthenol.'
              : (n.oilControl >= 60
                  ? 'Serum niacinamide untuk membantu mengatur minyak dan pori.'
                  : 'Serum antioksidan ringan seperti vitamin C atau E.'),
        ),
        RoutineStep(
          'Moisturizer',
          n.oilControl >= 65
              ? 'Gel moisturizer bebas minyak (oil-free) bertekstur ringan.'
              : (n.hydration >= 65
                  ? 'Krim dengan ceramide untuk mengunci kelembapan.'
                  : 'Lotion ringan yang menyeimbangkan kelembapan.'),
        ),
        const RoutineStep(
          'Sunscreen',
          'Gunakan SPF 30+ setiap pagi dan aplikasikan ulang tiap 2-3 jam bila di luar ruangan.',
        ),
      ];

  List<RoutineStep> night(NeedProfile n) => [
        const RoutineStep(
          'Cleanser',
          'Bersihkan wajah dari sunscreen dan kotoran. Lakukan double cleansing bila perlu.',
        ),
        RoutineStep(
          'Serum perawatan',
          n.gentleness >= 70
              ? 'Pilih serum menenangkan (centella, panthenol). Tunda bahan aktif kuat.'
              : (n.oilControl >= 65
                  ? 'Asam salisilat (BHA) 2-3 kali seminggu, selang-seling dengan serum hidrasi.'
                  : 'Serum hidrasi atau perbaikan skin barrier.'),
        ),
        RoutineStep(
          'Moisturizer',
          n.hydration >= 65
              ? 'Krim yang lebih kaya untuk memperbaiki skin barrier semalaman.'
              : 'Moisturizer ringan sampai sedang sesuai kenyamanan kulit.',
        ),
      ];

  List<String> recommendedIngredients(NeedProfile n, UserProfile profile) {
    final result = <String>[];
    if (n.oilControl >= 60) {
      result.addAll(['Niacinamide', 'Salicylic acid (BHA)', 'Zinc PCA']);
    }
    if (n.hydration >= 60) {
      result.addAll(['Hyaluronic acid', 'Ceramide', 'Glycerin', 'Panthenol']);
    }
    if (n.gentleness >= 65) {
      result.addAll(['Centella asiatica', 'Allantoin']);
    }
    if (result.isEmpty) {
      result.addAll(['Glycerin', 'Niacinamide', 'Vitamin C atau E']);
    }

    final avoidedKeywords = [
      for (final label in profile.avoidedIngredients)
        ...UserProfile.keywordsFor(label),
    ];
    return result
        .toSet()
        .where((i) => !avoidedKeywords.any((k) => i.toLowerCase().contains(k)))
        .toList();
  }

  List<String> avoidedIngredients(NeedProfile n, UserProfile profile) {
    final result = <String>[...profile.avoidedIngredients];
    if (n.oilControl >= 60) result.add('Minyak berat atau oklusif berlebih');
    if (n.hydration >= 60) result.addAll(['Alcohol denat.', 'Scrub kasar']);
    if (n.gentleness >= 65) {
      result.addAll(['Pewangi', 'Retinol atau asam kuat berkonsentrasi tinggi']);
    }
    return result.toSet().toList();
  }
}
