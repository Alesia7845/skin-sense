import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skinsense/features/auth/presentation/widgets/auth_modal_sheet.dart';
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
    _urlController =
        TextEditingController(text: context.read<SettingsCubit>().state);
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
      backgroundColor: AppTheme.navy,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Semua Riwayat?',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy),
        ),
        content: const Text(
          'Semua hasil scan dan rekomendasi akan dihapus secara permanen.',
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
    if (ok == true) await cubit.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    final profile = context.watch<ProfileCubit>().state;
    final serverUrl = context.watch<SettingsCubit>().state;
    final historyState = context.watch<HistoryCubit>().state;
    final totalScans = historyState.records.length;
    final latestSkin = historyState.records.isNotEmpty
        ? historyState.records.first.analysis.skinType.label
        : '-';

    return Scaffold(
      backgroundColor: AppTheme.pearl,
      appBar: AppBar(title: const Text('Profil & Pengaturan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            // User Profile Card
            SectionCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: user != null ? AppTheme.navy : AppTheme.mist,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: user != null ? Colors.white : AppTheme.navy,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user?.name ?? 'Pengguna Tamu',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.navy,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user != null
                                        ? AppTheme.emerald.withOpacity(0.14)
                                        : AppTheme.ice,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user != null ? 'Terdaftar' : 'Tamu',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: user != null
                                          ? AppTheme.emerald
                                          : AppTheme.slate,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user != null
                                  ? user.email
                                  : 'Daftar/masuk 1x untuk menyimpan riwayat scan.',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.slate),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _miniStat(Icons.document_scanner_outlined,
                            '$totalScans Total Scan'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _miniStat(
                            Icons.face_outlined, 'Tipe: $latestSkin'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (user == null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => showAuthRequiredSheet(context),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Daftar / Masuk Akun'),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<AuthCubit>().logout(),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Keluar Akun'),
                      ),
                    ),
                ],
              ),
            ),

            // Preferensi Kulit Tersimpan
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 8, top: 2),
              child: Text(
                'PROFIL KEBUTUHAN TERAKHIR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppTheme.slate,
                ),
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Sensitivitas Kulit', '${profile.sensitivity}/5'),
                  const Divider(height: 16, color: AppTheme.border),
                  _row('Anggaran Maksimal',
                      Formatters.rupiah(profile.maxBudget)),
                  const Divider(height: 16, color: AppTheme.border),
                  _row(
                    'Bahan Dihindari',
                    profile.avoidedIngredients.isEmpty
                        ? 'Tidak ada'
                        : profile.avoidedIngredients.join(', '),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Profil otomatis diperbarui setiap kali Anda menyelesaikan scan.',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.slate),
                  ),
                ],
              ),
            ),

            // Server Klasifikasi
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 8, top: 2),
              child: Text(
                'KONFIGURASI MODEL AI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppTheme.slate,
                ),
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dns_outlined,
                          size: 18, color: AppTheme.navy),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Server Klasifikasi (FastAPI)',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: serverUrl.isEmpty
                              ? AppTheme.coralSoft
                              : AppTheme.emerald.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          serverUrl.isEmpty ? 'Demo Lokal' : 'CNN Server',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: serverUrl.isEmpty
                                ? AppTheme.coral
                                : AppTheme.emerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    serverUrl.isEmpty
                        ? 'Mode demo aktif: analisis dilakukan di perangkat dengan estimasi sederhana.'
                        : 'Foto dikirim ke server untuk diklasifikasi oleh model CNN.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppTheme.slate,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'http://10.0.2.2:8000',
                      labelText: 'Alamat Server',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Emulator Android memakai 10.0.2.2 untuk localhost komputer. Kosongkan untuk mode demo.',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.slate),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _saveUrl,
                    child: const Text('Simpan Konfigurasi'),
                  ),
                ],
              ),
            ),

            // Data & Privasi
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 8, top: 2),
              child: Text(
                'DATA & PRIVASI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppTheme.slate,
                ),
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.coral,
                side: const BorderSide(color: AppTheme.coral),
              ),
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Hapus Semua Riwayat'),
            ),
            const SizedBox(height: 14),
            const DisclaimerBanner(),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'SkinSense v1.0.0 • D4 Rekayasa Perangkat Lunak',
                style: TextStyle(fontSize: 11.5, color: AppTheme.slate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.ice,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppTheme.navy),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(k,
                style: const TextStyle(fontSize: 12.5, color: AppTheme.slate)),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
            ),
          ),
        ],
      );
}
