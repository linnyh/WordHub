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
  TextEditingController? _widthController;
  TextEditingController? _heightController;
  TextEditingController? _borderRadiusController;
  TextEditingController? _cardColorController;
  TextEditingController? _canvasColorController;
  
  bool _enableCustomBackground = false;
  Color _cardColor = Colors.black;
  Color _canvasColor = Colors.black;
  
  bool _isGenerating = false;
  String _statusMessage = '';
  String? _lastSavedPath; // Store the path of the last saved file

  TextEditingController get widthController => _widthController ??= TextEditingController(text: '1024');
  TextEditingController get heightController => _heightController ??= TextEditingController(text: '1024');
  TextEditingController get borderRadiusController => _borderRadiusController ??= TextEditingController(text: '0');
  TextEditingController get cardColorController => _cardColorController ??= TextEditingController(text: '#000000');
  TextEditingController get canvasColorController => _canvasColorController ??= TextEditingController(text: '#000000');

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
    _widthController?.dispose();
    _heightController?.dispose();
    _borderRadiusController?.dispose();
    _cardColorController?.dispose();
    _canvasColorController?.dispose();
    super.dispose();
  }

  Color _parseColor(String text) {
    text = text.trim().replaceAll('#', '');
    if (text.toLowerCase() == 'transparent') return Colors.transparent;
    if (text.length == 6) {
      return Color(int.parse('0xFF$text'));
    } else if (text.length == 8) {
      return Color(int.parse('0x$text'));
    }
    return Colors.black;
  }

  String _colorToHex(Color color) {
    if (color == Colors.transparent) return 'Transparent';
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void _updateCardColor(String value) {
    setState(() {
      if (value.toLowerCase() == 'transparent') {
        _cardColor = Colors.transparent;
      } else {
        try {
          _cardColor = _parseColor(value);
        } catch (_) {}
      }
    });
  }

  void _updateCanvasColor(String value) {
    setState(() {
      if (value.toLowerCase() == 'transparent') {
        _canvasColor = Colors.transparent;
      } else {
        try {
          _canvasColor = _parseColor(value);
        } catch (_) {}
      }
    });
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

    setState(() {
      _isGenerating = true;
      _statusMessage = '';
    });

    // Artificial delay to show animation
    await Future.delayed(Duration(milliseconds: 800));

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
      
      final double contentWidth = prefixWidth + suffixBgWidth + elementSpacing;
      
      // Card dimensions (The "PornHub" part)
      final double cardWidth = contentWidth + (outerPadding * 2);
      final double cardHeight = suffixBgHeight + (outerPadding * 2);

      // Glow/Shadow margins
      const double glowBlurRadius = 30.0;
      const double glowSpreadRadius = 5.0;
      const double glowMargin = glowBlurRadius + glowSpreadRadius;

      double totalWidth;
      double totalHeight;
      double cardX;
      double cardY;
      
      if (_enableCustomBackground) {
        final double width = double.tryParse(widthController.text) ?? 1024;
        final double height = double.tryParse(heightController.text) ?? 1024;
        totalWidth = width;
        totalHeight = height;
        cardX = (totalWidth - cardWidth) / 2;
        cardY = (totalHeight - cardHeight) / 2;
      } else {
        totalWidth = cardWidth + (glowMargin * 2);
        totalHeight = cardHeight + (glowMargin * 2);
        cardX = glowMargin;
        cardY = glowMargin;
      }

      // SVG Construction
      final double borderRadius = _enableCustomBackground 
          ? (double.tryParse(borderRadiusController.text) ?? 0) 
          : 0;
      
      final String cardFill = _cardColor == Colors.transparent ? 'none' : '#${_cardColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      final String canvasFill = _canvasColor == Colors.transparent ? 'none' : '#${_canvasColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      final svgContent = '''
<svg width="$totalWidth" height="$totalHeight" viewBox="0 0 $totalWidth $totalHeight" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
      <feMorphology operator="dilate" radius="5" in="SourceAlpha" result="dilated"/>
      <feGaussianBlur stdDeviation="15" in="dilated" result="blurred"/>
      <feFlood flood-color="#FF9900" flood-opacity="0.2" result="color"/>
      <feComposite in="color" in2="blurred" operator="in" result="shadow"/>
      <feMerge>
        <feMergeNode in="shadow"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>

  <style>
    .text { font-family: Arial, sans-serif; font-weight: bold; font-size: ${fontSize}px; }
  </style>

  ${_enableCustomBackground ? '<rect width="100%" height="100%" fill="$canvasFill" rx="$borderRadius" ry="$borderRadius" />' : ''}
  
  <g transform="translate($cardX, $cardY)">
    <!-- Card Background with Glow and Border -->
    <rect width="$cardWidth" height="$cardHeight" fill="$cardFill" rx="$outerBorderRadius" ry="$outerBorderRadius" 
          filter="url(#glow)" stroke="#FF9900" stroke-opacity="0.5" stroke-width="2" />
    
    <!-- Prefix -->
    <text x="$outerPadding" y="${cardHeight / 2 + fontSize / 3}" fill="white" class="text">$prefix</text>
    
    <!-- Suffix Background -->
    <rect x="${outerPadding + prefixWidth + elementSpacing}" y="${(cardHeight - suffixBgHeight) / 2}" rx="$innerBorderRadius" ry="$innerBorderRadius" width="$suffixBgWidth" height="$suffixBgHeight" fill="#FF9900" />
    
    <!-- Suffix -->
    <text x="${outerPadding + prefixWidth + elementSpacing + bgPaddingX}" y="${cardHeight / 2 + fontSize / 3}" fill="black" class="text">$suffix</text>
  </g>
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
        _isGenerating = false;
      });
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error: $e';
        _lastSavedPath = null;
        _isGenerating = false;
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
    
    // Check screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;

    if (isWideScreen) {
      return _buildWideLayout(theme);
    }

    return _buildNarrowLayout(theme);
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      children: [
        // Left Side: Preview (Takes available space)
        Expanded(
          child: Container(
            color: Colors.grey[900], // Slightly different background for preview area
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: _buildPreviewCard(theme),
              ),
            ),
          ),
        ),
        
        // Right Side: Controls (Fixed width sidebar)
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(left: BorderSide(color: Colors.grey[800]!)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'LOGO GENERATOR',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      _buildInputsSection(theme),
                    ],
                  ),
                ),
              ),
              // Fixed Bottom Section for Action Button & Status
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(top: BorderSide(color: Colors.grey[800]!)),
                ),
                child: Column(
                  children: [
                    _buildGenerateButton(theme),
                    if (_statusMessage.isNotEmpty) ...[
                      SizedBox(height: 16),
                      _buildStatusMessage(theme),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
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
              _buildPreviewCard(theme),
              SizedBox(height: 60),
              _buildInputsSection(theme),
              SizedBox(height: 40),
              _buildGenerateButton(theme),
              if (_statusMessage.isNotEmpty) ...[
                SizedBox(height: 24),
                _buildStatusMessage(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    // Basic font metrics estimation - same as in _generateSvg
    const double fontSize = 100;
    
    Widget logoCard = _buildLogoCard(theme, fontSize);

    if (_enableCustomBackground) {
      final double width = double.tryParse(widthController.text) ?? 1024;
      final double height = double.tryParse(heightController.text) ?? 1024;
      final double borderRadius = double.tryParse(borderRadiusController.text) ?? 0;

      return FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _canvasColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: logoCard,
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: logoCard,
    );
  }

  Widget _buildLogoCard(ThemeData theme, double fontSize) {
    const double elementSpacing = 15;
    const double outerPadding = 30;
    const double innerBorderRadius = 10;
    const double outerBorderRadius = 20;
    
    final textStyle = TextStyle(
      fontFamily: 'Arial',
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );

    return Container(
      padding: EdgeInsets.all(outerPadding),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(outerBorderRadius),
        border: Border.all(
          color: const Color(0xFFFF9900).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9900).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _prefixController.text,
            style: textStyle.copyWith(color: Colors.white),
          ),
          SizedBox(width: elementSpacing),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9900),
              borderRadius: BorderRadius.circular(innerBorderRadius),
            ),
            child: Text(
              _suffixController.text,
              style: textStyle.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputsSection(ThemeData theme) {
    return Column(
      children: [
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
        SizedBox(height: 20),
        
        // Card Color Picker
        _buildColorPickerRow(theme, 'Card Color', cardColorController, _updateCardColor, _cardColor),
        SizedBox(height: 20),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Custom Background Size', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Define custom width, height and color for the background', style: TextStyle(color: Colors.grey[400])),
                value: _enableCustomBackground,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  setState(() {
                    _enableCustomBackground = value;
                  });
                },
              ),
              if (_enableCustomBackground) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widthController,
                        onChanged: (value) => setState(() {}),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Width (px)',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.horizontal_distribute, color: theme.colorScheme.primary),
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        onChanged: (value) => setState(() {}),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Height (px)',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.vertical_distribute, color: theme.colorScheme.primary),
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: borderRadiusController,
                  onChanged: (value) => setState(() {}),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Background Border Radius (px)',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.rounded_corner, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _buildColorPickerRow(theme, 'Canvas Color', canvasColorController, _updateCanvasColor, _canvasColor),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorPickerRow(ThemeData theme, String label, TextEditingController controller, Function(String) onChanged, Color currentColor) {
    final List<Color> presets = [
      Colors.black,
      Colors.white,
      Colors.grey,
      Color(0xFFFF9900), // PH Orange
      Colors.transparent,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '#000000 or Transparent',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.black,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: currentColor == Colors.transparent ? null : currentColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: currentColor == Colors.transparent 
                      ? Icon(Icons.block, size: 16, color: Colors.red) 
                      : null,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
            SizedBox(width: 12),
            ...presets.map((color) {
              final isSelected = currentColor == color;
              return GestureDetector(
                onTap: () {
                  final hex = _colorToHex(color);
                  controller.text = hex;
                  onChanged(hex);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color == Colors.transparent ? Colors.transparent : color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : Colors.grey[700]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: color == Colors.transparent 
                      ? Icon(Icons.block, size: 16, color: Colors.red) 
                      : null,
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateSvg,
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: theme.colorScheme.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.3),
        ),
        icon: _isGenerating 
            ? Container(
                width: 24, 
                height: 24, 
                padding: EdgeInsets.all(2),
                child: CircularProgressIndicator(
                  color: Colors.white, 
                  strokeWidth: 3,
                ),
              )
            : Icon(Icons.download_rounded, size: 28),
        label: Text(
          _isGenerating ? 'GENERATING...' : 'GENERATE SVG', 
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: _isGenerating ? Colors.white.withOpacity(0.8) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(ThemeData theme) {
    return Container(
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
