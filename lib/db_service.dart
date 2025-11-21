import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myapp/collections.dart';

class DBService {
  late Future<Isar> db;

  DBService() {
    db = _initDB();
  }

  Future<Isar> _initDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [SaveSlotSchema], // Schemaهای ما در اینجا قرار می‌گیرند
        directory: dir.path,
        inspector: true, // برای دیباگ کردن دیتابیس در مرورگر
      );
    }
    return Future.value(Isar.getInstance());
  }

  /// یک اسلات ذخیره جدید ایجاد می‌کند یا یک اسلات موجود را آپدیت می‌کند
  Future<void> saveGame(SaveSlot slot) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.saveSlots.put(slot);
    });
  }

  /// یک اسلات ذخیره را با استفاده از ID آن بارگذاری می‌کند
  Future<SaveSlot?> loadGame(int id) async {
    final isar = await db;
    return await isar.saveSlots.get(id);
  }

  /// تمام اسلات‌های ذخیره شده را برمی‌گرداند (مرتب شده بر اساس جدیدترین)
  Future<List<SaveSlot>> getAllSaveSlots() async {
    final isar = await db;
    return await isar.saveSlots.where().sortBySaveDateDesc().findAll();
  }

  /// یک اسلات ذخیره را با ID آن حذف می‌کند
  Future<void> deleteSaveSlot(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.saveSlots.delete(id);
    });
  }

  /// تمام داده های دیتابیس را پاک میکند
  Future<void> clearDatabase() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
