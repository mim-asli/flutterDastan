import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers.dart';
import 'package:myapp/providers/settings_provider.dart';
import 'package:myapp/screens/settings_screen.dart'; // وارد کردن صفحه تنظیمات
import 'package:myapp/screens/welcome_screen.dart'; // وارد کردن صفحه خوش‌آمدگویی
import 'package:myapp/services/tts_service.dart';
import 'package:myapp/widgets/image_display.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  // اطمینان از اینکه Isar قبل از اجرای برنامه آماده شده است
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.watch(settingsProvider.notifier);

    // تعریف تم روشن
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.vazirmatnTextTheme(ThemeData.light().textTheme),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFDB3838), // Red accent
        brightness: Brightness.light,
      ),
    );

    // تعریف تم تیره
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.vazirmatnTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: const Color(0xFF050505), // Nothing Phone Black
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFDB3838), // Red accent
        brightness: Brightness.dark,
        surface: const Color(0xFF101010),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // تنظیمات پیش‌فرض دکمه‌ها
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFDB3838),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    return MaterialApp(
      title: 'بازی داستانی هوش مصنوعی',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settingsNotifier.themeMode == 'dark'
          ? ThemeMode.dark
          : settingsNotifier.themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.system,
      home: const WelcomeScreen(), // شروع از صفحه خوش‌آمدگویی
      debugShowCheckedModeBanner: false,
    );
  }
}

// ویجت اصلی با چهار تب
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // لیست صفحات برنامه، صفحه تنظیمات به آن اضافه شده است
  static const List<Widget> _screens = <Widget>[
    GameScreen(),
    InventoryScreen(),
    SaveLoadScreen(),
    SettingsScreen(), // اضافه شدن صفحه تنظیمات
  ];

  // لیست آیتم‌های نوار ناوبری، آیتم تنظیمات به آن اضافه شده است
  static const List<BottomNavigationBarItem> _navBarItems =
      <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.gamepad_outlined), label: 'بازی'),
    BottomNavigationBarItem(
        icon: Icon(Icons.backpack_outlined), label: 'کوله‌پشتی'),
    BottomNavigationBarItem(
        icon: Icon(Icons.save_alt_outlined), label: 'سیستم'),
    BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'تنظیمات'), // اضافه شدن آیتم تنظیمات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _pageController.animateToPage(index,
            duration: 300.ms, curve: Curves.easeInOut),
        items: _navBarItems,
        // نوع ناوبری برای زمانی که تعداد آیتم‌ها زیاد است
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// ------------------- صفحه ذخیره و بارگذاری (SaveLoadScreen) -------------------
class SaveLoadScreen extends ConsumerWidget {
  const SaveLoadScreen({super.key});

  void _showConfirmDialog(BuildContext context, WidgetRef ref,
      {required String title,
      required String content,
      required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              child: const Text('لغو'),
              onPressed: () => Navigator.of(context).pop()),
          FilledButton(
              child: const Text('تایید'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              }),
        ],
      ),
    );
  }

  Future<void> _exportSaveSlot(
      BuildContext context, WidgetRef ref, int slotId) async {
    try {
      final dbService = ref.read(dbServiceProvider);
      final jsonString = await dbService.exportSaveSlotToJson(slotId);

      // ذخیره به فایل و اشتراک‌گذاری
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(jsonString.codeUnits),
            name: 'save_slot_$slotId.json',
            mimeType: 'application/json',
          )
        ],
        text: 'بازی ذخیره شده داستان',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فایل JSON آماده اشتراک‌گذاری است.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطا در صادرات: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _importSaveSlot(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.bytes == null) {
        return;
      }

      final jsonString = String.fromCharCodes(result.files.single.bytes!);
      final dbService = ref.read(dbServiceProvider);
      await dbService.importSaveSlotFromJson(jsonString);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('بازی با موفقیت وارد شد!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطا در وارد کردن: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveSlotsAsync = ref.watch(saveSlotsProvider);

    return Scaffold(
      appBar:
          AppBar(title: const Text('ذخیره و بارگذاری بازی'), centerTitle: true),
      body: saveSlotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطا در بارگذاری: $err')),
        data: (slots) {
          return slots.isEmpty
              ? const Center(child: Text('هیچ بازی ذخیره شده‌ای وجود ندارد.'))
              : ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final formattedDate =
                        DateFormat('yyyy/MM/dd – kk:mm').format(slot.saveDate);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('ذخیره اسلات ${slot.id}'),
                        subtitle: Text(formattedDate),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: const Icon(Icons.upload_file,
                                  color: Colors.blueAccent),
                              tooltip: "صادرات JSON",
                              onPressed: () =>
                                  _exportSaveSlot(context, ref, slot.id!)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              tooltip: "حذف",
                              onPressed: () => _showConfirmDialog(context, ref,
                                      title: "حذف ذخیره",
                                      content:
                                          "آیا از حذف این اسلات مطمئن هستید؟ این عمل غیرقابل بازگشت است.",
                                      onConfirm: () async {
                                    await ref
                                        .read(gameControllerProvider.notifier)
                                        .deleteGame(slot.id!);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'اسلات با موفقیت حذف شد.')));
                                  })),
                          IconButton(
                              icon: const Icon(Icons.drive_file_move_outline),
                              tooltip: "بازنویسی",
                              onPressed: () => _showConfirmDialog(context, ref,
                                      title: "بازنویسی ذخیره",
                                      content:
                                          "آیا می‌خواهید این اسلات را با وضعیت فعلی بازی بازنویسی کنید؟",
                                      onConfirm: () async {
                                    await ref
                                        .read(gameControllerProvider.notifier)
                                        .saveGame(id: slot.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'بازی با موفقیت بازنویسی شد.')));
                                  })),
                        ]),
                        onTap: () => _showConfirmDialog(context, ref,
                            title: "بارگذاری بازی",
                            content:
                                "تمام پیشرفت فعلی شما از بین خواهد رفت. آیا از بارگذاری این اسلات مطمئن هستید؟",
                            onConfirm: () async {
                          await ref
                              .read(gameControllerProvider.notifier)
                              .loadGame(slot.id!);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('بازی با موفقیت بارگذاری شد.')));
                        }),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'import',
            onPressed: () => _importSaveSlot(context, ref),
            tooltip: 'وارد کردن JSON',
            child: const Icon(Icons.download_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'save',
            icon: const Icon(Icons.add),
            label: const Text('ذخیره بازی جدید'),
            onPressed: () async {
              await ref.read(gameControllerProvider.notifier).saveGame();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('بازی با موفقیت در اسلات جدید ذخیره شد.')));
            },
          ),
        ],
      ),
    );
  }
}

