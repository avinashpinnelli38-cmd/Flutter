import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'add_log_screen.dart';
import 'vehicles_screen.dart';
import 'settings_screen.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Tabs are created the first time they are opened and then kept alive, so
  // scroll position and in-progress input survive tab switches. Building all
  // four up front would run four screens' layout, charts and animations at once.
  final List<Widget?> _screens = [const DashboardScreen(), null, null, null];

  static Widget _buildScreen(int index) {
    return switch (index) {
      0 => const DashboardScreen(),
      1 => const AddLogScreen(),
      2 => const VehiclesScreen(),
      _ => const SettingsScreen(),
    };
  }

  void _selectTab(int index) {
    setState(() {
      _screens[index] ??= _buildScreen(index);
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: GradientBlobBackground(dense: true, child: SizedBox()),
          ),
          IndexedStack(
            index: _currentIndex,
            children: [
              for (final screen in _screens) screen ?? const SizedBox.shrink(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(),
      floatingActionButton: _currentIndex == 1
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _selectTab(1),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Log'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE61E293B) : const Color(0xF2FFFFFF),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.6),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 300),
        destinations: [
          NavigationDestination(
            icon: _NavIcon(
              icon: Icons.dashboard_outlined,
              selected: _currentIndex == 0,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
            ),
            selectedIcon: _NavIcon(
              icon: Icons.dashboard_rounded,
              selected: true,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Dashboard',
            tooltip: 'Dashboard',
          ),
          NavigationDestination(
            icon: _NavIcon(
              icon: Icons.add_circle_outline,
              selected: _currentIndex == 1,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
            ),
            selectedIcon: _NavIcon(
              icon: Icons.add_circle_rounded,
              selected: true,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Add Log',
            tooltip: 'Add Fuel Log',
          ),
          NavigationDestination(
            icon: _NavIcon(
              icon: Icons.directions_car_outlined,
              selected: _currentIndex == 2,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
            ),
            selectedIcon: _NavIcon(
              icon: Icons.directions_car_rounded,
              selected: true,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Vehicles',
            tooltip: 'My Vehicles',
          ),
          NavigationDestination(
            icon: _NavIcon(
              icon: Icons.settings_outlined,
              selected: _currentIndex == 3,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
            ),
            selectedIcon: _NavIcon(
              icon: Icons.settings_rounded,
              selected: true,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Settings',
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Color color;

  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(14),
        border: selected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.25),
                width: 1,
              )
            : null,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
