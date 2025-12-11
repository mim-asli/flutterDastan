import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/providers.dart';
import 'package:myapp/widgets/vital_sign_indicator.dart';

class GameSidePanel extends ConsumerStatefulWidget {
  const GameSidePanel({super.key});

  @override
  ConsumerState<GameSidePanel> createState() => _GameSidePanelState();
}

class _GameSidePanelState extends ConsumerState<GameSidePanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.monitor_heart, 'label': 'علائم حیاتی'}, // Vital Signs
    {'icon': Icons.backpack, 'label': 'موجودی'}, // Inventory
    {'icon': Icons.person, 'label': 'مهارت‌ها'}, // Skills/Character
    {'icon': Icons.assignment, 'label': 'مأموریت‌ها'}, // Missions
    {'icon': Icons.theater_comedy, 'label': 'صحنه'}, // Scene
    {'icon': Icons.handyman, 'label': 'ساخت'}, // Crafting
    {'icon': Icons.map, 'label': 'نقشه'}, // Map
    {'icon': Icons.public, 'label': 'جهان'}, // World
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320, // Fixed width for panel
      decoration: const BoxDecoration(
        color: Color(0xFF151515), // Deep dark background
        border: Border(
          right: BorderSide(
            color: Color(0xFF2A2A2A), // Subtle separator
            width: 1,
          ),
        ),
      ),
      child: Row(
        // RTL Layout: Navigation Rail on the Right
        children: [
          // Navigation Rail (Standard NavigationRail is always at Start)
          // In RTL: Right side. In LTR: Left side.
          Container(
            width: 80,
            color: const Color(0xFF0F0F0F), // Slightly darker rail
            child: Column(
              children: [
                const SizedBox(height: 20),
                // App Logo / Main Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_stories,
                      color: Colors.redAccent, size: 28),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.separated(
                    itemCount: _tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _tabController.index == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _tabController.animateTo(index);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF252525)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: Colors.white24, width: 0.5)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _tabs[index]['icon'] as IconData,
                                color:
                                    isSelected ? Colors.white : Colors.white38,
                                size: 22,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _tabs[index]['label'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white38,
                                  fontSize: 10,
                                  fontFamily: 'Vazirmatn',
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StatusTab(),
                InventoryTab(),
                CharacterTab(),
                MissionsTab(),
                SceneTab(),
                CraftingTab(),
                MapTab(),
                WorldTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TABS CONTENT
// -----------------------------------------------------------------------------

class StatusTab extends ConsumerWidget {
  const StatusTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    return Container(
      color: const Color(0xFF151515),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('علائم حیاتی',
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              VitalSignIndicator(
                  label: 'سلامتی',
                  value: stats.health,
                  color: const Color(0xFF00FF9D), // Neon Green
                  icon: Icons.favorite),
              VitalSignIndicator(
                  label: 'عقلانیت',
                  value: stats.sanity,
                  color: const Color(0xFFD500F9), // Neon Purple
                  icon: Icons.psychology),
              VitalSignIndicator(
                  label: 'سیری',
                  value: stats.hunger,
                  color: const Color(0xFFFFAB00), // Neon Orange
                  icon: Icons.restaurant),
              VitalSignIndicator(
                  label: 'تشنگی',
                  value: stats.thirst,
                  color: const Color(0xFF00B0FF), // Neon Blue
                  icon: Icons.water_drop),
              VitalSignIndicator(
                  label: 'انرژی',
                  value: stats.energy,
                  color: const Color(0xFFFFEA00), // Neon Yellow
                  icon: Icons.flash_on),
              VitalSignIndicator(
                  label: 'مانا',
                  value: stats.energy,
                  color: const Color(0xFF651FFF), // Deep Purple
                  icon: Icons.auto_awesome),
            ],
          ),
        ],
      ),
    );
  }
}

