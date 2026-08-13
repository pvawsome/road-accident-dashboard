USE RoadAccidentDB;
GO

/* Preview imported staging data */

SELECT TOP (5) *
FROM stg.Collisions;
GO

SELECT TOP (5) *
FROM stg.Casualties;
GO

SELECT TOP (5) *
FROM stg.Vehicles;
GO


/* Validate row keys */

SELECT
    'Collisions' AS table_name,
    COUNT_BIG(*) AS total_rows,
    COUNT(DISTINCT collision_index) AS unique_keys,
    SUM(
        CASE
            WHEN collision_index IS NULL
              OR LTRIM(RTRIM(collision_index)) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_keys
FROM stg.Collisions

UNION ALL

SELECT
    'Casualties',
    COUNT_BIG(*),
    COUNT(DISTINCT casualty_key),
    SUM(
        CASE
            WHEN casualty_key IS NULL
              OR LTRIM(RTRIM(casualty_key)) = ''
            THEN 1
            ELSE 0
        END
    )
FROM stg.Casualties

UNION ALL

SELECT
    'Vehicles',
    COUNT_BIG(*),
    COUNT(DISTINCT vehicle_key),
    SUM(
        CASE
            WHEN vehicle_key IS NULL
              OR LTRIM(RTRIM(vehicle_key)) = ''
            THEN 1
            ELSE 0
        END
    )
FROM stg.Vehicles;
GO