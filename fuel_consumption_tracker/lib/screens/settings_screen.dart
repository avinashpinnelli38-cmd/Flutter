import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/animated_card.dart';
import 'profile_screen.dart';
import 'database_manager_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: Curves.easeOutCubic),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StaggeredEntrance(
              animation: _staggerAnimation,
              index: 0,
              child: _buildAccountSection(context, theme),
            ),
            const SizedBox(height: 24),
            StaggeredEntrance(
              animation: _staggerAnimation,
              index: 1,
              child: _buildAppearanceSection(context, themeProvider, theme),
            ),
            const SizedBox(height: 24),
            StaggeredEntrance(
              animation: _staggerAnimation,
              index: 2,
              child: _buildAboutSection(context, theme),
            ),
            const SizedBox(height: 24),
            StaggeredEntrance(
              animation: _staggerAnimation,
              index: 3,
              child: _buildDataSection(context, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, ThemeData theme) {
    final profile = context.watch<ProfileProvider>();
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Account'),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    profile.profile?.initials ?? 'GD',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  profile.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  profile.profile?.email ?? 'Guest account',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeData theme,
  ) {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Appearance'),
            const SizedBox(height: 16),
            _buildThemeTile(
              context,
              title: 'Light Mode',
              subtitle: 'Always use light theme',
              icon: Icons.light_mode_rounded,
              iconColor: const Color(0xFFB37B2C),
              isSelected: themeProvider.themeMode == ThemeMode.light,
              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
            ),
            const SizedBox(height: 12),
            _buildThemeTile(
              context,
              title: 'Dark Mode',
              subtitle: 'Always use dark theme',
              icon: Icons.dark_mode_rounded,
              iconColor: const Color(0xFF0D9488),
              isSelected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
            ),
            const SizedBox(height: 12),
            _buildThemeTile(
              context,
              title: 'System Default',
              subtitle: 'Follow system theme setting',
              icon: Icons.brightness_auto_rounded,
              iconColor: const Color(0xFF475569),
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'About'),
            const SizedBox(height: 16),
            _buildInfoRow(
              context: context,
              icon: Icons.info_outline_rounded,
              label: 'Version',
              value: '1.0.0',
              iconColor: theme.colorScheme.primary,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context: context,
              icon: Icons.code_rounded,
              label: 'Built with',
              value: 'Flutter & Material 3',
              iconColor: const Color(0xFF475569),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context: context,
              icon: Icons.favorite_rounded,
              label: 'Made for',
              value: 'Fuel tracking enthusiasts',
              iconColor: const Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context, ThemeData theme) {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Data'),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.storage_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Database Manager',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'View tables, schemas, and run SQL queries',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DatabaseManagerScreen(),
                  ),
                ),
              ),
            ),
            const Divider(height: 24),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    color: theme.colorScheme.error,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Clear All Data',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Permanently delete all vehicles and fuel logs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                onTap: () => _showClearDataDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.white.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                    ]
                  : [
                      theme.colorScheme.onSurface.withValues(alpha: 0.03),
                      theme.colorScheme.onSurface.withValues(alpha: 0.01),
                    ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                )
              else
                Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: theme.colorScheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Clear All Data'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(
          'This will permanently delete all your vehicles and fuel logs. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<FuelProvider>().clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All data cleared'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
