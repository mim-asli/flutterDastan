import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/collections.dart';
import 'package:myapp/db_service.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers/settings_provider.dart';
import 'package:myapp/services/base_ai_service.dart';
import 'package:myapp/services/cloud_ai_service.dart';
import 'package:myapp/services/local_ai_service.dart';
import 'package:myapp/services/stt_service.dart';
import 'package:myapp/services/tts_service.dart';

// ------------------- سرویس‌ها (Services) -------------------

/// Provider هوشمند و داینامیک برای سرویس هوش مصنوعی.
///
/// این Provider به تنظیمات کاربر گوش می‌دهد و بر اساس انتخاب او،
/// نمونه‌ای از `CloudAIService` (برای سرویس ابری) یا `LocalAIService` (برای سرور محلی) را ایجاد می‌کند.
/// خروجی این Provider همیشه از نوع `BaseAIService` است که به بقیه برنامه اجازه می‌دهد
/// بدون نگرانی از جزئیات پیاده‌سازی، با سرویس هوش مصنوعی کار کنند.
final aiServiceProvider = Provider<BaseAIService>((ref) {
  // به تنظیمات گوش می‌دهیم تا در صورت تغییر، این Provider دوباره ساخته شود.
  final settings = ref.watch(settingsProvider.notifier);

  // بر اساس انتخاب کاربر، سرویس مناسب را برمی‌گردانیم.
  switch (settings.aiProviderType) {
    case AiProviderType.local:
      return LocalAIService(
        settings.localApiUrl,
      ); // سرویس محلی را با آدرس تنظیم شده ایجاد کن
    case AiProviderType.cloud:
      final apiKey = settings.cloudApiKey;
      if (apiKey.isEmpty || apiKey == "gen-lang-client-0157950363") {
        throw Exception(
          'کلید API ابری در صفحه تنظیمات وارد نشده است. لطفاً کلید خود را وارد کنید.',
        );
      }
      return CloudAIService(apiKey); // سرویس ابری را با کلید API ایجاد کن
  }
});

/// Provider برای دسترسی به سرویس دیتابیس (Hive).
final dbServiceProvider = Provider((ref) => DBService());

/// Provider برای سرویس تبدیل متن به گفتار (Text-to-Speech).
/// این سرویس هنگام ساخته شدن مقداردهی اولیه می‌شود و هنگام بسته شدن Provider آزاد می‌شود.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final ttsService = TtsService();
  ttsService.init();
  ref.onDispose(() => ttsService.dispose());
  return ttsService;
});

/// Provider برای سرویس تبدیل گفتار به متن (Speech-to-Text).
final sttServiceProvider = Provider<SttService>((ref) {
  final sttService = SttService();
  ref.onDispose(() => sttService.dispose());
  return sttService;
});

// ------------------- وضعیت‌های UI (UI States) -------------------

/// وضعیت نمایش لودینگ (مثلاً زمانی که منتظر پاسخ هوش مصنوعی هستیم).
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// لیست گزینه‌هایی که کاربر می‌تواند انتخاب کند.
final optionsProvider = StateProvider<List<String>>((ref) => ["شروع بازی"]);

/// تاریخچه متن داستان که در صفحه نمایش داده می‌شود.
final storyLogProvider = StateProvider<List<String>>(
  (ref) => ["به اعماق ناشناخته خوش آمدید. ماجراجویی خود را آغاز کنید."],
);

// ------------------- وضعیت‌های داده‌ای (Data States) -------------------

/// وضعیت‌های حیاتی بازیکن (سلامتی، روان، گرسنگی، انرژی).
final statsProvider = StateProvider<GameStats>((ref) => const GameStats());

/// شمارنده نوبت‌ها برای مدیریت خلاصه سازی حافظه هوش مصنوعی.
final turnCounterProvider = StateProvider<int>((ref) => 0);

/// آستانه‌ای که بعد از آن تعداد نوبت، حافظه هوش مصنوعی خلاصه می‌شود.
const int summarizationThreshold = 5;

// ------------------- وضعیت‌های ساخت و ساز (Crafting States) -------------------

