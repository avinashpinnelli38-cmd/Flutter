import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../providers/fuel_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../widgets/mileage_gauge.dart';
import '../widgets/stat_card.dart';
import '../widgets/empty_state.dart';

/// `DateFormat` construction is comparatively expensive and these are called
/// from chart title/tooltip builders, so they are created once per app run.
final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
final DateFormat _shortDate = DateFormat('MMM dd');
final DateFormat _chartDate = DateFormat('MM/dd');
final DateFormat _activityDate = DateFormat('MMM dd, yyyy');

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _staggerController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
        if (provider.vehicles.isEmpty) {
          return EmptyState(
            icon: Icons.directions_car_outlined,
            title: 'No Vehicles Yet',
            subtitle:
                'Add your first vehicle to start tracking fuel consumption',
            actionLabel: 'Add Vehicle',
            onAction: () => _navigateToVehicles(context),
            animation: _fadeAnimation,
          );
        }

        final mileage = provider.mileageRecords;
        final monthlyExpenses = provider.monthlyExpenses;
        final logs = provider.fuelLogs;
        final recentLogs = logs.reversed.take(5).toList();
        final selectedVehicle = provider.selectedVehicle;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer
                      .withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
            child: RepaintBoundary(
              child: RefreshIndicator(
                onRefresh: () async => provider.loadAll(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, provider),
                            const SizedBox(height: 20),
                            _buildEfficiencyCard(context, provider),
                            const SizedBox(height: 24),
                            _buildSummaryCards(provider),
                            const SizedBox(height: 24),
                            if (selectedVehicle != null)
                              _buildVehicleQuickStats(
                                context,
                                selectedVehicle,
                                provider,
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    if (mileage.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Mileage Trend'),
                              const SizedBox(height: 12),
                              RepaintBoundary(
                                child: _buildMileageChart(context, mileage),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    if (monthlyExpenses.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Monthly Expenses'),
                              const SizedBox(height: 12),
                              RepaintBoundary(
                                child: _buildExpenseChart(
                                  context,
                                  monthlyExpenses,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('Recent Activity'),
                            if (recentLogs.isNotEmpty)
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                ),
                                label: const Text('View All'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (recentLogs.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: _buildEmptyActivity(),
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: recentLogs.length,
                        itemBuilder: (context, index) {
                          final log = recentLogs[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: _buildActivityCard(
                              context,
                              log.date,
                              log.odometer,
                              log.totalCost,
                              log.fuelVolume,
                              index,
                            ),
                          );
                        },
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FuelProvider provider) {
    final selectedVehicle = provider.selectedVehicle;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0x33475569),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Live Tracking',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedVehicle != null
                      ? 'Tracking ${selectedVehicle.name}'
                      : 'Select a vehicle to view details',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.95)),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.local_gas_station_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(FuelProvider provider) {
    return Row(
      children: [
        Expanded(
          child: StaggeredEntrance(
            animation: _staggerAnimation,
            index: 0,
            child: StatCard(
              icon: Icons.directions_car_rounded,
              label: 'Vehicles',
              value: '${provider.vehicles.length}',
              color: Theme.of(context).colorScheme.primary,
              trend: provider.vehicles.length > 1
                  ? '+${provider.vehicles.length - 1} more'
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StaggeredEntrance(
            animation: _staggerAnimation,
            index: 1,
            child: StatCard(
              icon: Icons.local_gas_station_rounded,
              label: 'Fuel Logs',
              value: '${provider.fuelLogs.length}',
              color: AppTheme.semanticPositive(context),
              trend: provider.fuelLogs.isNotEmpty ? 'Total entries' : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StaggeredEntrance(
            animation: _staggerAnimation,
            index: 2,
            child: StatCard(
              icon: Icons.trending_up_rounded,
              label: 'Trips Recorded',
              value: '${provider.mileageRecords.length}',
              color: AppTheme.semanticTertiary(context),
              trend: provider.mileageRecords.isNotEmpty
                  ? 'Complete trips'
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyCard(BuildContext context, FuelProvider provider) {
    final theme = Theme.of(context);
    final mileageRecords = provider.mileageRecords;
    final avgMileage = mileageRecords.isEmpty
        ? 0.0
        : mileageRecords
                  .map((r) => ((r['mileage'] ?? 0) as num).toDouble())
                  .fold(0.0, (a, b) => a + b) /
              mileageRecords.length;
    final costPerKm = mileageRecords.isEmpty
        ? 0.0
        : ((mileageRecords.last['cost_per_km'] ?? 0) as num).toDouble();
    final totalSpent = provider.fuelLogs.fold<double>(
      0,
      (sum, log) => sum + log.totalCost,
    );
    final efficiencyMax = avgMileage < 1
        ? 20.0
        : ((avgMileage * 1.6) / 5).ceil() * 5.0;

    final efficiencyColor = avgMileage <= 0
        ? theme.colorScheme.primary
        : avgMileage >= 12
        ? AppTheme.semanticPositive(context)
        : avgMileage >= 7
        ? AppTheme.semanticTertiary(context)
        : theme.colorScheme.error;

    return AnimatedCard(
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fuel Efficiency',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (provider.selectedVehicle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: efficiencyColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_gas_station_rounded,
                          size: 13,
                          color: efficiencyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.selectedVehicle!.fuelType,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: efficiencyColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                MileageGauge(
                  value: avgMileage,
                  maxValue: efficiencyMax,
                  width: 190,
                  height: 168,
                  trackColor: theme.colorScheme.primaryContainer,
                  arcColor: efficiencyColor,
                  caption: mileageRecords.isEmpty ? 'No trips yet' : null,
                  interactiveHint: mileageRecords.isEmpty,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MiniMetric(
                        icon: Icons.auto_graph_rounded,
                        label: 'Avg mileage',
                        value: mileageRecords.isEmpty
                            ? '—'
                            : '${avgMileage.toStringAsFixed(1)} km/L',
                        color: efficiencyColor,
                      ),
                      const SizedBox(height: 10),
                      _MiniMetric(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Cost per km',
                        value: mileageRecords.isEmpty
                            ? '—'
                            : '₹${costPerKm.toStringAsFixed(2)}',
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(height: 10),
                      _MiniMetric(
                        icon: Icons.payments_rounded,
                        label: 'Total spent',
                        value: '₹${totalSpent.toStringAsFixed(0)}',
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleQuickStats(
    BuildContext context,
    Vehicle vehicle,
    FuelProvider provider,
  ) {
    return AnimatedCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondaryContainer
                  .withValues(alpha: 0.4),
              Theme.of(context).colorScheme.secondaryContainer
                  .withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.speed_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Odometer',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.fuelLogs.isNotEmpty ? provider.fuelLogs.last.odometer.toStringAsFixed(0) : vehicle.name} km',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                vehicle.fuelType,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
    );
  }

  Widget _buildMileageChart(
    BuildContext context,
    List<Map<String, dynamic>> records,
  ) {
    final formattedRecords = List.generate(records.length, (i) {
      return FlSpot(i.toDouble(), records[i]['mileage']?.toDouble() ?? 0.0);
    });

    final avgMileage = records.isNotEmpty
        ? records
                  .map((r) => r['mileage']?.toDouble() ?? 0.0)
                  .reduce((a, b) => a + b) /
              records.length
        : 0.0;

    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Average: ${avgMileage.toStringAsFixed(2)} km/L',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${records.length} trips',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Theme.of(context).colorScheme.surface,
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final idx = spot.x.toInt();
                          if (idx >= 0 && idx < records.length) {
                            final date = _shortDate.format(
                              _isoDate.parse(records[idx]['end_date']),
                            );
                            return LineTooltipItem(
                              '$date\n${spot.y.toStringAsFixed(2)} km/L',
                              TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: (records.length / 5).ceil().toDouble().clamp(
                          1,
                          records.length.toDouble(),
                        ),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 &&
                              idx < records.length &&
                              idx %
                                      ((records.length / 5).ceil().clamp(
                                        1,
                                        records.length,
                                      )) ==
                                  0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _chartDate.format(
                                  _isoDate.parse(records[idx]['end_date']),
                                ),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toStringAsFixed(0),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: records.length > 1
                      ? (records.length - 1).toDouble()
                      : 1,
                  minY: 0,
                  maxY:
                      (records
                                  .map((r) => r['mileage']?.toDouble() ?? 0.0)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2)
                          .clamp(10.0, double.infinity),
                  lineBarsData: [
                    LineChartBarData(
                      spots: formattedRecords,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: Theme.of(context).colorScheme.primary,
                              strokeWidth: 3,
                              strokeColor: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.25),
                            Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart(
    BuildContext context,
    List<Map<String, dynamic>> expenses,
  ) {
    final maxExpense = expenses.isNotEmpty
        ? expenses
              .map((e) => (e['total_cost'] ?? 0).toDouble())
              .reduce((a, b) => a > b ? a : b)
        : 100.0;

    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${expenses.fold(0.0, (sum, e) => sum + (e['total_cost'] ?? 0).toDouble()).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${expenses.length} months',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxExpense * 1.3,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Theme.of(context).colorScheme.surface,
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final expense = expenses[group.x.toInt()];
                        return BarTooltipItem(
                          '${expense['month']}\n${expense['total_cost'].toStringAsFixed(0)}',
                          TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < expenses.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                expenses[idx]['month'],
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toStringAsFixed(0),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxExpense / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: expenses.asMap().entries.map((entry) {
                    final value = (entry.value['total_cost'] ?? 0).toDouble();
                    final isLast = entry.key == expenses.length - 1;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              isLast
                                  ? const Color(0xFFD97706)
                                  : Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.7),
                            ],
                          ),
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxExpense * 1.3,
                            color: Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String rawDate,
    double odometer,
    double totalCost,
    double fuelVolume,
    int index,
  ) {
    final date = _formatActivityDate(rawDate);
    return AnimatedSlideIn(
      key: ValueKey('activity-$rawDate-$odometer'),
      delay: Duration(milliseconds: 80 * index),
      child: AnimatedCard(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.18),
                      Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.local_gas_station_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${odometer.toStringAsFixed(0)} km',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalCost.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fuelVolume.toStringAsFixed(1)} L',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.6),
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

  Widget _buildEmptyActivity() {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No recent activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add your first fuel log to see activity here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToVehicles(BuildContext context) {
    DefaultTabController.of(context).animateTo(2);
  }

  static String _formatActivityDate(String raw) {
    return _activityDate.format(_isoDate.parse(raw));
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.18 : 0.12),
            color.withValues(alpha: isDark ? 0.06 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
