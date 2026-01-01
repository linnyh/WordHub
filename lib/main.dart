import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'WordHub',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF9900), // Pornhub Orange
            brightness: Brightness.dark,
            surface: Colors.black,
            primary: const Color(0xFFFF9900),
          ),
          scaffoldBackgroundColor: Colors.black,
          cardTheme: CardThemeData(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFFFF9900).withAlpha(100), width: 1),
            ),
            elevation: 8,
            shadowColor: const Color(0xFFFF9900).withAlpha(80),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFFFF9900),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 5,
              shadowColor: const Color(0xFFFF9900).withAlpha(100),
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}
