import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/collections.dart';

/// سرویس مدیریت دیتابیس با استفاده از Hive.
///
/// این کلاس مسئول تمام عملیات ذخیره، بازیابی، به‌روزرسانی و حذف داده‌های بازی است.
/// از Hive استفاده می‌کند که یک دیتابیس NoSQL سریع و سبک است و با وب سازگاری کامل دارد.
class DBService {
  late Future<Box<SaveSlot>> _boxFuture;

  DBService() {
    _boxFuture = _initDB();
  }

  /// مقداردهی اولیه دیتابیس Hive و ثبت آداپتورها.
  Future<Box<SaveSlot>> _initDB() async {
    // راه‌اندازی Hive برای فلاتر
    await Hive.initFlutter();

    // ثبت آداپتورهای مدل‌های داده‌ای برای اینکه Hive بداند چطور آن‌ها را ذخیره کند.
    // بررسی می‌کنیم که آداپتور قبلاً ثبت نشده باشد تا از خطا جلوگیری کنیم.
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SaveSlotAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GameStatsDBAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(InventoryItemDBAdapter());
    }

    // باز کردن جعبه (Box) مربوط به اسلات‌های ذخیره.
    // در Hive، داده‌ها در Box ذخیره می‌شوند که شبیه به جدول در SQL است.
    return await Hive.openBox<SaveSlot>('save_slots');
  }

  /// یک اسلات ذخیره جدید ایجاد می‌کند یا یک اسلات موجود را آپدیت می‌کند.
  ///
  /// [slot]: آبجکت اسلات ذخیره که باید ذخیره شود.
  Future<void> saveGame(SaveSlot slot) async {
    final box = await _boxFuture;

    if (slot.isInBox) {
      // اگر اسلات قبلاً در باکس باشد (یعنی قبلاً ذخیره شده)، فقط تغییرات را ذخیره می‌کنیم.
      await slot.save();
    } else if (slot.id != null) {
      // اگر اسلات ID دارد اما در باکس نیست (مثلاً دستی ساخته شده با ID مشخص)،
      // آن را با همان ID در باکس قرار می‌دهیم (آپدیت یا درج با ID خاص).
      await box.put(slot.id, slot);
    } else {
      // اگر اسلات جدید است و ID ندارد، آن را به باکس اضافه می‌کنیم.
      // Hive خودکار یک ID یکتا تولید می‌کند.
      final key = await box.add(slot);
      slot.id = key; // ID تولید شده را به اسلات اختصاص می‌دهیم
      await slot.save(); // دوباره ذخیره می‌کنیم تا ID هم ذخیره شود
    }
  }

  /// یک اسلات ذخیره را با استفاده از ID آن بارگذاری می‌کند.
  Future<SaveSlot?> loadGame(int id) async {
    final box = await _boxFuture;
    return box.get(id);
  }

  /// تمام اسلات‌های ذخیره شده را برمی‌گرداند.
  /// لیست خروجی بر اساس تاریخ ذخیره (از جدید به قدیم) مرتب می‌شود.
  Future<List<SaveSlot>> getAllSaveSlots() async {
    final box = await _boxFuture;
    final slots = box.values.toList();
    // مرتب‌سازی بر اساس تاریخ ذخیره (نزولی)
    slots.sort((a, b) => b.saveDate.compareTo(a.saveDate));
    return slots;
  }

  /// یک اسلات ذخیره را با ID آن حذف می‌کند.
  Future<void> deleteSaveSlot(int id) async {
    final box = await _boxFuture;
    await box.delete(id);
  }

  /// تمام داده‌های دیتابیس را پاک می‌کند (برای تست یا ریست کامل).
  Future<void> clearDatabase() async {
    final box = await _boxFuture;
    await box.clear();
  }

  /// صادرات یک اسلات ذخیره به فرمت JSON.
  /// [id]: شناسه اسلات مورد نظر
  /// خروجی: رشته JSON که می‌تواند در فایل ذخیره شود
  Future<String> exportSaveSlotToJson(int id) async {
    final slot = await loadGame(id);
    if (slot == null) {
      throw Exception('اسلات با شناسه $id یافت نشد.');
    }
    final jsonMap = slot.toJson();
    return jsonEncode(jsonMap);
  }

  /// وارد کردن یک اسلات ذخیره از رشته JSON.
  /// [jsonString]: رشته JSON حاوی اطلاعات بازی
  /// خروجی: اسلات ذخیره شده جدید با ID تولید شده
  Future<SaveSlot> importSaveSlotFromJson(String jsonString) async {
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final slot = SaveSlot.fromJson(jsonMap);

      // ID را null می‌کنیم تا Hive یک ID جدید تولید کند
      slot.id = null;

      await saveGame(slot);
      return slot;
    } catch (e) {
      throw Exception('خطا در پارس کردن JSON: $e');
    }
  }
}
