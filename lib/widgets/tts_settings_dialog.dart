import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/providers.dart';

/// دیالوگ تنظیمات TTS
///
/// این دیالوگ به کاربر اجازه می‌دهد سرعت، زیر و بمی و وضعیت فعال/غیرفعال TTS را تنظیم کند.
class TtsSettingsDialog extends ConsumerStatefulWidget {
  const TtsSettingsDialog({super.key});

  @override
  ConsumerState<TtsSettingsDialog> createState() => _TtsSettingsDialogState();
}

class _TtsSettingsDialogState extends ConsumerState<TtsSettingsDialog> {
  late double _speechRate;
  late double _pitch;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final tts = ref.read(ttsServiceProvider);
    _speechRate = tts.speechRate;
    _pitch = tts.pitch;
    _isEnabled = tts.isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final tts = ref.watch(ttsServiceProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تنظیمات صدا'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // فعال/غیرفعال کردن TTS
              SwitchListTile(
                title: const Text('فعال‌سازی خواندن متن'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                  tts.setEnabled(value);
                },
              ),
              const Divider(),

              // تنظیم سرعت
              const Text(
                'سرعت خواندن',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text('کند'),
                  Expanded(
                    child: Slider(
                      value: _speechRate,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      label: _speechRate.toStringAsFixed(1),
                      onChanged: _isEnabled
                          ? (value) {
                              setState(() {
                                _speechRate = value;
                              });
                              tts.setSpeechRate(value);
                            }
                          : null,
                    ),
                  ),
                  const Text('سریع'),
                ],
              ),
              const SizedBox(height: 16),

              // تنظیم زیر و بمی
              const Text(
                'زیر و بمی صدا',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text('بم'),
                  Expanded(
                    child: Slider(
                      value: _pitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: _pitch.toStringAsFixed(1),
                      onChanged: _isEnabled
                          ? (value) {
                              setState(() {
                                _pitch = value;
                              });
                              tts.setPitch(value);
                            }
                          : null,
                    ),
                  ),
                  const Text('زیر'),
                ],
              ),
              const SizedBox(height: 16),

              // دکمه تست
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isEnabled
                      ? () {
                          tts.speak(
                              'این یک متن آزمایشی برای تست تنظیمات صداست.');
                        }
                      : null,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('تست صدا'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }
}
