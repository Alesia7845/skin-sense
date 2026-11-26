import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/profile/presentation/pages/profile_input_page.dart';
import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';
import 'package:skinsense/features/scan/presentation/widgets/probability_bar.dart';
import 'package:skinsense/shared/models/skin_type.dart';
import 'package:skinsense/shared/widgets/disclaimer_banner.dart';
import 'package:skinsense/shared/widgets/section_card.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.analysis});

  final SkinAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final type = analysis.skinType;
    final sorted = SkinType.values.toList()
      ..sort((a, b) => (analysis.probabilities[b] ?? 0)
          .compareTo(analysis.probabilities[a] ?? 0));

    return Scaffold(
      backgroundColor: AppTheme.pearl,
      appBar: AppBar(title: const Text('Hasil Klasifikasi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            // Dark Navy Hero Result Card
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.navy, AppTheme.navyMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navy.withOpacity(0.20),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.coral, width: 2.2),
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: Image.file(
                          File(analysis.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: AppTheme.navyMid,
                            child: Icon(Icons.face_rounded,
                                color: Colors.white70, size: 36),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipe Kulit Terdeteksi',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Kulit ${type.label}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.coral,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Keyakinan ${Formatters.percent(analysis.confidence)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Probabilitas Tiap Kelas
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 19, color: AppTheme.navy),
                      SizedBox(width: 8),
                      Text(
                        'Probabilitas Tiap Kelas',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final t in sorted)
                    ProbabilityBar(
                      type: t,
                      value: analysis.probabilities[t] ?? 0,
                      isPrimary: t == type,
                    ),
                ],
              ),
            ),

            // Apa artinya?
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          size: 19, color: AppTheme.coral),
                      const SizedBox(width: 8),
                      Text(
                        'Apa artinya kulit ${type.label.toLowerCase()}?',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.slate,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.ice,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.memory_rounded,
                            size: 14, color: AppTheme.navy),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Sumber: ${analysis.source.label}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (analysis.source == AnalysisSource.onDevice)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.coralSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppTheme.coral),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Server belum diatur, sehingga hasil memakai estimasi demo. Atur alamat server di tab Profil untuk model CNN.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.navy,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const DisclaimerBanner(),
            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileInputPage(analysis: analysis))),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Lanjut Isi Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
