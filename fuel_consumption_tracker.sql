-- ============================================================================
--  Fuel Consumption Tracker - Complete SQLite Dump
--  Project : fuel_consumption_tracker (Flutter + sqflite)
--  Engine  : SQLite 3
--  Schema  : version 3 (matches DatabaseHelper._createDb / _createIndexes)
--  Contents: schema (tables + indexes), reporting views, seed/sample data,
--            demo accounts, and AUTOINCREMENT sequence reset.
--
--  Import (desktop / CLI):
--      sqlite3 fuel_tracker.db < fuel_consumption_tracker.sql
--
--  The app itself creates the same schema in:
--      lib/services/database_helper_mobile.dart
--      lib/services/database_helper_web.dart
--
--  NOTE: No live fuel_tracker.db file was found inside the project, so the
--  data below is representative seed data for every table. Replace or extend
--  it as needed. Demo login accounts are listed in section 5.
-- ============================================================================

PRAGMA foreign_keys = OFF;
PRAGMA encoding = 'UTF-8';
BEGIN TRANSACTION;

-- ----------------------------------------------------------------------------
-- 1. CLEAN SLATE (safe to re-run on an existing database)
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS v_monthly_expenses;
DROP VIEW IF EXISTS v_vehicle_summary;
DROP VIEW IF EXISTS v_fuel_log_details;
DROP TABLE IF EXISTS fuel_logs;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS users;

-- ----------------------------------------------------------------------------
-- 2. SCHEMA (exactly as created by the application)
-- ----------------------------------------------------------------------------
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  salt TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  is_guest INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE vehicles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  fuel_type TEXT NOT NULL,
  tank_capacity REAL NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE fuel_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  vehicle_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  odometer REAL NOT NULL,
  fuel_volume REAL NOT NULL,
  total_cost REAL NOT NULL,
  is_full_tank INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id)
);

-- ----------------------------------------------------------------------------
-- 3. INDEXES (schema version 3)
--    The dashboard, vehicle list and log list filter by user/vehicle and
--    order by date, so these keep those queries off full table scans.
-- ----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_vehicles_user
  ON vehicles(user_id);

CREATE INDEX IF NOT EXISTS idx_fuel_logs_user_vehicle_date
  ON fuel_logs(user_id, vehicle_id, date);

CREATE INDEX IF NOT EXISTS idx_fuel_logs_vehicle_date
  ON fuel_logs(vehicle_id, date);

-- ----------------------------------------------------------------------------
-- 4. REPORTING VIEWS (helper views mirroring in-app aggregations)
-- ----------------------------------------------------------------------------

-- Monthly fuel spend per vehicle (same shape as getMonthlyExpenses()).
CREATE VIEW v_monthly_expenses AS
SELECT
  fl.user_id,
  u.name                                   AS user_name,
  fl.vehicle_id,
  v.name                                   AS vehicle_name,
  strftime('%Y-%m', fl.date)               AS month,
  COUNT(*)                                 AS fill_count,
  ROUND(SUM(fl.fuel_volume), 3)            AS total_fuel_volume,
  ROUND(SUM(fl.total_cost), 2)             AS total_cost
FROM fuel_logs fl
JOIN users    u ON u.id = fl.user_id
JOIN vehicles v ON v.id = fl.vehicle_id
GROUP BY fl.user_id, u.name, fl.vehicle_id, v.name, strftime('%Y-%m', fl.date)
ORDER BY month ASC;

-- Lifetime totals per vehicle.
CREATE VIEW v_vehicle_summary AS
SELECT
  v.id                                     AS vehicle_id,
  v.user_id,
  u.name                                   AS owner_name,
  v.name                                   AS vehicle_name,
  v.fuel_type,
  v.tank_capacity,
  COUNT(fl.id)                             AS total_fills,
  COALESCE(ROUND(SUM(fl.fuel_volume), 3), 0) AS total_fuel_volume,
  COALESCE(ROUND(SUM(fl.total_cost), 2), 0)  AS total_cost,
  COALESCE(ROUND(AVG(NULLIF(fl.fuel_volume, 0)), 3), 0) AS avg_fill_volume,
  MIN(fl.odometer)                         AS first_odometer,
  MAX(fl.odometer)                         AS last_odometer
FROM vehicles v
JOIN users u ON u.id = v.user_id
LEFT JOIN fuel_logs fl
       ON fl.vehicle_id = v.id AND fl.user_id = v.user_id
GROUP BY v.id, v.user_id, u.name, v.name, v.fuel_type, v.tank_capacity
ORDER BY u.name ASC, v.name ASC;

