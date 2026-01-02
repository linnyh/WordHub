import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class PhLogoPage extends StatefulWidget {
  const PhLogoPage({super.key});

  @override
  State<PhLogoPage> createState() => _PhLogoPageState();
}

class _PhLogoPageState extends State<PhLogoPage> {
  late TextEditingController _prefixController;
  late TextEditingController _suffixController;
  String _statusMessage = '';
  String? _lastSavedPath; // Store the path of the last saved file

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<MyAppState>(context, listen: false);
    _prefixController = TextEditingController(text: appState.logoPrefix ?? 'Porn');
    _suffixController = TextEditingController(text: appState.logoSuffix ?? 'Hub');
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _suffixController.dispose();
    super.dispose();
  }

  void _generateSvg() async {
    final prefix = _prefixController.text;
    final suffix = _suffixController.text;

    if (prefix.isEmpty && suffix.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter some text.';
      });
      return;
    }

    try {
      // Basic font metrics estimation
      const double fontSize = 100;
      const double elementSpacing = 15; // Increased spacing between text parts
      const double outerPadding = 30;   // Increased padding around the content
      const double innerBorderRadius = 10; // Radius for the orange box
      const double outerBorderRadius = 20; // Radius for the black card
      
      final textStyle = TextStyle(
        fontFamily: 'Arial',
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      );

      final prefixPainter = TextPainter(
        text: TextSpan(text: prefix, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final suffixPainter = TextPainter(
        text: TextSpan(text: suffix, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final double prefixWidth = prefixPainter.width;
      final double suffixWidth = suffixPainter.width;
      final double height = prefixPainter.height > suffixPainter.height ? prefixPainter.height : suffixPainter.height;
      
      // Suffix background padding
      const double bgPaddingX = 15.0;
      const double bgPaddingY = 5.0;
      
      final double suffixBgWidth = suffixWidth + (bgPaddingX * 2);
      final double suffixBgHeight = height + (bgPaddingY * 2); 
      
      final double totalWidth = prefixWidth + suffixBgWidth + elementSpacing + (outerPadding * 2);
      final double totalHeight = suffixBgHeight + (outerPadding * 2);

      // SVG Construction
      final svgContent = '''
<svg width="$totalWidth" height="$totalHeight" viewBox="0 0 $totalWidth $totalHeight" xmlns="http://www.w3.org/2000/svg">
  <style>
    .text { font-family: Arial, sans-serif; font-weight: bold; font-size: ${fontSize}px; }
  </style>
  <rect width="100%" height="100%" fill="black" rx="$outerBorderRadius" ry="$outerBorderRadius" />
  
  <!-- Prefix -->
  <text x="$outerPadding" y="${totalHeight / 2 + fontSize / 3}" fill="white" class="text">$prefix</text>
  
  <!-- Suffix Background -->
  <rect x="${outerPadding + prefixWidth + elementSpacing}" y="${(totalHeight - suffixBgHeight) / 2}" rx="$innerBorderRadius" ry="$innerBorderRadius" width="$suffixBgWidth" height="$suffixBgHeight" fill="#FF9900" />
  
  <!-- Suffix -->
  <text x="${outerPadding + prefixWidth + elementSpacing + bgPaddingX}" y="${totalHeight / 2 + fontSize / 3}" fill="black" class="text">$suffix</text>
</svg>
''';

      final appState = Provider.of<MyAppState>(context, listen: false);
      String savePath;
      if (appState.svgSavePath != null) {
        savePath = appState.svgSavePath!;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath = directory.path;
      }

      // Sanitize filename
      final safePrefix = prefix.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fa5]'), '').trim().replaceAll(RegExp(r'\s+'), '_');
      final safeSuffix = suffix.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fa5]'), '').trim().replaceAll(RegExp(r'\s+'), '_');
      final fileName = 'ph_logo_${safePrefix}_${safeSuffix}_${DateTime.now().millisecondsSinceEpoch}.svg';
      
      final file = File('$savePath/$fileName');
      await file.writeAsString(svgContent);

      if (!mounted) return;

      setState(() {
        _statusMessage = 'SVG Successfully Saved!';
        _lastSavedPath = file.path;
      });
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _lastSavedPath = null;
      });
    }
  }

  void _openFile(String path) {
    if (Platform.isMacOS) {
      Process.run('open', [path]);
    } else if (Platform.isWindows) {
      Process.run('explorer', [path]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [path]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      fontWeight: FontWeight.bold,
      letterSpacing: -1.5,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: BoxConstraints(maxWidth: 700),
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Wrap content
            children: [
              Text(
                'LOGO GENERATOR',
                style: theme.textTheme.labelLarge!.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 40),
              
              // Preview Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _prefixController.text,
                        style: style.copyWith(color: Colors.white),
                      ),
                      SizedBox(width: 15),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _suffixController.text,
                          style: style.copyWith(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 60),
              
              // Inputs
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _prefixController,
                      label: 'Prefix',
                      icon: Icons.edit,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField(
                      controller: _suffixController,
                      label: 'Suffix',
                      icon: Icons.edit_attributes,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 40),
              
              // Button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _generateSvg,
                  style: ElevatedButton.styleFrom(
                    elevation: 8,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(Icons.download_rounded, size: 28),
                  label: Text(
                    'GENERATE SVG', 
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              
              if (_statusMessage.isNotEmpty) ...[
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _statusMessage.startsWith('Error') 
                        ? Colors.red.withOpacity(0.1) 
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _statusMessage.startsWith('Error') ? Colors.red : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _statusMessage.startsWith('Error') ? Icons.error_outline : Icons.check_circle_outline,
                            color: _statusMessage.startsWith('Error') ? Colors.red : Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _statusMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _statusMessage.startsWith('Error') ? Colors.red[300] : Colors.green[300],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_lastSavedPath != null && !_statusMessage.startsWith('Error')) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.folder_open, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _lastSavedPath!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => _openFile(_lastSavedPath!),
                          icon: Icon(Icons.open_in_new, size: 18),
                          label: Text('Open File Location'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: Colors.white, 
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Color(0xFFFF9900)),
        filled: true,
        fillColor: Colors.black,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFFF9900), width: 2),
        ),
      ),
      onChanged: (value) => setState(() {}),
    );
  }
}
