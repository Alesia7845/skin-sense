import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skinsense/features/auth/presentation/widgets/auth_modal_sheet.dart';
import 'package:skinsense/features/history/domain/entities/history_record.dart';
import 'package:skinsense/features/history/presentation/cubit/history_cubit.dart';
import 'package:skinsense/features/recommendation/presentation/pages/recommendation_page.dart';
import 'package:skinsense/shared/models/skin_type.dart';
import 'package:skinsense/shared/widgets/skin_type_style.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.onScanTap});

  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
      backgroundColor: AppTheme.pearl,
      appBar: AppBar(title: const Text('Riwayat Scan')),
      body: !authState.isLoggedIn
          ? _GuestLockView(
              onScanTap: onScanTap,
              onLoginTap: () => showAuthRequiredSheet(
                context,
                subtitle:
                    'Daftar atau masuk sekali saja di awal untuk menyimpan dan memantau seluruh riwayat scan wajahmu.',
              ),
            )
          : BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.coral),
                  );
                }

                final records = state.records;
                final oilyCount = records
                    .where((r) => r.analysis.skinType == SkinType.oily)
                    .length;
                final normalCount = records
                    .where((r) => r.analysis.skinType == SkinType.normal)
                    .length;
                final dryCount = records
                    .where((r) => r.analysis.skinType == SkinType.dry)
                    .length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  children: [
                    // Navy Summary Card
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.navy, AppTheme.navyMid],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ringkasan Analisis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  '${records.length} Total Scan',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _summaryMetric('Berminyak', '$oilyCount'),
                              const SizedBox(width: 10),
                              _summaryMetric('Normal', '$normalCount'),
                              const SizedBox(width: 10),
                              _summaryMetric('Kering', '$dryCount'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (records.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history_rounded,
                                size: 56, color: AppTheme.navy),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum Ada Riwayat',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.navy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Scan wajah pertama Anda untuk menyimpan progres dan rekomendasi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.slate,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: onScanTap,
                              child: const Text('Mulai Scan'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      for (var i = 0; i < records.length; i++)
                        _HistoryItemCard(
                          record: records[i],
                          isLatest: i == 0,
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RecommendationPage(
                              analysis: records[i].analysis,
                              profile: records[i].profile,
                              saveToHistory: false,
                            ),
                          )),
                          onDelete: () =>
                              _confirmDelete(context, records[i].id),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.mist,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_graph_rounded,
                                size: 18, color: AppTheme.navy),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tips: Lakukan scan berkala setiap 2 minggu untuk memantau perubahan kondisi kulitmu.',
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
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _summaryMetric(String label, String count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<HistoryCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Riwayat?',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy),
        ),
        content: const Text(
          'Hasil scan dan rekomendasinya akan dihapus dari perangkat.',
          style: TextStyle(color: AppTheme.slate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Batal', style: TextStyle(color: AppTheme.slate)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(
                    color: AppTheme.coral, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.remove(id);
  }
}

class _GuestLockView extends StatelessWidget {
  const _GuestLockView({
    required this.onScanTap,
    required this.onLoginTap,
  });

  final VoidCallback onScanTap;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: AppTheme.coralSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 38,
                  color: AppTheme.coral,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Masuk untuk Menyimpan Riwayat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kamu tetap bisa scan wajah dan melihat rekomendasi tanpa login. Daftar atau masuk cukup 1x saja di awal agar hasil scan tersimpan otomatis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppTheme.slate,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onLoginTap,
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text('Daftar / Masuk Sekarang'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onScanTap,
                  child: const Text('Langsung Scan Wajah Dulu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({
    required this.record,
    required this.isLatest,
    required this.onTap,
    required this.onDelete,
  });

  final HistoryRecord record;
  final bool isLatest;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final type = record.analysis.skinType;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.file(
                    File(record.analysis.imagePath),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy,
                          ),
                        ),
                        if (isLatest) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.coralSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Terbaru',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.coral,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Keyakinan ${Formatters.percent(record.analysis.confidence)} • Sensitivitas ${record.profile.sensitivity}/5',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.navy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.dateTime(record.createdAt),
                      style:
                          const TextStyle(fontSize: 11.5, color: AppTheme.slate),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.slate, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
