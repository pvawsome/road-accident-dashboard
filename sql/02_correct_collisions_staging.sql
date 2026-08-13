USE RoadAccidentDB;
GO

/* The staging table should still be empty. */
IF EXISTS (SELECT 1 FROM stg.Collisions)
BEGIN
    THROW 50001,
          'stg.Collisions contains data and was not dropped.',
          1;
END;
GO

DROP TABLE IF EXISTS stg.Collisions;
GO

CREATE TABLE stg.Collisions
(
    collision_index                     NVARCHAR(100) NULL,
    collision_year                      NVARCHAR(50)  NULL,
    longitude                           NVARCHAR(50)  NULL,
    latitude                            NVARCHAR(50)  NULL,
    collision_severity                  NVARCHAR(50)  NULL,
    number_of_vehicles                  NVARCHAR(50)  NULL,
    number_of_casualties                NVARCHAR(50)  NULL,
    day_of_week                         NVARCHAR(50)  NULL,
    local_authority_highway_current     NVARCHAR(100) NULL,
    road_type                           NVARCHAR(50)  NULL,
    speed_limit                         NVARCHAR(50)  NULL,
    light_conditions                    NVARCHAR(50)  NULL,
    weather_conditions                  NVARCHAR(50)  NULL,
    road_surface_conditions             NVARCHAR(50)  NULL,
    urban_or_rural_area                 NVARCHAR(50)  NULL,
    collision_date                      NVARCHAR(50)  NULL,
    collision_time                      NVARCHAR(50)  NULL,
    collision_hour                      NVARCHAR(50)  NULL,
    month_number                        NVARCHAR(50)  NULL,
    month_name                          NVARCHAR(30)  NULL,
    quarter                             NVARCHAR(10)  NULL,
    collision_severity_label            NVARCHAR(200) NULL,
    day_of_week_label                   NVARCHAR(200) NULL,
    road_type_label                     NVARCHAR(200) NULL,
    light_conditions_label              NVARCHAR(200) NULL,
    weather_conditions_label            NVARCHAR(200) NULL,
    road_surface_conditions_label       NVARCHAR(200) NULL,
    urban_or_rural_area_label           NVARCHAR(200) NULL
);
GO

/* Verify the corrected column order. */
SELECT
    column_id,
    name AS column_name
FROM sys.columns
WHERE object_id = OBJECT_ID('stg.Collisions')
ORDER BY column_id;
GO