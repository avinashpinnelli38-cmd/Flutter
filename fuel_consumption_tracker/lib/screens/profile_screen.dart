import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/fuel_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/glass_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditDialog(ProfileProvider profileProvider) {
    final current = profileProvider.profile;
    final nameController = TextEditingController(text: current?.name ?? '');
    final emailController = TextEditingController(text: current?.email ?? '');
    final phoneController = TextEditingController(text: current?.phone ?? '');
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Edit Profile'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_rounded),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone (optional)',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final error = await profileProvider.updateProfile(
                  UserProfile(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                  ),
                );
                if (error != null && ctx.mounted) {
                  ScaffoldMessenger.of(ctx)
                      .showSnackBar(SnackBar(content: Text(error)));
                } else if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
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
                Icons.logout_rounded,
                color: theme.colorScheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Sign Out'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text(
          'You will return to the login screen. Your vehicles and fuel logs remain saved on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.logout();
      if (!mounted) return;
      context.read<FuelProvider>().clearSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final fuelProvider = context.watch<FuelProvider>();
    final totalSpent = fuelProvider.fuelLogs.fold<double>(
      0,
      (sum, log) => sum + log.totalCost,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: GradientBlobBackground(
        dense: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3],
            ),
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(theme, profileProvider),
              const SizedBox(height: 16),
              _buildInfoCard(theme, profileProvider),
              const SizedBox(height: 16),
              _buildStatsCard(theme, fuelProvider, totalSpent),
              const SizedBox(height: 16),
              _buildSignOut(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, ProfileProvider provider) {
    final profile = provider.profile;
    final initials = profile?.initials ?? 'GD';
    return AnimatedCard(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Text(
                initials,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.email ?? 'Guest account',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (provider.isGuest) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'GUEST',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, ProfileProvider provider) {
    final profile = provider.profile;
    return AnimatedCard(
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showEditDialog(provider),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              theme,
              icon: Icons.person_rounded,
              label: 'Name',
              value: provider.displayName,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              theme,
              icon: Icons.mail_rounded,
              label: 'Email',
              value: profile?.email ?? 'Not set',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              theme,
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: profile?.phone?.isEmpty ?? true
                  ? 'Not set'
                  : profile!.phone!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    ThemeData theme,
    FuelProvider fuelProvider,
    double totalSpent,
  ) {
    final stats = [
      (
        Icons.directions_car_rounded,
        '${fuelProvider.vehicles.length}',
        'vehicles',
        theme.colorScheme.primary,
      ),
      (
        Icons.local_gas_station_rounded,
        '${fuelProvider.fuelLogs.length}',
        'fuel logs',
        theme.colorScheme.secondary,
      ),
      (
        Icons.payments_rounded,
        totalSpent.toStringAsFixed(0),
        'total spent',
        theme.colorScheme.tertiary,
      ),
    ];

    return AnimatedCard(
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: stats.map((s) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: s.$4.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(s.$1, color: s.$4, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.$2,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.$3,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSignOut(ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: _confirmLogout,
      icon: Icon(
        Icons.logout_rounded,
        size: 20,
        color: theme.colorScheme.error,
      ),
      label: Text('Sign Out', style: TextStyle(color: theme.colorScheme.error)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}
