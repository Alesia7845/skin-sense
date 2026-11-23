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
import 'package:skinsense/shared/widgets/skin_type_style.dart';

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
      appBar: AppBar(title: const Text('Hasil klasifikasi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            SectionCard(
              color: type.color.withOpacity(0.10),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: Image.file(
                        File(analysis.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: AppTheme.mist),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tipe kulit Anda'),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(type.icon, color: type.color),
                            const SizedBox(width: 6),
                            Text(type.label,
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: type.color)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Keyakinan ${Formatters.percent(analysis.confidence)}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Probabilitas tiap kelas',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                  const SizedBox(height: 6),
                  for (final t in sorted)
                    ProbabilityBar(type: t, value: analysis.probabilities[t] ?? 0),
                ],
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tentang kulit ${type.label.toLowerCase()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppTheme.ink)),
                  const SizedBox(height: 8),
                  Text(type.description, style: const TextStyle(height: 1.45)),
                  const SizedBox(height: 10),
                  Text('Sumber analisis: ${analysis.source.label}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            if (analysis.source == AnalysisSource.onDevice)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Server belum diatur, sehingga hasil memakai estimasi demo. '
                  'Atur alamat server di tab Profil untuk memakai model CNN.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.coral),
                ),
              ),
            const DisclaimerBanner(),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileInputPage(analysis: analysis))),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Lanjut isi profil'),
            ),
          ],
        ),
      ),
    );
  }
}
