import 'package:auth_repository/auth_repository.dart';
import 'package:buddy_bot/auth/auth.dart';
import 'package:buddy_bot/home/home.dart';
import 'package:buddy_bot/setup/setup.dart';
import 'package:buddy_bot/text_to_speech/text_to_speech.dart';
import 'package:buddy_bot/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuddyBotApp extends StatelessWidget {
  const BuddyBotApp({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      child: TextToSpeechProvider(
        child: MaterialApp(
          key: key,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: DefaultTextHeightBehavior(
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.currentUser == null
                      ? const SetupPage(key: Key('setupPage'))
                      : const HomePage(key: Key('homePage')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
