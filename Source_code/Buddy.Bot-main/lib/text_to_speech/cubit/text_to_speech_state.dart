part of 'text_to_speech_cubit.dart';

enum TextToSpeechStatus { initial, idle, speaking, unsupported }

class TextToSpeechState extends Equatable {
  const TextToSpeechState({
    this.status = TextToSpeechStatus.initial,
    this.language,
  });

  final TextToSpeechStatus status;
  final String? language;

  @override
  List<Object?> get props => [status, language];
}
