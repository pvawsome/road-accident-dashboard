USE RoadAccidentDB;
GO

/* Create staging schema */
IF SCHEMA_ID('stg') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA stg AUTHORIZATION dbo;');
END;
GO


/* =========================================================
   STAGING TABLE: COLLISIONS
   Text columns make the initial CSV import safer.
   ========================================================= */

IF OBJECT_ID('stg.Collisions', 'U') IS NULL
BEGIN
    CREATE TABLE stg.Collisions
    (
        collision_index                     NVARCHAR(100) NULL,
        collision_year                      NVARCHAR(50)  NULL,
        collision_severity                  NVARCHAR(50)  NULL,
        number_of_vehicles                  NVARCHAR(50)  NULL,
        number_of_casualties                NVARCHAR(50)  NULL,
        day_of_week                         NVARCHAR(50)  NULL,
        longitude                           NVARCHAR(50)  NULL,
        latitude                            NVARCHAR(50)  NULL,
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
END;
GO


/* =========================================================
   STAGING TABLE: CASUALTIES
   ========================================================= */

IF OBJECT_ID('stg.Casualties', 'U') IS NULL
BEGIN
    CREATE TABLE stg.Casualties
    (
        collision_index                 NVARCHAR(100) NULL,
        collision_year                  NVARCHAR(50)  NULL,
        vehicle_reference               NVARCHAR(50)  NULL,
        casualty_reference              NVARCHAR(50)  NULL,
        casualty_class                  NVARCHAR(50)  NULL,
        sex_of_casualty                 NVARCHAR(50)  NULL,
        age_of_casualty                 NVARCHAR(50)  NULL,
        age_band_of_casualty            NVARCHAR(50)  NULL,
        casualty_severity               NVARCHAR(50)  NULL,
        casualty_type                   NVARCHAR(50)  NULL,
        casualty_key                    NVARCHAR(100) NULL,
        vehicle_key                     NVARCHAR(100) NULL,
        casualty_class_label            NVARCHAR(200) NULL,
        sex_of_casualty_label           NVARCHAR(200) NULL,
        age_band_of_casualty_label      NVARCHAR(200) NULL,
        casualty_severity_label         NVARCHAR(200) NULL,
        casualty_type_label             NVARCHAR(300) NULL
    );
END;
GO


/* =========================================================
   STAGING TABLE: VEHICLES
   ========================================================= */

IF OBJECT_ID('stg.Vehicles', 'U') IS NULL
BEGIN
    CREATE TABLE stg.Vehicles
    (
        collision_index             NVARCHAR(100) NULL,
        collision_year              NVARCHAR(50)  NULL,
        vehicle_reference           NVARCHAR(50)  NULL,
        vehicle_type                NVARCHAR(50)  NULL,
        sex_of_driver               NVARCHAR(50)  NULL,
        age_of_driver               NVARCHAR(50)  NULL,
        age_band_of_driver          NVARCHAR(50)  NULL,
        engine_capacity_cc          NVARCHAR(50)  NULL,
        age_of_vehicle              NVARCHAR(50)  NULL,
        generic_make_model          NVARCHAR(300) NULL,
        escooter_flag               NVARCHAR(50)  NULL,
        vehicle_key                 NVARCHAR(100) NULL,
        vehicle_type_label          NVARCHAR(200) NULL,
        sex_of_driver_label         NVARCHAR(200) NULL,
        age_band_of_driver_label    NVARCHAR(200) NULL
    );
END;
GO


/* =========================================================
   FINAL TYPED TABLE: COLLISIONS
   ========================================================= */

IF OBJECT_ID('dbo.Collisions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Collisions
    (
        collision_index                     VARCHAR(20)    NOT NULL,
        collision_year                      SMALLINT       NOT NULL,
        collision_severity                  SMALLINT       NULL,
        number_of_vehicles                  SMALLINT       NULL,
        number_of_casualties                SMALLINT       NULL,
        day_of_week                         SMALLINT       NULL,
        longitude                           DECIMAL(9, 6)  NULL,
        latitude                            DECIMAL(9, 6)  NULL,
        local_authority_highway_current     VARCHAR(20)    NULL,
        road_type                           SMALLINT       NULL,
        speed_limit                         SMALLINT       NULL,
        light_conditions                    SMALLINT       NULL,
        weather_conditions                  SMALLINT       NULL,
        road_surface_conditions             SMALLINT       NULL,
        urban_or_rural_area                 SMALLINT       NULL,
        collision_date                      DATE           NULL,
        collision_time                      TIME(0)        NULL,
        collision_hour                      TINYINT        NULL,
        month_number                        TINYINT        NULL,
        month_name                          VARCHAR(15)    NULL,
        quarter                             CHAR(2)        NULL,
        collision_severity_label            NVARCHAR(50)   NULL,
        day_of_week_label                   NVARCHAR(50)   NULL,
        road_type_label                     NVARCHAR(100)  NULL,
        light_conditions_label              NVARCHAR(150)  NULL,
        weather_conditions_label            NVARCHAR(150)  NULL,
        road_surface_conditions_label       NVARCHAR(150)  NULL,
        urban_or_rural_area_label           NVARCHAR(100)  NULL,

        CONSTRAINT PK_Collisions
            PRIMARY KEY CLUSTERED (collision_index)
    );
END;
GO


/* =========================================================
   FINAL TYPED TABLE: CASUALTIES
   ========================================================= */

IF OBJECT_ID('dbo.Casualties', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Casualties
    (
        collision_index                 VARCHAR(20)    NOT NULL,
        collision_year                  SMALLINT       NOT NULL,
        vehicle_reference               SMALLINT       NULL,
        casualty_reference              SMALLINT       NULL,
        casualty_class                  SMALLINT       NULL,
        sex_of_casualty                 SMALLINT       NULL,
        age_of_casualty                 SMALLINT       NULL,
        age_band_of_casualty            SMALLINT       NULL,
        casualty_severity               SMALLINT       NULL,
        casualty_type                   SMALLINT       NULL,
        casualty_key                    VARCHAR(40)    NOT NULL,
        vehicle_key                     VARCHAR(40)    NULL,
        casualty_class_label            NVARCHAR(100)  NULL,
        sex_of_casualty_label           NVARCHAR(100)  NULL,
        age_band_of_casualty_label      NVARCHAR(100)  NULL,
        casualty_severity_label         NVARCHAR(50)   NULL,
        casualty_type_label             NVARCHAR(300)  NULL,

        CONSTRAINT PK_Casualties
            PRIMARY KEY CLUSTERED (casualty_key)
    );
END;
GO


/* =========================================================
   FINAL TYPED TABLE: VEHICLES
   ========================================================= */

IF OBJECT_ID('dbo.Vehicles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Vehicles
    (
        collision_index             VARCHAR(20)    NOT NULL,
        collision_year              SMALLINT       NOT NULL,
        vehicle_reference           SMALLINT       NULL,
        vehicle_type                SMALLINT       NULL,
        sex_of_driver               SMALLINT       NULL,
        age_of_driver               SMALLINT       NULL,
        age_band_of_driver          SMALLINT       NULL,
        engine_capacity_cc          INT            NULL,
        age_of_vehicle              SMALLINT       NULL,
        generic_make_model          NVARCHAR(300)  NULL,
        escooter_flag               SMALLINT       NULL,
        vehicle_key                 VARCHAR(40)    NOT NULL,
        vehicle_type_label          NVARCHAR(200)  NULL,
        sex_of_driver_label         NVARCHAR(100)  NULL,
        age_band_of_driver_label    NVARCHAR(100)  NULL,

        CONSTRAINT PK_Vehicles
            PRIMARY KEY CLUSTERED (vehicle_key)
    );
END;
GO


/* Verify all six tables */

SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
WHERE s.name IN ('dbo', 'stg')
  AND t.name IN ('Collisions', 'Casualties', 'Vehicles')
ORDER BY
    s.name,
    t.name;
GO