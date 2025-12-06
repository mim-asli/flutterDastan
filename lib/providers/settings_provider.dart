import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// یک enum برای نمایش خوانا و ایمن انواع سرویس‌های هوش مصنوعی
enum AiProviderType { local, cloud }

/// این کلاس مسئول مدیریت و ذخیره‌سازی تنظیمات برنامه است.
///
/// از `StateNotifier` استفاده می‌کند تا هر زمان که تنظیماتی تغییر کرد،
/// به ویجت‌ها و سرویس‌های دیگر اطلاع دهد تا خود را به‌روز کنند.
/// این کلاس تنظیمات را در حافظه دستگاه (SharedPreferences) ذخیره می‌کند تا با بستن برنامه پاک نشوند.
class SettingsProvider extends StateNotifier<AsyncValue<void>> {
  late SharedPreferences _prefs;

  // مقادیر پیش‌فرض برای تنظیمات
  AiProviderType _aiProviderType = AiProviderType.cloud;
  String _localApiUrl = 'http://10.0.2.2:1234/v1';
  String _cloudApiKey = 'gen-lang-client-0157950363';
  bool _isImageGenerationEnabled = false;
  bool _isDeepSeekEnabled = false;
  String _themeMode = 'dark'; // 'dark', 'light', 'system'

  // Getters
  AiProviderType get aiProviderType => _aiProviderType;
  String get localApiUrl => _localApiUrl;
  String get cloudApiKey => _cloudApiKey;
  bool get isImageGenerationEnabled => _isImageGenerationEnabled;
  bool get isDeepSeekEnabled => _isDeepSeekEnabled;
  String get themeMode => _themeMode;

  SettingsProvider() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final providerIndex = _prefs.getInt('aiProviderType') ?? 1;
      _aiProviderType = AiProviderType.values[providerIndex];
      _localApiUrl = _prefs.getString('localApiUrl') ?? _localApiUrl;
      _cloudApiKey = _prefs.getString('cloudApiKey') ?? _cloudApiKey;
      _isImageGenerationEnabled =
          _prefs.getBool('isImageGenerationEnabled') ?? false;
      _isDeepSeekEnabled = _prefs.getBool('isDeepSeekEnabled') ?? false;
      _themeMode = _prefs.getString('themeMode') ?? 'dark';
      _fontFamily = _prefs.getString('fontFamily') ?? 'Vazirmatn';

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> setAiProviderType(AiProviderType type) async {
    _aiProviderType = type;
    await _prefs.setInt('aiProviderType', type.index);
    state = const AsyncValue.data(null);
  }

  Future<void> setLocalApiUrl(String url) async {
    _localApiUrl = url;
    await _prefs.setString('localApiUrl', url);
    state = const AsyncValue.data(null);
  }

  Future<void> setCloudApiKey(String key) async {
    _cloudApiKey = key;
    await _prefs.setString('cloudApiKey', key);
    state = const AsyncValue.data(null);
  }

  Future<void> setImageGenerationEnabled(bool enabled) async {
    _isImageGenerationEnabled = enabled;
    await _prefs.setBool('isImageGenerationEnabled', enabled);
    state = const AsyncValue.data(null);
  }

  Future<void> setDeepSeekEnabled(bool enabled) async {
    _isDeepSeekEnabled = enabled;
    await _prefs.setBool('isDeepSeekEnabled', enabled);
    state = const AsyncValue.data(null);
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs.setString('themeMode', mode);
    state = const AsyncValue.data(null);
  }

  // Font Family
  String _fontFamily = 'Vazirmatn';
  String get fontFamily => _fontFamily;

  Future<void> setFontFamily(String font) async {
    _fontFamily = font;
    await _prefs.setString('fontFamily', font);
    state = const AsyncValue.data(null);
  }
}

/// Provider اصلی برای دسترسی به `SettingsProvider` در سراسر برنامه.
/// بقیه بخش‌های برنامه از طریق این متغیر به تنظیمات دسترسی پیدا می‌کنند.
final settingsProvider =
    StateNotifierProvider<SettingsProvider, AsyncValue<void>>((ref) {
  return SettingsProvider();
});
