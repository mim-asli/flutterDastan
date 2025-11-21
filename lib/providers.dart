import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/collections.dart';
import 'package:myapp/db_service.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers/settings_provider.dart';
import 'package:myapp/services/base_ai_service.dart';
import 'package:myapp/services/cloud_ai_service.dart'; // مسیر وارد کردن به‌روز شد
import 'package:myapp/services/local_ai_service.dart';
import 'package:myapp/services/stt_service.dart';
import 'package:myapp/services/tts_service.dart';

// ------------------- سرویس‌ها -------------------

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
      return LocalAIService(); // سرویس محلی را ایجاد کن
    case AiProviderType.cloud:
      final apiKey = settings.cloudApiKey;
      if (apiKey.isEmpty || apiKey == "gen-lang-client-0157950363") {
        throw Exception(
            'کلید API ابری در صفحه تنظیمات وارد نشده است. لطفاً کلید خود را وارد کنید.');
      }
      return CloudAIService(apiKey); // سرویس ابری را با کلید API ایجاد کن
  }
});


/// Provider برای سرویس دیتابیس Isar.
final dbServiceProvider = Provider((ref) => DBService());

/// Provider برای سرویس Text-to-Speech (خواندن متن).
final ttsServiceProvider = Provider<TtsService>((ref) {
  final ttsService = TtsService();
  ttsService.init(); 
  ref.onDispose(() => ttsService.dispose());
  return ttsService;
});

/// Provider برای سرویس Speech-to-Text (تشخیص گفتار).
final sttServiceProvider = Provider<SttService>((ref) {
  final sttService = SttService();
  ref.onDispose(() => sttService.dispose());
  return sttService;
});

// ------------------- وضعیت‌های UI -------------------

final isLoadingProvider = StateProvider<bool>((ref) => false);
final optionsProvider = StateProvider<List<String>>((ref) => ["شروع بازی"]);
final storyLogProvider = StateProvider<List<String>>(
    (ref) => ["به اعماق ناشناخته خوش آمدید. ماجراجویی خود را آغاز کنید."]);

// ------------------- وضعیت‌های داده‌ای -------------------

final statsProvider = StateProvider<GameStats>((ref) => const GameStats());
final turnCounterProvider = StateProvider<int>((ref) => 0);
const int summarizationThreshold = 5;

// ------------------- وضعیت‌های Crafting -------------------

final inventoryProvider = StateProvider<List<InventoryItem>>((ref) => [
      const InventoryItem(name: "تکه چوب", description: "یک تکه چوب خشک و محکم."),
      const InventoryItem(name: "سنگ تیز", description: "سنگی با لبه‌های برنده."),
      const InventoryItem(name: "طناب کهنه", description: "یک تکه طناب فرسوده ولی قابل استفاده."),
      const InventoryItem(name: "کنسرو لوبیا", description: "یک وعده غذایی فراموش شده."),
    ]);

final craftingSelectionProvider =
    StateProvider<List<InventoryItem>>((ref) => []);

// ------------------- وضعیت‌های سیستم ذخیره -------------------

final saveSlotsProvider = FutureProvider<List<SaveSlot>>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return db.getAllSaveSlots();
});

// ------------------- کنترلر اصلی بازی -------------------

final gameControllerProvider =
    StateNotifierProvider<GameController, void>((ref) {
  return GameController(ref);
});


class GameController extends StateNotifier<void> {
  final Ref _ref;

  GameController(this._ref) : super(null);