// ------------------- صفحه بازی (GameScreen) -------------------
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  void _showAskNarratorDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('سوال از راوی'),
        content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: 'سوال خود را اینجا بنویسید...')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو')),
          FilledButton(
              onPressed: () {
                final question = textController.text;
                if (question.isNotEmpty) {
                  Navigator.pop(context);
                  _handleNarratorQuestion(context, ref, question);
                }
              },
              child: const Text('بپرس')),
        ],
      ),
    );
  }

  void _handleNarratorQuestion(
      BuildContext context, WidgetRef ref, String question) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    final answer =
        await ref.read(gameControllerProvider.notifier).askNarrator(question);
    if (!context.mounted) return;
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              title: const Text('پاسخ راوی'),
              content: SingleChildScrollView(child: Text(answer)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('باشه'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final storyLog = ref.watch(storyLogProvider);
    final options = ref.watch(optionsProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ماجراجویی در غار'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'سوال از راوی',
              onPressed: () => _showAskNarratorDialog(context, ref))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlayerStatus(stats: stats),
            const SizedBox(height: 24),
            const ImageDisplay(),
            StoryDisplay(storyText: storyLog.last),
            const SizedBox(height: 24),
            OptionsDisplay(isLoading: isLoading, options: options),
          ],
        ),
      ),
    );
  }
}

// ------------------- صفحه کوله‌پشتی (InventoryScreen) -------------------
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  bool _isCrafting = false;

  Future<void> _onCraftPressed() async {
    setState(() {
      _isCrafting = true;
    });

    final response =
        await ref.read(gameControllerProvider.notifier).craftSelectedItems();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.message),
          backgroundColor:
              response.success ? Colors.green.shade700 : Colors.red.shade700));
      setState(() {
        _isCrafting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final selection = ref.watch(craftingSelectionProvider);

    return Scaffold(
      appBar: AppBar(
          title: const Text('کوله‌پشتی و ساخت‌وساز'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: inventory.isEmpty
                ? const Center(child: Text('کوله‌پشتی شما خالی است.'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8),
                    padding: const EdgeInsets.all(16),
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      final item = inventory[index];
                      final isSelected = selection.contains(item);
                      return InkWell(
                        onTap: () {
                          ref
                              .read(craftingSelectionProvider.notifier)
                              .update((state) {
                            if (isSelected) return state..remove(item);
                            if (state.length < 2) return [...state, item];
                            return state;
                          });
                        },
                        child: Card(
                          color: isSelected
                              ? const Color(0xFFDB3838) // Red accent
                              : const Color(0xFF2C2C2C),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.inventory_2_outlined,
                                        size: 40),
                                    const SizedBox(height: 8),
                                    Text(item.name,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(item.description,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)
                                  ])),
                        )
                            .animate()
                            .fadeIn(delay: (50 * index).ms, duration: 400.ms),
                      );
                    },
                  ),
          ),
          if (_isCrafting)
            const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.build),
                label: const Text('ترکیب'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                onPressed: selection.length == 2 ? _onCraftPressed : null,
              ),
            ),
        ],
      ),
    );
  }
}

