import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/word_info_display.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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

    return Align(
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
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
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

            // 2. Scrollable Content (Info + Buttons)
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
                         
                         if (!appState.isLoading) ...[
                           SizedBox(height: 32),
                           
                           // Buttons
                           Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Like
                                InkWell(
                                  onTap: () => appState.toggleFavorite(pair),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                                          border: Border.all(color: Colors.grey[800]!),
                                        ),
                                        child: Text('LIKE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF9900),
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                                        ),
                                        child: Icon(icon, size: 20, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Next
                                InkWell(
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
                                  borderRadius: BorderRadius.circular(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                                          border: Border.all(color: Colors.grey[800]!),
                                        ),
                                        child: Text('NEXT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF9900),
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                                        ),
                                        child: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                           ),
                         ],
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                                          border: Border.all(color: Colors.grey[800]!),
                                        ),
                                        child: Text(historyPair.asLowerCase, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
    );
  }
}
