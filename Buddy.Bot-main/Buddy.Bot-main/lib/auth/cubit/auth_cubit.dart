import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState());

  final AuthRepository _authRepository;

  StreamSubscription<User?>? _currentUserSubscription;

  @override
  Future<void> close() async {
    await _currentUserSubscription?.cancel();
    await super.close();
  }

  void subscribeToCurrentUser() {
    _currentUserSubscription = _authRepository.currentUser.listen((user) {
      emit(AuthState(currentUser: user));
    });
  }
}
