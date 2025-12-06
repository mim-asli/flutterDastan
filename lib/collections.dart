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
}
