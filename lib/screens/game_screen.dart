import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myapp/providers.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:myapp/widgets/side_panel.dart';
import 'package:myapp/widgets/tts_settings_dialog.dart';
import 'package:myapp/widgets/adaptive_layout_wrapper.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPanelOpen = false; // For mobile drawer
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _inputController = TextEditingController();

  // Speech to Text
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
    });
  }

  Future<void> _listen() async {
    if (!_isListening) {
      // Request permission functionality is handled by initialize usually,
      // but explicit permission check is good practice
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) return;
      }

      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorNotification')),
          );
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _inputController.text = val.recognizedWords;
          }),
          localeId: 'fa_IR', // Persian locale
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _inputController.dispose();
    _speech.cancel(); // Cancel speaking if disposing
    super.dispose();
  }

  void _handleOptionSelect(String text) {
    ref.read(gameControllerProvider.notifier).processUserInput(text);
  }

  void _handleInputSubmit() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _handleOptionSelect(text);
      _inputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keyboard shortcuts handler
    return KeyboardListener(
      focusNode: FocusNode(), // Dummy node to capture keys
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final options = ref.read(optionsProvider);
          if (event.logicalKey == LogicalKeyboardKey.digit1 &&
              options.isNotEmpty) {
            _handleOptionSelect(options[0]);
          } else if (event.logicalKey == LogicalKeyboardKey.digit2 &&
              options.length > 1) {
            _handleOptionSelect(options[1]);
          } else if (event.logicalKey == LogicalKeyboardKey.digit3 &&
              options.length > 2) {
            _handleOptionSelect(options[2]);
          } else if (event.logicalKey == LogicalKeyboardKey.digit4 &&
              options.length > 3) {
            _handleOptionSelect(options[3]);
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (_inputFocusNode.hasFocus) {
              _handleInputSubmit();
            } else {
              _inputFocusNode.requestFocus();
            }
          }
        }
      },
      child: AdaptiveLayoutWrapper(
        builder: (context, isMobile, isTablet, isDesktop) {
          if (isDesktop) {
            return _buildDesktopLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  // --- Desktop Layout ---
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Blacker background
      body: Row(
        // In RTL (Persian), the first child appears on the Right.
        // So [GameSidePanel, Expanded(...) ] means Panel is on Right, Main Content on Left.
        // This is correct for the desired RTL dashboard layout.
        children: [
          // SidePanel (Right side in fa_IR)
          const SizedBox(
            width: 320,
            child: GameSidePanel(),
          ),

          // Main Content (Left side in fa_IR)
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context, isDesktop: true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, // Padding from Left (End side in RTL)
                        top: 10,
                        bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Arrow indicator (Pointing to panel? visual only)
                        const SizedBox(
                            width: 20,
                            child: Center(
                                child: Icon(
                                    Icons
                                        .keyboard_arrow_right, // Corrected arrow direction for RTL
                                    color: Colors.white24))),

                        // Story Log (Center)
                        Expanded(
                          flex: 3,
                          child: _buildStoryLayoutV2(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Refined Desktop Layout to match Image 3 (Story Top, Actions Bottom)
  Widget _buildStoryLayoutV2(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildStoryArea(context)),
        const SizedBox(height: 16),
        SizedBox(
          height: 300, // Fixed height for actions
          child: _buildInteractionArea(context),
        ),
      ],
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            // In RTL, margin left/right logic is reversed if using Directionality? No, margin is logical usually?
            // EdgeInsets.only(left: ...) is physical.
            // For RTL slide, we want the main content to slide Left (negative X) or Right?
            // If panel is on Right (start), content should slide Left (margin Right increases?)
            // Let's use Directionality.of(context) to be safe or just physical margins for RTL 'fa'.
            // Simpler: Just make the main content shrink or translation.
            // Let's implement standard EndDrawer behavior manually using Stack.
            // In RTL, Start is Right. Panel slides from Right.
            // Content stays put, Panel covers it (Overlay) OR Content pushes.
            // Let's do Overlay for mobile as it preserves space better.
            child: Column(
              children: [
                _buildAppBar(context, isDesktop: false),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildStoryLayoutV2(context),
                  ),
                ),
              ],
            ),
          ),

          // Backdrop
          if (_isPanelOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePanel,
                child: Container(
                  color: Colors.black54,
                ),
              ),
            ),

          // Sliding Panel (From Right/Start in RTL)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            // In RTL context:
            // "right" property aligns from right edge.
            // If open: right: 0. If closed: right: -320.
            right: _isPanelOpen ? 0 : -320,
            top: 0,
            bottom: 0,
            width: 320,
            child: const Material(
              // Added Material for elevation/shadow
              elevation: 16,
              color: Colors.transparent,
              child: GameSidePanel(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Shared Widgets ---

  Widget _buildStoryArea(BuildContext context) {
    final storyLog = ref.watch(storyLogProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent, // Transparent to blend
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: storyLog.length,
        itemBuilder: (context, index) {
          final reversedIndex = storyLog.length - 1 - index;
          final text = storyLog[reversedIndex];
          final isNewest = reversedIndex == storyLog.length - 1;

          // Check if text is speaker label or narration
          // Simple heuristic: if contains ':', bold the part before it.
          // For now, implementing standard rich text.

          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: isNewest
                ? AnimatedTextKit(
                    key: ValueKey(text.hashCode),
                    animatedTexts: [
                      TypewriterAnimatedText(
                        text,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          height: 2.0, // Increased line height
                          color: Color(0xFFE0E0E0),
                          fontFamily: 'Vazirmatn',
                        ),
                        textAlign: TextAlign.justify,
                        speed: const Duration(milliseconds: 20),
                        cursor: '▋',
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                    isRepeatingAnimation: false,
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 2.0,
                      color: Color(0xFFE0E0E0),
                      fontFamily: 'Vazirmatn',
                    ),
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl, // Explicit RTL
                  ),
          );
        },
      ),
    );
  }

  Widget _buildInteractionArea(BuildContext context) {
    final options = ref.watch(optionsProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hint or extra controls could go here
              Container(),
              Text(
                'اقدامات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazirmatn'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.redAccent),
                        SizedBox(height: 16),
                        Text('راوی در حال فکر کردن...',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildOptionButton(context, options[index], index);
                    },
                  ),
          ),
          const SizedBox(height: 16),
          // Input Field with STT
          Row(
            children: [
              // Microphone Button
              Container(
                decoration: BoxDecoration(
                  color: _isListening
                      ? Colors.redAccent
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  color: _isListening ? Colors.white : Colors.white70,
                  onPressed: _listen,
                  tooltip: 'گفتگو (Hold to speak)',
                ),
              ),
              const SizedBox(width: 10),

              // Text Field
              Expanded(
                child: TextField(
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  onSubmitted: (_) => _handleInputSubmit(),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                      hintText: 'چه کار می‌کنید؟',
                      hintStyle: const TextStyle(
                          color: Colors.white30, fontFamily: 'Vazirmatn'),
                      hintTextDirection: TextDirection.rtl,
                      filled: true,
                      fillColor: Colors.black12,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: IconButton(
                        // Send button on left because RTL
                        icon: const Icon(Icons.send, color: Colors.redAccent),
                        onPressed: _handleInputSubmit,
                      )),
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Vazirmatn'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String text, int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.03),
        foregroundColor: Colors.white,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        elevation: 0,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.08);
            }
            return null;
          },
        ),
      ),
      onPressed: () => _handleOptionSelect(text),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
              child: Text(text,
                  style:
                      const TextStyle(fontSize: 14, fontFamily: 'Vazirmatn'))),
          Row(
            children: [
              const Icon(Icons.arrow_back_ios_new, // Pointing left for RTL
                  size: 12,
                  color: Colors.white30),
              const SizedBox(width: 8),
              if (index < 4)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text('${index + 1}',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 10)),
                ),
            ],
          ),
        ],
      ),
    ).animate().slideX(
          begin: 0.1,
          end: 0,
          delay: (index * 50).ms,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildAppBar(BuildContext context, {required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.transparent,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            tooltip: 'خروج',
            onPressed: () => _showExitConfirmDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white70),
            tooltip: 'تنظیمات صدا',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const TtsSettingsDialog(),
              );
            },
          ),
          const Spacer(),
          const Text('داستان',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazirmatn',
                  color: Colors.red)),
          if (!isDesktop) ...[
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                _isPanelOpen ? Icons.menu_open : Icons.menu,
                color: Colors.white,
              ),
              onPressed: _togglePanel,
            ),
          ],
        ],
      ),
    );
  }

  void _showExitConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text('خروج به لابی',
            style: TextStyle(color: Colors.white), textAlign: TextAlign.right),
        content: const Text('آیا مطمئن هستید؟ پیشرفت شما ذخیره خواهد شد.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade900),
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
