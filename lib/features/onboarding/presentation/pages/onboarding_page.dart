import 'package:flutter/material.dart';
import 'package:skinsense/core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    (
      Icons.face_retouching_natural,
      'Kenali tipe kulit Anda',
      'Foto wajah tanpa makeup, lalu SkinSense mengklasifikasikannya sebagai normal, berminyak, atau kering.'
    ),
    (
      Icons.tune,
      'Sesuaikan dengan kebutuhan',
      'Isi sensitivitas, anggaran, dan bahan yang dihindari. Logika fuzzy menyusun profil kebutuhan perawatan Anda.'
    ),
    (
      Icons.checklist_rtl,
      'Rutinitas dan produk yang pas',
      'Dapatkan rutinitas pagi-malam dan peringkat produk per kategori yang dihitung dengan SAW.'
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onDone,
                child: const Text('Lewati'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                            color: AppTheme.mist,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.$1, size: 72, color: AppTheme.teal),
                        ),
                        const SizedBox(height: 36),
                        Text(page.$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink)),
                        const SizedBox(height: 14),
                        Text(page.$3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15, height: 1.5)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: i == _index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? AppTheme.teal : AppTheme.mist,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: FilledButton(
                onPressed: () {
                  if (last) {
                    widget.onDone();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(last ? 'Mulai' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