-- Denormalised fuel log feed with computed price per litre.
CREATE VIEW v_fuel_log_details AS
SELECT
  fl.id                                    AS log_id,
  fl.user_id,
  u.name                                   AS user_name,
  fl.vehicle_id,
  v.name                                   AS vehicle_name,
  v.fuel_type,
  fl.date,
  fl.odometer,
  fl.fuel_volume,
  fl.total_cost,
  ROUND(fl.total_cost / NULLIF(fl.fuel_volume, 0), 2) AS price_per_litre,
  fl.is_full_tank
FROM fuel_logs fl
JOIN users    u ON u.id = fl.user_id
JOIN vehicles v ON v.id = fl.vehicle_id
ORDER BY fl.date ASC, fl.id ASC;

-- ----------------------------------------------------------------------------
-- 5. DATA - users
--    Password hashing used by the app: sha256("<salt>::<password>")
--    Demo accounts:
--      demo@fueltracker.app  / demo123      (Demo Driver)
--      avinash@example.com   / avinash123   (Avinash Reddy)
--    Guest row (id = 1) mirrors ProfileProvider.continueAsGuest().
-- ----------------------------------------------------------------------------
DELETE FROM sqlite_sequence;

INSERT INTO users (id, name, email, phone, salt, password_hash, is_guest) VALUES
  (1, 'Guest Driver', '__guest__', NULL, 'guest', 'guest', 1),
  (2, 'Demo Driver', 'demo@fueltracker.app', '+91 98765 43210',
      'ZGVtby1zYWx0LTEyMzQ1Ng==',
      '974f4da00e2089772cc64e56b9d4bba3db3ce07306a687d50e0f2a4b3c0ca678', 0),
  (3, 'Avinash Reddy', 'avinash@example.com', '+91 91234 56789',
      'YXZpbmFzaC1zYWx0LTIwMjY=',
      '048176ab142db701e493309c833a3a42b9c075bd001f75bbc91a22a53d4f0a60', 0);

-- ----------------------------------------------------------------------------
-- 6. DATA - vehicles
-- ----------------------------------------------------------------------------
INSERT INTO vehicles (id, user_id, name, fuel_type, tank_capacity) VALUES
  (1, 2, 'Honda City',                'Petrol', 40.0),
  (2, 2, 'Royal Enfield Classic 350', 'Petrol', 13.0),
  (3, 2, 'Tata Nexon',                'Diesel', 44.0),
  (4, 3, 'Maruti Swift',              'Petrol', 37.0),
  (5, 3, 'Bajaj Pulsar 150',          'Petrol', 15.0),
  (6, 1, 'Guest Car',                 'Petrol', 45.0);

-- ----------------------------------------------------------------------------
-- 7. DATA - fuel logs
--    is_full_tank = 1 marks a full tank (mileage reference point);
--    0 marks a partial fill that is rolled into the next segment.
-- ----------------------------------------------------------------------------

-- Vehicle 1 - Honda City (user 2)
INSERT INTO fuel_logs (id, user_id, vehicle_id, date, odometer, fuel_volume, total_cost, is_full_tank) VALUES
  (1,  2, 1, '2026-01-05', 12500.0, 32.50, 3412.50, 1),
  (2,  2, 1, '2026-01-19', 12985.0, 33.10, 3508.60, 1),
  (3,  2, 1, '2026-02-03', 13470.0, 31.80, 3370.80, 1),
  (4,  2, 1, '2026-02-18', 13990.0, 34.50, 3691.50, 1),
  (5,  2, 1, '2026-03-06', 14480.0, 32.20, 3445.40, 1),
  (6,  2, 1, '2026-03-24', 14995.0, 33.00, 3564.00, 1),
  (7,  2, 1, '2026-04-10', 15460.0, 31.50, 3402.00, 1),
  (8,  2, 1, '2026-05-02', 15990.0, 34.80, 3828.00, 1),
  (9,  2, 1, '2026-06-15', 16470.0, 32.00, 3520.00, 1),
  (10, 2, 1, '2026-07-01', 16720.0, 15.00, 1650.00, 0),
  (11, 2, 1, '2026-08-09', 16980.0, 33.50, 3752.00, 1),
  (12, 2, 1, '2026-10-12', 17485.0, 32.90, 3783.50, 1);

