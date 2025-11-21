// مدل‌های داده برای وضعیت و پاسخ بازی
import 'package:equatable/equatable.dart';

// نگهدارنده تمام آمارهای بازیکن
class GameStats extends Equatable {
  final int health;
  final int sanity;
  final int hunger;
  final int energy;

  const GameStats({
    this.health = 100,
    this.sanity = 100,
    this.hunger = 100,
    this.energy = 100,
  });

  // متدی برای کپی کردن و تغییر مقادیر (Immutable)
  GameStats copyWith({
    int? health,
    int? sanity,
    int? hunger,
    int? energy,
  }) {
    return GameStats(
      health: health ?? this.health,
      sanity: sanity ?? this.sanity,
      hunger: hunger ?? this.hunger,
      energy: energy ?? this.energy,
    );
  }

  Map<String, int> toJson() => {
        'health': health,
        'sanity': sanity,
        'hunger': hunger,
        'energy': energy,
      };

  @override
  List<Object?> get props => [health, sanity, hunger, energy];
}

// مدلی برای پارس کردن پاسخ JSON از Gemini
class GameResponse {
  final String storyText;
  final List<String> options;
  final Map<String, dynamic>? statusUpdates;

  GameResponse({
    required this.storyText,
    required this.options,
    this.statusUpdates,
  });

  // متد Factory برای ساختن نمونه از روی یک نقشه (Map) JSON
  factory GameResponse.fromJson(Map<String, dynamic> json) {
    return GameResponse(
      storyText: json['story_text'] ?? 'داستان یافت نشد.',
      options: List<String>.from(json['options'] ?? []),
      statusUpdates: json['status_updates'] as Map<String, dynamic>?,
    );
  }
}

// -------------- مدل‌های مربوط به Crafting --------------

/// نمایانگر یک آیتم در کوله‌پشتی بازیکن
class InventoryItem extends Equatable {
  final String name;
  final String description;

  const InventoryItem({required this.name, required this.description});

  @override
  List<Object?> get props => [name]; // نام آیتم یونیک است
}

/// پاسخی که از AI برای درخواست ترکیب آیتم‌ها دریافت می‌شود
class CraftingResponse {
  final bool success;
  final InventoryItem? newItem;
  final String message;

  CraftingResponse({
    required this.success,
    this.newItem,
    required this.message,
  });

  factory CraftingResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    InventoryItem? item;
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
