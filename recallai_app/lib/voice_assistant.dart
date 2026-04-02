import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {

  final SpeechToText speech = SpeechToText();
  final FlutterTts tts = FlutterTts();

  String recognizedText = "";

  Future<String> listen() async {

    bool available = await speech.initialize(
      onStatus: (status) {
        print("Speech status: $status");
      },
      onError: (error) {
        print("Speech error");
      },
    );

    if (!available) {
      return "";
    }

    recognizedText = "";

    await speech.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      localeId: "en_US",
    );

    await Future.delayed(const Duration(seconds: 6));

    await speech.stop();

    return recognizedText;
  }

  Future<void> speak(String text) async {

    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);

    await tts.speak(text);
  }
}