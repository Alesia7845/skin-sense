import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skinsense/app.dart';
import 'package:skinsense/core/di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final deps = await AppDependencies.create();
  runApp(SkinSenseApp(deps: deps));
}
