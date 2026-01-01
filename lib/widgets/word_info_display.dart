import 'package:flutter/material.dart';

class WordInfoDisplay extends StatelessWidget {
  final Map<String, dynamic> info;
  final bool loading;

  const WordInfoDisplay({super.key, required this.info, required this.loading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (loading) {
      return SizedBox.shrink();
    }

    final definition = info['definition_en'] ?? "No definition found.";
    final chineseDefinition = info['definition_cn'] ?? "暂无释义";
    final originEn = info['origin_en'] ?? "No origin found.";
    final originCn = info['origin_cn'] ?? "暂无由来";
    List<Map<String, String>> sentences = [];
    var rawSentences = info['sentences'];
    if (rawSentences is List) {
      sentences = rawSentences.map<Map<String, String>>((item) {
        return {
          'en': item['en']?.toString() ?? "No sentence",
          'cn': item['cn']?.toString() ?? "暂无翻译"
        };
      }).toList();
    } else {
      sentences = [{'en': "No sentence found.", 'cn': ""}];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'DEFINITION',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: const Color(0xFFFF9900),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          chineseDefinition,
          textAlign: TextAlign.left,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
            fontFamily: 'Arial',
          ),
        ),
        SizedBox(height: 4),
        Text(
          definition,
          textAlign: TextAlign.left,
          style: theme.textTheme.headlineSmall!.copyWith(
            color: Colors.white,
            height: 1.4,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'ORIGIN',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: const Color(0xFFFF9900),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          originCn,
          textAlign: TextAlign.left,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
            fontFamily: 'Arial',
          ),
        ),
        SizedBox(height: 4),
        Text(
          originEn,
          textAlign: TextAlign.left,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: Colors.white,
            height: 1.4,
            fontFamily: 'Arial',
          ),
        ),
        SizedBox(height: 24),
        Text(
          'USAGE',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: const Color(0xFFFF9900),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var s in sentences)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey[800]!, width: 3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${s['en']}"',
                        textAlign: TextAlign.left,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${s['cn']}',
                        textAlign: TextAlign.left,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: Colors.grey[600],
                          height: 1.4,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
