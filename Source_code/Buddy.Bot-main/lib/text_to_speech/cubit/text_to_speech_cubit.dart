import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:text_to_speech/text_to_speech.dart';

part 'text_to_speech_state.dart';

class TextToSpeechCubit extends Cubit<TextToSpeechState> {
  TextToSpeechCubit()
      : _tts = TextToSpeech(),
        super(const TextToSpeechState());

  final TextToSpeech _tts;

  bool get _canSpeak => [
        TextToSpeechStatus.idle,
        TextToSpeechStatus.speaking,
      ].contains(state.status);

  static const _supportedLanguages = ['nl-NL', 'nl-BE'];

  Future<void> setDefaultSettings() async {
    final allLanguages = await _tts.getLanguages();
    final language = _supportedLanguages.cast<String?>().firstWhere(
          allLanguages.contains,
          orElse: () => null,
        );

    if (language == null) {
      print('No supported language found');
      emit(
        const TextToSpeechState(
          status: TextToSpeechStatus.unsupported,
        ),
      );
      return;
    }

    print('Setting language to $language');

    emit(
      TextToSpeechState(
        status: TextToSpeechStatus.idle,
        language: language,
      ),
    );
  }

  Future<void> speak(String message) async {
    if (!_canSpeak) {
      return;
    }

    await _tts.speak(message);
  }

  Future<void> stopSpeaking() async {
    if (!_canSpeak) {
      return;
    }

    await _tts.stop();
  }
}
