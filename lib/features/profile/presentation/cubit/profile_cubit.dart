import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/features/profile/data/profile_repository.dart';
import 'package:skinsense/features/profile/domain/entities/user_profile.dart';

class ProfileCubit extends Cubit<UserProfile> {
  ProfileCubit(this._repository) : super(_repository.load());

  final ProfileRepository _repository;

  Future<void> save(UserProfile profile) async {
    await _repository.save(profile);
    emit(profile);
  }
}
