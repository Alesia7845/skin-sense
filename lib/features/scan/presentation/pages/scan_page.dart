import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:skinsense/features/scan/presentation/pages/result_page.dart';
import 'package:skinsense/shared/widgets/section_card.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  static const _tips = [
    (Icons.wb_sunny_outlined, 'Gunakan cahaya cukup, sebaiknya cahaya alami.'),
    (Icons.face_retouching_off_outlined, 'Tanpa makeup dan tanpa filter.'),
    (Icons.center_focus_strong_outlined, 'Wajah menghadap lurus, satu wajah saja.'),
    (Icons.straighten_outlined, 'Jarak sekitar 30 cm dari kamera.'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanBloc, ScanState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ScanStatus.success && state.analysis != null) {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (_) => ResultPage(analysis: state.analysis!)))
              .then((_) {
            if (context.mounted) context.read<ScanBloc>().add(const ScanReset());
          });
        } else if (state.status == ScanStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message ?? 'Gagal memproses foto.'),
              behavior: SnackBarBehavior.floating,
            ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Scan wajah')),
          body: SafeArea(
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _Preview(path: state.imagePath),
                    const SizedBox(height: 20),
                    const Text('Agar hasil akurat',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink)),
                    const SizedBox(height: 10),
                    SectionCard(
                      child: Column(
                        children: [
                          for (final tip in _tips)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(tip.$1, color: AppTheme.teal, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(tip.$2)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    FilledButton.icon(
                      onPressed: state.isBusy
                          ? null
                          : () => context
                              .read<ScanBloc>()
                              .add(const ScanImageRequested(ImageSource.camera)),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Ambil foto'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: state.isBusy
                          ? null
                          : () => context
                              .read<ScanBloc>()
                              .add(const ScanImageRequested(ImageSource.gallery)),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Pilih dari galeri'),
                    ),
                  ],
                ),
                if (state.isBusy)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white.withOpacity(0.85),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              state.status == ScanStatus.validating
                                  ? 'Memeriksa wajah...'
                                  : 'Menganalisis tipe kulit...',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppTheme.ink),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({this.path});
  final String? path;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.mist,
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: path == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.face_outlined, size: 96, color: AppTheme.teal),
                  SizedBox(height: 12),
                  Text('Posisikan wajah di tengah bingkai',
                      style: TextStyle(color: AppTheme.ink)),
                ],
              )
            : Image.file(File(path!), fit: BoxFit.cover),
      ),
    );
  }
}
