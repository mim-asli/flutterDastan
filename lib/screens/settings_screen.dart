import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings, color: Color(0xFFDB3838)),
              const SizedBox(width: 8),
              Text(
                'تنظیمات',
                style: GoogleFonts.vazirmatn(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDB3838),
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const SettingsContent(),
      ),
    );
  }
}

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    // Controllers
    final localModelNameController =
        TextEditingController(text: settingsNotifier.localModelName);
    final cloudApiKeyController =
        TextEditingController(text: settingsNotifier.cloudApiKey);
    final imageGenApiKeyController =
        TextEditingController(text: settingsNotifier.imageGenApiKey);

    return settingsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
          child: Text('خطا: $err', style: const TextStyle(color: Colors.red))),
      data: (_) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- Theme Section ---
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          icon: Icons.monitor,
                          title: 'پوسته برنامه',
                          subtitle: 'ظاهر کلی برنامه را انتخاب کنید.',
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildThemeCard(
                                context,
                                title: 'تاریک',
                                icon: Icons.dark_mode_outlined,
                                isSelected:
                                    settingsNotifier.themeMode == 'dark',
                                onTap: () =>
                                    settingsNotifier.setThemeMode('dark'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildThemeCard(
                                context,
                                title: 'روشن',
                                icon: Icons.light_mode_outlined,
                                isSelected:
                                    settingsNotifier.themeMode == 'light',
                                onTap: () =>
                                    settingsNotifier.setThemeMode('light'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Font Section (NEW) ---
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          icon: Icons.text_fields,
                          title: 'فونت برنامه',
                          subtitle: 'فونت اصلی متن‌های بازی را انتخاب کنید.',
                        ),
                        const SizedBox(height: 24),
                        Column(
                          children: [
                            _buildFontOption(
                              context,
                              title: 'وزیرمتن (پیش‌فرض)',
                              fontFamily: 'Vazirmatn',
                              isSelected:
                                  settingsNotifier.fontFamily == 'Vazirmatn',
                              onTap: () =>
                                  settingsNotifier.setFontFamily('Vazirmatn'),
                            ),
                            const SizedBox(height: 8),
                            _buildFontOption(
                              context,
                              title: 'ربات (Roboto)',
                              fontFamily: 'Roboto',
                              isSelected:
                                  settingsNotifier.fontFamily == 'Roboto',
                              onTap: () =>
                                  settingsNotifier.setFontFamily('Roboto'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- AI Config Section ---
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          icon: Icons.psychology,
                          title: 'پیکربندی هوش مصنوعی',
                          subtitle:
                              'موتور هوش مصنوعی بازی را انتخاب و پیکربندی کنید. می‌توانید از مدل‌های ابری (مانند Gemini) یا یک مدل محلی (Local LLM) استفاده کنید.',
                        ),
                        const SizedBox(height: 24),

                        // Model Selection Dropdown (Styled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: settingsNotifier.aiProviderType ==
                                      AiProviderType.cloud
                                  ? 'Google Gemini'
                                  : 'Local LLM',
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E1E1E),
                              style: GoogleFonts.vazirmatn(color: Colors.white),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Google Gemini',
                                    child: Text('Google Gemini')),
                                DropdownMenuItem(
                                    value: 'Local LLM',
                                    child: Text('مدل زبان محلی')),
                              ],
                              onChanged: (val) {
                                if (val == 'Google Gemini') {
                                  settingsNotifier
                                      .setAiProviderType(AiProviderType.cloud);
                                } else {
                                  settingsNotifier
                                      .setAiProviderType(AiProviderType.local);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        if (settingsNotifier.aiProviderType ==
                            AiProviderType.local) ...[
                          Text(
                            'نام مدل محلی (مانند llama-3.2-1b)',
                            style: GoogleFonts.vazirmatn(
                                fontSize: 12, color: Colors.white38),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: localModelNameController,
                            style: GoogleFonts.roboto(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'نام مدل (مثلاً gemma-2-9b-it)',
                              hintStyle: const TextStyle(color: Colors.white24),
                              filled: true,
                              fillColor: Colors.black,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.white12),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onChanged: (val) =>
                                settingsNotifier.setLocalModelName(val),
                          ),
                        ] else
                          Text(
                            'مدل زبان محلی',
                            style: GoogleFonts.vazirmatn(
                                fontSize: 12, color: Colors.white38),
                          ),

                        const SizedBox(height: 24),

                        // API Key Input
                        Text(
                          'دریافت کلید API از Google AI Studio',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12,
                            color: const Color(0xFFDB3838),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFFDB3838),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: cloudApiKeyController,
                                style: GoogleFonts.roboto(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText:
                                      'جدید اضافه کنید API یک کلید', // RTL placeholder
                                  hintStyle:
                                      const TextStyle(color: Colors.white24),
                                  filled: true,
                                  fillColor: Colors.black,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFDB3838)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                onChanged: (val) =>
                                    settingsNotifier.setCloudApiKey(val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 48,
                              child: FilledButton.icon(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'کلید API ذخیره شد.',
                                        style: GoogleFonts.vazirmatn(),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('ذخیره'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFDB3838),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Image Generation API Key Input
                        Text(
                          'کلید API برای تولید تصویر (OpenAI DALL-E) (اختیاری)',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12,
                            color: const Color(0xFFDB3838),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: imageGenApiKeyController,
                                style: GoogleFonts.roboto(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText:
                                      'sk-proj-... (کلید OpenAI)', // RTL placeholder
                                  hintStyle:
                                      const TextStyle(color: Colors.white24),
                                  filled: true,
                                  fillColor: Colors.black,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFDB3838)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                onChanged: (val) =>
                                    settingsNotifier.setImageGenApiKey(val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 48,
                              child: FilledButton.icon(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'کلید تصویرسازی ذخیره شد.',
                                        style: GoogleFonts.vazirmatn(),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('ذخیره'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFDB3838),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101010), // Slightly lighter than background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFDB3838), size: 24), // Red icon
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.vazirmatn(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.vazirmatn(
            fontSize: 12,
            color: Colors.white54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(BuildContext context,
      {required String title,
      required IconData icon,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFDB3838).withAlpha(20)
              : const Color(0xFF1E1E1E), // Dark card bg
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFDB3838) : Colors.transparent,
            width: isSelected ? 1 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.vazirmatn(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontOption(BuildContext context,
      {required String title,
      required String fontFamily,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? const Color(0xFFDB3838) : Colors.white12),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? const Color(0xFFDB3838).withAlpha(20)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFDB3838) : Colors.white54,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.getFont(
                fontFamily == 'Vazirmatn' ? 'Vazirmatn' : fontFamily,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
