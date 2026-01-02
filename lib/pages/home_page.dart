import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import 'favorites_page.dart';
import 'generator_page.dart';
import 'settings_page.dart';
import 'ph_logo_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var isNavigationRailExtended = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var selectedIndex = appState.selectedIndex;
    
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
      case 3:
        page = PhLogoPage();
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
                NavigationRailDestination(
                  icon: Icon(Icons.design_services),
                  label: Text('Logo Gen'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                appState.setSelectedIndex(value);
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
