import 'package:hive/hive.dart';

part 'collections.g.dart';

/// مدل ذخیره‌سازی کل وضعیت بازی در دیتابیس Hive.
///
/// این کلاس تمام اطلاعات لازم برای بازیابی یک بازی ذخیره شده را نگه می‌دارد.
/// از `HiveObject` ارث‌بری می‌کند تا قابلیت‌های ذخیره و حذف مستقیم را داشته باشد.
@HiveType(typeId: 0)
class SaveSlot extends HiveObject {
  /// شناسه منحصر به فرد اسلات.
  /// اگر null باشد، یعنی هنوز در دیتابیس ذخیره نشده است.
  @HiveField(0)
  int? id;

  /// تاریخ و زمان ذخیره بازی.
  @HiveField(1)
  DateTime saveDate;

  /// تاریخچه کامل متن داستان (لاگ بازی).
  @HiveField(2)
  List<String> storyLog;

  /// وضعیت‌های بازیکن (سلامتی، انرژی و ...) در لحظه ذخیره.
  @HiveField(3)
  GameStatsDB? stats;

  /// لیست آیتم‌های موجود در کوله‌پشتی بازیکن در لحظه ذخیره.
  @HiveField(4)
  List<InventoryItemDB> inventoryItems;

  SaveSlot({
    this.id,
    required this.saveDate,
    required this.storyLog,
    this.stats,
    required this.inventoryItems,
  });

  Map<String, dynamic> toJson() => {
        'version': '1.0',
        'id': id,
        'saveDate': saveDate.toIso8601String(),
        'storyLog': storyLog,
        'stats': stats?.toJson(),
        'inventoryItems': inventoryItems.map((item) => item.toJson()).toList(),
      };

  factory SaveSlot.fromJson(Map<String, dynamic> json) {
    return SaveSlot(
      id: json['id'],
      saveDate: DateTime.parse(json['saveDate']),
      storyLog: List<String>.from(json['storyLog'] ?? []),
      stats: json['stats'] != null ? GameStatsDB.fromJson(json['stats']) : null,
      inventoryItems: (json['inventoryItems'] as List?)
              ?.map((item) => InventoryItemDB.fromJson(item))
              .toList() ??
          [],
    );
  }
}

/// مدل دیتابیس برای وضعیت‌های بازیکن.
///
/// این کلاس جدا از `GameStats` در `models.dart` است تا ساختار دیتابیس مستقل از منطق برنامه باشد.
@HiveType(typeId: 1)
class GameStatsDB {
  @HiveField(0)
  int health;

  @HiveField(1)
  int sanity;

  @HiveField(2)
  int hunger;

  @HiveField(3)
  int energy;

  GameStatsDB({
    this.health = 100,
    this.sanity = 100,
    this.hunger = 100,
    this.energy = 100,
  });

  Map<String, dynamic> toJson() => {
        'health': health,
        'sanity': sanity,
        'hunger': hunger,
        'energy': energy,
      };

  factory GameStatsDB.fromJson(Map<String, dynamic> json) {
    return GameStatsDB(
      health: json['health'] ?? 100,
      sanity: json['sanity'] ?? 100,
      hunger: json['hunger'] ?? 100,
      energy: json['energy'] ?? 100,
    );
  }
}

/// مدل دیتابیس برای آیتم‌های کوله‌پشتی.
@HiveType(typeId: 2)
class InventoryItemDB {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  InventoryItemDB({
    this.name = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  factory InventoryItemDB.fromJson(Map<String, dynamic> json) {
    return InventoryItemDB(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
