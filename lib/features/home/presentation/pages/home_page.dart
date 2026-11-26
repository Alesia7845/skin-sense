import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/history/presentation/cubit/history_cubit.dart';
import 'package:skinsense/features/recommendation/presentation/pages/recommendation_page.dart';
import 'package:skinsense/shared/models/skin_type.dart';
import 'package:skinsense/shared/widgets/disclaimer_banner.dart';
import 'package:skinsense/shared/widgets/section_card.dart';
import 'package:skinsense/shared/widgets/skin_type_style.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onScanTap,
    this.onHistoryTap,
    this.onProfileTap,
  });

  final VoidCallback onScanTap;
  final VoidCallback? onHistoryTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pearl,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.mist,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SkinSense AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Halo! Yuk kenali kulitmu',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navy,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        color: AppTheme.navy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero Navy Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.navy, AppTheme.navyMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navy.withOpacity(0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: AppTheme.coral, size: 13),
                            SizedBox(width: 5),
                            Text(
                              'CNN + Fuzzy-SAW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.center_focus_strong_outlined,
                          color: Colors.white70, size: 22),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Analisis Kondisi Wajah Secara Akurat & Personal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ambil foto wajah untuk mendeteksi tipe kulit serta mendapatkan rutinitas & rekomendasi produk.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onScanTap,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text('Mulai Scan Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3 Quick Stat Chips
            Row(
              children: [
                _statBox('3 Tipe', 'Klasifikasi'),
                const SizedBox(width: 10),
                _statBox('Fuzzy-SAW', 'Metode'),
                const SizedBox(width: 10),
                _statBox('Gratis', 'Tanpa Biaya'),
              ],
            ),
            const SizedBox(height: 20),

            // Tips Sebelum Scan
            const Text(
              'Tips Sebelum Scan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                children: [
                  _tipRow(
                    Icons.wb_sunny_outlined,
                    'Cahaya Cukup',
                    'Gunakan pencahayaan alami menghadap sumber cahaya.',
                  ),
                  const Divider(height: 16, color: AppTheme.border),
                  _tipRow(
                    Icons.face_retouching_off_outlined,
                    'Tanpa Makeup',
                    'Bersihkan wajah dan hindari penggunaan filter kamera.',
                  ),
                  const Divider(height: 16, color: AppTheme.border),
                  _tipRow(
                    Icons.center_focus_weak_rounded,
                    'Wajah Jelas',
                    'Posisikan satu wajah menghadap lurus jarak ±30 cm.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Mengenal Tipe Kulit
            const Text(
              'Mengenal Tipe Kulit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < SkinType.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _skinTypeCard(SkinType.values[i]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Scan Terakhir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                if (onHistoryTap != null)
                  GestureDetector(
                    onTap: onHistoryTap,
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.coral,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state.records.isEmpty) {
                  return SectionCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.ice,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.history_toggle_off_rounded,
                              color: AppTheme.slate),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Belum ada riwayat scan. Tekan "Mulai Scan Sekarang" di atas untuk memulai.',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.slate,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final r = state.records.first;
                final type = r.analysis.skinType;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RecommendationPage(
                      analysis: r.analysis,
                      profile: r.profile,
                      saveToHistory: false,
                    ),
                  )),
                  child: SectionCard(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: Image.file(
                              File(r.analysis.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: type.softColor,
                                child: Icon(type.icon, color: type.color),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Kulit ${type.label}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppTheme.navy,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: type.softColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      Formatters.percent(r.analysis.confidence),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: type.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                Formatters.dateTime(r.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.slate),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.slate),
                      ],
                    ),
                  ),
                );
              },
            ),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.slate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.ice,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: AppTheme.navy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 11.5, color: AppTheme.slate),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skinTypeCard(SkinType type) {
    final hint = switch (type) {
      SkinType.normal => 'Seimbang & lembap',
      SkinType.oily => 'Sebum berlebih',
      SkinType.dry => 'Butuh hidrasi ekstra',
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: type.softColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(type.icon, size: 18, color: type.color),
          ),
          const SizedBox(height: 10),
          Text(
            type.label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.slate,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
