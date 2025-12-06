import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    // Controllers
    final apiKeyController =
        TextEditingController(text: settingsNotifier.cloudApiKey);
    final localUrlController =
        TextEditingController(text: settingsNotifier.localApiUrl);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF151515), // Dark background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                'تنظیمات',
                style: GoogleFonts.vazirmatn(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: settingsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
              child:
                  Text('خطا: $err', style: const TextStyle(color: Colors.red))),
          data: (_) {
            return SingleChildScrollView(
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

                  // --- Model Guide Section ---
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          icon: Icons.psychology,
                          title: 'راهنمای انتخاب و استفاده از مدل',
                          subtitle:
                              'توصیه‌هایی برای به دست آوردن بهترین تجربه داستانی با توجه به منابع سیستم شما.',
                        ),
                        const SizedBox(height: 16),
                        _buildExpansionTile(
                          title: 'ابری در مقابل محلی',
                          icon: Icons.cloud_sync_outlined,
                          content:
                              'مدل‌های ابری (مانند Gemini) کیفیت بالاتری دارند اما به اینترنت نیاز دارند. مدل‌های محلی حریم خصوصی بیشتری دارند اما به سخت‌افزار قوی نیاز دارند.',
                        ),
                        _buildExpansionTile(
                          title: 'چگونه بهترین مدل محلی را انتخاب کنیم؟',
                          icon: Icons.layers_outlined,
                          content:
                              'برای سیستم‌های ضعیف‌تر از مدل‌های 7B یا 8B استفاده کنید. اگر کارت گرافیک قوی دارید، مدل‌های بزرگتر کیفیت بهتری دارند.',
                        ),
                        _buildExpansionTile(
                          title: 'کوانتیزیشن (Quantization) چیست؟',
                          icon: Icons.compress,
                          content:
                              'روشی برای کاهش حجم مدل‌ها. مدل‌های Q4_K_M تعادل خوبی بین کیفیت و سرعت دارند.',
                        ),
                        _buildExpansionTile(
                          title: 'دریافت آدرس Endpoint از ابزارها',
                          icon: Icons.link,
                          content:
                              'در LM Studio سرور را استارت کنید و آدرس نمایش داده شده (معمولا http://localhost:1234/v1) را کپی کنید.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Image Generation Section ---
                  _buildSectionContainer(
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          icon: Icons.image_outlined,
                          title: 'تولید تصویر با هوش مصنوعی',
                          subtitle:
                              'به‌طور خودکار برای لحظات کلیدی داستان، تصاویر تولید کنید. (ممکن است هزینه اضافی داشته باشد)',
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchRow(
                          label: 'فعالسازی تولید تصویر',
                          value: settingsNotifier.isImageGenerationEnabled,
                          onChanged: (val) =>
                              settingsNotifier.setImageGenerationEnabled(val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Google Gemini API Keys ---
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          icon: Icons.vpn_key_outlined,
                          title: 'کلیدهای Google Gemini API',
                          subtitle:
                              'موتور اصلی تولید داستان. می‌توانید چندین کلید برای چرخش خودکار اضافه کنید.',
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: apiKeyController,
                                style: GoogleFonts.roboto(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText:
                                      '....................................',
                                  hintStyle:
                                      const TextStyle(color: Colors.white24),
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                onChanged: (val) =>
                                    settingsNotifier.setCloudApiKey(val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A6FE2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton.icon(
                                onPressed: () {}, // Logic to add key
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                label: Text('افزودن کلید',
                                    style: GoogleFonts.vazirmatn(
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: Colors.white.withAlpha(20)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('تست همه کلیدهای فعال',
                                style: GoogleFonts.vazirmatn(
                                    color: Colors.white70)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- DeepSeek AI (Optional) ---
                  _buildSectionContainer(
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          icon: Icons.smart_toy_outlined,
                          title: 'هوش مصنوعی DeepSeek (اختیاری)',
                          subtitle:
                              'از مدل‌های زبان DeepSeek به عنوان جایگزین یا پشتیبان استفاده کنید. آدرس Endpoint معمولاً به `/v1/chat/completions` ختم می‌شود.',
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchRow(
                          label: 'فعالسازی DeepSeek',
                          value: settingsNotifier.isDeepSeekEnabled,
                          onChanged: (val) =>
                              settingsNotifier.setDeepSeekEnabled(val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Local AI (Optional) ---
                  _buildSectionContainer(
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          icon: Icons.computer_outlined,
                          title: 'هوش مصنوعی محلی (اختیاری)',
                          subtitle:
                              'بازی را به یک مدل زبان در حال اجرا روی سیستم خود متصل کنید. از ابزارهایی مانند Ollama یا LM Studio برای اجرای مدل‌ها استفاده کنید.',
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchRow(
                          label: 'فعالسازی مدل محلی',
                          value: settingsNotifier.aiProviderType ==
                              AiProviderType.local,
                          onChanged: (val) {
                            // Toggle logic: if turning on, set to local. If turning off, set to cloud.
                            // This is a simplification based on the UI switch metaphor.
                            settingsNotifier.setAiProviderType(val
                                ? AiProviderType.local
                                : AiProviderType.cloud);
                          },
                        ),
                        if (settingsNotifier.aiProviderType ==
                            AiProviderType.local) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: localUrlController,
                            style: GoogleFonts.roboto(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'آدرس سرور محلی',
                              labelStyle:
                                  const TextStyle(color: Colors.white54),
                              hintText: 'http://localhost:1234/v1',
                              hintStyle: const TextStyle(color: Colors.white24),
                              filled: true,
                              fillColor: Colors.white.withAlpha(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (val) =>
                                settingsNotifier.setLocalApiUrl(val),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
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
            Icon(icon, color: const Color(0xFF3A6FE2), size: 24),
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
              ? const Color(0xFFDB3838).withAlpha(50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFDB3838)
                : Colors.white.withAlpha(20),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFFDB3838) : Colors.white70),
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

  Widget _buildExpansionTile(
      {required String title,
      required IconData icon,
      required String content}) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.white54, size: 20),
        title: Text(
          title,
          style: GoogleFonts.vazirmatn(fontSize: 14, color: Colors.white70),
        ),
        iconColor: Colors.white54,
        collapsedIconColor: Colors.white54,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
            child: Text(
              content,
              style: GoogleFonts.vazirmatn(
                  fontSize: 13, color: Colors.white38, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
      {required String label,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.vazirmatn(fontSize: 14, color: Colors.white70),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF3A6FE2),
          activeTrackColor: const Color(0xFF3A6FE2).withAlpha(100),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.white.withAlpha(20),
        ),
      ],
    );
  }
}
