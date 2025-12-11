import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:myapp/providers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class SaveLoadContent extends ConsumerWidget {
  const SaveLoadContent({super.key});

  void _showConfirmDialog(BuildContext context, WidgetRef ref,
      {required String title,
      required String content,
      required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
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

    return Container(
      color: const Color(0xFF151515),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'مدیریت فایل‌های ذخیره',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: saveSlotsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('خطا در بارگذاری: $err')),
              data: (slots) {
                return slots.isEmpty
                    ? const Center(
                        child: Text('هیچ بازی ذخیره شده‌ای وجود ندارد.',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: slots.length,
                        itemBuilder: (context, index) {
                          final slot = slots[index];
                          final formattedDate = DateFormat('yyyy/MM/dd – kk:mm')
                              .format(slot.saveDate);
                          return Card(
                            color: Colors.white.withValues(alpha: 0.05),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 6),
                            child: ListTile(
                              title: Text('ذخیره اسلات ${slot.id}',
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(formattedDate,
                                  style:
                                      const TextStyle(color: Colors.white54)),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.upload_file,
                                            color: Colors.blueAccent),
                                        tooltip: "صادرات JSON",
                                        onPressed: () => _exportSaveSlot(
                                            context, ref, slot.id!)),
                                    IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.redAccent),
                                        tooltip: "حذف",
                                        onPressed: () => _showConfirmDialog(
                                                context, ref,
                                                title: "حذف ذخیره",
                                                content:
                                                    "آیا از حذف این اسلات مطمئن هستید؟ این عمل غیرقابل بازگشت است.",
                                                onConfirm: () async {
                                              await ref
                                                  .read(gameControllerProvider
                                                      .notifier)
                                                  .deleteGame(slot.id!);
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'اسلات با موفقیت حذف شد.')));
                                            })),
                                    IconButton(
                                        icon: const Icon(
                                            Icons.drive_file_move_outline,
                                            color: Colors.white70),
                                        tooltip: "بازنویسی",
                                        onPressed: () => _showConfirmDialog(
                                                context, ref,
                                                title: "بازنویسی ذخیره",
                                                content:
                                                    "آیا می‌خواهید این اسلات را با وضعیت فعلی بازی بازنویسی کنید؟",
                                                onConfirm: () async {
                                              await ref
                                                  .read(gameControllerProvider
                                                      .notifier)
                                                  .saveGame(id: slot.id);
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
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
                                        content: Text(
                                            'بازی با موفقیت بارگذاری شد.')));
                              }),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.download_outlined),
                label: const Text('وارد کردن'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () => _importSaveSlot(context, ref),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('ذخیره جدید'),
                onPressed: () async {
                  await ref.read(gameControllerProvider.notifier).saveGame();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('بازی با موفقیت در اسلات جدید ذخیره شد.')));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
