import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/data/game_data.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers.dart';
import 'package:myapp/screens/game_screen.dart';

final newGameWizardProvider =
    StateNotifierProvider<NewGameWizardNotifier, WizardState>((ref) {
  return NewGameWizardNotifier();
});

class WizardState {
  final String worldName;
  final String genre;
  final String difficulty;
  final String narratorStyle;
  final String characterName;
  final String characterClass;
  final List<String> selectedItems;
  final String startingScenario;

  WizardState({
    this.worldName = '',
    this.genre = 'Fantasy',
    this.difficulty = 'Medium',
    this.narratorStyle = 'Epic',
    this.characterName = '',
    this.characterClass = '',
    this.selectedItems = const [],
    this.startingScenario = '',
  });

  WizardState copyWith({
    String? worldName,
    String? genre,
    String? difficulty,
    String? narratorStyle,
    String? characterName,
    String? characterClass,
    List<String>? selectedItems,
    String? startingScenario,
  }) {
    return WizardState(
      worldName: worldName ?? this.worldName,
      genre: genre ?? this.genre,
      difficulty: difficulty ?? this.difficulty,
      narratorStyle: narratorStyle ?? this.narratorStyle,
      characterName: characterName ?? this.characterName,
      characterClass: characterClass ?? this.characterClass,
      selectedItems: selectedItems ?? this.selectedItems,
      startingScenario: startingScenario ?? this.startingScenario,
    );
  }
}

class NewGameWizardNotifier extends StateNotifier<WizardState> {
  NewGameWizardNotifier() : super(WizardState());

  void updateWorldName(String name) => state = state.copyWith(worldName: name);
  void updateGenre(String genre) => state = state.copyWith(genre: genre);
  void updateDifficulty(String difficulty) =>
      state = state.copyWith(difficulty: difficulty);
  void updateNarratorStyle(String style) =>
      state = state.copyWith(narratorStyle: style);
  void updateCharacterName(String name) =>
      state = state.copyWith(characterName: name);
  void updateCharacterClass(String charClass) =>
      state = state.copyWith(characterClass: charClass);
  void updateStartingScenario(String scenario) =>
      state = state.copyWith(startingScenario: scenario);

  void toggleItem(String itemId) {
    final items = List<String>.from(state.selectedItems);
    if (items.contains(itemId)) {
      items.remove(itemId);
    } else {
      // محدودیت تعداد آیتم بر اساس سختی (مثلاً)
      // فعلاً ساده: حداکثر ۳ آیتم
      if (items.length < 3) {
        items.add(itemId);
      }
    }
    state = state.copyWith(selectedItems: items);
  }
}

class NewGameWizard extends ConsumerStatefulWidget {
  const NewGameWizard({super.key});

  @override
  ConsumerState<NewGameWizard> createState() => _NewGameWizardState();
}

