// مدل‌های داده برای وضعیت و پاسخ بازی
import 'package:equatable/equatable.dart';

/// مدل نگهدارنده تمام آمارهای حیاتی بازیکن.
///
/// این کلاس Immutable (غیرقابل تغییر) است، یعنی برای تغییر مقدار باید یک نمونه جدید با `copyWith` بسازید.
/// از `Equatable` ارث‌بری می‌کند تا مقایسه دو آبجکت بر اساس مقادیر فیلدها انجام شود نه آدرس حافظه.
class GameStats extends Equatable {
  final int health; // سلامتی
  final int sanity; // سلامت روان
  final int hunger; // گرسنگی
  final int energy; // انرژی
  final int thirst; // تشنگی
  final int fatigue; // خستگی
  final int morale; // روحیه
  final int xp; // تجربه
  final int level; // سطح

  const GameStats({
    this.health = 100,
    this.sanity = 100,
    this.hunger = 100,
    this.energy = 100,
    this.thirst = 100,
    this.fatigue = 0,
    this.morale = 100,
    this.xp = 0,
    this.level = 1,
  });

  /// متدی برای کپی کردن آبجکت فعلی و تغییر مقادیر دلخواه.
  /// اگر مقداری پاس داده نشود، از مقدار فعلی استفاده می‌شود.
  GameStats copyWith({
    int? health,
    int? sanity,
    int? hunger,
    int? energy,
    int? thirst,
    int? fatigue,
    int? morale,
    int? xp,
    int? level,
  }) {
    return GameStats(
      health: health ?? this.health,
      sanity: sanity ?? this.sanity,
      hunger: hunger ?? this.hunger,
      energy: energy ?? this.energy,
      thirst: thirst ?? this.thirst,
      fatigue: fatigue ?? this.fatigue,
      morale: morale ?? this.morale,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }

  /// تبدیل آبجکت به فرمت JSON برای ارسال به API.
  Map<String, int> toJson() => {
        'health': health,
        'sanity': sanity,
        'hunger': hunger,
        'energy': energy,
        'thirst': thirst,
        'fatigue': fatigue,
        'morale': morale,
        'xp': xp,
        'level': level,
      };

  @override
  List<Object?> get props => [
        health,
        sanity,
        hunger,
        energy,
        thirst,
        fatigue,
        morale,
        xp,
        level,
      ];
}

/// مدلی برای پارس کردن پاسخ JSON دریافتی از هوش مصنوعی (Gemini).
/// شامل متن داستان، گزینه‌های انتخابی و تغییرات وضعیت بازیکن است.
class GameResponse {
  final String storyText;
  final List<String> options;
  final Map<String, dynamic>? statusUpdates;
  final List<String>? newSkills;
  final List<String>? newMissions;
  final List<String>? completedMissions;
  final List<Map<String, dynamic>>? sceneEntities;
  final List<Map<String, dynamic>>? mapUpdates;

  GameResponse({
    required this.storyText,
    required this.options,
    this.statusUpdates,
    this.newSkills,
    this.newMissions,
    this.completedMissions,
    this.sceneEntities,
    this.mapUpdates,
  });

  /// متد Factory برای ساختن نمونه از روی یک نقشه (Map) JSON.
  /// این متد داده‌های خام دریافتی از API را به آبجکت دارت تبدیل می‌کند.
  factory GameResponse.fromJson(Map<String, dynamic> json) {
    return GameResponse(
      storyText: json['story_text'] ?? 'داستان یافت نشد.',
      options: List<String>.from(json['options'] ?? []),
      statusUpdates: json['status_updates'] as Map<String, dynamic>?,
      newSkills: json['new_skills'] != null
          ? List<String>.from(json['new_skills'])
          : null,
      newMissions: json['new_missions'] != null
          ? List<String>.from(json['new_missions'])
          : null,
      completedMissions: json['completed_missions'] != null
          ? List<String>.from(json['completed_missions'])
          : null,
      sceneEntities: json['scene_entities'] != null
          ? List<Map<String, dynamic>>.from(json['scene_entities'])
          : null,
      mapUpdates: json['map_updates'] != null
          ? List<Map<String, dynamic>>.from(json['map_updates'])
          : null,
    );
  }
}

// -------------- مدل‌های مربوط به Crafting (ساخت و ساز) --------------

/// نمایانگر یک آیتم در کوله‌پشتی بازیکن.
class InventoryItem extends Equatable {
  final String name;
  final String description;

  const InventoryItem({required this.name, required this.description});

  @override
  List<Object?> get props =>
      [name]; // نام آیتم یونیک است و برای مقایسه استفاده می‌شود
}

/// پاسخی که از هوش مصنوعی برای درخواست ترکیب آیتم‌ها دریافت می‌شود.
class CraftingResponse {
  final bool success; // آیا ترکیب موفق بود؟
  final InventoryItem? newItem; // آیتم جدید ساخته شده (در صورت موفقیت)
  final String message; // پیام توضیحی برای نمایش به کاربر

  CraftingResponse({
    required this.success,
    this.newItem,
    required this.message,
  });

  /// تبدیل JSON دریافتی از هوش مصنوعی به آبجکت CraftingResponse.
  factory CraftingResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    InventoryItem? item;

    // اگر موفق بود و آیتم جدیدی تعریف شده بود، آن را بساز
    if (success && json['new_item'] != null) {
      item = InventoryItem(
        name: json['new_item']['name'] ?? 'آیتم بی‌نام',
        description: json['new_item']['description'] ?? 'توضیحات نامشخص',
      );
    }

    return CraftingResponse(
      success: success,
      newItem: item,
      message: json['message'] as String? ??
          (success ? 'ترکیب موفقیت‌آمیز بود!' : 'هیچ اتفاقی نیفتاد.'),
    );
  }
}

// -------------- تنظیمات و وضعیت جهان بازی --------------

/// تنظیمات اولیه بازی که از ویزارد دریافت می‌شود.
class GameConfig {
  final String worldName;
  final String genre;
  final String difficulty;
  final String narratorStyle;
  final String characterName;
  final String characterClass;
  final List<String> selectedItems;
  final String startingScenario;

  GameConfig({
    required this.worldName,
    required this.genre,
    required this.difficulty,
    required this.narratorStyle,
    required this.characterName,
    required this.characterClass,
    required this.selectedItems,
    required this.startingScenario,
  });
}

/// وضعیت کلی جهان بازی شامل زمان و آب‌وهوا.
class WorldState extends Equatable {
  final String timeOfDay; // صبح، ظهر، عصر، شب
  final String weather; // آفتابی، بارانی، طوفانی و ...
  final int dayCount; // روز چندم ماجراجویی

  const WorldState({
    this.timeOfDay = 'صبح',
    this.weather = 'آفتابی',
    this.dayCount = 1,
  });

  WorldState copyWith({
    String? timeOfDay,
    String? weather,
    int? dayCount,
  }) {
    return WorldState(
      timeOfDay: timeOfDay ?? this.timeOfDay,
      weather: weather ?? this.weather,
      dayCount: dayCount ?? this.dayCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'timeOfDay': timeOfDay,
        'weather': weather,
        'dayCount': dayCount,
      };

  factory WorldState.fromJson(Map<String, dynamic> json) {
    return WorldState(
      timeOfDay: json['timeOfDay'] ?? 'صبح',
      weather: json['weather'] ?? 'آفتابی',
      dayCount: json['dayCount'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [timeOfDay, weather, dayCount];
}
