USE RoadAccidentDB;
GO


/* =========================================================
   COLLISION VIEW
   Grain: one row per collision
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_CollisionAnalysis
AS
SELECT
    c.collision_index,
    c.collision_year,
    c.collision_date,
    c.collision_time,
    c.collision_hour,
    c.month_number,
    c.month_name,
    c.quarter,

    c.day_of_week,
    c.day_of_week_label,

    c.collision_severity,
    c.collision_severity_label,

    c.number_of_vehicles,
    c.number_of_casualties,

    c.longitude,
    c.latitude,
    c.local_authority_highway_current,

    c.road_type,
    c.road_type_label,
    c.speed_limit,

    c.light_conditions,
    c.light_conditions_label,

    c.weather_conditions,
    c.weather_conditions_label,

    c.road_surface_conditions,
    c.road_surface_conditions_label,

    c.urban_or_rural_area,
    c.urban_or_rural_area_label
FROM dbo.Collisions AS c;
GO


/* =========================================================
   CASUALTY VIEW
   Grain: one row per casualty
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_CasualtyAnalysis
AS
SELECT
    ca.casualty_key,
    ca.vehicle_key,
    ca.collision_index,

    c.collision_year,
    c.collision_date,
    c.collision_time,
    c.collision_hour,
    c.month_number,
    c.month_name,
    c.quarter,
    c.day_of_week_label,

    c.collision_severity AS collision_severity_code,
    c.collision_severity_label,

    ca.casualty_reference,
    ca.casualty_class,
    ca.casualty_class_label,

    ca.sex_of_casualty,
    ca.sex_of_casualty_label,

    ca.age_of_casualty,
    ca.age_band_of_casualty,
    ca.age_band_of_casualty_label,

    ca.casualty_severity,
    ca.casualty_severity_label,

    ca.casualty_type,
    ca.casualty_type_label,

    v.vehicle_type,
    v.vehicle_type_label,
    v.sex_of_driver_label,
    v.age_of_driver,
    v.age_band_of_driver_label,

    c.road_type_label,
    c.speed_limit,
    c.light_conditions_label,
    c.weather_conditions_label,
    c.road_surface_conditions_label,
    c.urban_or_rural_area_label,

    c.longitude,
    c.latitude
FROM dbo.Casualties AS ca
INNER JOIN dbo.Collisions AS c
    ON ca.collision_index = c.collision_index
LEFT JOIN dbo.Vehicles AS v
    ON ca.vehicle_key = v.vehicle_key;
GO


/* =========================================================
   VEHICLE VIEW
   Grain: one row per vehicle
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_VehicleAnalysis
AS
SELECT
    v.vehicle_key,
    v.collision_index,

    c.collision_year,
    c.collision_date,
    c.collision_time,
    c.collision_hour,
    c.month_number,
    c.month_name,
    c.quarter,
    c.day_of_week_label,

    c.collision_severity,
    c.collision_severity_label,

    v.vehicle_reference,
    v.vehicle_type,
    v.vehicle_type_label,

    v.sex_of_driver,
    v.sex_of_driver_label,

    v.age_of_driver,
    v.age_band_of_driver,
    v.age_band_of_driver_label,

    v.engine_capacity_cc,
    v.age_of_vehicle,
    v.generic_make_model,
    v.escooter_flag,

    c.road_type_label,
    c.speed_limit,
    c.light_conditions_label,
    c.weather_conditions_label,
    c.road_surface_conditions_label,
    c.urban_or_rural_area_label,

    c.longitude,
    c.latitude
FROM dbo.Vehicles AS v
INNER JOIN dbo.Collisions AS c
    ON v.collision_index = c.collision_index;
GO


/* Verify the views and their row counts */

SELECT
    'vw_CollisionAnalysis' AS view_name,
    COUNT_BIG(*) AS row_count
FROM dbo.vw_CollisionAnalysis

UNION ALL

SELECT
    'vw_CasualtyAnalysis',
    COUNT_BIG(*)
FROM dbo.vw_CasualtyAnalysis

UNION ALL

SELECT
    'vw_VehicleAnalysis',
    COUNT_BIG(*)
FROM dbo.vw_VehicleAnalysis;
GO