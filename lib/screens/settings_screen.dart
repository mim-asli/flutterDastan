import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/providers/settings_provider.dart';

/// صفحه‌ای برای نمایش و تغییر تنظیمات برنامه.
///
/// این ویجت به کاربر اجازه می‌دهد تا بین سرویس‌های هوش مصنوعی (محلی و ابری)
/// انتخاب کرده و اطلاعات مربوط به هر کدام را وارد نماید.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // به وضعیت SettingsProvider گوش می‌دهیم تا در صورت بارگذاری یا خطا، UI مناسب نمایش دهیم.
    final settingsState = ref.watch(settingsProvider);
    
    // کنترلرهای متنی برای فیلدهای ورودی. آن‌ها را با مقادیر اولیه پر می‌کنیم.
    final localUrlController = TextEditingController();
    final apiKeyController = TextEditingController();

    // خواندن مقادیر اولیه از Provider
    // ما از read استفاده می‌کنیم چون نمی‌خواهیم با هر تغییر حرف در فیلد، ویجت دوباره ساخته شود.
    final settings = ref.read(settingsProvider.notifier);
    localUrlController.text = settings.localApiUrl;
    apiKeyController.text = settings.cloudApiKey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
      ),
      body: settingsState.when(
        // اگر تنظیمات در حال بارگذاری از حافظه بود، یک لودینگ نمایش بده
        loading: () => const Center(child: CircularProgressIndicator()),
        // اگر در بارگذاری تنظیمات خطایی رخ داد، پیام خطا را نمایش بده
        error: (err, stack) => Center(child: Text('خطا در بارگذاری تنظیمات: $err')),
        // اگر تنظیمات با موفقیت بارگذاری شد، صفحه را نمایش بده
        data: (_) {
          // از watch برای گوش دادن به تغییرات نوع Provider استفاده می‌کنیم
          // تا UI (مثلا دکمه‌های SegmentedButton) به‌روز شود.
          final selectedProviderType = ref.watch(settingsProvider.notifier).aiProviderType;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- بخش انتخاب نوع سرویس ---
              Text('ارائه‌دهنده سرویس هوش مصنوعی', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              
              // استفاده از SegmentedButton برای یک انتخاب مدرن و زیبا
              SegmentedButton<AiProviderType>(
                segments: const <ButtonSegment<AiProviderType>>[
                  ButtonSegment<AiProviderType>(
                    value: AiProviderType.cloud,
                    label: Text('ابری'),
                    icon: Icon(Icons.cloud_outlined),
                  ),
                  ButtonSegment<AiProviderType>(
                    value: AiProviderType.local,
                    label: Text('محلی'),
                    icon: Icon(Icons.dns_outlined),
                  ),
                ],
                selected: {selectedProviderType},
                onSelectionChanged: (Set<AiProviderType> newSelection) {
                  ref.read(settingsProvider.notifier).setAiProviderType(newSelection.first);
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.standard, 
                ),
              ),
              
              const Divider(height: 32),

              // --- بخش تنظیمات سرویس ابری ---
              Text('تنظیمات سرویس ابری', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                // افزودن `const` به سازنده InputDecoration
                // چون محتوای آن (لیبل و کادر) ثابت است، با این کار به فلاتر می‌گوییم
                // که نیازی به ساخت مجدد آن در هر بار رندر نیست و می‌تواند از همان نمونه قبلی استفاده کند.
                // این یک بهینه‌سازی کوچک اما مهم در عملکرد است.
                decoration: const InputDecoration(
                  labelText: 'کلید API ابری (Cloud API Key)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'کلید API خود را از ارائه‌دهنده سرویس ابری (مانند Google AI Studio) دریافت کنید.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 32),

              // --- بخش تنظیمات سرویس محلی ---
              Text('تنظیمات سرویس محلی', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: localUrlController,
                // اینجا هم از `const` برای بهینه‌سازی استفاده می‌کنیم.
                decoration: const InputDecoration(
                  labelText: 'آدرس سرور محلی (Local Server URL)',
                  hintText: 'http://10.0.2.2:1234',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'آدرس سرور محلی خود (مانند LM Studio) را وارد کنید. برای شبیه‌ساز اندروید از 10.0.2.2 استفاده کنید.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // --- دکمه ذخیره ---
              ElevatedButton(
                // طبق استاندارد فلاتر، بهتر است ابتدا تمام پارامترهای پیکربندی (مانند onPressed و style)
                // را تعریف کرده و در آخر، پارامتر `child` را قرار دهیم.
                // این کار خوانایی کد را، به خصوص برای ویجت‌های پیچیده، افزایش می‌دهد.
                onPressed: () {
                  final settingsNotifier = ref.read(settingsProvider.notifier);
                  settingsNotifier.setCloudApiKey(apiKeyController.text);
                  settingsNotifier.setLocalApiUrl(localUrlController.text);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تنظیمات با موفقیت ذخیره شد!')),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)
                ),
                child: const Text('ذخیره تنظیمات'),
              ),
            ],
          );
        },
      ),
    );
  }
}
