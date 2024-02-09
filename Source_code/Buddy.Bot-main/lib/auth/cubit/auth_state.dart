part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({
    // this.currentFirebaseUser,
    this.currentUser,
  });

  // final FirebaseUser? currentFirebaseUser;
  final User? currentUser;

  @override
  List<Object?> get props => [
        // currentFirebaseUser,
        currentUser,
      ];
}
