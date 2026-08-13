USE RoadAccidentDB;
GO

/* Clear staging tables so the script can be safely rerun. */
TRUNCATE TABLE stg.Collisions;
TRUNCATE TABLE stg.Casualties;
TRUNCATE TABLE stg.Vehicles;
GO


PRINT 'Importing collisions...';

BULK INSERT stg.Collisions
FROM 'C:\SQLData\RoadAccidentData\collisions_clean.csv'
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
FROM 'C:\SQLData\RoadAccidentData\casualties_clean.csv'
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
FROM 'C:\SQLData\RoadAccidentData\vehicles_clean.csv'
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