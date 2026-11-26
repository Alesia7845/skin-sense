import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/profile/domain/entities/user_profile.dart';
import 'package:skinsense/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skinsense/features/recommendation/presentation/pages/recommendation_page.dart';
import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';
import 'package:skinsense/shared/widgets/section_card.dart';

class ProfileInputPage extends StatefulWidget {
  const ProfileInputPage({super.key, required this.analysis});

  final SkinAnalysis analysis;

  @override
  State<ProfileInputPage> createState() => _ProfileInputPageState();
}

class _ProfileInputPageState extends State<ProfileInputPage> {
  late double _sensitivity;
  late double _budget;
  late Set<String> _avoided;
  final _customController = TextEditingController();

  static const _sensitivityLabels = {
    1: 'Tidak sensitif',
    2: 'Agak sensitif',
    3: 'Sedang',
    4: 'Sensitif',
    5: 'Sangat sensitif',
  };

  @override
  void initState() {
    super.initState();
    final saved = context.read<ProfileCubit>().state;
    _sensitivity = saved.sensitivity.toDouble();
    _budget = saved.maxBudget.clamp(25000, 500000).toDouble();
    _avoided = {...saved.avoidedIngredients};
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addCustom() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    setState(() => _avoided.add(text));
    _customController.clear();
  }

  Future<void> _submit() async {
    final profile = UserProfile(
      sensitivity: _sensitivity.round(),
      maxBudget: _budget.round(),
      avoidedIngredients: _avoided.toList(),
    );
    await context.read<ProfileCubit>().save(profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) =>
          RecommendationPage(analysis: widget.analysis, profile: profile),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final customOnly =
        _avoided.where((e) => !UserProfile.knownAllergens.containsKey(e));
    return Scaffold(
      backgroundColor: AppTheme.pearl,
      appBar: AppBar(title: const Text('Profil Kebutuhan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.navy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppTheme.coral, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sesuaikan 3 parameter berikut agar sistem Fuzzy-SAW menyusun rekomendasi yang paling pas.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sensitivitas
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tingkat Sensitivitas Kulit',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: AppTheme.navy,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.coralSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_sensitivity.round()}/5 • ${_sensitivityLabels[_sensitivity.round()]}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.coral,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.coral,
                      inactiveTrackColor: AppTheme.mist,
                      thumbColor: AppTheme.navy,
                    ),
                    child: Slider(
                      value: _sensitivity,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _sensitivityLabels[_sensitivity.round()],
                      onChanged: (v) => setState(() => _sensitivity = v),
                    ),
                  ),
                ],
              ),
            ),

            // Anggaran
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Anggaran Maks. / Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: AppTheme.navy,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.mist,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          Formatters.rupiah(_budget),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.navy,
                      inactiveTrackColor: AppTheme.mist,
                      thumbColor: AppTheme.coral,
                    ),
                    child: Slider(
                      value: _budget,
                      min: 25000,
                      max: 500000,
                      divisions: 19,
                      label: Formatters.rupiah(_budget),
                      onChanged: (v) => setState(() => _budget = v),
                    ),
                  ),
                ],
              ),
            ),

            // Bahan Dihindari
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bahan yang Dihindari (Opsional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih kandungan yang memicu iritasi atau alergi pada kulitmu.',
                    style: TextStyle(fontSize: 12, color: AppTheme.slate),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final label in UserProfile.knownAllergens.keys)
                        FilterChip(
                          label: Text(label),
                          selected: _avoided.contains(label),
                          selectedColor: AppTheme.coralSoft,
                          checkmarkColor: AppTheme.coral,
                          backgroundColor: AppTheme.ice,
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _avoided.contains(label)
                                ? AppTheme.coral
                                : AppTheme.navy,
                          ),
                          side: BorderSide(
                            color: _avoided.contains(label)
                                ? AppTheme.coral
                                : AppTheme.border,
                          ),
                          onSelected: (on) => setState(() => on
                              ? _avoided.add(label)
                              : _avoided.remove(label)),
                        ),
                      for (final label in customOnly)
                        InputChip(
                          label: Text(label),
                          backgroundColor: AppTheme.coralSoft,
                          deleteIconColor: AppTheme.coral,
                          labelStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.coral,
                          ),
                          onDeleted: () =>
                              setState(() => _avoided.remove(label)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addCustom(),
                          decoration: const InputDecoration(
                            hintText: 'Tambah bahan lain, mis. lanolin',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.navy,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _addCustom,
                        icon: const Icon(Icons.add_rounded),
                        tooltip: 'Tambah',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Lihat Rekomendasi'),
            ),
          ],
        ),
      ),
    );
  }
}
