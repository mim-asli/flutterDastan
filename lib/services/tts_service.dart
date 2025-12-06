import 'package:flutter_tts/flutter_tts.dart';

/// وضعیت‌های مختلف پخش صدا
enum TtsState { playing, stopped, paused }

/// سرویس تبدیل متن به گفتار (Text-to-Speech).
///
/// این کلاس از پکیج `flutter_tts` برای خواندن متن داستان برای کاربر استفاده می‌کند.
/// این قابلیت برای دسترس‌پذیری و همچنین افزایش جذابیت بازی مفید است.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  TtsState _ttsState = TtsState.stopped;
  String? _currentText; // متنی که در حال خواندن آن هستیم

  // تنظیمات فعلی
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _language = "fa-IR";
  bool _isEnabled = true;

  TtsState get ttsState => _ttsState;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
  String get language => _language;
  bool get isEnabled => _isEnabled;

  /// مقداردهی اولیه سرویس و تنظیمات زبان و صدا.
  Future<void> init() async {
    await _applySettings();

    // هندلر برای زمانی که خواندن شروع می‌شود
    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
    });

    // هندلر برای زمانی که خواندن تمام می‌شود
    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      _currentText = null;
    });

    // هندلر برای زمانی که خطایی رخ می‌دهد
    _flutterTts.setErrorHandler((msg) {
      _ttsState = TtsState.stopped;
      _currentText = null;
    });
  }

  /// اعمال تنظیمات فعلی به موتور TTS
  Future<void> _applySettings() async {
    await _flutterTts.setLanguage(_language);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);
  }

  /// تنظیم سرعت خواندن (۰.۱ تا ۱.۰)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  /// تنظیم زیر و بمی صدا (۰.۵ تا ۲.۰)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
  }

  /// تنظیم بلندی صدا (۰.۰ تا ۱.۰)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
  }

  /// تنظیم زبان
  Future<void> setLanguage(String languageCode) async {
    _language = languageCode;
    await _flutterTts.setLanguage(_language);
  }

  /// فعال/غیرفعال کردن TTS
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled && _ttsState == TtsState.playing) {
      stop();
    }
  }

  /// دریافت لیست زبان‌های در دسترس
  Future<List<dynamic>> getAvailableLanguages() async {
    return await _flutterTts.getLanguages ?? [];
  }

  /// خواندن یک متن مشخص.
  /// اگر متنی در حال خواندن باشد، آن را قطع نمی‌کند مگر اینکه `stop` صدا زده شود.
  Future<void> speak(String text) async {
    if (!_isEnabled) return;

    _currentText = text;
    if (_ttsState == TtsState.stopped) {
      final result = await _flutterTts.speak(text);
      if (result == 1) _ttsState = TtsState.playing;
    }
  }

  /// متوقف کردن خواندن.
  Future<void> stop() async {
    final result = await _flutterTts.stop();
    if (result == 1) {
      _ttsState = TtsState.stopped;
      _currentText = null;
    }
  }

  /// تغییر وضعیت خواندن (اگر در حال خواندن است قطع کن، اگر نه بخوان).
  /// این متد برای دکمه‌های Play/Stop در رابط کاربری مفید است.
  Future<void> toggle(String text) async {
    if (!_isEnabled) return;

    if (_ttsState == TtsState.playing && _currentText == text) {
      await stop();
    } else {
      await speak(text);
    }
  }

  /// آزادسازی منابع سرویس.
  void dispose() {
    _flutterTts.stop();
  }
}
