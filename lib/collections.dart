import 'package:isar/isar.dart';

part 'collections.g.dart'; // این خط برای ساخت فایل توسط build_runner ضروری است

@collection
class SaveSlot {
  Id id = Isar.autoIncrement; // شناسه منحصر به فرد برای هر اسلات ذخیره

  DateTime saveDate; // تاریخ و زمان ذخیره

  // لاگ داستان به صورت لیستی از رشته‌ها ذخیره می‌شود
  List<String> storyLog;

  // آمار بازی به صورت یک شیء جاسازی شده (Embedded)
  GameStatsDB? stats;

  // آیتم‌های کوله‌پشتی به صورت لیستی از اشیاء جاسازی شده
  List<InventoryItemDB> inventoryItems;

  SaveSlot({
    required this.saveDate,
    required this.storyLog,
    this.stats,
    required this.inventoryItems,
  });
}

@embedded
class GameStatsDB {
  int health;
  int sanity;
  int hunger;
  int energy;

  GameStatsDB({
    this.health = 100,
    this.sanity = 100,
    this.hunger = 100,
    this.energy = 100,
  });
}

@embedded
class InventoryItemDB {
  String name;
  String description;

  InventoryItemDB({
    this.name = '',
    this.description = '',
  });
}
