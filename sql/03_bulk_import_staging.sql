USE RoadAccidentDB;
GO

/* ==================================================================
   03_bulk_import_staging.sql

   Edit the :setvar line below, then run this script.

   This script runs in SQLCMD mode. In SSMS enable it with
   Query > SQLCMD Mode; from a terminal run it with the sqlcmd
   utility. BULK INSERT reads the files server-side, so DataPath must
   point to a folder the SQL Server service account can read -- which
   is not necessarily the folder on the machine you are typing from.

   The three *_clean.csv files are produced by src/prepare_data.py
   into data/processed/clean/.
   ================================================================== */

:setvar DataPath "C:\SQLData\RoadAccidentData"


/* Clear staging tables so the script can be safely rerun. */
TRUNCATE TABLE stg.Collisions;
TRUNCATE TABLE stg.Casualties;
TRUNCATE TABLE stg.Vehicles;
GO


PRINT 'Importing collisions...';

BULK INSERT stg.Collisions
FROM '$(DataPath)\collisions_clean.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO


PRINT 'Importing casualties...';

BULK INSERT stg.Casualties
FROM '$(DataPath)\casualties_clean.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO


PRINT 'Importing vehicles...';

BULK INSERT stg.Vehicles
FROM '$(DataPath)\vehicles_clean.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO


/* Verify imported row counts. */
SELECT 'Collisions' AS table_name, COUNT_BIG(*) AS row_count
FROM stg.Collisions

UNION ALL

SELECT 'Casualties', COUNT_BIG(*)
FROM stg.Casualties

UNION ALL

SELECT 'Vehicles', COUNT_BIG(*)
FROM stg.Vehicles;
GO