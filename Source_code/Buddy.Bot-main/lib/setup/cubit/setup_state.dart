// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'setup_cubit.dart';

enum SetupStatus { initial, loading, success, failure }

@immutable
class SetupState extends Equatable {
  const SetupState({
    this.currentUser,
    this.cameraPermissionStatus,
  });

  final User? currentUser;
  final PermissionStatus? cameraPermissionStatus;

  bool get isSetupComplete =>
      currentUser != null && cameraPermissionStatus == PermissionStatus.granted;

  SetupState copyWith({
    User? currentUser,
    PermissionStatus? cameraPermissionStatus,
  }) {
    return SetupState(
      currentUser: currentUser ?? this.currentUser,
      cameraPermissionStatus:
          cameraPermissionStatus ?? this.cameraPermissionStatus,
    );
  }

  @override
  List<Object?> get props => [currentUser, cameraPermissionStatus];
}
