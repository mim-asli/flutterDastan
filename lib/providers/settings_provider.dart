import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// یک enum برای نمایش خوانا و 안전한 انواع سرویس‌های هوش مصنوعی
enum AiProviderType { local, cloud }

/// این کلاس مسئول مدیریت و ذخیره‌سازی تنظیمات برنامه است.
///
/// از `ChangeNotifier` استفاده می‌کند تا هر زمان که تنظیماتی تغییر کرد،
/// به ویجت‌ها و سرویس‌های دیگر اطلاع دهد تا خود را به‌روز کنند.
class SettingsProvider extends StateNotifier<AsyncValue<void>> {
  late SharedPreferences _prefs;

  // مقادیر پیش‌فرض برای تنظیمات
  AiProviderType _aiProviderType = AiProviderType.cloud; // به طور پیش‌فرض از سرویس ابری استفاده می‌کنیم
  String _localApiUrl = 'http://10.0.2.2:1234';
  String _cloudApiKey = 'gen-lang-client-0157950363'; // کلید API پیش‌فرض

  // Getters برای دسترسی به مقادیر فعلی تنظیمات
  AiProviderType get aiProviderType => _aiProviderType;
  String get localApiUrl => _localApiUrl;
  String get cloudApiKey => _cloudApiKey;

  SettingsProvider() : super(const AsyncValue.loading()) {
    _init();
  }

  /// متد اولیه برای بارگذاری تنظیمات ذخیره شده از حافظه دستگاه.
  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // خواندن مقادیر ذخیره شده. اگر مقداری وجود نداشت، از مقدار پیش‌فرض استفاده می‌شود.
      final providerIndex = _prefs.getInt('aiProviderType') ?? 0;
      _aiProviderType = AiProviderType.values[providerIndex];
      _localApiUrl = _prefs.getString('localApiUrl') ?? _localApiUrl;
      _cloudApiKey = _prefs.getString('cloudApiKey') ?? _cloudApiKey;
      state = const AsyncValue.data(null); // نشان‌دهنده موفقیت‌آمیز بودن بارگذاری
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // در صورت بروز خطا
    }
  }

  /// به‌روزرسانی نوع ارائه‌دهنده سرویس هوش مصنوعی.
  Future<void> setAiProviderType(AiProviderType type) async {
    _aiProviderType = type;
    await _prefs.setInt('aiProviderType', type.index);
    // چون این یک StateNotifier است، باید state را تغییر دهیم تا شنوندگان با خبر شوند.
    // اگرچه در این مورد خاص، Provider اصلی (aiServiceProvider) خودش به این تغییر واکنش نشان می‌دهد.
    state = const AsyncValue.data(null);
  }

  /// به‌روزرسانی آدرس سرور محلی.
  Future<void> setLocalApiUrl(String url) async {
    _localApiUrl = url;
    await _prefs.setString('localApiUrl', url);
    state = const AsyncValue.data(null);
  }

  /// به‌روزرسانی کلید API سرویس ابری.
  Future<void> setCloudApiKey(String key) async {
    _cloudApiKey = key;
    await _prefs.setString('cloudApiKey', key);
    state = const AsyncValue.data(null);
  }
}

/// Provider اصلی برای دسترسی به `SettingsProvider` در سراسر برنامه.
final settingsProvider = StateNotifierProvider<SettingsProvider, AsyncValue<void>>((ref) {
  return SettingsProvider();
});
