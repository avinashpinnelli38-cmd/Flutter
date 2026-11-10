import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../models/fuel_log.dart';
import '../providers/fuel_provider.dart';
import '../screens/vehicles_screen.dart';
import '../widgets/animated_card.dart';
import '../widgets/empty_state.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _fuelVolumeController = TextEditingController();
  final _totalCostController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isFullTank = true;
  Vehicle? _selectedVehicle;
  bool _isSubmitting = false;

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

    final provider = context.read<FuelProvider>();
    provider.loadVehicles();
    if (provider.vehicles.isNotEmpty && provider.selectedVehicle == null) {
      _selectedVehicle = provider.vehicles.first;
    } else {
      _selectedVehicle = provider.selectedVehicle;
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _fuelVolumeController.dispose();
    _totalCostController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme
                .copyWith(primary: Theme.of(context).colorScheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      if (_selectedVehicle == null) {
        setState(() => _isSubmitting = false);
        _showErrorMessage('Please select a vehicle first');
        return;
      }

      final provider = context.read<FuelProvider>();
      final log = FuelLog(
        vehicleId: _selectedVehicle!.id!,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        odometer: double.parse(_odometerController.text),
        fuelVolume: double.parse(_fuelVolumeController.text),
        totalCost: double.parse(_totalCostController.text),
        isFullTank: _isFullTank,
      );

      provider
          .addFuelLog(log)
          .then((_) {
            if (!mounted) return;
            setState(() => _isSubmitting = false);
            _showSuccessMessage('Fuel log saved successfully');
            _odometerController.clear();
            _fuelVolumeController.clear();
            _totalCostController.clear();
            setState(() {
              _selectedDate = DateTime.now();
              _isFullTank = true;
            });
          })
          .catchError((error) {
            if (!mounted) return;
            setState(() => _isSubmitting = false);
            _showErrorMessage('Failed to save fuel log: ${error.toString()}');
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelProvider>(
      builder: (context, provider, _) {
        if (provider.vehicles.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add Fuel Log')),
            body: Center(
              child: EmptyState(
                icon: Icons.directions_car_outlined,
                title: 'No Vehicles Yet',
                subtitle: 'Add a vehicle before logging fuel',
                actionLabel: 'Add Vehicle',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Fuel Log'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                onPressed: () {},
                tooltip: 'View History',
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
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            StaggeredEntrance(
                              animation: _staggerAnimation,
                              index: 0,
                              step: 0.1,
                              distance: 20,
                              child: _buildVehicleSelector(context, provider),
                            ),
                            const SizedBox(height: 16),
                            StaggeredEntrance(
                              animation: _staggerAnimation,
                              index: 1,
                              step: 0.1,
                              distance: 20,
                              child: _buildOdometerField(context),
                            ),
                            const SizedBox(height: 16),
                            StaggeredEntrance(
                              animation: _staggerAnimation,
                              index: 2,
                              step: 0.1,
                              distance: 20,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildFuelVolumeField(context),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTotalCostField(context),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            StaggeredEntrance(
                              animation: _staggerAnimation,
                              index: 3,
                              step: 0.1,
                              distance: 20,
                              child: _buildFullTankToggle(context),
                            ),
                            const SizedBox(height: 16),
                            StaggeredEntrance(
                              animation: _staggerAnimation,
                              index: 4,
                              step: 0.1,
                              distance: 20,
                              child: _buildDatePicker(context),
                            ),
                            const SizedBox(height: 32),
                            StaggeredEntrance(
                              animation: _staggerAnimation,
                              index: 5,
                              step: 0.1,
                              distance: 20,
                              child: _buildSubmitButton(context, provider),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleSelector(BuildContext context, FuelProvider provider) {
    final theme = Theme.of(context);
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vehicle',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Vehicle>(
              initialValue: _selectedVehicle,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Select Vehicle',
                hintText: 'Choose a vehicle',
                prefixIcon: Icon(
                  Icons.directions_car_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                errorText: _selectedVehicle == null && _isSubmitting
                    ? 'Please select a vehicle'
                    : null,
              ),
              items: provider.vehicles
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              v.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedVehicle = v),
              validator: (_) =>
                  _selectedVehicle == null ? 'Select a vehicle' : null,
              menuMaxHeight: 300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOdometerField(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _odometerController,
          decoration: InputDecoration(
            labelText: 'Odometer Reading',
            hintText: 'e.g. 15,234',
            prefixIcon: Icon(
              Icons.speed_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            suffixText: 'km',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            final v = double.tryParse(value.replaceAll(',', ''));
            if (v == null || v < 0) return 'Enter a valid number';
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildFuelVolumeField(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _fuelVolumeController,
          decoration: InputDecoration(
            labelText: 'Fuel Volume',
            hintText: 'e.g. 45.5',
            prefixIcon: Icon(
              Icons.local_gas_station_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            suffixText: 'L',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            final v = double.tryParse(value.replaceAll(',', ''));
            if (v == null || v <= 0) return 'Enter a valid amount';
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildTotalCostField(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _totalCostController,
          decoration: InputDecoration(
            labelText: 'Total Cost',
            hintText: 'e.g. 1250.00',
            prefixIcon: Icon(
              Icons.attach_money_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixText: '₹ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            final v = double.tryParse(value.replaceAll(',', ''));
            if (v == null || v < 0) return 'Enter a valid amount';
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildFullTankToggle(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Tank Fill',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Enable if you filled the tank completely',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isFullTank,
              onChanged: (v) => setState(() => _isFullTank = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCard(
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: theme.colorScheme.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, FuelProvider provider) {
    final theme = Theme.of(context);
    return FilledButton(
      onPressed: _selectedVehicle == null || _isSubmitting ? null : _submit,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_rounded, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Save Fuel Log',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
    );
  }
}
