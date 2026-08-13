USE RoadAccidentDB;
GO


/* =========================================================
   ANNUAL SUMMARY
   One row per year
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_AnnualRoadSafetySummary
AS
WITH CollisionSummary AS
(
    SELECT
        collision_year,
        COUNT_BIG(*) AS total_collisions
    FROM dbo.vw_CollisionAnalysis
    GROUP BY collision_year
),
CasualtySummary AS
(
    SELECT
        collision_year,
        COUNT_BIG(*) AS total_casualties,

        SUM(
            CASE
                WHEN casualty_severity_label = 'Fatal'
                THEN 1 ELSE 0
            END
        ) AS fatal_casualties,

        SUM(
            CASE
                WHEN casualty_severity_label = 'Serious'
                THEN 1 ELSE 0
            END
        ) AS serious_casualties,

        SUM(
            CASE
                WHEN casualty_severity_label = 'Slight'
                THEN 1 ELSE 0
            END
        ) AS slight_casualties
    FROM dbo.vw_CasualtyAnalysis
    GROUP BY collision_year
)
SELECT
    c.collision_year,
    c.total_collisions,
    ca.total_casualties,
    ca.fatal_casualties,
    ca.serious_casualties,
    ca.slight_casualties,

    CAST(
        ca.total_casualties * 1.0
        / NULLIF(c.total_collisions, 0)
        AS DECIMAL(10, 2)
    ) AS casualties_per_collision
FROM CollisionSummary AS c
INNER JOIN CasualtySummary AS ca
    ON c.collision_year = ca.collision_year;
GO


/* =========================================================
   CASUALTIES BY SEVERITY
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_CasualtiesBySeverity
AS
SELECT
    collision_year,
    casualty_severity,
    casualty_severity_label,
    COUNT_BIG(*) AS total_casualties
FROM dbo.vw_CasualtyAnalysis
GROUP BY
    collision_year,
    casualty_severity,
    casualty_severity_label;
GO


/* =========================================================
   CASUALTIES BY VEHICLE TYPE
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_CasualtiesByVehicleType
AS
SELECT
    collision_year,
    vehicle_type,
    COALESCE(vehicle_type_label, 'Unknown') AS vehicle_type_label,
    COUNT_BIG(*) AS total_casualties
FROM dbo.vw_CasualtyAnalysis
GROUP BY
    collision_year,
    vehicle_type,
    COALESCE(vehicle_type_label, 'Unknown');
GO


/* =========================================================
   MONTHLY ROAD-SAFETY TREND
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_MonthlyRoadSafetyTrend
AS
WITH MonthlyCollisions AS
(
    SELECT
        collision_year,
        month_number,
        month_name,
        COUNT_BIG(*) AS total_collisions
    FROM dbo.vw_CollisionAnalysis
    GROUP BY
        collision_year,
        month_number,
        month_name
),
MonthlyCasualties AS
(
    SELECT
        collision_year,
        month_number,
        month_name,
        COUNT_BIG(*) AS total_casualties
    FROM dbo.vw_CasualtyAnalysis
    GROUP BY
        collision_year,
        month_number,
        month_name
)
SELECT
    c.collision_year,
    c.month_number,
    c.month_name,
    c.total_collisions,
    ca.total_casualties
FROM MonthlyCollisions AS c
INNER JOIN MonthlyCasualties AS ca
    ON c.collision_year = ca.collision_year
   AND c.month_number = ca.month_number;
GO


/* =========================================================
   VERIFY THE SUMMARY VIEWS
   ========================================================= */

SELECT *
FROM dbo.vw_AnnualRoadSafetySummary
ORDER BY collision_year;
GO

SELECT *
FROM dbo.vw_CasualtiesBySeverity
ORDER BY collision_year, casualty_severity;
GO

SELECT TOP (20) *
FROM dbo.vw_CasualtiesByVehicleType
ORDER BY collision_year, total_casualties DESC;
GO

SELECT *
FROM dbo.vw_MonthlyRoadSafetyTrend
ORDER BY collision_year, month_number;
GO