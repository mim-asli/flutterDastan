import 'dart:convert';
import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/models.dart';
import 'package:myapp/services/base_ai_service.dart';

/// این کلاس، پیاده‌سازی "ابری" سرویس هوش مصنوعی است.
///
/// این کلاس از `BaseAIService` ارث‌بری می‌کند و مسئول ارتباط با
/// APIهای ابری مانند Google Gemini است. تمام منطق مربوط به ارسال درخواست،
/// دریافت پاسخ و مدیریت تاریخچه چت با سرویس ابری در اینجا کپسوله شده است.
class CloudAIService implements BaseAIService {
  late final GenerativeModel _model; // مدل اصلی هوش مصنوعی برای تولید داستان
  late ChatSession _chat; // جلسه چت برای نگهداری تاریخچه مکالمه
  final String _apiKey; // کلید API برای احراز هویت

  CloudAIService(this._apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // استفاده از مدل بهینه و سریع Gemini 1.5 Flash
      apiKey: _apiKey,
      // تنظیم مدل برای دریافت خروجی به فرمت JSON. این کار پردازش پاسخ را بسیار ساده‌تر می‌کند.
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      // دستورالعمل اولیه (System Prompt) برای تنظیم رفتار، لحن و قوانین هوش مصنوعی
      systemInstruction: Content.text(_systemPrompt),
    );
    // شروع یک جلسه چت جدید
    _chat = _model.startChat();
  }

  /// ارسال پیام کاربر و وضعیت فعلی بازی به هوش مصنوعی و دریافت ادامه داستان.
  @override
  Future<GameResponse> sendMessage(
      String userMessage,
      GameStats currentStats,
      WorldState worldState,
      List<InventoryItem> inventory,
      GameConfig? config) async {
    // تبدیل وضعیت بازیکن به یک رشته JSON
    final statsJson = jsonEncode(currentStats.toJson());
    final worldJson = jsonEncode(worldState.toJson());
    final inventoryJson =
        jsonEncode(inventory.map((e) => e.name).toList()); // فقط نام آیتم‌ها

    // ساخت کانتکست تنظیمات بازی (اگر موجود باشد)
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

    // ساخت پرامپت نهایی ترکیبی
    final prompt = '''
    $configContext
    Current World State: $worldJson
    Player Stats: $statsJson
    Player Inventory: $inventoryJson
    
    User Action: "$userMessage"
    ''';

    // ارسال درخواست به API
    final response = await _chat.sendMessage(Content.text(prompt));
    final text = response.text;

    if (text == null) {
      developer.log("پاسخ خالی از AI دریافت شد",
          name: 'CloudAIService.sendMessage');
      throw Exception("پاسخ خالی از طرف هوش مصنوعی دریافت شد.");
    }

    try {
      // تلاش برای پارس کردن پاسخ JSON دریافت شده به آبجکت GameResponse
      final jsonMap = jsonDecode(text) as Map<String, dynamic>;
      return GameResponse.fromJson(jsonMap);
    } catch (e, stackTrace) {
      // در صورت بروز خطا در پارس کردن (مثلاً اگر AI خروجی JSON معتبر نداد)،
      // آن را لاگ کرده و یک پاسخ خطای استاندارد و ایمن برمی‌گردانیم تا بازی کرش نکند.
      developer.log('خطا در پارس کردن پاسخ JSON از AI',
          name: 'CloudAIService.sendMessage', error: e, stackTrace: stackTrace);
      developer.log('پاسخ دریافت شده: $text',
          name: 'CloudAIService.sendMessage');
      return GameResponse.fromJson({
        "story_text":
            "متاسفانه در پردازش داستان مشکلی پیش آمد. انگار کلمات در فضا گم شده‌اند. لطفاً دوباره تلاش کنید.",
        "options": ["تلاش مجدد"],
        "status_updates": {}
      });
    }
  }

  /// پرسیدن سوال مستقیم از راوی (خارج از جریان اصلی داستان).
  /// این متد از یک مدل جداگانه استفاده می‌کند تا تاریخچه داستان اصلی را خراب نکند،
  /// اما تاریخچه داستان را به عنوان "زمینه" (Context) به مدل می‌دهد تا پاسخ‌های مرتبط بدهد.
  @override
  Future<String> askNarrator(String userQuestion) async {
    developer.log('سوال از راوی: $userQuestion', name: 'CloudAIService');

    // استخراج تاریخچه چت فعلی برای دادن زمینه به راوی
    final history = _chat.history.toList();
    final historyAsString = history
        .map((c) => c.parts.whereType<TextPart>().map((p) => p.text).join('\n'))
        .join('\n\n');

    // ایجاد یک مدل موقت برای راوی (بدون دستورالعمل JSON، چون پاسخ متنی ساده می‌خواهیم)
    final narratorModel =
        GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

    final narratorPrompt = '''
    You are the omniscient narrator of a text-based RPG in Persian. The user is stepping out of character to ask you, the narrator, a question about the game world or story.
    Based on the story so far, answer the user's question concisely in Persian. Do not advance the story or give options. Just provide a direct, simple, and informative answer to the question.

    STORY SO FAR:
    ---
    $historyAsString
    ---

    USER'S QUESTION: "$userQuestion"

    YOUR ANSWER (as the narrator in Persian):
    ''';

    try {
      final response =
          await narratorModel.generateContent([Content.text(narratorPrompt)]);
      final answer = response.text;

      if (answer == null || answer.isEmpty) {
        return "راوی در سکوتی معنادار فرو می‌رود و پاسخی نمی‌دهد.";
      }
      return answer;
    } catch (e) {
      developer.log("خطا در ارتباط با راوی",
          name: "CloudAIService.askNarrator", error: e);
      return "خطایی در ارتباط با راوی رخ داد. شاید او در حال حاضر در دنیای دیگری سیر می‌کند.";
    }
  }

  /// خلاصه‌سازی تاریخچه مکالمه برای مدیریت مصرف توکن و حافظه.
  /// وقتی مکالمه طولانی می‌شود، این متد کل تاریخچه قبلی را به یک پاراگراف خلاصه تبدیل می‌کند
  /// و چت را با آن خلاصه ریست می‌کند.
  @override
  Future<void> summarizeAndResetHistory() async {
    developer.log('شروع فرآیند خلاصه‌سازی تاریخچه...', name: 'CloudAIService');
    final history = _chat.history.toList();

    // اگر تاریخچه کوتاه باشد، نیازی به خلاصه‌سازی نیست
    if (history.length < 4) {
      developer.log('تاریخچه برای خلاصه‌سازی به اندازه کافی طولانی نیست.',
          name: 'CloudAIService');
      return;
    }

    // استفاده از یک مدل موقت برای تولید خلاصه
    final summaryModel =
        GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    final summarizationPrompt = '''
    The following is a story log from a text-based RPG in Persian. Create a concise one-paragraph summary of the key events, characters, and the player's current situation. This summary will be used as the starting context for the next part of the game. Respond only with the summary text in Persian.
    ---
    ${history.map((c) => c.parts.whereType<TextPart>().map((p) => p.text).join('\n')).join('\n')}
    ---
    ''';

    try {
      final summaryResponse = await summaryModel
          .generateContent([Content.text(summarizationPrompt)]);
      final summaryText = summaryResponse.text;

      if (summaryText == null || summaryText.isEmpty) {
        throw Exception('خلاصه تولید شده توسط هوش مصنوعی خالی است.');
      }

      // شروع یک جلسه چت جدید با تاریخچه‌ای که شامل خلاصه و پاسخ مدل است.
      // این کار باعث می‌شود مدل جدید بداند چه اتفاقی افتاده اما بار توکن‌های قبلی را نداشته باشد.
      _chat = _model.startChat(history: [
        Content.text("این خلاصه‌ای از وقایع بازی تاکنون است: $summaryText"),
        Content.model([
          TextPart("باشه، خلاصه رو فهمیدم. حالا منتظر حرکت بعدی بازیکن هستم.")
        ])
      ]);

      developer.log('تاریخچه با موفقیت خلاصه و ریست شد. خلاصه: $summaryText',
          name: 'CloudAIService');
    } catch (e, stackTrace) {
      developer.log('خطا در هنگام خلاصه‌سازی تاریخچه',
          name: 'CloudAIService.summarize', error: e, stackTrace: stackTrace);
      // در صورت خطا، چت را ادامه می‌دهیم تا بازی متوقف نشود.
    }
  }

  /// سرویس ترکیب آیتم‌ها (Crafting).
  /// دو آیتم را می‌گیرد و از هوش مصنوعی می‌پرسد که آیا ترکیب آن‌ها منطقی است و چه نتیجه‌ای دارد.
  @override
  Future<CraftingResponse> craftItems(
      InventoryItem item1, InventoryItem item2) async {
    final craftingModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'));

    final prompt = '''
    You are a crafting master in a survival RPG. The user wants to combine two items. Based on common sense and survival logic, determine the result.
    The user combines "${item1.name}" and "${item2.name}".

    Your response MUST be a valid JSON object with the following structure:
    {
      "success": <boolean>, // true if crafting is successful, false otherwise
      "new_item": { // The new item if success is true, otherwise null
        "name": "<نام آیتم جدید>",
        "description": "<توضیح کوتاه آیتم جدید>"
      },
      "message": "<یک پیام کوتاه به فارسی برای نمایش به کاربر درباره نتیجه>"
    }

    Examples:
    - "چوب" and "سنگ تیز": { "success": true, "new_item": { "name": "تبر سنگی", "description": "ابزاری ساده برای جمع‌آوری چوب بیشتر."}, "message": "شما یک تبر سنگی ساختید!" }
    - "آب" and "برگ": { "success": false, "new_item": null, "message": "ترکیب آب و برگ نتیجه خاصی نداشت." }
    ''';

    try {
      final response =
          await craftingModel.generateContent([Content.text(prompt)]);
      final jsonMap = jsonDecode(response.text!) as Map<String, dynamic>;
      return CraftingResponse.fromJson(jsonMap);
    } catch (e) {
      developer.log("خطا در ترکیب آیتم: $e", name: "CloudAIService.craftItems");
      return CraftingResponse(
          success: false,
          message: "ذهن صنعتگر یاری نمی‌کند. خطایی در فرآیند ترکیب رخ داد.");
    }
  }

  // دستورالعمل اصلی سیستم که رفتار هوش مصنوعی را به عنوان راوی بازی مشخص می‌کند.
  // این متن به مدل می‌گوید که چگونه رفتار کند، چه فرمتی خروجی دهد و قوانین بازی چیست.
  static const String _systemPrompt = '''
  تو یک راوی حرفه‌ای برای یک بازی نقش‌آفرینی (RPG) به زبان فارسی هستی. 
  هدف تو ساخت یک داستان جذاب، پویا و تعاملی بر اساس انتخاب‌های کاربر است.

  **قوانین خروجی:**
  1.  خروجی تو **همیشه و حتماً** باید یک آبجکت JSON معتبر باشد.
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

  @override
  Future<String?> generateImage(String prompt) async {
    // TODO: Implement actual image generation API call (e.g., OpenAI DALL-E, Stability AI)
    // For now, we return a placeholder image URL based on the prompt keywords or a random fantasy image.
    // Since we don't have a real image gen API key configured yet, this is a simulation.

    developer.log('Generating image for prompt: $prompt',
        name: 'CloudAIService');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return a high-quality fantasy placeholder image
    return 'https://picsum.photos/seed/${prompt.hashCode}/800/600';
  }
}
