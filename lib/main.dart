import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/settings_provider.dart';
import 'package:myapp/screens/welcome_screen.dart';

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
      locale: const Locale('fa', 'IR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'), // Persian
        Locale('en', 'US'), // English
      ],
    );
  }
}
