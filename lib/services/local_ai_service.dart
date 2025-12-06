import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:myapp/models.dart';
import 'package:myapp/services/base_ai_service.dart';

/// این کلاس، پیاده‌سازی "محلی" سرویس هوش مصنوعی است.
///
/// این کلاس مسئول ارتباط با یک سرور هوش مصنوعی محلی است که از طریق ابزاری
/// مانند LM Studio اجرا می‌شود. این سرور API سازگار با OpenAI را شبیه‌سازی می‌کند.
/// این کلاس برای توسعه و تست آفلاین بسیار مفید است و نیازی به اینترنت ندارد.
class LocalAIService implements BaseAIService {
  /// آدرس پایه سرور LM Studio (مثلاً http://localhost:1234/v1).
  final String _baseUrl;

  /// نام دقیق مدلی که در LM Studio بارگذاری شده است.
  /// این نام باید دقیقاً با نام مدل در سرور محلی یکی باشد.
  final String _modelName = "gemma-3-4b-persian-v0";

  /// تاریخچه مکالمه با مدل که برای حفظ زمینه داستان استفاده می‌شود.
  /// برخلاف سرویس ابری که خودش تاریخچه را مدیریت می‌کند، اینجا باید دستی مدیریت کنیم.
  List<Map<String, String>> _chatHistory = [];

  LocalAIService(this._baseUrl) {
    _resetChatHistory();
  }

  @visibleForTesting
  String get baseUrl => _baseUrl;

  /// ریست کردن تاریخچه چت به حالت اولیه (فقط دستورالعمل سیستم).
  void _resetChatHistory() {
    _chatHistory = [
      {"role": "system", "content": _systemInstruction},
    ];
  }

