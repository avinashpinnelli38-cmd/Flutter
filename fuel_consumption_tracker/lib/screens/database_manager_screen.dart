import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/database_viewer.dart';
import '../providers/fuel_provider.dart';
import '../models/vehicle.dart';
import '../models/fuel_log.dart';
import '../widgets/glass_container.dart';

class DatabaseManagerScreen extends StatefulWidget {
  const DatabaseManagerScreen({super.key});

  @override
  State<DatabaseManagerScreen> createState() => _DatabaseManagerScreenState();
}

class _DatabaseManagerScreenState extends State<DatabaseManagerScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseViewer _viewer = DatabaseViewer.instance;

  List<String> _tables = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _schema = [];
  List<Map<String, dynamic>> _rows = [];
  String _ddl = '';
  List<Map<String, dynamic>> _queryResults = [];
  List<String>? _queryColumns;
  String _sqlInput = '';
  String _sqlOutput = '';

  late final TextEditingController _sqlController;
  late TabController _tabController;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _sqlController = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
    _loadTables();
  }

  @override
  void dispose() {
    _sqlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final tables = await _viewer.getTableNames();
      setState(() {
        _tables = tables;
        if (tables.isNotEmpty && _selectedTable == null) {
          _selectedTable = tables.first;
        }
      });
      if (_selectedTable != null) {
        await _loadTableContent();
      }
    } catch (e) {
      setState(() => _error = 'Error loading tables: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadTableContent() async {
    if (_selectedTable == null) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final schema = await _viewer.getTableSchema(_selectedTable!);
      final rows = await _viewer.getTableRows(_selectedTable!);
      final ddl = await _viewer.getTableDdl(_selectedTable!);
      setState(() {
        _schema = schema;
        _rows = rows;
        _ddl = ddl;
      });
    } catch (e) {
      setState(() => _error = 'Error loading table: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _runSql() async {
    final sql = _sqlInput.trim();
    if (sql.isEmpty) {
      setState(() => _sqlOutput = 'Enter a SQL statement first.');
      return;
    }
    setState(() {
      _queryResults = [];
      _queryColumns = null;
      _sqlOutput = 'Running...';
    });

    final normalized = sql.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final isRead =
        normalized.startsWith('SELECT') ||
        normalized.startsWith('PRAGMA') ||
        normalized.startsWith('EXPLAIN');

    try {
      if (isRead) {
        final results = await _viewer.runQuery(sql);
        setState(() {
          _queryResults = results;
          _queryColumns = results.isNotEmpty
              ? results.first.keys.toList()
              : null;
          _sqlOutput = 'Query returned ${results.length} row(s).';
        });
      } else {
        final changed = await _viewer.runWrite(sql);
        setState(() {
          _queryResults = [];
          _queryColumns = null;
          _sqlOutput = 'Statement executed. $changed row(s) affected.';
        });
        await _loadTableContent();
      }
    } catch (e) {
      setState(() {
        _queryResults = [];
        _queryColumns = null;
        _sqlOutput = 'Error: $e';
      });
    }
  }

  Future<void> _deleteRow(Map<String, dynamic> row) async {
    if (_selectedTable == null) return;
    final id = row['id'];
    final provider = context.read<FuelProvider>();
    final messenger = ScaffoldMessenger.of(context);
    if (id == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Cannot delete row without an id column')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Row'),
        content: Text('Delete row with id = $id from "$_selectedTable"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (_selectedTable == 'vehicles') {
        await provider.deleteVehicle(id as int);
      } else if (_selectedTable == 'fuel_logs') {
        await provider.deleteFuelLog(id as int);
      } else {
        await _viewer.runWrite('DELETE FROM "$_selectedTable" WHERE id = $id');
      }
      messenger.showSnackBar(const SnackBar(content: Text('Row deleted')));
      await _loadTableContent();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Manager'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.colorScheme.onPrimary,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Schema'),
              Tab(text: 'DDL'),
              Tab(text: 'Rows'),
              Tab(text: 'SQL'),
            ],
          ),
        ),
      ),
      body: GradientBlobBackground(
        dense: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text(
                    'Table: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedTable,
                      isExpanded: true,
                      items: _tables
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedTable = value);
                        _loadTableContent();
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadTables,
                  ),
                ],
              ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _error,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSchemaTab(theme),
                        _buildDdlTab(theme),
                        _buildRowsTab(theme),
                        _buildSqlTab(theme),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemaTab(ThemeData theme) {
    if (_schema.isEmpty) {
      return const Center(child: Text('No schema information'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Column')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('PK')),
            DataColumn(label: Text('Not Null')),
            DataColumn(label: Text('Default')),
          ],
          rows: _schema.map((c) {
            return DataRow(
              cells: [
                DataCell(Text(c['name']?.toString() ?? '')),
                DataCell(Text(c['type']?.toString() ?? '')),
                DataCell(Text((c['pk'] ?? 0) == 1 ? 'YES' : '')),
                DataCell(Text((c['notnull'] ?? 0) == 1 ? 'YES' : '')),
                DataCell(Text(c['dflt_value']?.toString() ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDdlTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _ddl,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      ),
    );
  }

  Widget _buildRowsTab(ThemeData theme) {
    if (_rows.isEmpty) {
      return const Center(child: Text('No rows in this table'));
    }
    final columns = _rows.first.keys.toList();

    // Determine editability
    final isVehicle = _selectedTable == 'vehicles';
    final isFuelLog = _selectedTable == 'fuel_logs';
    final editable = isVehicle || isFuelLog;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  if (editable) const DataColumn(label: Text('Actions')),
                  ...columns.map((c) => DataColumn(label: Text(c))),
                ],
                rows: _rows.map((row) {
                  return DataRow(
                    cells: [
                      if (editable)
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isVehicle)
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () =>
                                      _editVehicleRow(context, row),
                                ),
                              if (isFuelLog)
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () =>
                                      _editFuelLogRow(context, row),
                                ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => _deleteRow(row),
                              ),
                            ],
                          ),
                        ),
                      ...columns.map(
                        (c) => DataCell(Text(_formatCell(row[c]))),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (isVehicle || isFuelLog)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(isVehicle ? 'Add Vehicle' : 'Add Fuel Log'),
                  onPressed: () => isVehicle
                      ? _addVehicleRow(context)
                      : _addFuelLogRow(context),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSqlTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _sqlController,
            onChanged: (v) => _sqlInput = v,
            maxLines: 3,
            minLines: 2,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter SQL... e.g. SELECT * FROM vehicles;',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run'),
                onPressed: _runSql,
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _sqlController.clear();
                  setState(() {
                    _sqlInput = '';
                    _sqlOutput = '';
                    _queryResults = [];
                    _queryColumns = null;
                  });
                },
              ),
            ],
          ),
          if (_sqlOutput.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _sqlOutput,
                style: TextStyle(
                  color: _sqlOutput.startsWith('Error')
                      ? theme.colorScheme.error
                      : null,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _queryColumns == null
                ? const Center(child: Text('Run a query to see results'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: _queryColumns!
                            .map((c) => DataColumn(label: Text(c)))
                            .toList(),
                        rows: _queryResults.map((row) {
                          return DataRow(
                            cells: [
                              ..._queryColumns!.map(
                                (c) => DataCell(Text(_formatCell(row[c]))),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatCell(Object? value) {
    if (value == null) return 'NULL';
    return value.toString();
  }

  Future<void> _editVehicleRow(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    final vehicle = Vehicle(
      id: row['id'] as int?,
      name: row['name']?.toString() ?? '',
      fuelType: row['fuel_type']?.toString() ?? '',
      tankCapacity: (row['tank_capacity'] as num?)?.toDouble() ?? 0,
    );

    final nameCtrl = TextEditingController(text: vehicle.name);
    final fuelCtrl = TextEditingController(text: vehicle.fuelType);
    final tankCtrl = TextEditingController(
      text: vehicle.tankCapacity.toString(),
    );
    final provider = context.read<FuelProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: fuelCtrl,
              decoration: const InputDecoration(labelText: 'Fuel Type'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tankCtrl,
              decoration: const InputDecoration(labelText: 'Tank Capacity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      try {
        await provider.updateVehicle(
          Vehicle(
            id: vehicle.id,
            name: nameCtrl.text,
            fuelType: fuelCtrl.text,
            tankCapacity: double.tryParse(tankCtrl.text) ?? 0,
          ),
        );
        await _loadTableContent();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  Future<void> _addVehicleRow(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final fuelCtrl = TextEditingController();
    final tankCtrl = TextEditingController();
    final provider = context.read<FuelProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: fuelCtrl,
              decoration: const InputDecoration(labelText: 'Fuel Type'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tankCtrl,
              decoration: const InputDecoration(labelText: 'Tank Capacity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (saved == true) {
      try {
        await provider.addVehicle(
          Vehicle(
            name: nameCtrl.text,
            fuelType: fuelCtrl.text,
            tankCapacity: double.tryParse(tankCtrl.text) ?? 0,
          ),
        );
        await _loadTableContent();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Add failed: $e')));
      }
    }
  }

  Future<void> _editFuelLogRow(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    final log = FuelLog(
      id: row['id'] as int?,
      vehicleId: (row['vehicle_id'] as num).toInt(),
      date: row['date']?.toString() ?? '',
      odometer: (row['odometer'] as num?)?.toDouble() ?? 0,
      fuelVolume: (row['fuel_volume'] as num?)?.toDouble() ?? 0,
      totalCost: (row['total_cost'] as num?)?.toDouble() ?? 0,
      isFullTank: (row['is_full_tank'] ?? 0) == 1,
    );

    final vehicleIdCtrl = TextEditingController(text: log.vehicleId.toString());
    final dateCtrl = TextEditingController(text: log.date);
    final odometerCtrl = TextEditingController(text: log.odometer.toString());
    final fuelCtrl = TextEditingController(text: log.fuelVolume.toString());
    final costCtrl = TextEditingController(text: log.totalCost.toString());
    final provider = context.read<FuelProvider>();
    final messenger = ScaffoldMessenger.of(context);

    var isFullTank = log.isFullTank;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Fuel Log'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleIdCtrl,
                decoration: const InputDecoration(labelText: 'Vehicle ID'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Date (yyyy-MM-dd)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: odometerCtrl,
                decoration: const InputDecoration(labelText: 'Odometer (km)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fuelCtrl,
                decoration: const InputDecoration(labelText: 'Fuel Volume (L)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'Total Cost'),
                keyboardType: TextInputType.number,
              ),
              CheckboxListTile(
                title: const Text('Full Tank'),
                value: isFullTank,
                onChanged: (v) => setDialogState(() => isFullTank = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      try {
        await provider.updateFuelLog(
          FuelLog(
            id: log.id,
            vehicleId: int.tryParse(vehicleIdCtrl.text) ?? log.vehicleId,
            date: dateCtrl.text,
            odometer: double.tryParse(odometerCtrl.text) ?? log.odometer,
            fuelVolume: double.tryParse(fuelCtrl.text) ?? log.fuelVolume,
            totalCost: double.tryParse(costCtrl.text) ?? log.totalCost,
            isFullTank: isFullTank,
          ),
        );
        await _loadTableContent();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  Future<void> _addFuelLogRow(BuildContext context) async {
    final provider = context.read<FuelProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final selected = provider.selectedVehicle;

    final vehicleId = selected?.id ?? 1;
    final vehicleIdCtrl = TextEditingController(text: '$vehicleId');
    final dateCtrl = TextEditingController();
    final odometerCtrl = TextEditingController();
    final fuelCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    var isFullTank = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Fuel Log'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleIdCtrl,
                decoration: const InputDecoration(labelText: 'Vehicle ID'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Date (yyyy-MM-dd)',
                  hintText: '2026-09-08',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: odometerCtrl,
                decoration: const InputDecoration(labelText: 'Odometer (km)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fuelCtrl,
                decoration: const InputDecoration(labelText: 'Fuel Volume (L)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'Total Cost'),
                keyboardType: TextInputType.number,
              ),
              CheckboxListTile(
                title: const Text('Full Tank'),
                value: isFullTank,
                onChanged: (v) => setDialogState(() => isFullTank = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      try {
        await provider.addFuelLog(
          FuelLog(
            vehicleId: int.tryParse(vehicleIdCtrl.text) ?? vehicleId,
            date: dateCtrl.text,
            odometer: double.tryParse(odometerCtrl.text) ?? 0,
            fuelVolume: double.tryParse(fuelCtrl.text) ?? 0,
            totalCost: double.tryParse(costCtrl.text) ?? 0,
            isFullTank: isFullTank,
          ),
        );
        await _loadTableContent();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Add failed: $e')));
      }
    }
  }
}