  Future<void> processUserInput(String input) async {
    _ref.read(isLoadingProvider.notifier).state = true;
    _ref.read(optionsProvider.notifier).state = [];
    try {
      final ai = _ref.read(aiServiceProvider);
      final response = await ai.sendMessage(input, _ref.read(statsProvider));
      _ref
          .read(storyLogProvider.notifier)
          .update((state) => [...state, response.storyText]);
      _ref.read(optionsProvider.notifier).state = response.options;
      if (response.statusUpdates != null) {
        _updateStats(response.statusUpdates!);
      }
      if (input != "شروع بازی") {
        await _handleTurnCounter();
      }
    } catch (e) {
      _ref
          .read(storyLogProvider.notifier)
          .update((state) => [...state, "خطا: $e"]);
      _ref.read(optionsProvider.notifier).state = ["تلاش مجدد"];
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<String> askNarrator(String question) async {
    return await _ref.read(aiServiceProvider).askNarrator(question);
  }

  Future<CraftingResponse> craftSelectedItems() async {
    final selection = _ref.read(craftingSelectionProvider);
    if (selection.length != 2) {
      return CraftingResponse(
          success: false, message: "باید دقیقاً دو آیتم را انتخاب کنید.");
    }

    final item1 = selection[0];
    final item2 = selection[1];
    final response =
        await _ref.read(aiServiceProvider).craftItems(item1, item2);

    if (response.success && response.newItem != null) {
      _ref.read(inventoryProvider.notifier).update((inv) {
        final newList = List<InventoryItem>.from(inv)
          ..remove(item1)
          ..remove(item2)
          ..add(response.newItem!);
        return newList;
      });
    }
    _ref.read(craftingSelectionProvider.notifier).state = [];
    return response;
  }

  Future<void> saveGame({int? id}) async {
    final db = _ref.read(dbServiceProvider);
    final currentStats = _ref.read(statsProvider);
    final currentInventory = _ref.read(inventoryProvider);
    final currentStoryLog = _ref.read(storyLogProvider);

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
          .map((item) =>
              InventoryItemDB(name: item.name, description: item.description))
          .toList(),
    );

    if (id != null) {
      slot.id = id;
    }

    await db.saveGame(slot);
    _ref.invalidate(saveSlotsProvider); 
  }

  Future<void> loadGame(int id) async {
    final db = _ref.read(dbServiceProvider);
    final slot = await db.loadGame(id);

    if (slot != null) {
      _ref.read(statsProvider.notifier).state = GameStats(
        health: slot.stats?.health ?? 100,
        sanity: slot.stats?.sanity ?? 100,
        hunger: slot.stats?.hunger ?? 100,
        energy: slot.stats?.energy ?? 100,
      );
      _ref.read(inventoryProvider.notifier).state = slot.inventoryItems
          .map((item) =>
              InventoryItem(name: item.name, description: item.description))
          .toList();
      _ref.read(storyLogProvider.notifier).state = slot.storyLog;
      _ref.read(optionsProvider.notifier).state = ["ادامه ماجراجویی"];
      _ref.read(turnCounterProvider.notifier).state = 0;
    }
  }

  Future<void> deleteGame(int id) async {
    final db = _ref.read(dbServiceProvider);
    await db.deleteSaveSlot(id);
    _ref.invalidate(saveSlotsProvider); 
  }

  void _updateStats(Map<String, dynamic> updates) {
    _ref.read(statsProvider.notifier).update((s) => s.copyWith(
          health: _calculateNewStat(s.health, updates['health']),
          sanity: _calculateNewStat(s.sanity, updates['sanity']),
          hunger: _calculateNewStat(s.hunger, updates['hunger']),
          energy: _calculateNewStat(s.energy, updates['energy']),
        ));
  }

  int _calculateNewStat(int currentValue, dynamic change) {
    if (change is int) {
      return (currentValue + change).clamp(0, 100);
    }
    return currentValue;
  }

  Future<void> _handleTurnCounter() async {
    final currentTurn = _ref.read(turnCounterProvider.notifier).state + 1;
    if (currentTurn >= summarizationThreshold) {
      await _ref.read(aiServiceProvider).summarizeAndResetHistory();
      _ref.read(turnCounterProvider.notifier).state = 0; 
    } else {
      _ref.read(turnCounterProvider.notifier).state = currentTurn;
    }
  }
}