/// لیست آیتم‌های موجود در کوله‌پشتی بازیکن.
final inventoryProvider = StateProvider<List<InventoryItem>>(
  (ref) => [
    const InventoryItem(name: "تکه چوب", description: "یک تکه چوب خشک و محکم."),
    const InventoryItem(name: "سنگ تیز", description: "سنگی با لبه‌های برنده."),
    const InventoryItem(
      name: "طناب کهنه",
      description: "یک تکه طناب فرسوده ولی قابل استفاده.",
    ),
    const InventoryItem(
      name: "کنسرو لوبیا",
      description: "یک وعده غذایی فراموش شده.",
    ),
  ],
);

/// لیست آیتم‌هایی که کاربر برای ترکیب کردن انتخاب کرده است.
final craftingSelectionProvider = StateProvider<List<InventoryItem>>(
  (ref) => [],
);

// ------------------- وضعیت‌های سیستم ذخیره (Save System States) -------------------

/// دریافت لیست تمام اسلات‌های ذخیره شده از دیتابیس.
final saveSlotsProvider = FutureProvider<List<SaveSlot>>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return db.getAllSaveSlots();
});

/// تنظیمات بازی فعلی (مثل نام جهان، ژانر، کلاس شخصیت و ...).
final gameConfigProvider = StateProvider<GameConfig?>((ref) => null);

/// وضعیت جهان بازی (زمان، آب‌وهوا، روز).
final worldStateProvider =
    StateProvider<WorldState>((ref) => const WorldState());

/// آدرس تصویر تولید شده توسط هوش مصنوعی.
final generatedImageProvider = StateProvider<String?>((ref) => null);

// ------------------- کنترلر اصلی بازی (Game Controller) -------------------

/// کنترلر اصلی که منطق بازی را مدیریت می‌کند.
/// وظایفی مثل پردازش ورودی کاربر، ارتباط با هوش مصنوعی، مدیریت وضعیت‌ها و ذخیره/بازیابی بازی را بر عهده دارد.
final gameControllerProvider = StateNotifierProvider<GameController, void>((
  ref,
) {
  return GameController(ref);
});

class GameController extends StateNotifier<void> {
  final Ref _ref;
  int? _currentSlotId; // شناسه اسلات ذخیره فعلی (برای ذخیره خودکار)

  GameController(this._ref) : super(null);