// --- ویجت‌های مشترک  ---
class StoryDisplay extends ConsumerWidget {
  final String storyText;
  const StoryDisplay({super.key, required this.storyText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsServiceProvider).ttsState;
    final isPlaying = ttsState == TtsState.playing;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.black.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDB3838).withAlpha(100))),
        child: Stack(
          children: [
            SingleChildScrollView(
                child: Text(storyText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.8))
                    .animate()
                    .fadeIn(duration: 700.ms, curve: Curves.easeIn)),
            Align(
              alignment: Alignment.bottomLeft,
              child: IconButton(
                icon: Icon(
                    isPlaying
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                    size: 30),
                color: isPlaying ? Colors.redAccent : Colors.white,
                tooltip: isPlaying ? 'توقف' : 'خواندن داستان',
                onPressed: () => ref.read(ttsServiceProvider).toggle(storyText),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OptionsDisplay extends ConsumerStatefulWidget {
  final bool isLoading;
  final List<String> options;
  const OptionsDisplay(
      {super.key, required this.isLoading, required this.options});

  @override
  ConsumerState<OptionsDisplay> createState() => _OptionsDisplayState();
}

class _OptionsDisplayState extends ConsumerState<OptionsDisplay> {
  bool _isListening = false;
  String _recognizedText = '';

  void _handleVoiceCommand() async {
    final sttService = ref.read(sttServiceProvider);

    // اگر سرویس مقداردهی اولیه نشده باشد، ابتدا این کار را انجام می‌دهیم
    if (!sttService.isInitialized) {
      final bool isInitialized = await sttService.init();

      // نکته مهم: بعد از هر عملیات `await`، باید بررسی کنیم که آیا ویجت هنوز در درخت ویجت‌ها قرار دارد یا خیر.
      // در غیر این صورت، استفاده از `context` باعث خطا می‌شود.
      if (!mounted) return;

      // اگر مقداردهی اولیه ناموفق بود، یک پیام خطا نمایش داده و خارج می‌شویم.
      if (!isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در راه‌اندازی تشخیص گفتار.')),
        );
        return;
      }
    }

    // با اطمینان از مقداردهی اولیه، وضعیت گوش دادن را تغییر می‌دهیم
    if (sttService.isListening) {
      sttService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _recognizedText = 'در حال شنیدن...';
      });
      sttService.startListening(_onSpeechResult);
    }
  }

  void _onSpeechResult(String text) {
    if (!mounted) return;
    setState(() {
      _recognizedText = text;
    });

    final sttService = ref.read(sttServiceProvider);
    if (!sttService.isListening && text.isNotEmpty) {
      final bestMatch = _findBestMatch(text, widget.options);
      if (bestMatch != null) {
        ref.read(gameControllerProvider.notifier).processUserInput(bestMatch);
      }
      setState(() {
        _recognizedText = '';
      });
    }
  }

  String? _findBestMatch(String query, List<String> options) {
    if (query.isEmpty) return null;
    final trimmedQuery = query.trim();

    for (var option in options) {
      if (trimmedQuery == option.trim()) return option;
    }
    for (var option in options) {
      if (trimmedQuery.contains(option)) return option;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('هوش مصنوعی در حال نوشتن ادامه داستان است...')
                  ]))).animate().fadeIn();
    }
    return Column(children: [
      ...widget.options.map((option) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFDB3838), // Red accent
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () => ref
                  .read(gameControllerProvider.notifier)
                  .processUserInput(option),
              child: Text(option, style: const TextStyle(fontSize: 16)),
            ).animate().slide(
                begin: const Offset(0, 1),
                delay: (100 * widget.options.indexOf(option)).ms,
                duration: 500.ms,
                curve: Curves.easeOut));
      }),
      const SizedBox(height: 20),
      if (_isListening || _recognizedText.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_recognizedText,
              style: const TextStyle(
                  color: Colors.white70, fontStyle: FontStyle.italic)),
        ),
      FloatingActionButton(
        onPressed: _handleVoiceCommand,
        tooltip: 'فرمان صوتی',
        backgroundColor: _isListening
            ? Colors.red.shade400
            : Theme.of(context).colorScheme.secondary,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      )
    ]);
  }
}

class PlayerStatus extends StatelessWidget {
  final GameStats stats;
  const PlayerStatus({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withAlpha(51),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            StatusIndicator(
                icon: Icons.favorite,
                value: stats.health,
                color: Colors.red.shade400,
                label: 'سلامتی'),
            StatusIndicator(
                icon: Icons.psychology,
                value: stats.sanity,
                color: Colors.purpleAccent, // Changed from Blue to Purple
                label: 'روان'),
            StatusIndicator(
                icon: Icons.fastfood,
                value: stats.hunger,
                color: Colors.orange.shade400,
                label: 'گرسنگی'),
            StatusIndicator(
                icon: Icons.battery_charging_full,
                value: stats.energy,
                color: Colors.green.shade400,
                label: 'انرژی'),
          ]).animate().fadeIn(delay: 300.ms, duration: 500.ms)),
    );
  }
}

class StatusIndicator extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final String label;
  const StatusIndicator(
      {super.key,
      required this.icon,
      required this.value,
      required this.color,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.white70)),
      const SizedBox(height: 8),
      Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text('$value%',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold))
      ]),
    ]);
  }
}
