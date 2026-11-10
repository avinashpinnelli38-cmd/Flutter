import 'database_helper.dart';

class DatabaseViewer {
  static final DatabaseViewer instance = DatabaseViewer._internal();
  final DatabaseHelper _db = DatabaseHelper.instance;

  DatabaseViewer._internal();

  /// Browsers cannot lay out an unbounded `DataTable`, so the viewer caps how
  /// many rows it hands to the UI at once.
  static const int maxBrowsableRows = 500;

  bool lastRowsTruncated = false;

  Future<List<String>> getTableNames() async {
    final rows = await _db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getTableSchema(String table) async {
    return await _db.rawQuery('PRAGMA table_info("$table")');
  }

  Future<String> getTableDdl(String table) async {
    final rows = await _db.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type='table' AND name = ?",
      [table],
    );
    if (rows.isEmpty) return '/* No DDL found */';
    final sql = rows.first['sql'];
    return sql == null ? '/* No DDL found */' : sql.toString();
  }

  Future<List<Map<String, dynamic>>> getTableRows(String table) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM "$table" LIMIT $maxBrowsableRows',
    );
    lastRowsTruncated = rows.length == maxBrowsableRows;
    return rows;
  }

  Future<List<Map<String, dynamic>>> runQuery(String sql) async {
    return await _db.rawQuery(sql);
  }

  Future<int> runWrite(String sql) async {
    return await _db.rawExecute(sql);
  }
}
