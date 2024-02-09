import 'package:buddy_bot/text_to_speech/text_to_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextToSpeechProvider extends StatelessWidget {
  const TextToSpeechProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => TextToSpeechCubit()..setDefaultSettings(),
      child: child,
    );
  }
}
