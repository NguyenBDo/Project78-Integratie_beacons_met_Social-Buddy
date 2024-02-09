import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

part 'setup_state.dart';

class SetupCubit extends Cubit<SetupState> {
  SetupCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const SetupState());

  final AuthRepository _authRepository;

  StreamSubscription<User?>? _currentUserSubscription;

  @override
  Future<void> close() async {
    await _currentUserSubscription?.cancel();
    await super.close();
  }

  void subscribeToCurrentUser() {
    _currentUserSubscription = _authRepository.currentUser.listen((user) {
      emit(state.copyWith(currentUser: user));
    });
  }

  Future<void> signInWithGoogle() async {
    emit(
      state.copyWith(
        currentUser: await _authRepository.signInWithGoogle(),
      ),
    );
  }

  Future<void> checkPermissions() async {
    final status = await Permission.camera.status;
    emit(
      state.copyWith(
        cameraPermissionStatus: status,
      ),
    );
  }

  Future<void> attemptGrantPermissions() async {
    await Permission.camera.request();
    await checkPermissions();
  }
}
