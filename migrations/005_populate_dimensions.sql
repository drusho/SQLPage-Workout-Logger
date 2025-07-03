-- Migration: 005_populate_dimensions
-- Description: Populates the new dimension tables (DimUser, DimExercise, DimDate)
-- with data from the old schema and generated date series.
-- This version uses the older 'INSERT OR IGNORE' syntax for broader SQLite
-- version compatibility.
-- =============================================================================
-- 1. Populate DimUser
-- =============================================================================
-- This statement migrates all users from the old 'users' table into the new
-- 'DimUser' table. It relies on the DEFAULT constraint in DimUser to set the
-- Timezone to 'America/Denver' for all imported users.
INSERT OR IGNORE INTO
    DimUser (UserKey, DisplayName)
SELECT
    username,
    display_name
FROM
    users;

-- =============================================================================
-- 2. Populate DimExercise
-- =============================================================================
-- This statement migrates all exercises from the old 'ExerciseLibrary' table
-- into the new 'DimExercise' table.
INSERT OR IGNORE INTO
    DimExercise (
        ExerciseKey,
        ExerciseName,
        BodyGroup,
        EquipmentNeeded
    )
SELECT
    ExerciseID,
    ExerciseName,
    BodyGroup,
    EquipmentNeeded
FROM
    ExerciseLibrary;

-- =============================================================================
-- 3. Populate DimDate
-- =============================================================================
-- This statement uses a recursive Common Table Expression (CTE) to generate
-- a series of dates from January 1, 2020, to December 31, 2030. This ensures
-- the DimDate table is fully populated for historical and future analysis.
WITH RECURSIVE
    dates (date) AS (
        VALUES
            ('2020-01-01')
        UNION ALL
        SELECT
            DATE(date, '+1 day')
        FROM
            dates
        WHERE
            date < '2030-12-31'
    )
INSERT OR IGNORE INTO
    DimDate (DateKey, FullDate, DayOfWeekName, MonthName, Year)
SELECT
    CAST(STRFTIME('%Y%m%d', date) AS INTEGER),
    date,
    CASE CAST(STRFTIME('%w', date) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        ELSE 'Saturday'
    END,
    CASE CAST(STRFTIME('%m', date) AS INTEGER)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        ELSE 'December'
    END,
    CAST(STRFTIME('%Y', date) AS INTEGER)
FROM
    dates;
