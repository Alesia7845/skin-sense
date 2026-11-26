import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:skinsense/core/constants/app_constants.dart';
import 'package:skinsense/core/di/app_dependencies.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skinsense/features/history/presentation/cubit/history_cubit.dart';
import 'package:skinsense/features/home/presentation/pages/main_shell.dart';
import 'package:skinsense/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:skinsense/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skinsense/features/recommendation/domain/usecases/generate_recommendation_usecase.dart';
import 'package:skinsense/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:skinsense/features/settings/presentation/cubit/settings_cubit.dart';

class SkinSenseApp extends StatelessWidget {
  const SkinSenseApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<GenerateRecommendationUseCase>.value(
      value: deps.generateRecommendation,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(deps.auth)),
          BlocProvider(create: (_) => SettingsCubit(deps.settings)),
          BlocProvider(create: (_) => ProfileCubit(deps.profile)),
          BlocProvider(create: (_) => HistoryCubit(deps.history)..load()),
          BlocProvider(
            create: (_) => ScanBloc(
              validateFace: deps.validateFace,
              analyzeSkin: deps.analyzeSkin,
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('id', 'ID'),
          supportedLocales: const [Locale('id', 'ID'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _Gate(deps: deps),
        ),
      ),
    );
  }
}

/// Menampilkan onboarding pada pemakaian pertama, lalu halaman utama.
class _Gate extends StatefulWidget {
  const _Gate({required this.deps});

  final AppDependencies deps;

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  late bool _onboardingDone = widget.deps.settings.onboardingDone;

  Future<void> _finish() async {
    await widget.deps.settings.setOnboardingDone();
    if (mounted) setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return _onboardingDone
        ? const MainShell()
        : OnboardingPage(onDone: _finish);
  }
}
