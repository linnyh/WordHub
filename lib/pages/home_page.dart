import 'package:flutter/material.dart';

import 'favorites_page.dart';
import 'generator_page.dart';
import 'settings_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  var isNavigationRailExtended = false;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: isNavigationRailExtended,
              minWidth: 72,
              leading: Align(
                alignment: isNavigationRailExtended
                    ? Alignment.centerLeft
                    : Alignment.center,
                child: IconButton(
                  icon: Icon(
                    isNavigationRailExtended ? Icons.menu_open : Icons.menu,
                  ),
                  onPressed: () {
                    setState(() {
                      isNavigationRailExtended = !isNavigationRailExtended;
                    });
                  },
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}
