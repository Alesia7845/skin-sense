import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/history/presentation/cubit/history_cubit.dart';
import 'package:skinsense/features/recommendation/presentation/pages/recommendation_page.dart';
import 'package:skinsense/shared/widgets/skin_type_style.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.onScanTap});

  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat scan')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.records.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history, size: 64, color: AppTheme.teal),
                    const SizedBox(height: 12),
                    const Text('Belum ada riwayat',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Scan wajah pertama Anda untuk melihat hasilnya di sini.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton(onPressed: onScanTap, child: const Text('Mulai scan')),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: state.records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final record = state.records[i];
              final type = record.analysis.skinType;
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RecommendationPage(
                      analysis: record.analysis,
                      profile: record.profile,
                      saveToHistory: false,
                    ),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.file(
                              File(record.analysis.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: AppTheme.mist,
                                child: Icon(type.icon, color: type.color),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kulit ${type.label.toLowerCase()}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: type.color)),
                              const SizedBox(height: 2),
                              Text(
                                  'Keyakinan ${Formatters.percent(record.analysis.confidence)}'
                                  ' | sensitivitas ${record.profile.sensitivity}/5',
                                  style: const TextStyle(fontSize: 12.5)),
                              Text(Formatters.dateTime(record.createdAt),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(context, record.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<HistoryCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus riwayat?'),
        content: const Text('Hasil scan dan rekomendasinya akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) await cubit.remove(id);
  }
}
