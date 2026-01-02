import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/word_info_display.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  AnimationController? _menuController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  AnimationController get _controller {
    _menuController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    return _menuController!;
  }

  @override
  void dispose() {
    _menuController?.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildStyleOption(String style, IconData icon, int index, MyAppState appState) {
    final isSelected = appState.currentStyle == style;
    
    // Staggered animation: each item starts slightly later
    // Total items: 6. Duration: 300ms.
    // We want the bottom item (index 0) to appear first?
    // User asked "from bottom to top".
    // Let's assume the list is rendered in order [General, Tech, ...] from bottom up.
    
    // Let's define the interval based on index.
    // 6 items. 
    // Item 0: 0.0 - 0.5
    // Item 1: 0.1 - 0.6
    // ...
    // Item 5: 0.5 - 1.0
    
    final start = index * 0.1;
    final end = start + 0.5;
    
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeOutBack),
    );

    return ScaleTransition(
      scale: animation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
             // Label (Optional, showing on the left)
             if (_isMenuOpen)
               FadeTransition(
                 opacity: animation,
                 child: Container(
                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   margin: EdgeInsets.only(right: 8),
                   decoration: BoxDecoration(
                     color: Colors.black.withOpacity(0.6),
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: Text(
                     style,
                     style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                   ),
                 ),
               ),

            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFFF9900).withOpacity(0.8) 
                        : Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      appState.setStyle(style);
                      _toggleMenu();
                    },
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4), // Compensation to align 48px button center with 56px button center
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    final theme = Theme.of(context);

    IconData icon;
    if (appState.favoritePairs.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    
    String partOfSpeech = appState.currentInfo['part_of_speech'] ?? "...";

    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              // 1. Fixed Header (Word + Badge + TTS)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Word Group
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              pair.first.toLowerCase(),
                              style: theme.textTheme.displayLarge!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1.0,
                                fontFamily: 'Arial',
                              ),
                            ),
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9900),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                pair.second.toLowerCase(),
                                style: theme.textTheme.displayLarge!.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1.0,
                                  fontFamily: 'Arial',
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(width: 16),
                        
                        // Accessories Column (Badge + Speaker)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[700]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                partOfSpeech.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                 appState.speak(pair.asPascalCase);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.volume_up,
                                  color: const Color(0xFFFF9900),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (appState.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFF9900)),
                        ),
                      ),
                  ],
                ),
              ),

              // 2. Scrollable Content (Info)
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           WordInfoDisplay(info: appState.currentInfo, loading: appState.isLoading),
                           SizedBox(height: 80), // Space for floating buttons
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Fixed History
              if (appState.history.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('History', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.black, Colors.transparent],
                              stops: [0.9, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: AnimatedList(
                            key: _listKey,
                            scrollDirection: Axis.horizontal,
                            initialItemCount: appState.history.length,
                            itemBuilder: (context, index, animation) {
                              if (index >= appState.history.length) return SizedBox();
                              final historyPair = appState.history[index];
                              final isFavorite = appState.favoritePairs.contains(historyPair);
                              return SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTap: () => appState.setCurrent(historyPair),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[900],
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                                              border: Border.all(color: Colors.grey[800]!),
                                            ),
                                            child: Text(historyPair.asLowerCase, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF9900),
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                                            ),
                                            child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 16, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Fixed Buttons (Floating)
        Positioned(
            bottom: 120,
            right: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Style Selector (Floating)
                if (_isMenuOpen) ...[
                  ...MyAppState.styleIcons.entries.toList().asMap().entries.map((entry) {
                     int index = entry.key;
                     String style = entry.value.key;
                     IconData icon = entry.value.value;
                     return _buildStyleOption(style, icon, index, appState);
                  }).toList(),
                ],
                
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isMenuOpen ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isMenuOpen 
                              ? const Color(0xFFFF9900) 
                              : Colors.white.withOpacity(0.2),
                          width: _isMenuOpen ? 2 : 1
                        ),
                      ),
                      child: InkWell(
                        onTap: _toggleMenu,
                        child: AnimatedRotation(
                          turns: _isMenuOpen ? 0.5 : 0,
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            _isMenuOpen ? Icons.close : Icons.auto_awesome,
                            size: 28,
                            color: const Color(0xFFFF9900),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Like
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: InkWell(
                        onTap: () => appState.toggleFavorite(pair),
                        child: Icon(
                          icon,
                          size: 28,
                          color: appState.favoritePairs.contains(pair) ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Preview / Logo Gen
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: InkWell(
                        onTap: () {
                          appState.setLogoParts(pair.first, pair.second);
                          appState.setSelectedIndex(3);
                        },
                        child: Icon(
                          Icons.design_services,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Next
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: InkWell(
                        onTap: () {
                          var listState = _listKey.currentState;
                          var shouldInsert = !appState.history.contains(appState.current);
                          if (shouldInsert && listState != null) {
                            listState.insertItem(0, duration: Duration(milliseconds: 300));
                            if (appState.history.length >= MyAppState.maxHistoryLength) {
                              listState.removeItem(MyAppState.maxHistoryLength, (context, animation) => SizedBox(), duration: Duration.zero);
                            }
                          }
                          appState.getNext();
                        },
                        child: Icon(Icons.arrow_forward, size: 28, color: const Color(0xFFFF9900)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
