import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused }

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  TtsState _ttsState = TtsState.stopped;
  String? _currentText;

  TtsState get ttsState => _ttsState;

  Future<void> init() async {
    // تنظیم زبان فارسی
    await _flutterTts.setLanguage("fa-IR");
    await _flutterTts.setSpeechRate(0.5); // سرعت خواندن
    await _flutterTts.setVolume(1.0); // بلندی صدا
    await _flutterTts.setPitch(1.0); // زیر و بمی صدا

    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
    });

    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      _currentText = null;
    });

    _flutterTts.setErrorHandler((msg) {
      _ttsState = TtsState.stopped;
      _currentText = null;
    });
  }

  Future<void> speak(String text) async {
    _currentText = text;
    if (_ttsState == TtsState.stopped) {
      final result = await _flutterTts.speak(text);
      if (result == 1) _ttsState = TtsState.playing;
    }
  }

  Future<void> stop() async {
    final result = await _flutterTts.stop();
    if (result == 1) {
      _ttsState = TtsState.stopped;
      _currentText = null;
    }
  }

  Future<void> toggle(String text) async {
    if (_ttsState == TtsState.playing && _currentText == text) {
      await stop();
    } else {
      await speak(text);
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
