import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/new_game_wizard.dart';
import 'package:myapp/screens/save_load_screen.dart'; // Import extracted SaveLoadContent
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
      // Background color inherited from theme (0xFF050505)
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth =
              constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;

          return Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: contentWidth,
                  minHeight: constraints.maxHeight - 64,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end, // Align to bottom
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(), // Push content down

                      // عنوان اصلی
                      Text(
                        'داستان',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.vazirmatn(
                          fontSize: constraints.maxWidth > 600
                              ? 96
                              : 72, // Larger title
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDB3838), // Red
                          letterSpacing: -2,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 8),

                      Text(
                        'یک بازی نقش‌آفرینی بی‌پایان با هوش مصنوعی',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 64),

                      // دکمه‌ها
                      _MenuButton(
                        icon: Icons.add_circle_outline_rounded,
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
                      const SizedBox(height: 12),

                      _MenuButton(
                        icon: Icons.file_upload_outlined,
                        label: 'بارگذاری ماجراجویی',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                body: SaveLoadContent(),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 48),

                      // آیکون‌های پایین
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // Spread out
                        children: [
                          IconButton(
                            icon: const Icon(Icons.logo_dev,
                                size: 28), // Placeholder for logo
                            onPressed: () {},
                            color: Colors.white12,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.help_outline, size: 20),
                                color: Colors.white54,
                                tooltip: 'راهنما',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const HelpDialog(),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined,
                                    size: 20),
                                color: Colors.white54,
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
                              IconButton(
                                icon: const Icon(Icons.volume_up_outlined,
                                    size: 20),
                                color: Colors.white54,
                                tooltip: 'صدا',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const TtsSettingsDialog(),
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
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
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFFDB3838) // Red
              : Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(
                  color: Color(0xFF333333), width: 1), // Dark border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Slightly less rounded
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
