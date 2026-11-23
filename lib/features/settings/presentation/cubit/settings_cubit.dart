import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/features/settings/data/settings_repository.dart';

/// State = URL server saat ini (string kosong berarti mode demo).
class SettingsCubit extends Cubit<String> {
  SettingsCubit(this._repository) : super(_repository.serverUrl);

  final SettingsRepository _repository;

  Future<void> saveServerUrl(String url) async {
    await _repository.setServerUrl(url);
    emit(_repository.serverUrl);
  }
}
