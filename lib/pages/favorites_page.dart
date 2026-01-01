import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/big_card.dart';

class FavoritesPage extends StatelessWidget {
  String getPartOfSpeech(WordPair pair) {
    final partsOfSpeech = ["Noun", "Adjective", "Brand Name", "Startup"];
    return partsOfSpeech[(pair.first.length + pair.second.length) % partsOfSpeech.length];
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favoritePairs.isEmpty) {
      return Center(
        child: Text(
          'No favorites yet.',
          style: TextStyle(fontFamily: 'Courier', color: Colors.grey),
        ),
      );
    }

    // 统计词性
    final stats = <String, int>{};
    for (var pair in appState.favoritePairs) {
      final pos = getPartOfSpeech(pair);
      stats[pos] = (stats[pos] ?? 0) + 1;
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have ${appState.favoritePairs.length} favorites:',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF9900),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: stats.entries.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                          ),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9900),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < appState.favoritePairs.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[800]!),
              ),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(Icons.delete_outline, semanticLabel: 'Remove'),
                  color: const Color(0xFFFF9900),
                  onPressed: () {
                    appState.toggleFavorite(appState.favoritePairs[i]);
                  },
                ),
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(fontFamily: 'Arial', fontSize: 16),
                    children: [
                      TextSpan(
                        text: appState.favoritePairs[i].first.toLowerCase(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " ${appState.favoritePairs[i].second.toLowerCase()}",
                        style: TextStyle(color: const Color(0xFFFF9900), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return FavoriteDetailDialog(
                        favorites: appState.favoritePairs,
                        initialIndex: i,
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
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
  bool _isNext = true; // Track direction

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
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
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: currentIndex > 0
                        ? () {
                            setState(() {
                              _isNext = false;
                              currentIndex--;
                            });
                          }
                        : null,
                    icon: Icon(Icons.arrow_back),
                    label: Text('Previous'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: currentIndex < widget.favorites.length - 1
                        ? () {
                            setState(() {
                              _isNext = true;
                              currentIndex++;
                            });
                          }
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Next'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
