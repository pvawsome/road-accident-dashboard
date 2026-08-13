USE RoadAccidentDB;
GO

/* 1. Compare staging and final row counts */

SELECT
    'Collisions' AS table_name,
    (SELECT COUNT_BIG(*) FROM stg.Collisions) AS staging_rows,
    (SELECT COUNT_BIG(*) FROM dbo.Collisions) AS final_rows

UNION ALL

SELECT
    'Vehicles',
    (SELECT COUNT_BIG(*) FROM stg.Vehicles),
    (SELECT COUNT_BIG(*) FROM dbo.Vehicles)

UNION ALL

SELECT
    'Casualties',
    (SELECT COUNT_BIG(*) FROM stg.Casualties),
    (SELECT COUNT_BIG(*) FROM dbo.Casualties);
GO


/* 2. Check the date and year ranges */

SELECT
    MIN(collision_date) AS earliest_date,
    MAX(collision_date) AS latest_date,
    MIN(collision_year) AS earliest_year,
    MAX(collision_year) AS latest_year
FROM dbo.Collisions;
GO


/* 3. Check important converted fields for missing values */

SELECT
    COUNT_BIG(*) AS total_collisions,
    SUM(CASE WHEN collision_date IS NULL THEN 1 ELSE 0 END)
        AS missing_dates,
    SUM(CASE WHEN collision_time IS NULL THEN 1 ELSE 0 END)
        AS missing_times,
    SUM(CASE WHEN longitude IS NULL THEN 1 ELSE 0 END)
        AS missing_longitude,
    SUM(CASE WHEN latitude IS NULL THEN 1 ELSE 0 END)
        AS missing_latitude
FROM dbo.Collisions;
GO


/* 4. Check for vehicles without a matching collision */

SELECT
    COUNT_BIG(*) AS vehicles_without_collision
FROM dbo.Vehicles AS v
LEFT JOIN dbo.Collisions AS c
    ON v.collision_index = c.collision_index
WHERE c.collision_index IS NULL;
GO


/* 5. Check for casualties without a matching collision */

SELECT
    COUNT_BIG(*) AS casualties_without_collision
FROM dbo.Casualties AS ca
LEFT JOIN dbo.Collisions AS c
    ON ca.collision_index = c.collision_index
WHERE c.collision_index IS NULL;
GO


/* 6. Check casualty-to-vehicle relationships */

SELECT
    SUM(
        CASE
            WHEN ca.vehicle_key IS NULL THEN 1
            ELSE 0
        END
    ) AS casualties_missing_vehicle_key,

    SUM(
        CASE
            WHEN ca.vehicle_key IS NOT NULL
             AND v.vehicle_key IS NULL
            THEN 1
            ELSE 0
        END
    ) AS casualties_without_matching_vehicle
FROM dbo.Casualties AS ca
LEFT JOIN dbo.Vehicles AS v
    ON ca.vehicle_key = v.vehicle_key;
GO