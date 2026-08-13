USE RoadAccidentDB;
GO

/* =========================================================
   FOREIGN-KEY RELATIONSHIPS
   ========================================================= */

/* Every vehicle belongs to a collision. */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Vehicles_Collisions'
)
BEGIN
    ALTER TABLE dbo.Vehicles WITH CHECK
    ADD CONSTRAINT FK_Vehicles_Collisions
        FOREIGN KEY (collision_index)
        REFERENCES dbo.Collisions (collision_index);
END;
GO


/* Every casualty belongs to a collision. */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Casualties_Collisions'
)
BEGIN
    ALTER TABLE dbo.Casualties WITH CHECK
    ADD CONSTRAINT FK_Casualties_Collisions
        FOREIGN KEY (collision_index)
        REFERENCES dbo.Collisions (collision_index);
END;
GO


/* A casualty's vehicle key connects to the vehicle table.
   NULL values are allowed. */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Casualties_Vehicles'
)
BEGIN
    ALTER TABLE dbo.Casualties WITH CHECK
    ADD CONSTRAINT FK_Casualties_Vehicles
        FOREIGN KEY (vehicle_key)
        REFERENCES dbo.Vehicles (vehicle_key);
END;
GO


/* =========================================================
   JOIN INDEXES
   ========================================================= */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Vehicles')
      AND name = 'IX_Vehicles_CollisionIndex'
)
BEGIN
    CREATE INDEX IX_Vehicles_CollisionIndex
        ON dbo.Vehicles (collision_index);
END;
GO


IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Casualties')
      AND name = 'IX_Casualties_CollisionIndex'
)
BEGIN
    CREATE INDEX IX_Casualties_CollisionIndex
        ON dbo.Casualties (collision_index);
END;
GO


IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Casualties')
      AND name = 'IX_Casualties_VehicleKey'
)
BEGIN
    CREATE INDEX IX_Casualties_VehicleKey
        ON dbo.Casualties (vehicle_key);
END;
GO


/* =========================================================
   DASHBOARD-ANALYSIS INDEXES
   ========================================================= */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Collisions')
      AND name = 'IX_Collisions_Year_Severity'
)
BEGIN
    CREATE INDEX IX_Collisions_Year_Severity
        ON dbo.Collisions
        (
            collision_year,
            collision_severity
        )
        INCLUDE
        (
            collision_date,
            number_of_casualties,
            road_type,
            urban_or_rural_area
        );
END;
GO


IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Casualties')
      AND name = 'IX_Casualties_Year_Severity'
)
BEGIN
    CREATE INDEX IX_Casualties_Year_Severity
        ON dbo.Casualties
        (
            collision_year,
            casualty_severity
        )
        INCLUDE
        (
            collision_index,
            casualty_type,
            age_band_of_casualty,
            sex_of_casualty
        );
END;
GO


IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Vehicles')
      AND name = 'IX_Vehicles_Year_Type'
)
BEGIN
    CREATE INDEX IX_Vehicles_Year_Type
        ON dbo.Vehicles
        (
            collision_year,
            vehicle_type
        )
        INCLUDE
        (
            collision_index,
            sex_of_driver,
            age_band_of_driver
        );
END;
GO


/* =========================================================
   VERIFY FOREIGN KEYS
   ========================================================= */

SELECT
    fk.name AS foreign_key,
    OBJECT_SCHEMA_NAME(fk.parent_object_id)
        + '.'
        + OBJECT_NAME(fk.parent_object_id) AS child_table,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id)
        + '.'
        + OBJECT_NAME(fk.referenced_object_id) AS parent_table,
    fk.is_disabled,
    fk.is_not_trusted
FROM sys.foreign_keys AS fk
WHERE fk.name IN
(
    'FK_Vehicles_Collisions',
    'FK_Casualties_Collisions',
    'FK_Casualties_Vehicles'
)
ORDER BY fk.name;
GO


/* Verify the new indexes. */

SELECT
    OBJECT_SCHEMA_NAME(i.object_id)
        + '.'
        + OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc
FROM sys.indexes AS i
WHERE i.name IN
(
    'IX_Vehicles_CollisionIndex',
    'IX_Casualties_CollisionIndex',
    'IX_Casualties_VehicleKey',
    'IX_Collisions_Year_Severity',
    'IX_Casualties_Year_Severity',
    'IX_Vehicles_Year_Type'
)
ORDER BY table_name, index_name;
GO
