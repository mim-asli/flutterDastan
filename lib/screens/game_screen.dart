import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:myapp/widgets/help_dialog.dart';
import 'package:myapp/widgets/tts_settings_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final storyLog = ref.watch(storyLogProvider);
    final options = ref.watch(optionsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final worldState = ref.watch(worldStateProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text('دنیای تاریک',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              'روز ${worldState.dayCount} - ${worldState.timeOfDay} - ${worldState.weather}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'تنظیمات صدا',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const TtsSettingsDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'راهنما',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const HelpDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: () => _showExitConfirmDialog(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context, stats),
      body: Column(
        children: [
          // Story Area
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (storyLog.isEmpty)
                      const Center(child: Text('...'))
                    else
                      Text(
                        storyLog.last,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      ).animate().fadeIn(duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),

          // Interaction Area
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('راوی در حال نوشتن...',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A3A3A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            ref
                                .read(gameControllerProvider.notifier)
                                .processUserInput(options[index]);
                          },
                          child: Text(
                            options[index],
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ).animate().slideY(
                              begin: 0.5,
                              end: 0,
                              delay: (index * 100).ms,
                              duration: 400.ms,
                              curve: Curves.easeOutQuad,
                            );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, GameStats stats) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: const Color(0xFF1E1E1E),
      child: DefaultTabController(
        length: 7,
        child: Column(
          children: [
            const SizedBox(height: 40),
            const TabBar(
              isScrollable: true,
              indicatorColor: Colors.deepPurple,
              labelColor: Colors.deepPurpleAccent,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.person), text: 'وضعیت'),
                Tab(icon: Icon(Icons.backpack), text: 'کوله'),
                Tab(icon: Icon(Icons.face), text: 'شخصیت'),
                Tab(icon: Icon(Icons.landscape), text: 'صحنه'),
                Tab(icon: Icon(Icons.build), text: 'ساخت'),
                Tab(icon: Icon(Icons.map), text: 'نقشه'),
                Tab(icon: Icon(Icons.public), text: 'جهان'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _StatusTab(stats: stats),
                  const _InventoryTab(),
                  const _CharacterTab(),
                  const _SceneTab(),
                  const _CraftingTab(),
                  const _MapTab(),
                  const _WorldTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خروج به لابی'),
        content: const Text('آیا مطمئن هستید؟ پیشرفت شما ذخیره خواهد شد.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}

// --- Tabs ---

class _StatusTab extends StatelessWidget {
  final GameStats stats;
  const _StatusTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatBar('سلامتی', stats.health, Colors.red),
        _buildStatBar('روان', stats.sanity, Colors.blue),
        _buildStatBar('انرژی', stats.energy, Colors.amber),
        _buildStatBar('گرسنگی', stats.hunger, Colors.orange),
        _buildStatBar('تشنگی', stats.thirst, Colors.cyan),
        _buildStatBar('روحیه', stats.morale, Colors.purple),
        _buildStatBar('خستگی', stats.fatigue, Colors.grey, isReverse: true),
      ],
    );
  }

  Widget _buildStatBar(String label, int value, Color color,
      {bool isReverse = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$value/100'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _InventoryTab extends ConsumerWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    return inventory.isEmpty
        ? const Center(child: Text('کوله پشتی خالی است'))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final item = inventory[index];
              return Card(
                color: Colors.white10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.backpack, size: 32, color: Colors.white70),
                    const SizedBox(height: 8),
                    Text(item.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          );
  }
}

class _CharacterTab extends ConsumerWidget {
  const _CharacterTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameConfigProvider);
    final stats = ref.watch(statsProvider);

    if (config == null) {
      return const Center(child: Text('اطلاعات شخصیت در دسترس نیست.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(config.characterName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(config.characterClass,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white70)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildStatRow(context, 'سطح', '${stats.level}'),
          _buildStatRow(context, 'تجربه', '${stats.xp}'),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildStatRow(context, 'سلامتی', '${stats.health}%',
              icon: Icons.favorite, color: Colors.redAccent),
          _buildStatRow(context, 'روان', '${stats.sanity}%',
              icon: Icons.psychology, color: Colors.blueAccent),
          _buildStatRow(context, 'انرژی', '${stats.energy}%',
              icon: Icons.flash_on, color: Colors.yellowAccent),
          _buildStatRow(context, 'گرسنگی', '${stats.hunger}%',
              icon: Icons.restaurant, color: Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value,
      {IconData? icon, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color ?? Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _SceneTab extends StatelessWidget {
  const _SceneTab();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.landscape, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text('صحنه فعلی', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('توصیف بصری صحنه در اینجا نمایش داده می‌شود.',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),
          const Text('(قابلیت تولید تصویر در فازهای بعدی)',
              style: TextStyle(
                  color: Colors.white24, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _CraftingTab extends ConsumerStatefulWidget {
  const _CraftingTab();

  @override
  ConsumerState<_CraftingTab> createState() => _CraftingTabState();
}

class _CraftingTabState extends ConsumerState<_CraftingTab> {
  bool _isCrafting = false;

  Future<void> _onCraftPressed() async {
    setState(() {
      _isCrafting = true;
    });

    final response =
        await ref.read(gameControllerProvider.notifier).craftSelectedItems();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.message),
          backgroundColor:
              response.success ? Colors.green.shade700 : Colors.red.shade700));
      setState(() {
        _isCrafting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final selection = ref.watch(craftingSelectionProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'دو آیتم را برای ترکیب انتخاب کنید',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: inventory.isEmpty
              ? const Center(child: Text('کوله‌پشتی شما خالی است.'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8),
                  padding: const EdgeInsets.all(16),
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    final isSelected = selection.contains(item);
                    return InkWell(
                      onTap: () {
                        ref
                            .read(craftingSelectionProvider.notifier)
                            .update((state) {
                          if (isSelected) return state..remove(item);
                          if (state.length < 2) return [...state, item];
                          return state;
                        });
                      },
                      child: Card(
                        color: isSelected
                            ? Colors.deepPurple.shade300
                            : Colors.white10,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.inventory_2_outlined,
                                      size: 32, color: Colors.white70),
                                  const SizedBox(height: 8),
                                  Text(item.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12)),
                                ])),
                      ),
                    );
                  },
                ),
        ),
        if (_isCrafting)
          const Padding(
              padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())
        else
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.build),
              label: const Text('ترکیب آیتم‌ها'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.deepPurple),
              onPressed: selection.length == 2 ? _onCraftPressed : null,
            ),
          ),
      ],
    );
  }
}

class _MapTab extends StatelessWidget {
  const _MapTab();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 100, color: Colors.white24),
          const SizedBox(height: 16),
          Text('نقشه جهان', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('موقعیت شما روی نقشه نمایش داده خواهد شد.',
              style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class _WorldTab extends ConsumerWidget {
  const _WorldTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worldState = ref.watch(worldStateProvider);
    final config = ref.watch(gameConfigProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getWeatherIcon(worldState.weather),
              size: 80, color: Colors.white70),
          const SizedBox(height: 16),
          Text(worldState.weather,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(worldState.timeOfDay,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 32),
          Text('روز ${worldState.dayCount}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.deepPurpleAccent)),
          const SizedBox(height: 16),
          if (config != null)
            Text('جهان: ${config.worldName}',
                style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String weather) {
    if (weather.contains('باران')) return Icons.water_drop;
    if (weather.contains('برف')) return Icons.ac_unit;
    if (weather.contains('ابری')) return Icons.cloud;
    if (weather.contains('طوفان')) return Icons.thunderstorm;
    return Icons.wb_sunny;
  }
}
