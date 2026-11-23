import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/history/presentation/cubit/history_cubit.dart';
import 'package:skinsense/features/recommendation/presentation/pages/recommendation_page.dart';
import 'package:skinsense/shared/widgets/disclaimer_banner.dart';
import 'package:skinsense/shared/widgets/section_card.dart';
import 'package:skinsense/shared/widgets/skin_type_style.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onScanTap});

  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            const Text('SkinSense',
                style: TextStyle(
                    fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            const SizedBox(height: 4),
            const Text('Kenali kulit, pilih perawatan yang pas.'),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.center_focus_strong_outlined,
                      color: Colors.white, size: 34),
                  const SizedBox(height: 14),
                  const Text('Analisis kulit wajah',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Ambil foto, dapatkan tipe kulit, rutinitas, dan peringkat produk.',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.4)),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.coral,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onScanTap,
                    child: const Text('Mulai scan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Scan terakhir',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.ink)),
            const SizedBox(height: 10),
            BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state.records.isEmpty) {
                  return const SectionCard(
                    child: Text('Belum ada scan. Mulai dari tombol di atas.'),
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
                        Icon(type.icon, color: type.color, size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kulit ${type.label.toLowerCase()}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: type.color)),
                              Text(Formatters.dateTime(r.createdAt),
                                  style: const TextStyle(fontSize: 12.5)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }
}
