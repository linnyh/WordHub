import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/big_card.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getPartOfSpeech(WordPair pair) {
    final partsOfSpeech = ["Noun", "Adjective", "Brand", "Startup"];
    return partsOfSpeech[(pair.first.length + pair.second.length) % partsOfSpeech.length];
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favoritePairs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[800]),
            SizedBox(height: 16),
            Text(
              'No favorites yet.',
              style: TextStyle(fontFamily: 'Arial', color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    final filteredPairs = appState.favoritePairs.where((pair) {
      return pair.asLowerCase.startsWith(_searchQuery.toLowerCase());
    }).toList();

    // 统计词性
    final stats = <String, int>{};
    for (var pair in filteredPairs) {
      final pos = getPartOfSpeech(pair);
      stats[pos] = (stats[pos] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorites',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search your collection...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: const Color(0xFFFF9900)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[900],
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: const Color(0xFFFF9900), width: 1),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  if (stats.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: stats.entries.map((entry) {
                          return Container(
                            margin: EdgeInsets.only(right: 12),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[800]!),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9900),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${entry.value}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          filteredPairs.isEmpty && _searchQuery.isNotEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No matches found.',
                      style: TextStyle(color: Colors.grey, fontFamily: 'Arial'),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final pair = filteredPairs[index];
                        return _FavoriteCard(
                          pair: pair,
                          onDelete: () => appState.toggleFavorite(pair),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return FavoriteDetailDialog(
                                  favorites: filteredPairs,
                                  initialIndex: index,
                                );
                              },
                            );
                          },
                        );
                      },
                      childCount: filteredPairs.length,
                    ),
                  ),
                ),
          SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final WordPair pair;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _FavoriteCard({
    required this.pair,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pair.first.toLowerCase(),
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9900),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pair.second.toLowerCase(),
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: Colors.grey[500]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteDetailDialog extends StatefulWidget {
  final List<WordPair> favorites;
  final int initialIndex;

  const FavoriteDetailDialog({
    super.key,
    required this.favorites,
    required this.initialIndex,
  });

  @override
  State<FavoriteDetailDialog> createState() => _FavoriteDetailDialogState();
}

class _FavoriteDetailDialogState extends State<FavoriteDetailDialog> {
  late int currentIndex;
  bool _isNext = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = widget.favorites[currentIndex];
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final direction = _isNext ? -1.0 : 1.0;
                    
                    final inTween = Tween<Offset>(
                      begin: Offset(direction, 0.0),
                      end: Offset.zero,
                    );
                    
                    final outTween = Tween<Offset>(
                      begin: Offset(-direction, 0.0),
                      end: Offset.zero,
                    );

                    if (child.key == ValueKey(pair)) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: inTween.animate(animation), child: child),
                      );
                    } else {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: outTween.animate(animation), child: child),
                      );
                    }
                  },
                  child: BigCard(
                    key: ValueKey(pair),
                    pair: pair,
                    style: appState.currentStyle,
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: MyAppState.styleIcons.entries.map((entry) {
                      final style = entry.key;
                      final icon = entry.value;
                      final isSelected = appState.currentStyle == style;
                      
                      return GestureDetector(
                        onTap: () => appState.setStyle(style),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF9900) : Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF9900) : Colors.grey[800]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icon, 
                                size: 16, 
                                color: isSelected ? Colors.black : Colors.grey[400]
                              ),
                              SizedBox(width: 6),
                              Text(
                                style,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: Icon(Icons.arrow_circle_left_outlined, 
                        color: currentIndex > 0 ? Colors.white : Colors.grey[800]),
                      onPressed: currentIndex > 0
                          ? () {
                              setState(() {
                                _isNext = false;
                                currentIndex--;
                              });
                            }
                          : null,
                    ),
                    SizedBox(width: 40),
                    IconButton(
                      iconSize: 48,
                      icon: Icon(Icons.arrow_circle_right_outlined,
                        color: currentIndex < widget.favorites.length - 1 ? const Color(0xFFFF9900) : Colors.grey[800]),
                      onPressed: currentIndex < widget.favorites.length - 1
                          ? () {
                              setState(() {
                                _isNext = true;
                                currentIndex++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CLOSE',
                    style: TextStyle(color: Colors.grey, letterSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
