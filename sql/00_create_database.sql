USE master;
GO

/* ==================================================================
   00_create_database.sql

   Creates the RoadAccidentDB database if it does not already exist.
   Run this FIRST, before 01_create_tables.sql. It is safe to rerun.
   ================================================================== */

IF DB_ID('RoadAccidentDB') IS NULL
BEGIN
    CREATE DATABASE RoadAccidentDB;
    PRINT 'Created database: RoadAccidentDB';
END
ELSE
BEGIN
    PRINT 'Database already exists: RoadAccidentDB';
END;
GO
