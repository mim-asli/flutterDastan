import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/main.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/new_game_wizard.dart';
import 'package:myapp/widgets/help_dialog.dart';
import 'package:myapp/widgets/tts_settings_dialog.dart';

/// صفحه خوش‌آمدگویی (Welcome Screen)
///
/// این صفحه اولین چیزی است که کاربر هنگام باز کردن برنامه می‌بیند.
/// شامل گزینه‌هایی برای ادامه بازی قبلی، شروع بازی جدید، بارگذاری بازی و تنظیمات است.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // محاسبه عرض مناسب برای محتوا (حداکثر 600 پیکسل برای دسکتاپ/وب)
          final contentWidth =
              constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
          final isSmallScreen = constraints.maxHeight < 700;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1C),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: contentWidth,
                    minHeight: constraints.maxHeight -
                        64, // برای پر کردن ارتفاع در صورت امکان
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isSmallScreen) const Spacer(),
                        const SizedBox(height: 32),

                        // عنوان اصلی
                        Text(
                          'داستان',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(
                            fontSize: constraints.maxWidth > 600 ? 72 : 56,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFFDB3838),
                            letterSpacing: 2,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 16),

                        Text(
                          'یک بازی نقش‌آفرینی متنی که هر بار پویایی‌تری می‌شود، تماماً توسط هوش مصنوعی',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(
                            fontSize: constraints.maxWidth > 600 ? 16 : 14,
                            fontWeight: FontWeight.w300,
                            color: Colors.white60,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(delay: 400.ms),

                        if (!isSmallScreen)
                          const Spacer()
                        else
                          const SizedBox(height: 48),

                        // دکمه‌ها
                        _MenuButton(
                          icon: Icons.play_arrow_rounded,
                          label: 'ماجراجویی جدید',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NewGameWizard(),
                              ),
                            );
                          },
                          isPrimary: true,
                        ),
                        const SizedBox(height: 16),

                        _MenuButton(
                          icon: Icons.folder_open_rounded,
                          label: 'بارگذاری داستان‌ها',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Scaffold(
                                  body: SaveLoadScreen(),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 64),

                        // آیکون‌های پایین
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.settings_outlined, size: 24),
                              color: Colors.white30,
                              tooltip: 'تنظیمات',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.volume_up_outlined,
                                  size: 24),
                              color: Colors.white30,
                              tooltip: 'صدا',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const TtsSettingsDialog(),
                                );
                              },
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.help_outline, size: 24),
                              color: Colors.white30,
                              tooltip: 'راهنما',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const HelpDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ویجت کمکی برای دکمه‌های منو با استایل یکسان
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFFDB3838) // قرمز Nothing برای دکمه اصلی
              : Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withAlpha(10),
          disabledForegroundColor: Colors.white38,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF3A3A3A), width: 1),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
