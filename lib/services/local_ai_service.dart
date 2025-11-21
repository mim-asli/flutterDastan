import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:myapp/models.dart';
import 'package:myapp/services/base_ai_service.dart';

/// این کلاس، پیاده‌سازی "محلی" سرویس هوش مصنوعی است.
///
/// این کلاس مسئول ارتباط با یک سرور هوش مصنوعی محلی است که از طریق ابزاری
/// مانند LM Studio اجرا می‌شود. این سرور API سازگار با OpenAI را شبیه‌سازی می‌کند.
/// این کلاس برای توسعه و تست آفلاین بسیار مفید است.
class LocalAIService implements BaseAIService {
  /// آدرس پایه سرور LM Studio.
  final String _baseUrl = Platform.isAndroid ? 'http://10.0.2.2:1234/v1' : 'http://localhost:1234/v1';
  
  /// نام دقیق مدلی که در LM Studio بارگذاری شده است.
  final String _modelName = "gemma-3-4b-persian-v0";

  /// تاریخچه مکالمه با مدل که برای حفظ زمینه داستان استفاده می‌شود.
  List<Map<String, String>> _chatHistory = [];

  LocalAIService() {
    _resetChatHistory();
  }

  void _resetChatHistory(){
      _chatHistory = [
      {
        "role": "system",
        "content": _systemInstruction
      }
    ];
  }

  @override
  Future<GameResponse> sendMessage(String userMessage, GameStats currentStats) async {
    
    String fullUserMessage = '''
    انتخاب بازیکن: $userMessage
    وضعیت فعلی بازیکن: ${jsonEncode(currentStats.toJson())}
    (یادت باشد خروجی فقط و فقط باید یک JSON معتبر باشد و هیچ متنی قبل یا بعد از آن ننویسی.)
    ''';
    
    _chatHistory.add({
      "role": "user",
      "content": fullUserMessage
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": _modelName,
          "messages": _chatHistory,
          "temperature": 0.7,
          "max_tokens": 1000,
          "stream": false
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String aiContent = data['choices'][0]['message']['content'];

        _chatHistory.add({
          "role": "assistant",
          "content": aiContent
        });
        
        final cleanedJsonString = _cleanJsonString(aiContent);

        final jsonResponse = jsonDecode(cleanedJsonString);
        return GameResponse.fromJson(jsonResponse);
      } else {
        developer.log(
          'سرور محلی با کد خطا پاسخ داد: ', 
          name: 'LocalAIService',
          error: "${response.statusCode} - ${response.body}"
        );
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      developer.log("خطا در ارتباط با سرور محلی AI", name: 'LocalAIService', error: e, stackTrace: stackTrace);
      return GameResponse(
        storyText: "ارتباط با سرور محلی برقرار نشد. آیا LM Studio در حال اجرا و سرور آن فعال است؟\n\nخطا: $e",
        options: ["تلاش مجدد"],
      );
    }
  }

  String _cleanJsonString(String rawText) {
    int startIndex = rawText.indexOf('{');
    int endIndex = rawText.lastIndexOf('}');
    
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return rawText.substring(startIndex, endIndex + 1);
    }
    return rawText; 
  }

  @override
  Future<String> askNarrator(String userQuestion) async {
    final historyAsString = _chatHistory
        .map((c) => '${c["role"]}: ${c["content"]}')
        .join('\n\n');

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
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": _modelName,
          // برای این درخواست، یک تاریخچه موقت و یکباره می‌سازیم تا در داستان اصلی تداخل ایجاد نکند.
          "messages": [{"role": "user", "content": narratorPrompt}],
          "temperature": 0.3, // پاسخ راوی باید دقیق و کم‌خلاقیت باشد
          "max_tokens": 300,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? "راوی در سکوت فرو رفته است.";
      } else {
        return "پاسخ راوی در هیاهوی کیهانی گم شد. (خطای سرور: ${response.statusCode})";
      }
    } catch (e) {
      developer.log("خطا در ارتباط با راوی محلی", name: 'LocalAIService.askNarrator', error: e);
      return "خطایی در ارتباط با راوی رخ داد. او در حال حاضر پاسخگو نیست.";
    }
  }

  @override
  Future<CraftingResponse> craftItems(InventoryItem item1, InventoryItem item2) async {
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
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": _modelName,
          "messages": [{"role": "user", "content": prompt}],
          "temperature": 0.2, // نتیجه ترکیب باید قطعی باشد
          "max_tokens": 250,
        }),
      ).timeout(const Duration(seconds: 45));

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
      developer.log("خطا در ترکیب آیتم محلی: $e", name: "LocalAIService.craftItems");
      return CraftingResponse(
          success: false,
          message: "ذهن صنعتگر یاری نمی‌کند. خطایی در فرآیند ترکیب رخ داد.");
    }
  }

  @override
  Future<void> summarizeAndResetHistory() async {
    // برای مدل‌های محلی، فعلاً فقط تاریخچه را پاک می‌کنیم. این کار سریع و موثر است.
    _resetChatHistory();
    developer.log('تاریخچه چت محلی ریست شد.', name: 'LocalAIService');
    return;
  }

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