class _NewGameWizardState extends ConsumerState<NewGameWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
  }

  void _prevPage() {
    _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ساخت داستان جدید (${_currentPage + 1}/5)'),
        centerTitle: true,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevPage,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                const WorldBasicsPage(),
                const CharacterProfilePage(),
                const StartingItemsPage(),
                const StartingScenarioPage(),
                const SummaryPage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  OutlinedButton(
                    onPressed: _prevPage,
                    child: const Text('قبلی'),
                  )
                else
                  const SizedBox.shrink(),
                FilledButton(
                  onPressed: _currentPage < 4
                      ? _nextPage
                      : () async {
                          final wizardState = ref.read(newGameWizardProvider);
                          final config = GameConfig(
                            worldName: wizardState.worldName,
                            genre: wizardState.genre,
                            difficulty: wizardState.difficulty,
                            narratorStyle: wizardState.narratorStyle,
                            characterName: wizardState.characterName,
                            characterClass: wizardState.characterClass,
                            selectedItems: wizardState.selectedItems,
                            startingScenario: wizardState.startingScenario,
                          );

                          // شروع بازی جدید
                          await ref
                              .read(gameControllerProvider.notifier)
                              .startNewGame(config);

                          if (context.mounted) {
                            // رفتن به صفحه اصلی بازی و حذف تمام صفحات قبلی (مثل ویزارد و ولکام)
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const GameScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                  child: Text(_currentPage < 4 ? 'بعدی' : 'شروع بازی'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- صفحه ۱: مبانی جهان ---
class WorldBasicsPage extends ConsumerWidget {
  const WorldBasicsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(newGameWizardProvider);
    final notifier = ref.read(newGameWizardProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '۱. مبانی جهان',
            style: GoogleFonts.vazirmatn(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'قوانین و حال و هوای کلی دنیای خود را مشخص کنید.',
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // نام جهان
          TextField(
            style: GoogleFonts.vazirmatn(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'عنوان سناریو (مثلا: انتقام جادوگر تاریکی)',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withAlpha(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDB3838)),
              ),
            ),
            onChanged: notifier.updateWorldName,
          ),
          const SizedBox(height: 32),

          // ژانر داستان
          Text(
            'ژانر',
            style: GoogleFonts.vazirmatn(
              fontSize: 16,
              color: const Color(0xFFDB3838),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _SelectionCard(
                label: 'فانتزی',
                icon: Icons.auto_fix_high,
                isSelected: wizardState.genre == 'Fantasy',
                onTap: () => notifier.updateGenre('Fantasy'),
              ),
              _SelectionCard(
                label: 'علمی-تخیلی',
                icon: Icons.rocket_launch,
                isSelected: wizardState.genre == 'Sci-Fi',
                onTap: () => notifier.updateGenre('Sci-Fi'),
              ),
              _SelectionCard(
                label: 'ترسناک',
                icon: Icons.psychology_alt, // Skull replacement
                isSelected: wizardState.genre == 'Horror',
                onTap: () => notifier.updateGenre('Horror'),
              ),
              _SelectionCard(
                label: 'ماجراجویی',
                icon: Icons.explore,
                isSelected: wizardState.genre == 'Adventure',
                onTap: () => notifier.updateGenre('Adventure'),
              ),
              _SelectionCard(
                label: 'معمایی',
                icon: Icons.fingerprint,
                isSelected: wizardState.genre == 'Mystery',
                onTap: () => notifier.updateGenre('Mystery'),
              ),
              _SelectionCard(
                label: 'پسا-آخرالزمانی',
                icon: Icons.warning_amber, // Radioactive replacement
                isSelected: wizardState.genre == 'Post-Apocalyptic',
                onTap: () => notifier.updateGenre('Post-Apocalyptic'),
              ),
              _SelectionCard(
                label: 'ابرقهرمانی',
                icon: Icons.bolt,
                isSelected: wizardState.genre == 'Superheroic',
                onTap: () => notifier.updateGenre('Superheroic'),
              ),
              _SelectionCard(
                label: 'کلاسیک',
                icon: Icons.account_balance,
                isSelected: wizardState.genre == 'Slice of Life',
                onTap: () => notifier.updateGenre('Slice of Life'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // سطح سختی
          Text(
            'سطح دشواری',
            style: GoogleFonts.vazirmatn(
              fontSize: 16,
              color: const Color(0xFFDB3838),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SelectionCard(
                  label: 'آسان\n(امتیاز 15)',
                  isSelected: wizardState.difficulty == 'Easy',
                  onTap: () => notifier.updateDifficulty('Easy'),
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SelectionCard(
                  label: 'معمولی\n(امتیاز 10)',
                  isSelected: wizardState.difficulty == 'Medium',
                  onTap: () => notifier.updateDifficulty('Medium'),
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SelectionCard(
                  label: 'سخت\n(امتیاز 7)',
                  isSelected: wizardState.difficulty == 'Hard',
                  onTap: () => notifier.updateDifficulty('Hard'),
                  isSmall: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // سبک راوی
          Text(
            'سبک راوی (GM)',
            style: GoogleFonts.vazirmatn(
              fontSize: 16,
              color: const Color(0xFFDB3838),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: wizardState.narratorStyle,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E1E),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.white54),
                style: GoogleFonts.vazirmatn(color: Colors.white),
                items: const [
                  DropdownMenuItem(
                      value: 'Epic', child: Text('روایی و سینمایی')),
                  DropdownMenuItem(
                      value: 'Serious', child: Text('جدی و تاریک')),
                  DropdownMenuItem(value: 'Humorous', child: Text('طنز و شوخ')),
                  DropdownMenuItem(value: 'Romantic', child: Text('رمانتیک')),
                ],
                onChanged: (value) {
                  if (value != null) notifier.updateNarratorStyle(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSmall;

  const _SelectionCard({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : const Color(0xFF101010),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFDB3838) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white54,
                size: 28,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: isSmall ? 12 : 14,
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

// --- صفحه ۲: پروفایل شخصیت ---
class CharacterProfilePage extends ConsumerWidget {
  const CharacterProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(newGameWizardProvider);
    final notifier = ref.read(newGameWizardProvider.notifier);

    // دریافت کلاس‌های مربوط به ژانر انتخاب شده
    final classes = getClassesForGenre(wizardState.genre);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'قهرمان خود را بسازید',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // نام شخصیت
          TextField(
            decoration: const InputDecoration(
              labelText: 'نام شخصیت',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: notifier.updateCharacterName,
          ),
          const SizedBox(height: 24),

          const Text(
            'انتخاب کلاس',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // لیست کلاس‌ها
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: classes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final charClass = classes[index];
              final isSelected = wizardState.characterClass == charClass.id;

              return Card(
                color: isSelected ? Colors.deepPurple.withAlpha(100) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? const BorderSide(
                          color: Colors.deepPurpleAccent, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => notifier.updateCharacterClass(charClass.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              charClass.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (isSelected) ...[
                              const Spacer(),
                              const Icon(Icons.check_circle,
                                  color: Colors.greenAccent),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(charClass.description),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.add_circle_outline,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(charClass.strengths,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.greenAccent))),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.remove_circle_outline,
                                size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(charClass.weaknesses,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.redAccent))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- صفحه ۳: آیتم‌های آغازین ---
class StartingItemsPage extends ConsumerWidget {
  const StartingItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(newGameWizardProvider);
    final notifier = ref.read(newGameWizardProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تجهیزات سفر',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'حداکثر ۳ آیتم انتخاب کنید',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // لیست آیتم‌ها
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startingItems.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = startingItems[index];
              final isSelected = wizardState.selectedItems.contains(item.id);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  notifier.toggleItem(item.id);
                },
                title: Text(
                  '${item.icon} ${item.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item.description),
                activeColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? const BorderSide(color: Colors.deepPurple, width: 1)
                      : BorderSide.none,
                ),
                tileColor: isSelected ? Colors.deepPurple.withAlpha(20) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- صفحه ۴: سناریو آغازین ---
class StartingScenarioPage extends ConsumerWidget {
  const StartingScenarioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(newGameWizardProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'داستان چگونه آغاز می‌شود؟',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          const Text(
            'می‌توانید سناریوی آغازین خود را بنویسید یا آن را خالی بگذارید تا هوش مصنوعی تصمیم بگیرد.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          TextField(
            maxLines: 8,
            decoration: const InputDecoration(
              hintText:
                  'مثال: در یک مسافرخانه قدیمی بیدار می‌شوم در حالی که صدای فریاد از بیرون می‌آید...',
              border: OutlineInputBorder(),
            ),
            onChanged: notifier.updateStartingScenario,
          ),
          const SizedBox(height: 24),

          // در آینده: دکمه پیشنهاد هوش مصنوعی
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('این قابلیت در فاز بعدی اضافه می‌شود')),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('پیشنهاد هوش مصنوعی'),
          ),
        ],
      ),
    );
  }
}

// --- صفحه ۵: خلاصه و شروع ---
class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(newGameWizardProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'خلاصه ماجراجویی',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSummaryItem(
              'نام جهان',
              wizardState.worldName.isEmpty
                  ? '(بی‌نام)'
                  : wizardState.worldName),
          _buildSummaryItem('ژانر', wizardState.genre),
          _buildSummaryItem('سختی', wizardState.difficulty),
          _buildSummaryItem('سبک راوی', wizardState.narratorStyle),
          const Divider(height: 32),
          _buildSummaryItem(
              'نام قهرمان',
              wizardState.characterName.isEmpty
                  ? '(بی‌نام)'
                  : wizardState.characterName),
          _buildSummaryItem('کلاس', wizardState.characterClass),
          _buildSummaryItem(
              'تجهیزات',
              wizardState.selectedItems.isEmpty
                  ? '(هیچ)'
                  : '${wizardState.selectedItems.length} آیتم'),
          const Divider(height: 32),
          const Text('سناریو آغازین:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            wizardState.startingScenario.isEmpty
                ? 'تصمیم با هوش مصنوعی...'
                : wizardState.startingScenario,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
