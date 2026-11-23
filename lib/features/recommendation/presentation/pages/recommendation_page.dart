import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
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
import 'package:skinsense/shared/widgets/skin_type_style.dart';

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
    return BlocProvider(
      create: (ctx) => RecommendationCubit(
        useCase: ctx.read<GenerateRecommendationUseCase>(),
        history: ctx.read<HistoryCubit>(),
      )..generate(analysis, profile, save: saveToHistory),
      child: Scaffold(
        appBar: AppBar(title: const Text('Rekomendasi')),
        body: BlocBuilder<RecommendationCubit, RecommendationState>(
          builder: (context, state) {
            switch (state.status) {
              case RecommendationStatus.loading:
                return const Center(child: CircularProgressIndicator());
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
                );
            }
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.analysis, required this.profile, required this.rec});

  final SkinAnalysis analysis;
  final UserProfile profile;
  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final type = analysis.skinType;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(type.icon, color: type.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Profil kebutuhan kulit ${type.label.toLowerCase()}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              NeedMeter(label: 'Kontrol minyak', value: rec.need.oilControl, color: const Color(0xFFD98E1F)),
              NeedMeter(label: 'Hidrasi', value: rec.need.hydration, color: const Color(0xFF5B6FD1)),
              NeedMeter(label: 'Kelembutan', value: rec.need.gentleness, color: AppTheme.teal),
              if (rec.need.activations.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Dasar penilaian (fuzzy): ${rec.need.activations.take(2).map((a) => '${a.description} (${a.strength.toStringAsFixed(2)})').join('; ')}.',
                  style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        _RoutineCard(title: 'Rutinitas pagi', icon: Icons.wb_sunny_outlined, steps: rec.morning),
        _RoutineCard(title: 'Rutinitas malam', icon: Icons.nightlight_outlined, steps: rec.night),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bahan aktif yang cocok',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
              const SizedBox(height: 8),
              _Chips(items: rec.recommendedIngredients, color: AppTheme.teal),
              const SizedBox(height: 14),
              const Text('Bahan yang sebaiknya dihindari',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
              const SizedBox(height: 8),
              _Chips(items: rec.avoidedIngredients, color: AppTheme.coral),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 6, 2, 8),
          child: Text('Peringkat produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            'Diurutkan dengan Fuzzy-SAW, difilter anggaran maks. ${Formatters.rupiah(profile.maxBudget)} per produk dan bahan yang dihindari.',
            style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.4),
          ),
        ),
        for (final category in ProductCategory.values) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 0, 8),
            child: Text(category.label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.teal)),
          ),
          if ((rec.products[category] ?? const []).isEmpty)
            const SectionCard(
              child: Text(
                  'Tidak ada produk yang memenuhi anggaran dan filter bahan. Coba naikkan anggaran atau kurangi bahan yang dihindari.',
                  style: TextStyle(fontSize: 13)),
            )
          else
            for (final item in rec.products[category]!) ProductTile(item: item),
        ],
        const SizedBox(height: 10),
        const DisclaimerBanner(),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.home_outlined),
          label: const Text('Kembali ke beranda'),
        ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.title, required this.icon, required this.steps});

  final String title;
  final IconData icon;
  final List<RoutineStep> steps;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.teal),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink)),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.mist,
                    child: Text('${i + 1}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].title,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(steps[i].detail,
                            style: const TextStyle(height: 1.4, fontSize: 13.5)),
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
  const _Chips({required this.items, required this.color});

  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('-');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final i in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(i,
                style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}
