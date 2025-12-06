import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/providers.dart';
import 'package:myapp/providers/settings_provider.dart';
import 'package:myapp/services/local_ai_service.dart';
import 'package:myapp/services/cloud_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
      'aiServiceProvider returns LocalAIService with correct URL when type is local',
      () async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({
      'aiProviderType': AiProviderType.local.index,
      'localApiUrl': 'http://test-url:1234',
    });

    final container = ProviderContainer();

    // Wait for settings to load
    final settingsNotifier = container.read(settingsProvider.notifier);
    if (container.read(settingsProvider).isLoading) {
      await settingsNotifier.stream.firstWhere((state) => !state.isLoading);
    }

    final aiService = container.read(aiServiceProvider);

    expect(aiService, isA<LocalAIService>());
    expect((aiService as LocalAIService).baseUrl, 'http://test-url:1234');
  });

  test('aiServiceProvider returns CloudAIService when type is cloud', () async {
    SharedPreferences.setMockInitialValues({
      'aiProviderType': AiProviderType.cloud.index,
      'cloudApiKey': 'test-api-key',
    });

    final container = ProviderContainer();
    final settingsNotifier = container.read(settingsProvider.notifier);
    if (container.read(settingsProvider).isLoading) {
      await settingsNotifier.stream.firstWhere((state) => !state.isLoading);
    }

    final aiService = container.read(aiServiceProvider);

    expect(aiService, isA<CloudAIService>());
  });
}