-- Vehicle 2 - Royal Enfield Classic 350 (user 2)
INSERT INTO fuel_logs (id, user_id, vehicle_id, date, odometer, fuel_volume, total_cost, is_full_tank) VALUES
  (13, 2, 2, '2026-01-08',  8200.0, 10.50,  997.50, 1),
  (14, 2, 2, '2026-02-12',  8560.0, 10.20,  969.00, 1),
  (15, 2, 2, '2026-03-15',  8915.0, 10.80, 1026.00, 1),
  (16, 2, 2, '2026-04-20',  9270.0, 10.10,  959.50, 1),
  (17, 2, 2, '2026-06-05',  9635.0, 10.60, 1007.00, 1),
  (18, 2, 2, '2026-08-22',  9990.0, 10.40,  988.00, 1),
  (19, 2, 2, '2026-10-05', 10340.0, 10.90, 1035.50, 1);

-- Vehicle 3 - Tata Nexon (user 2)
INSERT INTO fuel_logs (id, user_id, vehicle_id, date, odometer, fuel_volume, total_cost, is_full_tank) VALUES
  (20, 2, 3, '2026-01-10', 22100.0, 38.50, 3426.50, 1),
  (21, 2, 3, '2026-02-08', 22620.0, 39.20, 3488.80, 1),
  (22, 2, 3, '2026-03-12', 23150.0, 38.90, 3462.10, 1),
  (23, 2, 3, '2026-04-18', 23640.0, 37.80, 3364.20, 1),
  (24, 2, 3, '2026-06-02', 24130.0, 39.50, 3555.00, 1),
  (25, 2, 3, '2026-07-25', 24660.0, 38.20, 3438.00, 1),
  (26, 2, 3, '2026-09-14', 25180.0, 39.00, 3549.00, 1);

-- Vehicle 4 - Maruti Swift (user 3)
INSERT INTO fuel_logs (id, user_id, vehicle_id, date, odometer, fuel_volume, total_cost, is_full_tank) VALUES
  (27, 3, 4, '2026-02-02',  9800.0, 30.50, 3202.50, 1),
  (28, 3, 4, '2026-03-08', 10320.0, 31.20, 3276.00, 1),
  (29, 3, 4, '2026-04-14', 10800.0, 29.80, 3129.00, 1),
  (30, 3, 4, '2026-05-30', 11340.0, 30.90, 3244.50, 1),
  (31, 3, 4, '2026-07-18', 11860.0, 31.50, 3307.50, 1),
  (32, 3, 4, '2026-09-22', 12390.0, 30.70, 3223.50, 1);

-- Vehicle 5 - Bajaj Pulsar 150 (user 3)
INSERT INTO fuel_logs (id, user_id, vehicle_id, date, odometer, fuel_volume, total_cost, is_full_tank) VALUES
  (33, 3, 5, '2026-01-15', 15200.0, 8.50, 892.50, 1),
  (34, 3, 5, '2026-02-25', 15580.0, 8.20, 861.00, 1),
  (35, 3, 5, '2026-04-05', 15920.0, 8.70, 913.50, 1),
  (36, 3, 5, '2026-05-19', 16275.0, 8.40, 882.00, 1),
  (37, 3, 5, '2026-07-08', 16640.0, 8.60, 903.00, 1),
  (38, 3, 5, '2026-08-30', 16990.0, 8.30, 871.50, 1),
  (39, 3, 5, '2026-10-18', 17350.0, 8.80, 924.00, 1);

-- Vehicle 6 - Guest Car (user 1)
INSERT INTO fuel_logs (id, user_id, vehicle_id, date, odometer, fuel_volume, total_cost, is_full_tank) VALUES
  (40, 1, 6, '2026-03-03', 7500.0, 40.00, 4200.00, 1),
  (41, 1, 6, '2026-04-22', 7950.0, 41.50, 4357.50, 1),
  (42, 1, 6, '2026-06-11', 8390.0, 39.50, 4147.50, 1);

-- ----------------------------------------------------------------------------
-- 8. AUTOINCREMENT SEQUENCES
--    Keep future inserts from colliding with the seeded ids above.
-- ----------------------------------------------------------------------------
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence (name, seq) VALUES
  ('users',     3),
  ('vehicles',  6),
  ('fuel_logs', 42);

-- ----------------------------------------------------------------------------
-- 9. SCHEMA VERSION + FINALISE
--    onUpgrade() uses PRAGMA user_version, so importers should see 3.
-- ----------------------------------------------------------------------------
PRAGMA user_version = 3;

COMMIT;
PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- 10. VERIFICATION (uncomment to run manually)
-- ----------------------------------------------------------------------------
-- SELECT COUNT(*) AS users    FROM users;
-- SELECT COUNT(*) AS vehicles FROM vehicles;
-- SELECT COUNT(*) AS fuel_logs FROM fuel_logs;
-- SELECT * FROM v_vehicle_summary;
-- SELECT * FROM v_monthly_expenses;
-- SELECT * FROM v_fuel_log_details;
