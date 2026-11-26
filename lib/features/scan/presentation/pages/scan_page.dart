import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:skinsense/features/scan/presentation/pages/result_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, this.isActive = true});

  /// Bernilai true saat tab Scan sedang dibuka agar kamera langsung aktif
  /// di dalam aplikasi, dan otomatis dilepas saat pindah ke tab lain.
  final bool isActive;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIdx = 0;
  bool _initializing = false;
  bool _takingPicture = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) {
      _initCamera();
    }
  }

  @override
  void didUpdateWidget(covariant ScanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initCamera();
    } else if (!widget.isActive && oldWidget.isActive) {
      _disposeCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera({int? preferredIndex}) async {
    if (_initializing) return;
    setState(() {
      _initializing = true;
      _cameraError = null;
    });

    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _initializing = false;
            _cameraError = 'Kamera tidak tersedia pada perangkat ini.';
          });
        }
        return;
      }

      if (preferredIndex != null) {
        _cameraIdx = preferredIndex % _cameras.length;
      } else {
        // Default ke kamera depan (front) untuk selfie scan wajah
        final frontIdx = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        _cameraIdx = frontIdx >= 0 ? frontIdx : 0;
      }

      final old = _controller;
      _controller = null;
      await old?.dispose();

      final controller = CameraController(
        _cameras[_cameraIdx],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted || !widget.isActive) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _cameraError = e.description ?? 'Izin kamera ditolak atau gagal dibuka.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _cameraError = 'Gagal memuat kamera: $e';
        });
      }
    }
  }

  Future<void> _disposeCamera() async {
    final old = _controller;
    _controller = null;
    if (mounted) setState(() {});
    await old?.dispose();
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _initializing) return;
    await _initCamera(preferredIndex: _cameraIdx + 1);
  }

  Future<void> _captureAndScan() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _takingPicture) {
      return;
    }

    setState(() => _takingPicture = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      context.read<ScanBloc>().add(ScanCapturedPathRequested(file.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.navy,
        behavior: SnackBarBehavior.floating,
        content: Text('Gagal mengambil foto: $e'),
      ));
    } finally {
      if (mounted) setState(() => _takingPicture = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanBloc, ScanState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) async {
        if (state.status == ScanStatus.success && state.analysis != null) {
          await _disposeCamera();
          if (!context.mounted) return;
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ResultPage(analysis: state.analysis!),
          ));
          if (!context.mounted) return;
          context.read<ScanBloc>().add(const ScanReset());
          if (widget.isActive) _initCamera(preferredIndex: _cameraIdx);
        } else if (state.status == ScanStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              backgroundColor: AppTheme.navy,
              content: Text(state.message ?? 'Gagal memproses foto.'),
              behavior: SnackBarBehavior.floating,
            ));
          context.read<ScanBloc>().add(const ScanReset());
        }
      },
      builder: (context, state) {
        final isReady =
            _controller != null && _controller!.value.isInitialized;
        final isFront = isReady &&
            _controller!.description.lensDirection ==
                CameraLensDirection.front;

        return Scaffold(
          backgroundColor: AppTheme.pearl,
          appBar: AppBar(
            title: const Text('Scan Wajah'),
            actions: [
              if (_cameras.length > 1)
                IconButton(
                  tooltip: 'Ganti Kamera Depan/Belakang',
                  icon: const Icon(Icons.flip_camera_ios_outlined,
                      color: AppTheme.navy),
                  onPressed: state.isBusy ? null : _switchCamera,
                ),
              IconButton(
                tooltip: 'Panduan Scan',
                icon: const Icon(Icons.help_outline_rounded,
                    color: AppTheme.navy),
                onPressed: () => _showTipsSheet(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    children: [
                      // Top guidance pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny_outlined,
                                size: 15, color: AppTheme.coral),
                            SizedBox(width: 6),
                            Text(
                              'Posisikan wajah di tengah bingkai oval',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Live In-App Camera Viewfinder
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.navyDark,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.navy.withOpacity(0.16),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (state.imagePath != null)
                                Image.file(
                                  File(state.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              else if (isReady)
                                _buildCameraFeed(_controller!, isFront)
                              else if (_cameraError != null)
                                _buildCameraFallback()
                              else
                                const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                          color: AppTheme.coral),
                                      SizedBox(height: 12),
                                      Text(
                                        'Membuka kamera...',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Face Oval Guide Overlay
                              CustomPaint(
                                painter: _OvalGuidePainter(
                                  hasImage: isReady || state.imagePath != null,
                                ),
                              ),

                              // Bottom viewfinder status chip
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.52),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Tanpa makeup • Jarak ±30 cm • Satu wajah',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Shutter & Gallery Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionCircleButton(
                            icon: Icons.photo_library_outlined,
                            label: 'Galeri',
                            onTap: state.isBusy
                                ? null
                                : () => context
                                    .read<ScanBloc>()
                                    .add(const ScanGalleryRequested()),
                          ),

                          // Primary In-App Shutter Button
                          GestureDetector(
                            onTap: (state.isBusy || !isReady || _takingPicture)
                                ? null
                                : _captureAndScan,
                            child: Container(
                              width: 74,
                              height: 74,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isReady
                                      ? AppTheme.coral
                                      : AppTheme.slate,
                                  width: 3,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isReady
                                      ? AppTheme.coral
                                      : AppTheme.slate,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_camera_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),

                          _ActionCircleButton(
                            icon: Icons.tips_and_updates_outlined,
                            label: 'Tips',
                            onTap: () => _showTipsSheet(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Busy Overlay
                if (state.isBusy)
                  Positioned.fill(
                    child: ColoredBox(
                      color: AppTheme.navyDark.withOpacity(0.82),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 36),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                  color: AppTheme.coral),
                              const SizedBox(height: 16),
                              Text(
                                state.status == ScanStatus.validating
                                    ? 'Memeriksa Deteksi Wajah...'
                                    : 'Menganalisis Tipe Kulit...',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppTheme.navy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Mohon tunggu sebentar',
                                style: TextStyle(
                                    fontSize: 12, color: AppTheme.slate),
                              ),
                            ],
                          ),
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

  Widget _buildCameraFeed(CameraController controller, bool isFront) {
    final previewSize = controller.value.previewSize;
    Widget preview = CameraPreview(controller);
    if (isFront) {
      preview = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: preview,
      );
    }

    if (previewSize == null) return preview;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height,
        height: previewSize.width,
        child: preview,
      ),
    );
  }

  Widget _buildCameraFallback() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 54,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          Text(
            _cameraError ?? 'Kamera tidak dapat diakses',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => _initCamera(preferredIndex: _cameraIdx),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Buka Kamera Lagi'),
          ),
        ],
      ),
    );
  }

  void _showTipsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Panduan Scan Akurat',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 14),
            _sheetTip(Icons.wb_sunny_outlined,
                'Gunakan cahaya cukup, sebaiknya cahaya alami.'),
            _sheetTip(Icons.face_retouching_off_outlined,
                'Pastikan wajah bersih tanpa makeup dan tanpa filter.'),
            _sheetTip(Icons.center_focus_strong_outlined,
                'Wajah menghadap lurus ke kamera, hanya satu wajah.'),
            _sheetTip(Icons.straighten_outlined,
                'Jaga jarak sekitar 30 cm dari kamera.'),
          ],
        ),
      ),
    );
  }

  Widget _sheetTip(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.ice,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: AppTheme.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, color: AppTheme.navy),
              ),
            ),
          ],
        ),
      );
}

class _ActionCircleButton extends StatelessWidget {
  const _ActionCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(icon, color: AppTheme.navy, size: 22),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _OvalGuidePainter extends CustomPainter {
  _OvalGuidePainter({required this.hasImage});
  final bool hasImage;

  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.47),
      width: size.width * 0.64,
      height: size.height * 0.66,
    );

    // Gelapkan sedikit area di luar bingkai oval agar fokus ke wajah
    final outerPath = Path()..addRect(Offset.zero & size);
    final innerPath = Path()..addOval(ovalRect);
    final maskPath =
        Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(
      maskPath,
      Paint()..color = Colors.black.withOpacity(0.28),
    );

    final borderPaint = Paint()
      ..color = hasImage ? Colors.white : Colors.white.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _OvalGuidePainter oldDelegate) =>
      oldDelegate.hasImage != hasImage;
}
