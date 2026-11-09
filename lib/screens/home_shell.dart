import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/book_repository.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.repository,
    required this.controller,
  });

  final BookRepository repository;
  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        repository: widget.repository,
        controller: widget.controller,
        openSearch: () => setState(() => _index = 1),
      ),
      SearchScreen(
        repository: widget.repository,
        controller: widget.controller,
      ),
      SettingsScreen(
        repository: widget.repository,
        controller: widget.controller,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'الفهرس',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'البحث',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
