import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../providers/fuel_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../widgets/empty_state.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _staggerController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _staggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Vehicles'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _showAddDialog(context, provider),
                tooltip: 'Add Vehicle',
              ),
              const SizedBox(width: 8),
            ],
          ),
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
            child: RepaintBoundary(
              child: provider.vehicles.isEmpty
                  ? EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'No Vehicles Added',
                      subtitle: 'Add your first vehicle to start tracking fuel consumption',
                      actionLabel: 'Add Vehicle',
                      onAction: () => _showAddDialog(context, provider),
                      animation: _fadeAnimation,
                    )
                  : CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: StaggeredEntrance(
                              animation: _staggerAnimation,
                              index: 0,
                              child: _buildSummaryCard(context, provider),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList.builder(
                            itemCount: provider.vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = provider.vehicles[index];
                              return StaggeredEntrance(
                                animation: _staggerAnimation,
                                index: index + 1,
                                child: _buildVehicleCard(
                                  context,
                                  provider,
                                  vehicle,
                                  index,
                                ),
                              );
                            },
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, FuelProvider provider) {
    final theme = Theme.of(context);
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${provider.vehicles.length} Vehicle${provider.vehicles.length != 1 ? 's' : ''}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a vehicle to select it for fuel logging',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    FuelProvider provider,
    Vehicle vehicle,
    int index,
  ) {
    final isSelected = provider.selectedVehicle?.id == vehicle.id;
    final theme = Theme.of(context);

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => provider.selectVehicle(vehicle),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : Border.all(color: theme.dividerColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vehicle.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.local_gas_station_rounded,
                            label: vehicle.fuelType,
                            color: AppTheme.semanticInfo(context),
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.water_drop_rounded,
                            label:
                                '${vehicle.tankCapacity.toStringAsFixed(0)} L',
                            color: AppTheme.semanticPositive(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'select') {
                      provider.selectVehicle(vehicle);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, provider, vehicle);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'select',
                      enabled: !isSelected,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Set as Active'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Delete',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, FuelProvider provider) {
    final nameController = TextEditingController();
    final fuelTypeController = TextEditingController(text: 'Petrol');
    final capacityController = TextEditingController(text: '50');
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
                Icons.add_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Add Vehicle'),
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
                  decoration: InputDecoration(
                    labelText: 'Vehicle Name',
                    hintText: 'e.g. My Honda City',
                    prefixIcon: Icon(
                      Icons.directions_car_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a name' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fuelTypeController,
                  decoration: InputDecoration(
                    labelText: 'Fuel Type',
                    hintText: 'Petrol / Diesel / CNG / Electric',
                    prefixIcon: Icon(
                      Icons.local_gas_station_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter fuel type' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: 'Tank Capacity',
                    hintText: 'e.g. 50',
                    prefixIcon: Icon(
                      Icons.water_drop_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    suffixText: 'L',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final v = double.tryParse(value);
                    if (v == null || v <= 0) return 'Enter a valid capacity';
                    return null;
                  },
                  textInputAction: TextInputAction.done,
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
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final vehicle = Vehicle(
                  name: nameController.text,
                  fuelType: fuelTypeController.text,
                  tankCapacity:
                      double.tryParse(capacityController.text) ?? 50.0,
                );
                provider.addVehicleAndSelect(vehicle);
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FuelProvider provider,
    Vehicle vehicle,
  ) {
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
                Icons.delete_rounded,
                color: theme.colorScheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Vehicle'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(
          'Are you sure you want to delete "${vehicle.name}"? All associated fuel logs will also be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteVehicle(vehicle.id!);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
