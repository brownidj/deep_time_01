import 'package:sqlite3/sqlite3.dart';

class AppDatabaseSchema {
  const AppDatabaseSchema._();

  static void create(Database db) {
    db.execute('''
CREATE TABLE IF NOT EXISTS geologic_divisions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  rank TEXT NOT NULL,
  start_ma REAL NOT NULL,
  start_ma_uncertainty REAL,
  end_ma REAL NOT NULL,
  explanation TEXT,
  parent_id INTEGER,
  FOREIGN KEY (parent_id) REFERENCES geologic_divisions(id) ON DELETE SET NULL
);
''');

    db.execute('''
CREATE TABLE IF NOT EXISTS paleontology_taxa (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  summary TEXT NOT NULL
);
''');

    db.execute('''
CREATE TABLE IF NOT EXISTS fossil_ranges (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  taxon_id INTEGER NOT NULL,
  start_ma REAL NOT NULL,
  end_ma REAL NOT NULL,
  FOREIGN KEY (taxon_id) REFERENCES paleontology_taxa(id) ON DELETE CASCADE
);
''');

    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fossil_ranges_span ON fossil_ranges(start_ma, end_ma)',
    );

    db.execute('''
CREATE TABLE IF NOT EXISTS app_meta (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
''');
  }

  static void ensureColumns(Database db) {
    final columns = db.select('PRAGMA table_info(geologic_divisions)');
    final names = columns.map((row) => row['name'] as String).toSet();
    if (!names.contains('start_ma_uncertainty')) {
      db.execute(
        'ALTER TABLE geologic_divisions ADD COLUMN start_ma_uncertainty REAL',
      );
    }
    if (!names.contains('explanation')) {
      db.execute('ALTER TABLE geologic_divisions ADD COLUMN explanation TEXT');
    }
  }
}
