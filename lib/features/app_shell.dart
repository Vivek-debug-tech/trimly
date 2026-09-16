import 'package:flutter/material.dart';
import 'package:trimly/features/home/home_screen.dart';
import 'package:trimly/features/optimizer/optimizer_screen.dart';
import 'package:trimly/features/savings_mission/savings_mission_screen.dart';
import 'package:trimly/features/value_check/value_check_screen.dart';

class TrimlyAppShell extends StatefulWidget {
  const TrimlyAppShell({super.key});

  @override
  State<TrimlyAppShell> createState() => _TrimlyAppShellState();
}

class _TrimlyAppShellState extends State<TrimlyAppShell> {
  int _index = 0;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, label: 'Home'),
    _NavItem(icon: Icons.fact_check_outlined, label: 'Value'),
    _NavItem(icon: Icons.savings_outlined, label: 'Mission'),
    _NavItem(icon: Icons.auto_awesome_outlined, label: 'Optimizer'),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const HomeScreen(),
      const ValueCheckScreen(),
      const SavingsMissionScreen(),
      const OptimizerScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: _items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