  /// ارسال پیام کاربر و وضعیت فعلی بازی به سرور محلی.
  @override
  Future<GameResponse> sendMessage(
      String userMessage,
      GameStats currentStats,
      WorldState worldState,
      List<InventoryItem> inventory,
      GameConfig? config) async {
    // ساخت کانتکست تنظیمات بازی
    String configContext = "";
    if (config != null) {
      configContext = '''
      Game Config:
      - World: ${config.worldName}
      - Genre: ${config.genre}
      - Character: ${config.characterName} (${config.characterClass})
      - Narrator Style: ${config.narratorStyle}
      ''';
    }

    // ساخت پیام کامل شامل انتخاب کاربر و وضعیت فعلی به فرمت JSON
    String fullUserMessage = '''
    $configContext
    Current World State: ${jsonEncode(worldState.toJson())}
    Player Stats: ${jsonEncode(currentStats.toJson())}
    Player Inventory: ${jsonEncode(inventory.map((e) => e.name).toList())}
    
    User Action: "$userMessage"
    
    (یادت باشد خروجی فقط و فقط باید یک JSON معتبر باشد و هیچ متنی قبل یا بعد از آن ننویسی.)
    ''';

    // اضافه کردن پیام کاربر به تاریخچه
    _chatHistory.add({"role": "user", "content": fullUserMessage});

    try {
      // ارسال درخواست POST به اندپوینت chat/completions سرور محلی
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "model": _modelName,
              "messages": _chatHistory,
              "temperature": 0.7, // میزان خلاقیت مدل
              "max_tokens": 1000, // حداکثر طول پاسخ
              "stream": false,
            }),
          )
          .timeout(const Duration(
              seconds: 60)); // تایم‌اوت برای جلوگیری از قفل شدن برنامه

      if (response.statusCode == 200) {
        // دیکد کردن پاسخ UTF-8 (برای پشتیبانی از فارسی)
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String aiContent = data['choices'][0]['message']['content'];

        // اضافه کردن پاسخ هوش مصنوعی به تاریخچه
        _chatHistory.add({"role": "assistant", "content": aiContent});

        // تمیز کردن رشته JSON (حذف متون اضافی احتمالی قبل و بعد از JSON)
        final cleanedJsonString = _cleanJsonString(aiContent);

        // پارس کردن JSON نهایی به آبجکت GameResponse
        final jsonResponse = jsonDecode(cleanedJsonString);
        return GameResponse.fromJson(jsonResponse);
      } else {
        developer.log(
          'سرور محلی با کد خطا پاسخ داد: ',
          name: 'LocalAIService',
          error: "${response.statusCode} - ${response.body}",
        );
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      developer.log(
        "خطا در ارتباط با سرور محلی AI",
        name: 'LocalAIService',
        error: e,
        stackTrace: stackTrace,
      );
      // بازگرداندن یک پاسخ خطا به کاربر به جای کرش کردن برنامه
      return GameResponse(
        storyText:
            "ارتباط با سرور محلی برقرار نشد. آیا LM Studio در حال اجرا و سرور آن فعال است؟\n\nخطا: $e",
        options: ["تلاش مجدد"],
      );
    }
  }

  /// متدی کمکی برای استخراج JSON خالص از متن پاسخ مدل.
  /// گاهی مدل‌های محلی توضیحات اضافی قبل یا بعد از JSON چاپ می‌کنند که باعث خطا می‌شود.
  String _cleanJsonString(String rawText) {
    int startIndex = rawText.indexOf('{');
    int endIndex = rawText.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return rawText.substring(startIndex, endIndex + 1);
    }
    return rawText;
  }

  /// پرسیدن سوال از راوی با استفاده از سرور محلی.
  @override
  Future<String> askNarrator(String userQuestion) async {
    // تبدیل تاریخچه به متن ساده برای دادن زمینه به راوی
    final historyAsString =
        _chatHistory.map((c) => '${c["role"]}: ${c["content"]}').join('\n\n');

    final narratorPrompt = '''
    You are the omniscient narrator of a text-based RPG in Persian. The user is stepping out of character to ask you, the narrator, a question about the game world or story.
    Based on the story so far, answer the user's question concisely in Persian. Do not advance the story or give options. Just provide a direct, simple, and informative answer to the question. Do not respond in JSON format, just plain text.

    STORY SO FAR:
    ---
    $historyAsString
    ---

    USER'S QUESTION: "$userQuestion"

    YOUR ANSWER (as the narrator in Persian):
    ''';

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "model": _modelName,
              // برای این درخواست، یک تاریخچه موقت و یکباره می‌سازیم تا در داستان اصلی تداخل ایجاد نکند.
              "messages": [
                {"role": "user", "content": narratorPrompt},
              ],
              "temperature": 0.3, // پاسخ راوی باید دقیق و کم‌خلاقیت باشد
              "max_tokens": 300,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ??
            "راوی در سکوت فرو رفته است.";
      } else {
        return "پاسخ راوی در هیاهوی کیهانی گم شد. (خطای سرور: ${response.statusCode})";
      }
    } catch (e) {
      developer.log(
        "خطا در ارتباط با راوی محلی",
        name: 'LocalAIService.askNarrator',
        error: e,
      );
      return "خطایی در ارتباط با راوی رخ داد. او در حال حاضر پاسخگو نیست.";
    }
  }

  /// سرویس ترکیب آیتم‌ها با استفاده از سرور محلی.
  @override
  Future<CraftingResponse> craftItems(
    InventoryItem item1,
    InventoryItem item2,
  ) async {
    final prompt = '''
    You are a crafting master in a survival RPG. The user wants to combine two items. Based on common sense and survival logic, determine the result.
    The user combines "${item1.name}" and "${item2.name}".

    Your response MUST be a valid JSON object with the following structure. Do not write any text before or after the JSON block.
    {
      "success": <boolean>, // true if crafting is successful, false otherwise
      "new_item": { // The new item if success is true, otherwise null
        "name": "<نام آیتم جدید>",
        "description": "<توضیح کوتاه آیتم جدید>"
      },
      "message": "<یک پیام کوتاه به فارسی برای نمایش به کاربر درباره نتیجه>"
    }

    Examples:
    - User combines "تکه چوب" and "سنگ تیز": { "success": true, "new_item": { "name": "تبر سنگی", "description": "ابزاری ساده برای جمع‌آوری چوب بیشتر."}, "message": "شما یک تبر سنگی ساختید!" }
    - User combines "کنسرو لوبیا" and "سنگ تیز": { "success": true, "new_item": {"name": "کنسرو باز شده", "description": "غذایی آماده خوردن."}, "message": "با سنگ، در کنسرو را باز کردی."} 
    - User combines "چوب" and "طناب کهنه": { "success": false, "new_item": null, "message": "ترکیب چوب و طناب کهنه نتیجه خاصی نداشت." }
    ''';

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "model": _modelName,
              "messages": [
                {"role": "user", "content": prompt},
              ],
              "temperature": 0.2, // نتیجه ترکیب باید قطعی باشد
              "max_tokens": 250,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        final cleanedJson = _cleanJsonString(content);
        final jsonMap = jsonDecode(cleanedJson) as Map<String, dynamic>;
        return CraftingResponse.fromJson(jsonMap);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      developer.log(
        "خطا در ترکیب آیتم محلی: $e",
        name: "LocalAIService.craftItems",
      );
      return CraftingResponse(
        success: false,
        message: "ذهن صنعتگر یاری نمی‌کند. خطایی در فرآیند ترکیب رخ داد.",
      );
    }
  }

  /// خلاصه‌سازی و ریست کردن تاریخچه برای مدیریت حافظه در مدل محلی.
  @override
  Future<void> summarizeAndResetHistory() async {
    developer.log('شروع فرآیند خلاصه‌سازی تاریخچه محلی...',
        name: 'LocalAIService');

    if (_chatHistory.length < 4) {
      developer.log('تاریخچه برای خلاصه‌سازی کوتاه است.',
          name: 'LocalAIService');
      return;
    }

    // تبدیل تاریخچه به متن
    final historyAsString =
        _chatHistory.map((c) => '${c["role"]}: ${c["content"]}').join('\n\n');

    final summarizationPrompt = '''
    The following is a story log from a text-based RPG in Persian. Create a concise one-paragraph summary of the key events, characters, and the player's current situation. This summary will be used as the starting context for the next part of the game. Respond only with the summary text in Persian.
    
    LOG:
    ---
    $historyAsString
    ---
    ''';

    try {
      // درخواست خلاصه از مدل
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "model": _modelName,
              "messages": [
                {"role": "user", "content": summarizationPrompt},
              ],
              "temperature": 0.3,
              "max_tokens": 300,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final summaryText = data['choices'][0]['message']['content'];

        // ریست کردن تاریخچه
        _resetChatHistory();

        // اضافه کردن خلاصه به عنوان اولین پیام بعد از سیستم
        // ما این را به عنوان یک پیام "سیستم" یا "کاربر" مصنوعی اضافه می‌کنیم تا مدل بداند چه خبر است.
        _chatHistory.add({
          "role": "user",
          "content": "خلاصه وقایع قبلی: $summaryText\n\nحالا ادامه بده."
        });
        _chatHistory.add({
          "role": "assistant",
          "content":
              "متوجه شدم. آماده‌ام تا داستان را بر اساس این خلاصه ادامه دهم."
        });

        developer.log('تاریخچه محلی خلاصه و ریست شد.', name: 'LocalAIService');
      } else {
        developer.log('خطا در خلاصه‌سازی محلی: ${response.statusCode}',
            name: 'LocalAIService');
        // در صورت خطا، فقط ریست می‌کنیم تا برنامه قفل نکند
        _resetChatHistory();
      }
    } catch (e) {
      developer.log('خطا در ارتباط با مدل برای خلاصه‌سازی: $e',
          name: 'LocalAIService');
      _resetChatHistory();
    }
  }

  @override
  Future<String?> generateImage(String prompt) async {
    // Local models usually don't support image generation easily via this interface yet.
    return null;
  }

  // دستورالعمل اصلی سیستم (System Prompt) برای تنظیم رفتار مدل محلی.
  static const String _systemInstruction = '''
  تو یک راوی حرفه‌ای برای یک بازی نقش‌آفرینی (RPG) به زبان فارسی هستی. 
  هدف تو ساخت یک داستان جذاب، پویا و تعاملی بر اساس انتخاب‌های کاربر است.

  **قوانین خروجی:**
  1.  خروجی تو **همیشه و حتماً** باید یک آبجکت JSON معتبر باشد. هیچ متنی قبل یا بعد از JSON ننویس.
  2.  ساختار JSON باید دقیقاً به شکل زیر باشد:
      {
        "story_text": "متن داستانی که برای کاربر نمایش داده می‌شود. این متن باید تصویرساز و گیرا باشد.",
        "options": ["گزینه انتخاب ۱", "گزینه انتخاب ۲", "گزینه انتخاب ۳"],
        "status_updates": { 
          "health": <مقدار عددی تغییر سلامتی>, 
          "sanity": <مقدار عددی تغییر سلامت روان>,
          "hunger": <مقدار عددی تغییر گرسنگی>,
          "energy": <مقدار عددی تغییر انرژی>
        }
      }
  3. در قسمت status_updates فقط مقادیری را بیاور که تغییر کرده‌اند. اگر تغییری نبود، یک آبجکت خالی {} برگردان.

  **قوانین بازی:**
  - اگر اولین پیام کاربر حاوی کلمه "شروع" بود، یک مقدمه داستانی جذاب برای یک ماجراجویی (مثلا در یک جنگل اسرارآمیز، یک قلعه تسخیر شده یا یک سیاره بیگانه) بساز.
  - وضعیت بازیکن (stats) را به دقت مدیریت کن. اگر سلامتی (health) به صفر یا کمتر رسید، بازی را با یک پیام مناسب تمام کن و در گزینه‌ها، گزینه "شروع مجدد" را قرار بده.
  - لحن تو باید داستان‌گو، رازآلود و جذاب باشد. از توصیفات دقیق برای فضا‌سازی استفاده کن.
  ''';
}
