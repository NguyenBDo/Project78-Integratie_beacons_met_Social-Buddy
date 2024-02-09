import 'package:auth_repository/auth_repository.dart';
import 'package:buddy_bot/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthProvider extends StatelessWidget {
  const AuthProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthCubit(
          authRepository: context.read<AuthRepository>(),
        )..subscribeToCurrentUser(),
        child: child,
      ),
    );
  }
}
