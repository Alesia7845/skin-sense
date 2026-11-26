import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/features/auth/data/auth_repository.dart';
import 'package:skinsense/features/auth/domain/entities/auth_user.dart';

class AuthState extends Equatable {
  const AuthState({
    this.user,
    this.loading = false,
  });

  final AuthUser? user;
  final bool loading;

  bool get isLoggedIn => user != null;

  @override
  List<Object?> get props => [user, loading];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository)
      : super(AuthState(user: _repository.getCurrentUser()));

  final AuthRepository _repository;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    emit(AuthState(user: state.user, loading: true));
    try {
      final user = await _repository.login(email: email, password: password);
      emit(AuthState(user: user, loading: false));
      return true;
    } catch (_) {
      emit(AuthState(user: state.user, loading: false));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthState(user: state.user, loading: true));
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthState(user: user, loading: false));
      return true;
    } catch (_) {
      emit(AuthState(user: state.user, loading: false));
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(user: null, loading: false));
  }
}
