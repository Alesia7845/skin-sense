import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/history/presentation/cubit/history_cubit.dart';
import 'package:skinsense/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skinsense/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:skinsense/shared/widgets/disclaimer_banner.dart';
import 'package:skinsense/shared/widgets/section_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: context.read<SettingsCubit>().state);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    await context.read<SettingsCubit>().saveServerUrl(_urlController.text);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(_urlController.text.trim().isEmpty
          ? 'Mode demo di perangkat aktif.'
          : 'Alamat server disimpan.'),
    ));
  }

  Future<void> _clearHistory() async {
    final cubit = context.read<HistoryCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text('Semua hasil scan dan rekomendasi akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) await cubit.clear();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileCubit>().state;
    final serverUrl = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & pengaturan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profil terakhir',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                  const SizedBox(height: 10),
                  _row('Sensitivitas', '${profile.sensitivity}/5'),
                  _row('Anggaran maks.', Formatters.rupiah(profile.maxBudget)),
                  _row(
                    'Dihindari',
                    profile.avoidedIngredients.isEmpty
                        ? '-'
                        : profile.avoidedIngredients.join(', '),
                  ),
                  const SizedBox(height: 6),
                  const Text('Profil diperbarui setiap kali Anda menyelesaikan scan.',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Server klasifikasi (FastAPI)',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                  const SizedBox(height: 4),
                  Text(
                    serverUrl.isEmpty
                        ? 'Mode demo: analisis dilakukan di perangkat dengan estimasi sederhana.'
                        : 'Foto dikirim ke server untuk diklasifikasi oleh model CNN.',
                    style: const TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'http://10.0.2.2:8000',
                      labelText: 'Alamat server',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Emulator Android memakai 10.0.2.2 untuk menjangkau localhost komputer. '
                    'Kosongkan untuk kembali ke mode demo.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _saveUrl, child: const Text('Simpan')),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Hapus semua riwayat'),
            ),
            const SizedBox(height: 16),
            const DisclaimerBanner(),
            const SizedBox(height: 16),
            const Center(
              child: Text('SkinSense v1.0.0 | D4 Rekayasa Perangkat Lunak',
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(k, style: const TextStyle(color: Colors.black54))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