class InventoryTab extends ConsumerWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    return Container(
      color: const Color(0xFF151515),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text('موجودی',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: inventory.isEmpty
                ? const Center(
                    child: Text('کوله پشتی خالی است',
                        style: TextStyle(color: Colors.white54)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: inventory.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = inventory[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            Text('(x1)',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(item.name,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Vazirmatn')),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CharacterTab extends ConsumerWidget {
  const CharacterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameConfigProvider);
    final stats = ref.watch(statsProvider);
    final skills = ref.watch(skillsProvider);

    if (config == null) {
      return const Center(child: Text('اطلاعات شخصیت در دسترس نیست.'));
    }

    return Container(
      color: const Color(0xFF151515),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('مهارت‌ها و ویژگی‌ها',
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('توانایی‌ها و خصوصیات منحصر به فرد شما',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white38, fontSize: 11)),

          const SizedBox(height: 24),

          _buildInfoCard('نام: ${config.characterName}'),
          _buildInfoCard('کهن‌الگو: ${config.characterClass}'),
          // _buildInfoCard('ویژگی‌ها: کاریزماتیک'), // Dynamic trait if available

          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 24),

          _buildStatRow('سطح', '${stats.level}'),
          _buildStatRow('تجربه', '${stats.xp}'),

          const SizedBox(height: 24),
          // Skills List
          if (skills.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'هنوز مهارتی آموخته نشده است.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            )
          else
            ...skills.map((skill) => _buildSkillCard(skill)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(text,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }

  Widget _buildSkillCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(text,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class MissionsTab extends ConsumerWidget {
  const MissionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);

    return Container(
      color: const Color(0xFF151515),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('مأموریت‌ها',
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (missions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  'هیچ مأموریت فعالی ندارید.',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            ...missions.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(m,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white, height: 1.4)),
                )),
        ],
      ),
    );
  }
}

class SceneTab extends ConsumerWidget {
  const SceneTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entities = ref.watch(sceneEntitiesProvider);

    return Container(
      color: const Color(0xFF151515),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('صحنه',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: entities.isEmpty
                ? const Center(
                    child: Text(
                      'هیچ چیزی در صحنه قابل مشاهده نیست.',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: entities.length,
                    itemBuilder: (context, index) {
                      final e = entities[index];
                      // Fallback icon if not present
                      final IconData icon = e['icon'] ?? Icons.help_outline;
                      final String name = e['name'] ?? 'ناشناس';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: Colors.greenAccent, size: 30),
                            const SizedBox(height: 8),
                            Text(name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CraftingTab extends ConsumerStatefulWidget {
  const CraftingTab({super.key});

  @override
  ConsumerState<CraftingTab> createState() => _CraftingTabState();
}

class _CraftingTabState extends ConsumerState<CraftingTab> {
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

    return Container(
      color: const Color(0xFF151515),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'ساخت و ساز',
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'دو آیتم را برای ترکیب انتخاب کنید',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: inventory.isEmpty
                ? const Center(
                    child: Text('کوله‌پشتی شما خالی است.',
                        style: TextStyle(color: Colors.white54)))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.deepPurple.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: Colors.deepPurpleAccent)
                                : null,
                          ),
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
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.white)),
                                  ])),
                        ),
                      );
                    },
                  ),
          ),
          if (_isCrafting)
            const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.build),
                label: const Text('ترکیب آیتم‌ها'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: selection.length == 2 ? _onCraftPressed : null,
              ),
            ),
        ],
      ),
    );
  }
}

class MapTab extends ConsumerWidget {
  const MapTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(knownLocationsProvider);

    return Container(
      color: const Color(0xFF101010),
      child: Stack(
        children: [
          // Background Placeholder for Map (Darker/Hidden if empty)
          Positioned.fill(
            child: Opacity(
              opacity: locations.isEmpty ? 0.05 : 0.2, // Darker if unknown
              child: Image.network(
                  'https://via.placeholder.com/800x600/003300/FFFFFF?text=Map',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(
                      child:
                          Icon(Icons.map, size: 100, color: Colors.white10))),
            ),
          ),

          // Map Labels (Dynamic)
          if (locations.isNotEmpty)
            ...locations.map((loc) {
              final double top = loc['top'] ?? 0.0;
              final double left = loc['left'] ?? 0.0;
              final double? right = loc['right'];
              final double? bottom = loc['bottom'];

              return Positioned(
                top: top,
                left: right == null ? left : null,
                right: right,
                bottom: bottom,
                child: _MapLabel(loc['name'] ?? 'مکان نامشخص'),
              );
            })
          else
            const Center(
              child: Text(
                'نقشه جهان هنوز کشف نشده است.',
                style: TextStyle(color: Colors.white38),
              ),
            ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'نقشه جهان',
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  final String label;
  const _MapLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24)),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}

class WorldTab extends ConsumerWidget {
  const WorldTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worldState = ref.watch(worldStateProvider);
    return Container(
      color: const Color(0xFF151515),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'وضعیت جهان',
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          // Time Widget
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(worldState.timeOfDay,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const Text('زمان روز',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 20),
              const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 48),
            ],
          ),

          const SizedBox(height: 40),

          // Day Count
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('روز ${worldState.dayCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900)),
                  const Text('از شروع ماجراجویی',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Weather
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(worldState.weather,
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(width: 20),
              const Icon(Icons.wb_cloudy, color: Colors.blueGrey, size: 32),
            ],
          ),
        ],
      ),
    );
  }
}
