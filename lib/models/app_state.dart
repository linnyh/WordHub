import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

import '../services/moonshot_service.dart';

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];
  static const maxHistoryLength = 8;
  var favoritePairs = <WordPair>[];
  var apiKey = '';
  String? svgSavePath;
  
  // Navigation State
  int selectedIndex = 0;

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  // Logo Generation State
  String? logoPrefix;
  String? logoSuffix;

  void setLogoParts(String prefix, String suffix) {
    logoPrefix = prefix;
    logoSuffix = suffix;
    notifyListeners();
  }
  
  // Style configurations
  String currentStyle = 'General';
  static const Map<String, String> stylePrompts = {
    'General': 'A balanced, creative brand profile suitable for a general audience.',
    'Tech': 'Futuristic, innovative, high-tech, software, startup vibe, cyberpunk, AI-driven.',
    'Magic': 'Mystical, fantasy, ancient, ethereal, arcane, potions, spells, wizardry.',
    'Fashion': 'Luxury, trendy, bold, elegant, streetwear, artistic, haute couture.',
    'Organic': 'Natural, eco-friendly, sustainable, fresh, earthy, holistic, pure.',
    'Gaming': 'Energetic, competitive, esports, arcade, pixel, fun, immersive.',
  };

  static const Map<String, IconData> styleIcons = {
    'General': Icons.auto_awesome,
    'Tech': Icons.memory,
    'Magic': Icons.auto_fix_high,
    'Fashion': Icons.checkroom,
    'Organic': Icons.eco,
    'Gaming': Icons.sports_esports,
  };

  Map<String, dynamic> currentInfo = {};
  bool isLoading = false;
  final FlutterTts flutterTts = FlutterTts();
  Timer? _debounce;

  MyAppState() {
    _loadConfig();
    _loadFavorites();
    _loadCache().then((_) {
      fetchInfo(current);
    });
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> fetchInfo(WordPair pair) async {
    isLoading = true;
    currentInfo = {};
    notifyListeners();

    // Check cache (key now includes style to avoid mixing contexts)
    final cacheKey = "${pair.asPascalCase}_$currentStyle";
    if (_wordCache.containsKey(cacheKey)) {
      currentInfo = _wordCache[cacheKey]!;
      isLoading = false;
      notifyListeners();
      return;
    }

    final service = MoonshotService(apiKey: apiKey);

    try {
      final styleInstruction = stylePrompts[currentStyle] ?? stylePrompts['General']!;
      final prompt = '''
Generate a creative profile for the fictional brand name "${pair.asPascalCase}" (composed of "${pair.first}" and "${pair.second}").
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
      
      // Cache with style included in key
      _wordCache[cacheKey] = data;
      _saveCache();

      currentInfo = data;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching info: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/favorites.json');
  }

  Future<void> _loadFavorites() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return;
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);

      favoritePairs = jsonList.map((item) {
        final List<dynamic> pair = item;
        return WordPair(pair[0].toString(), pair[1].toString());
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final file = await _localFile;
      final jsonList = favoritePairs.map((pair) => [pair.first, pair.second]).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  Future<File> get _cacheFile async {
    final path = await _localPath;
    return File('$path/word_cache.json');
  }

  // Cache structure: Map<String, Map<String, dynamic>>
  // Key: "WordPair" (PascalCase)
  // Value: JSON data from AI
  Map<String, dynamic> _wordCache = {};

  Future<void> _loadCache() async {
    try {
      final file = await _cacheFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        _wordCache = jsonDecode(contents);
      }
    } catch (e) {
      debugPrint('Error loading word cache: $e');
    }
  }

  Future<void> _saveCache() async {
    try {
      final file = await _cacheFile;
      await file.writeAsString(jsonEncode(_wordCache));
    } catch (e) {
      debugPrint('Error saving word cache: $e');
    }
  }

  Map<String, dynamic>? getCachedData(WordPair pair) {
    // 1. Exact match with current style
    final currentKey = "${pair.asPascalCase}_$currentStyle";
    if (_wordCache.containsKey(currentKey)) {
      return _wordCache[currentKey];
    }
    
    // 2. Backward compatibility (no suffix)
    if (_wordCache.containsKey(pair.asPascalCase)) {
      return _wordCache[pair.asPascalCase];
    }

    // 3. Any other style match (fallback)
    final prefix = "${pair.asPascalCase}_";
    for (var key in _wordCache.keys) {
      if (key.startsWith(prefix)) {
        return _wordCache[key];
      }
    }

    return null;
  }

  void cacheData(WordPair pair, Map<String, dynamic> data) {
    _wordCache["${pair.asPascalCase}_$currentStyle"] = data;
    _saveCache();
  }

  Future<File> get _configFile async {
    final path = await _localPath;
    return File('$path/config.json');
  }

  Future<void> _loadConfig() async {
    try {
      final file = await _configFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents);
        if (json['apiKey'] != null) {
          apiKey = json['apiKey'];
        }
        if (json['svgSavePath'] != null) {
          svgSavePath = json['svgSavePath'];
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading config: $e');
    }
  }

  Future<void> _saveConfig() async {
    try {
      final file = await _configFile;
      await file.writeAsString(jsonEncode({'apiKey': apiKey}));
    } catch (e) {
      debugPrint('Error saving config: $e');
    }
  }

  Future<void> clearFavorites() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
      favoritePairs.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final file = await _cacheFile;
      if (await file.exists()) {
        await file.delete();
      }
      _wordCache.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  void setApiKey(String key) {
    apiKey = key;
    _saveConfig();
    notifyListeners();
  }

  void setSvgSavePath(String? path) {
    svgSavePath = path;
    _saveConfig();
    notifyListeners();
  }

  void setStyle(String style) {
    if (stylePrompts.containsKey(style) && currentStyle != style) {
      currentStyle = style;
      fetchInfo(current); // Re-fetch for the current word with new style
      notifyListeners();
    }
  }

  void setCurrent(WordPair pair) {
    current = pair;
    fetchInfo(current);
    notifyListeners();
  }

  void getNext() {
    if (!history.contains(current)) {
      history.insert(0, current);
    }
    if (history.length > maxHistoryLength) {
      history.removeLast();
    }
    current = WordPair.random();
    fetchInfo(current);
    notifyListeners();
  }

  void toggleFavorite(WordPair pair) {
    if (favoritePairs.contains(pair)) {
      favoritePairs.remove(pair);
    } else {
      favoritePairs.add(pair);
    }
    notifyListeners();
    _saveFavorites();
  }
}
