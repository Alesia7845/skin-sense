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
      builder: (_) => RecommendationPage(analysis: widget.analysis, profile: profile),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final customOnly = _avoided.where((e) => !UserProfile.knownAllergens.containsKey(e));
    return Scaffold(
      appBar: AppBar(title: const Text('Profil singkat')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'Tiga pertanyaan singkat agar rekomendasi sesuai kondisi dan anggaran Anda.',
                style: TextStyle(height: 1.4),
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tingkat sensitivitas kulit',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                  Slider(
                    value: _sensitivity,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _sensitivityLabels[_sensitivity.round()],
                    onChanged: (v) => setState(() => _sensitivity = v),
                  ),
                  Text('${_sensitivity.round()}/5 - ${_sensitivityLabels[_sensitivity.round()]}',
                      style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anggaran maksimum per produk',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                  Slider(
                    value: _budget,
                    min: 25000,
                    max: 500000,
                    divisions: 19,
                    label: Formatters.rupiah(_budget),
                    onChanged: (v) => setState(() => _budget = v),
                  ),
                  Text(Formatters.rupiah(_budget),
                      style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bahan yang dihindari (opsional)',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final label in UserProfile.knownAllergens.keys)
                        FilterChip(
                          label: Text(label),
                          selected: _avoided.contains(label),
                          onSelected: (on) => setState(
                              () => on ? _avoided.add(label) : _avoided.remove(label)),
                        ),
                      for (final label in customOnly)
                        InputChip(
                          label: Text(label),
                          onDeleted: () => setState(() => _avoided.remove(label)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addCustom(),
                          decoration: const InputDecoration(
                            hintText: 'Bahan lain, mis. lanolin',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _addCustom,
                        icon: const Icon(Icons.add),
                        tooltip: 'Tambah',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Lihat rekomendasi'),
            ),
          ],
        ),
      ),
    );
  }
}