  /// پردازش ورودی کاربر (انتخاب گزینه یا تایپ متن).
  Future<void> processUserInput(String input) async {
    // فعال کردن حالت لودینگ و پاک کردن گزینه‌ها
    _ref.read(isLoadingProvider.notifier).state = true;
    _ref.read(optionsProvider.notifier).state = [];

    // اگر بازی جدید شروع شده، ID فعلی را پاک کن تا یک اسلات جدید ساخته شود
    if (input == "شروع بازی") {
      _currentSlotId = null;
    }

    try {
      final ai = _ref.read(aiServiceProvider);
      final currentStats = _ref.read(statsProvider);
      final worldState = _ref.read(worldStateProvider);
      final inventory = _ref.read(inventoryProvider);
      final config = _ref.read(gameConfigProvider);

      // ارسال پیام به هوش مصنوعی و دریافت پاسخ
      final response = await ai.sendMessage(
          input, currentStats, worldState, inventory, config);

      // آپدیت کردن لاگ داستان و گزینه‌ها
      _ref
          .read(storyLogProvider.notifier)
          .update((state) => [...state, response.storyText]);
      _ref.read(optionsProvider.notifier).state = response.options;

      // اعمال تغییرات وضعیت (اگر وجود داشته باشد)
      if (response.statusUpdates != null) {
        _updateStats(response.statusUpdates!);
      }

      // مدیریت شمارنده نوبت برای خلاصه‌سازی حافظه
      if (input != "شروع بازی") {
        await _handleTurnCounter();
      }

      // تولید تصویر اگر در تنظیمات فعال باشد
      final settingsNotifier = _ref.read(settingsProvider.notifier);
      if (settingsNotifier.isImageGenerationEnabled) {
        // برای جلوگیری از کندی UI، این کار را به صورت غیرهمزمان و جداگانه انجام می‌دهیم
        // اما چون می‌خواهیم نتیجه را نمایش دهیم، شاید بهتر باشد منتظر بمانیم یا یک لودینگ جداگانه داشته باشیم.
        // فعلاً منتظر می‌مانیم تا تصویر آماده شود.
        try {
          final imageUrl = await ai.generateImage(response.storyText);
          if (imageUrl != null) {
            _ref.read(generatedImageProvider.notifier).state = imageUrl;
          }
        } catch (e) {
          developer.log("Error generating image: $e", name: "GameController");
        }
      }

      // ذخیره خودکار بازی بعد از هر نوبت موفق
      await saveGame(id: _currentSlotId);
    } catch (e) {
      // مدیریت خطا و نمایش پیام به کاربر
      _ref
          .read(storyLogProvider.notifier)
          .update((state) => [...state, "خطا: $e"]);
      _ref.read(optionsProvider.notifier).state = ["تلاش مجدد"];
    } finally {
      // غیرفعال کردن حالت لودینگ
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  /// پرسیدن سوال آزاد از راوی (بدون پیش بردن داستان اصلی).
  Future<String> askNarrator(String question) async {
    return await _ref.read(aiServiceProvider).askNarrator(question);
  }

  /// ترکیب آیتم‌های انتخاب شده در کوله‌پشتی.
  Future<CraftingResponse> craftSelectedItems() async {
    final selection = _ref.read(craftingSelectionProvider);
    // بررسی اینکه دقیقاً دو آیتم انتخاب شده باشد
    if (selection.length != 2) {
      return CraftingResponse(
        success: false,
        message: "باید دقیقاً دو آیتم را انتخاب کنید.",
      );
    }

    final item1 = selection[0];
    final item2 = selection[1];

    // درخواست از هوش مصنوعی برای ترکیب آیتم‌ها
    final response =
        await _ref.read(aiServiceProvider).craftItems(item1, item2);

    // اگر ترکیب موفق بود، آیتم جدید را اضافه و آیتم‌های قبلی را حذف کن
    if (response.success && response.newItem != null) {
      _ref.read(inventoryProvider.notifier).update((inv) {
        final newList = List<InventoryItem>.from(inv)
          ..remove(item1)
          ..remove(item2)
          ..add(response.newItem!);
        return newList;
      });
    }
    // پاک کردن انتخاب‌ها
    _ref.read(craftingSelectionProvider.notifier).state = [];
    return response;
  }

  /// شروع یک بازی کاملاً جدید.
  Future<void> startNewGame(GameConfig config) async {
    _currentSlotId = null; // پاک کردن ID برای ایجاد اسلات جدید

    // ذخیره تنظیمات بازی
    _ref.read(gameConfigProvider.notifier).state = config;

    // ریست کردن تمام وضعیت‌ها به حالت اولیه
    _ref.read(statsProvider.notifier).state = const GameStats();

    // تنظیم آیتم‌های اولیه بر اساس انتخاب کاربر
    // نکته: در اینجا فرض می‌کنیم نام آیتم‌ها در GameData با نام‌های انتخاب شده یکی است.
    // در یک پیاده‌سازی واقعی‌تر، باید آیتم‌ها را از GameData پیدا کنیم.
    final initialItems = config.selectedItems.map((itemName) {
      // جستجوی توضیحات آیتم (فعلاً یک توضیح پیش‌فرض می‌گذاریم)
      return InventoryItem(name: itemName, description: "آیتم شروع بازی");
    }).toList();

    _ref.read(inventoryProvider.notifier).state = initialItems;

    // تنظیم متن شروع بازی
    final startText = config.startingScenario.isNotEmpty
        ? config.startingScenario
        : "به جهان ${config.worldName} خوش آمدید. شما یک ${config.characterClass} هستید. ماجراجویی آغاز می‌شود...";

    _ref.read(storyLogProvider.notifier).state = [startText];
    _ref.read(optionsProvider.notifier).state = ["شروع بازی"];
    _ref.read(turnCounterProvider.notifier).state = 0;
  }

  /// ادامه آخرین بازی ذخیره شده.
  /// این متد لیست ذخیره‌ها را می‌گیرد و جدیدترین آن‌ها را بارگذاری می‌کند.
  Future<void> continueLastGame() async {
    final db = _ref.read(dbServiceProvider);
    final slots = await db.getAllSaveSlots();

    if (slots.isNotEmpty) {
      // چون getAllSaveSlots مرتب شده است، اولین آیتم جدیدترین است.
      final lastSave = slots.first;
      if (lastSave.id != null) {
        await loadGame(lastSave.id!);
      }
    }
  }

  /// ذخیره وضعیت فعلی بازی در دیتابیس.
  /// اگر `id` داده شود، روی همان اسلات ذخیره می‌کند (آپدیت)، در غیر این صورت اسلات جدید می‌سازد.
  Future<void> saveGame({int? id}) async {
    final db = _ref.read(dbServiceProvider);
    final currentStats = _ref.read(statsProvider);
    final currentInventory = _ref.read(inventoryProvider);
    final currentStoryLog = _ref.read(storyLogProvider);

    // ساخت آبجکت ذخیره
    final slot = SaveSlot(
      saveDate: DateTime.now(),
      storyLog: currentStoryLog,
      stats: GameStatsDB(
        health: currentStats.health,
        sanity: currentStats.sanity,
        hunger: currentStats.hunger,
        energy: currentStats.energy,
      ),
      inventoryItems: currentInventory
          .map(
            (item) =>
                InventoryItemDB(name: item.name, description: item.description),
          )
          .toList(),
    );

    if (id != null) {
      slot.id = id;
    }

    // ذخیره در دیتابیس
    await db.saveGame(slot);

    // به‌روزرسانی ID فعلی پس از ذخیره (برای ذخیره‌های بعدی)
    if (slot.id != null) {
      _currentSlotId = slot.id;
    }

    // رفرش کردن لیست ذخیره‌ها در UI
    _ref.invalidate(saveSlotsProvider);
  }

  /// بارگذاری بازی از یک اسلات مشخص.
  Future<void> loadGame(int id) async {
    final db = _ref.read(dbServiceProvider);
    final slot = await db.loadGame(id);

    if (slot != null) {
      _currentSlotId = id; // تنظیم ID فعلی برای ادامه بازی روی همین اسلات

      // بازیابی وضعیت‌ها از دیتابیس
      _ref.read(statsProvider.notifier).state = GameStats(
        health: slot.stats?.health ?? 100,
        sanity: slot.stats?.sanity ?? 100,
        hunger: slot.stats?.hunger ?? 100,
        energy: slot.stats?.energy ?? 100,
      );
      _ref.read(inventoryProvider.notifier).state = slot.inventoryItems
          .map(
            (item) =>
                InventoryItem(name: item.name, description: item.description),
          )
          .toList();
      _ref.read(storyLogProvider.notifier).state = slot.storyLog;
      // اگر آخرین پیام هوش مصنوعی گزینه‌ای نداشت، یک گزینه پیش‌فرض بگذار
      _ref.read(optionsProvider.notifier).state = ["ادامه ماجراجویی"];
      _ref.read(turnCounterProvider.notifier).state = 0;
    }
  }

  /// حذف یک اسلات ذخیره.
  Future<void> deleteGame(int id) async {
    final db = _ref.read(dbServiceProvider);
    await db.deleteSaveSlot(id);

    // اگر اسلات فعلی حذف شد، ID فعلی را پاک کن تا ذخیره بعدی در اسلات جدید باشد
    if (_currentSlotId == id) {
      _currentSlotId = null;
    }
    _ref.invalidate(saveSlotsProvider);
  }

  /// به‌روزرسانی وضعیت‌های بازیکن بر اساس پاسخ هوش مصنوعی.
  void _updateStats(Map<String, dynamic> updates) {
    _ref.read(statsProvider.notifier).update(
          (s) => s.copyWith(
            health: _calculateNewStat(s.health, updates['health']),
            sanity: _calculateNewStat(s.sanity, updates['sanity']),
            hunger: _calculateNewStat(s.hunger, updates['hunger']),
            energy: _calculateNewStat(s.energy, updates['energy']),
          ),
        );
  }

  /// محاسبه مقدار جدید یک وضعیت با محدود کردن بین ۰ تا ۱۰۰.
  int _calculateNewStat(int currentValue, dynamic change) {
    if (change is int) {
      return (currentValue + change).clamp(0, 100);
    }
    return currentValue;
  }

  /// مدیریت شمارنده نوبت و خلاصه‌سازی خودکار تاریخچه.
  Future<void> _handleTurnCounter() async {
    final currentTurn = _ref.read(turnCounterProvider.notifier).state + 1;
    if (currentTurn >= summarizationThreshold) {
      // اگر به حد نصاب رسید، درخواست خلاصه‌سازی بده
      await _ref.read(aiServiceProvider).summarizeAndResetHistory();
      _ref.read(turnCounterProvider.notifier).state = 0;
    } else {
      _ref.read(turnCounterProvider.notifier).state = currentTurn;
    }
  }
}
