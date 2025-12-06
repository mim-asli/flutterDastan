import 'package:myapp/models.dart';

/// یک "قرارداد" یا اینترفیس انتزاعی برای تمام سرویس‌های هوش مصنوعی.
///
/// این کلاس تضمین می‌کند که هر سرویس هوش مصنوعی (چه محلی و چه ابری)
/// باید متدهای مشخصی را پیاده‌سازی کند. این کار به بقیه برنامه اجازه می‌دهد
/// تا بدون نگرانی از اینکه کدام سرویس در حال استفاده است، با هوش مصنوعی ارتباط برقرار کنند.
abstract class BaseAIService {
  /// پیام کاربر و وضعیت فعلی او را برای تولید ادامه داستان ارسال می‌کند.
  Future<GameResponse> sendMessage(String userMessage, GameStats currentStats,
      WorldState worldState, List<InventoryItem> inventory, GameConfig? config);

  /// یک سوال مستقیم از راوی بازی می‌پرسد.
  Future<String> askNarrator(String userQuestion);

  /// تاریخچه مکالمه را برای جلوگیری از طولانی شدن بیش از حد، خلاصه می‌کند.
  Future<void> summarizeAndResetHistory();

  /// درخواست برای ترکیب دو آیتم و دریافت نتیجه.
  Future<CraftingResponse> craftItems(InventoryItem item1, InventoryItem item2);

  /// درخواست برای تولید تصویر بر اساس توصیف.
  /// اگر سرویس پشتیبانی نکند یا خطایی رخ دهد، null برمی‌گرداند.
  Future<String?> generateImage(String prompt);
}
