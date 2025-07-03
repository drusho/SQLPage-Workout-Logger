-- Migration: 008_consolidated_star_schema_migration
-- Description: This single, consolidated script creates the entire star schema
-- with a consistent camelCase naming convention.
-- NOTE: This version ONLY creates the tables and does not migrate data, as
-- the old source tables have already been dropped.
PRAGMA foreign_keys = OFF;

-- =============================================================================
-- Step 0: Drop Existing New-Schema Tables (to ensure idempotency)
-- =============================================================================
-- This section ensures that if the script is run multiple times, it starts
-- with a clean slate, preventing errors from partially-created tables.
DROP TABLE IF EXISTS factWorkoutHistory;

DROP TABLE IF EXISTS dimExercisePlan;

DROP TABLE IF EXISTS dimUserExercisePreferences;

DROP TABLE IF EXISTS dimExercise;

DROP TABLE IF EXISTS dimDate;

DROP TABLE IF EXISTS dimUser;

PRAGMA foreign_keys = ON;

-- =============================================================================
-- Step 1: Create New Tables with Production Naming Conventions
-- =============================================================================
CREATE TABLE IF NOT EXISTS dimUser (
    userId TEXT PRIMARY KEY,
    displayName TEXT NOT NULL,
    timezone TEXT DEFAULT 'America/Denver'
);

CREATE TABLE IF NOT EXISTS dimDate (
    dateId INTEGER PRIMARY KEY, -- TRX_YYYYMMDD format
    fullDate TEXT NOT NULL, -- YYYY-MM-DD format
    dayOfWeek TEXT NOT NULL,
    monthName TEXT NOT NULL,
    year INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS dimExercise (
    exerciseId TEXT PRIMARY KEY,
    exerciseName TEXT NOT NULL UNIQUE,
    bodyGroup TEXT,
    equipmentNeeded TEXT
);

CREATE TABLE IF NOT EXISTS dimUserExercisePreferences (
    userId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    userExerciseAlias TEXT NOT NULL,
    PRIMARY KEY (userId, exerciseId),
    FOREIGN KEY (userId) REFERENCES dimUser (userId),
    FOREIGN KEY (exerciseId) REFERENCES dimExercise (exerciseId)
);

CREATE TABLE IF NOT EXISTS dimExercisePlan (
    exercisePlanId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    templateName TEXT,
    userTemplateAlias TEXT,
    isActive INTEGER NOT NULL DEFAULT 1,
    currentStepNumber INTEGER,
    current1rmEstimate REAL,
    targetSets INTEGER,
    targetReps INTEGER,
    FOREIGN KEY (userId) REFERENCES dimUser (userId),
    FOREIGN KEY (exerciseId) REFERENCES dimExercise (exerciseId)
);

CREATE TABLE IF NOT EXISTS factWorkoutHistory (
    workoutHistoryId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    dateId INTEGER NOT NULL,
    exercisePlanId TEXT, -- Can be NULL if no active plan exists
    setNumber INTEGER NOT NULL,
    repsPerformed INTEGER NOT NULL,
    weightUsed REAL NOT NULL,
    rpeRecorded REAL,
    createdAt INTEGER NOT NULL,
    updatedAt INTEGER NOT NULL,
    FOREIGN KEY (userId) REFERENCES dimUser (userId),
    FOREIGN KEY (exerciseId) REFERENCES dimExercise (exerciseId),
    FOREIGN KEY (dateId) REFERENCES dimDate (dateId),
    FOREIGN KEY (exercisePlanId) REFERENCES dimExercisePlan (exercisePlanId)
);

-- =============================================================================
-- Step 2: Create Indexes for Performance
-- =============================================================================
CREATE INDEX IF NOT EXISTS idxFactWorkoutHistoryUserId ON factWorkoutHistory (userId);

CREATE INDEX IF NOT EXISTS idxFactWorkoutHistoryExerciseId ON factWorkoutHistory (exerciseId);

CREATE INDEX IF NOT EXISTS idxFactWorkoutHistoryDateId ON factWorkoutHistory (dateId);

CREATE INDEX IF NOT EXISTS idxFactWorkoutHistoryPlanId ON factWorkoutHistory (exercisePlanId);

CREATE INDEX IF NOT EXISTS idxDimExercisePlanUserActive ON dimExercisePlan (userId, isActive);

-- =============================================================================
-- Step 3: Populate Essential Dimension Tables (Date Only)
-- =============================================================================
-- Since user and exercise data was dropped, we can only populate the
-- generated date dimension.
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
    dimDate (dateId, fullDate, dayOfWeek, monthName, year)
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
