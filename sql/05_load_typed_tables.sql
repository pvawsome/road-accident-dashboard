USE RoadAccidentDB;
GO

/* Clear final tables so this script can be rerun safely. */

TRUNCATE TABLE dbo.Casualties;
TRUNCATE TABLE dbo.Vehicles;
TRUNCATE TABLE dbo.Collisions;
GO


/* =========================================================
   LOAD COLLISIONS
   ========================================================= */

PRINT 'Loading dbo.Collisions...';

INSERT INTO dbo.Collisions
(
    collision_index,
    collision_year,
    collision_severity,
    number_of_vehicles,
    number_of_casualties,
    day_of_week,
    longitude,
    latitude,
    local_authority_highway_current,
    road_type,
    speed_limit,
    light_conditions,
    weather_conditions,
    road_surface_conditions,
    urban_or_rural_area,
    collision_date,
    collision_time,
    collision_hour,
    month_number,
    month_name,
    quarter,
    collision_severity_label,
    day_of_week_label,
    road_type_label,
    light_conditions_label,
    weather_conditions_label,
    road_surface_conditions_label,
    urban_or_rural_area_label
)
SELECT
    CAST(NULLIF(TRIM(REPLACE(collision_index, CHAR(13), '')), '') AS VARCHAR(20)),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(collision_year, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(collision_severity, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(number_of_vehicles, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(number_of_casualties, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(day_of_week, CHAR(13), '')), '')),
    TRY_CONVERT(DECIMAL(9,6), NULLIF(TRIM(REPLACE(longitude, CHAR(13), '')), '')),
    TRY_CONVERT(DECIMAL(9,6), NULLIF(TRIM(REPLACE(latitude, CHAR(13), '')), '')),
    CAST(NULLIF(TRIM(REPLACE(local_authority_highway_current, CHAR(13), '')), '') AS VARCHAR(20)),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(road_type, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(speed_limit, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(light_conditions, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(weather_conditions, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(road_surface_conditions, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(urban_or_rural_area, CHAR(13), '')), '')),
    TRY_CONVERT(DATE, NULLIF(TRIM(REPLACE(collision_date, CHAR(13), '')), ''), 23),
    TRY_CONVERT(TIME(0), NULLIF(TRIM(REPLACE(collision_time, CHAR(13), '')), '')),
    TRY_CONVERT(TINYINT, NULLIF(TRIM(REPLACE(collision_hour, CHAR(13), '')), '')),
    TRY_CONVERT(TINYINT, NULLIF(TRIM(REPLACE(month_number, CHAR(13), '')), '')),
    NULLIF(TRIM(REPLACE(month_name, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(quarter, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(collision_severity_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(day_of_week_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(road_type_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(light_conditions_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(weather_conditions_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(road_surface_conditions_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(urban_or_rural_area_label, CHAR(13), '')), '')
FROM stg.Collisions;
GO


/* =========================================================
   LOAD VEHICLES
   ========================================================= */

PRINT 'Loading dbo.Vehicles...';

INSERT INTO dbo.Vehicles
(
    collision_index,
    collision_year,
    vehicle_reference,
    vehicle_type,
    sex_of_driver,
    age_of_driver,
    age_band_of_driver,
    engine_capacity_cc,
    age_of_vehicle,
    generic_make_model,
    escooter_flag,
    vehicle_key,
    vehicle_type_label,
    sex_of_driver_label,
    age_band_of_driver_label
)
SELECT
    CAST(NULLIF(TRIM(REPLACE(collision_index, CHAR(13), '')), '') AS VARCHAR(20)),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(collision_year, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(vehicle_reference, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(vehicle_type, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(sex_of_driver, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(age_of_driver, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(age_band_of_driver, CHAR(13), '')), '')),
    TRY_CONVERT(INT, NULLIF(TRIM(REPLACE(engine_capacity_cc, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(age_of_vehicle, CHAR(13), '')), '')),
    NULLIF(TRIM(REPLACE(generic_make_model, CHAR(13), '')), ''),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(escooter_flag, CHAR(13), '')), '')),
    CAST(NULLIF(TRIM(REPLACE(vehicle_key, CHAR(13), '')), '') AS VARCHAR(40)),
    NULLIF(TRIM(REPLACE(vehicle_type_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(sex_of_driver_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(age_band_of_driver_label, CHAR(13), '')), '')
FROM stg.Vehicles;
GO


/* =========================================================
   LOAD CASUALTIES
   ========================================================= */

PRINT 'Loading dbo.Casualties...';

INSERT INTO dbo.Casualties
(
    collision_index,
    collision_year,
    vehicle_reference,
    casualty_reference,
    casualty_class,
    sex_of_casualty,
    age_of_casualty,
    age_band_of_casualty,
    casualty_severity,
    casualty_type,
    casualty_key,
    vehicle_key,
    casualty_class_label,
    sex_of_casualty_label,
    age_band_of_casualty_label,
    casualty_severity_label,
    casualty_type_label
)
SELECT
    CAST(NULLIF(TRIM(REPLACE(collision_index, CHAR(13), '')), '') AS VARCHAR(20)),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(collision_year, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(vehicle_reference, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(casualty_reference, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(casualty_class, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(sex_of_casualty, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(age_of_casualty, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(age_band_of_casualty, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(casualty_severity, CHAR(13), '')), '')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(REPLACE(casualty_type, CHAR(13), '')), '')),
    CAST(NULLIF(TRIM(REPLACE(casualty_key, CHAR(13), '')), '') AS VARCHAR(40)),
    CAST(NULLIF(TRIM(REPLACE(vehicle_key, CHAR(13), '')), '') AS VARCHAR(40)),
    NULLIF(TRIM(REPLACE(casualty_class_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(sex_of_casualty_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(age_band_of_casualty_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(casualty_severity_label, CHAR(13), '')), ''),
    NULLIF(TRIM(REPLACE(casualty_type_label, CHAR(13), '')), '')
FROM stg.Casualties;
GO


/* Verify final table counts. */

SELECT 'Collisions' AS table_name, COUNT_BIG(*) AS row_count
FROM dbo.Collisions

UNION ALL

SELECT 'Vehicles', COUNT_BIG(*)
FROM dbo.Vehicles

UNION ALL

SELECT 'Casualties', COUNT_BIG(*)
FROM dbo.Casualties;
GO