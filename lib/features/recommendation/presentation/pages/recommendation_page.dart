import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skinsense/features/auth/presentation/widgets/auth_modal_sheet.dart';
import 'package:skinsense/features/history/presentation/cubit/history_cubit.dart';
import 'package:skinsense/features/profile/domain/entities/user_profile.dart';
import 'package:skinsense/features/recommendation/domain/entities/product.dart';
import 'package:skinsense/features/recommendation/domain/entities/recommendation.dart';
import 'package:skinsense/features/recommendation/domain/usecases/generate_recommendation_usecase.dart';
import 'package:skinsense/features/recommendation/presentation/cubit/recommendation_cubit.dart';
import 'package:skinsense/features/recommendation/presentation/widgets/need_meter.dart';
import 'package:skinsense/features/recommendation/presentation/widgets/product_tile.dart';
import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';
import 'package:skinsense/shared/widgets/disclaimer_banner.dart';
import 'package:skinsense/shared/widgets/section_card.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({
    super.key,
    required this.analysis,
    required this.profile,
    this.saveToHistory = true,
  });

  final SkinAnalysis analysis;
  final UserProfile profile;
  final bool saveToHistory;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.read<AuthCubit>().state.isLoggedIn;
    // Hanya otomatis tersimpan ke riwayat jika user sudah pernah login/daftar
    final shouldAutoSave = saveToHistory && isLoggedIn;

    return BlocProvider(
      create: (ctx) => RecommendationCubit(
        useCase: ctx.read<GenerateRecommendationUseCase>(),
        history: ctx.read<HistoryCubit>(),
      )..generate(analysis, profile, save: shouldAutoSave),
      child: Scaffold(
        backgroundColor: AppTheme.pearl,
        appBar: AppBar(title: const Text('Rekomendasi Perawatan')),
        body: BlocBuilder<RecommendationCubit, RecommendationState>(
          builder: (context, state) {
            switch (state.status) {
              case RecommendationStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.coral),
                );
              case RecommendationStatus.failure:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(state.message ?? 'Terjadi kesalahan.'),
                  ),
                );
              case RecommendationStatus.success:
                return _Body(
                  analysis: analysis,
                  profile: profile,
                  rec: state.recommendation!,
                  isSaved: state.isSaved,
                  openedFromHistory: !saveToHistory,
                );
            }
          },
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.analysis,
    required this.profile,
    required this.rec,
    required this.isSaved,
    required this.openedFromHistory,
  });

  final SkinAnalysis analysis;
  final UserProfile profile;
  final Recommendation rec;
  final bool isSaved;
  final bool openedFromHistory;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  int _tabIndex = 0; // 0 = Perawatan (Rutinitas & Bahan), 1 = Produk

  Future<void> _handleSaveToHistory() async {
    final ok = await showAuthRequiredSheet(
      context,
      subtitle:
          'Daftar atau masuk sekali saja di awal untuk menyimpan hasil scan dan rekomendasi ini ke Riwayat.',
    );
    if (!ok || !mounted) return;

    await context
        .read<RecommendationCubit>()
        .saveRecord(widget.analysis, widget.profile);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        backgroundColor: AppTheme.navy,
        behavior: SnackBarBehavior.floating,
        content: Text('Berhasil disimpan ke Riwayat Scan!'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.analysis.skinType;
    final rec = widget.rec;
    final showSavedBadge = widget.isSaved || widget.openedFromHistory;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      children: [
        // Navy Summary Header Card
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
                      color: AppTheme.coral,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Kulit ${type.label}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sensitivitas ${widget.profile.sensitivity}/5',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Rekomendasi Personal Fuzzy-SAW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anggaran maks. ${Formatters.rupiah(widget.profile.maxBudget)} per produk',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),

        // Profil Kebutuhan Kulit
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 19, color: AppTheme.navy),
                  SizedBox(width: 8),
                  Text(
                    'Profil Kebutuhan Kulit',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              NeedMeter(
                label: 'Kontrol Minyak',
                value: rec.need.oilControl,
                color: AppTheme.coral,
              ),
              NeedMeter(
                label: 'Hidrasi',
                value: rec.need.hydration,
                color: AppTheme.periwinkle,
              ),
              NeedMeter(
                label: 'Kelembutan',
                value: rec.need.gentleness,
                color: AppTheme.emerald,
              ),
              if (rec.need.activations.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.ice,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Aturan fuzzy aktif: ${rec.need.activations.take(2).map((a) => '${a.description} (${a.strength.toStringAsFixed(2)})').join('; ')}.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.slate,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Segmented Toggle: Perawatan vs Produk
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: 'Perawatan & Bahan',
                  icon: Icons.spa_outlined,
                  selected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
              ),
              Expanded(
                child: _SegmentButton(
                  label: 'Peringkat Produk',
                  icon: Icons.shopping_bag_outlined,
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ),
            ],
          ),
        ),

        if (_tabIndex == 0) ...[
          _RoutineCard(
            title: 'Rutinitas Pagi',
            badge: 'AM',
            icon: Icons.wb_sunny_outlined,
            accentColor: AppTheme.gold,
            steps: rec.morning,
          ),
          _RoutineCard(
            title: 'Rutinitas Malam',
            badge: 'PM',
            icon: Icons.nightlight_outlined,
            accentColor: AppTheme.periwinkle,
            steps: rec.night,
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: AppTheme.emerald),
                    SizedBox(width: 6),
                    Text(
                      'Bahan Aktif yang Cocok',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _Chips(
                  items: rec.recommendedIngredients,
                  color: AppTheme.navy,
                  bgColor: AppTheme.mist,
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.block_rounded,
                        size: 18, color: AppTheme.coral),
                    SizedBox(width: 6),
                    Text(
                      'Bahan yang Dihindari',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _Chips(
                  items: rec.avoidedIngredients,
                  color: AppTheme.coral,
                  bgColor: AppTheme.coralSoft,
                ),
              ],
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'Diurutkan dengan Fuzzy-SAW (maks. ${Formatters.rupiah(widget.profile.maxBudget)}/produk).',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.slate,
                height: 1.4,
              ),
            ),
          ),
          for (final category in ProductCategory.values) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 6, 0, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.coral,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navy,
                    ),
                  ),
                ],
              ),
            ),
            if ((rec.products[category] ?? const []).isEmpty)
              const SectionCard(
                child: Text(
                  'Tidak ada produk yang memenuhi anggaran dan filter bahan. Coba naikkan anggaran atau kurangi bahan yang dihindari.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.slate),
                ),
              )
            else
              for (final item in rec.products[category]!)
                ProductTile(item: item),
          ],
        ],

        const SizedBox(height: 8),
        const DisclaimerBanner(),
        const SizedBox(height: 16),

        // Tombol Simpan ke Riwayat (wajib daftar/login 1x jika belum masuk)
        if (!showSavedBadge) ...[
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.coral,
              foregroundColor: Colors.white,
            ),
            onPressed: _handleSaveToHistory,
            icon: const Icon(Icons.bookmark_add_rounded, size: 18),
            label: const Text('Simpan ke Riwayat Scan'),
          ),
          const SizedBox(height: 10),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.emerald.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.emerald.withOpacity(0.35)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 18, color: AppTheme.emerald),
                SizedBox(width: 8),
                Text(
                  'Tersimpan di Riwayat Scan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.emerald,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.home_rounded, size: 18),
          label: const Text('Selesai & Kembali ke Beranda'),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppTheme.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppTheme.slate,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppTheme.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.title,
    required this.badge,
    required this.icon,
    required this.accentColor,
    required this.steps,
  });

  final String title;
  final String badge;
  final IconData icon;
  final Color accentColor;
  final List<RoutineStep> steps;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.ice,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: AppTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[i].detail,
                          style: const TextStyle(
                            height: 1.4,
                            fontSize: 12.5,
                            color: AppTheme.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.items,
    required this.color,
    required this.bgColor,
  });

  final List<String> items;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('-', style: TextStyle(color: AppTheme.slate));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final i in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              i,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
