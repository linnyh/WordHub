import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../services/moonshot_service.dart';
import 'word_info_display.dart';

class BigCard extends StatefulWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  State<BigCard> createState() => _BigCardState();
}

class _BigCardState extends State<BigCard> {
  Map<String, dynamic> currentInfo = {};
  bool _loading = true;
  bool _isFetching = false;
  final FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
    _initTts();
  }
  
  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    
    flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    
    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    
    flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isSpeaking = false);
      debugPrint("TTS Error: $msg");
    });
  }
  
  Future<void> _speak() async {
    if (_isSpeaking) {
      await flutterTts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      await flutterTts.speak(widget.pair.asPascalCase);
    }
  }
  
  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(BigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pair != oldWidget.pair) {
      _fetchInfo();
      if (_isSpeaking) {
        flutterTts.stop();
        if (mounted) setState(() => _isSpeaking = false);
      }
    }
  }

  Future<void> _fetchInfo() async {
    final appState = Provider.of<MyAppState>(context, listen: false);
    
    // 1. Try to find EXACT match for current style
    final strictData = appState.getCachedData(widget.pair, strict: true);
    if (strictData != null) {
      if (mounted) {
        setState(() {
          currentInfo = strictData;
          _loading = false;
        });
      }
      return;
    }

    // 2. If no exact match, try fallback to show SOMETHING while fetching
    final fallbackData = appState.getCachedData(widget.pair, strict: false);
    if (mounted) {
      setState(() {
        if (fallbackData != null) {
          currentInfo = fallbackData;
          _loading = false; // Show fallback content
        } else {
          currentInfo = {};
          _loading = true; // Show loading spinner
        }
        _isFetching = true; // Start showing rhythmic animation
      });
    }

    // 3. Fetch from API for the current style
    final service = MoonshotService(apiKey: appState.apiKey);

    try {
      final styleInstruction = MyAppState.stylePrompts[appState.currentStyle] ?? MyAppState.stylePrompts['General']!;
      final prompt = '''
Generate a creative profile for the fictional brand name "${widget.pair.asPascalCase}" (composed of "${widget.pair.first}" and "${widget.pair.second}").
Context/Theme: $styleInstruction

Return ONLY a valid JSON object with these keys:
- "part_of_speech": The most suitable part of speech (e.g., Noun, Verb, Adjective).
- "definition_en": A creative English definition (max 20 words).
- "definition_cn": The Chinese translation of the definition.
- "origin_en": A short, creative fictional origin story or etymology (max 30 words).
- "origin_cn": The Chinese translation of the origin.
- "sentences": An array of exactly 3 objects, each with "en" (English sentence) and "cn" (Chinese translation).

Example:
{
  "part_of_speech": "Noun",
  "definition_en": "A smart tool for...",
  "definition_cn": "一种智能工具...",
  "origin_en": "Derived from ancient myths...",
  "origin_cn": "源于古老的神话...",
  "sentences": [
    {"en": "I used it.", "cn": "我用了它。"},
    {"en": "It is great.", "cn": "它很棒。"},
    {"en": "Buy it now.", "cn": "现在购买。"}
  ]
}
''';

      final response = await service.chat(messages: [
        {'role': 'user', 'content': prompt}
      ]);

      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) {
        throw Exception('No JSON object found in response');
      }
      
      final cleanJson = jsonMatch.group(0)!;
      final data = jsonDecode(cleanJson);
      
      appState.cacheData(widget.pair, data);
      
      if (mounted) {
        setState(() {
          currentInfo = data;
          _loading = false;
          _isFetching = false;
        });
      }
    } catch (e) {
      debugPrint('Error in _fetchInfo: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _isFetching = false;
          // If we failed and had no fallback, we might show empty. 
          // If we had fallback, we keep showing it.
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fetch when dependencies (AppState) change
    _fetchInfo();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pair = widget.pair;
    
    // Ensure we are watching AppState so didChangeDependencies triggers on change
    context.watch<MyAppState>();
    
    String partOfSpeech = currentInfo['part_of_speech'] ?? "...";
    
    double cardWidth = MediaQuery.of(context).size.width * 0.8;
    
    return Container(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Card Style)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9900).withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFFF9900).withAlpha(100)),
                      ),
                      child: Text(
                        partOfSpeech.toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xFFFF9900),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pair.first.toLowerCase(),
                        style: theme.textTheme.displayMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontFamily: 'Arial',
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9900),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pair.second.toLowerCase(),
                          style: theme.textTheme.displayMedium!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // TTS Button (Card Style)
                      IconButton(
                        icon: Icon(
                          _isSpeaking ? Icons.volume_up : Icons.volume_down_outlined,
                          color: const Color(0xFFFF9900),
                          size: 24,
                        ),
                        onPressed: _speak,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          
          if (_isFetching)
            LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(const Color(0xFFFF9900)),
            )
          else
            SizedBox(height: 2),

          // Body (Info)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                left: BorderSide(color: Colors.grey[800]!),
                right: BorderSide(color: Colors.grey[800]!),
                bottom: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: WordInfoDisplay(info: currentInfo, loading: _loading),
          ),
        ],
      ),
    );
  }
}
