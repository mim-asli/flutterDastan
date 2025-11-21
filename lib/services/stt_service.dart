import 'dart:developer' as developer;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SttService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// آیا سرویس در حال گوش دادن به ورودی صوتی است؟
  /// این مقدار پس از شروع `startListening` برابر `true` و پس از `stopListening` یا پایان تشخیص، `false` می‌شود.
  bool get isListening => _isListening;

  /// آیا سرویس با موفقیت مقداردهی اولیه شده است؟
  /// تنها در صورتی که این مقدار `true` باشد، می‌توان از سرویس استفاده کرد.
  bool get isInitialized => _isInitialized;

  /// سرویس تشخیص گفتار را مقداردهی اولیه می‌کند.
  /// این متد باید قبل از هر استفاده دیگری از سرویس فراخوانی شود.
  /// اگر مقداردهی اولیه موفقیت‌آمیز باشد `true` و در غیر این صورت `false` برمی‌گرداند.
  Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speechToText.initialize(
      onStatus: (status) =>
          developer.log('[STT] وضعیت: $status', name: 'SttService'),
      onError: (error) =>
          developer.log('[STT] خطا: $error', name: 'SttService', error: error),
    );
    return _isInitialized;
  }

  /// گوش دادن به گفتار کاربر را شروع می‌کند.
  /// [onResultCallback] یک تابع است که با هر تغییر در متن تشخیص داده شده (چه میانی و چه نهایی) فراخوانی می‌شود.
  void startListening(Function(String) onResultCallback) {
    // اگر سرویس آماده نیست یا در حال گوش دادن است، کاری انجام نده.
    if (!_isInitialized || _isListening) return;
    _isListening = true;

    // استفاده از گزینه‌های جدید برای کنترل نحوه گوش دادن
    final listenOptions = SpeechListenOptions(
      cancelOnError: true, // در صورت بروز خطا، گوش دادن را لغو کن
      partialResults:
          true, // نتایج میانی را هم گزارش کن تا کاربر بازخورد آنی داشته باشد
    );

    _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        // هر بار که کلمات جدیدی تشخیص داده می‌شود، callback را فراخوانی کن
        onResultCallback(result.recognizedWords);
        // اگر نتیجه نهایی است، وضعیت گوش دادن را به `false` تغییر بده
        if (result.finalResult) {
          _isListening = false;
        }
      },
      listenFor: const Duration(
          seconds: 10), // حداکثر زمانی که سرویس به گوش دادن ادامه می‌دهد
      pauseFor: const Duration(
          seconds: 3), // مدت زمان سکوتی که پس از آن تشخیص پایان می‌یابد
      localeId: "fa_IR", // تنظیم زبان فارسی برای تشخیص بهتر
      listenOptions: listenOptions, // اعمال گزینه‌های جدید
    );
  }

  /// به صورت دستی، سرویس تشخیص گفتار را متوقف می‌کند.
  void stopListening() {
    if (!_isListening) return;
    _speechToText.stop();
    _isListening = false;
  }

  /// عملیات تشخیص فعلی را لغو کرده و منابع را آزاد می‌کند.
  /// این متد معمولاً در dispose یک ویجت فراخوانی می‌شود.
  void dispose() {
    _speechToText.cancel();
  }
}
