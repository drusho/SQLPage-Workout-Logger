-- Migration: 004_create_star_schema_tables
-- Description: Creates the new fact and dimension tables for the star schema.
-- This version adds support for user-specific aliases and inactivating old plans.
-- Turn on foreign key enforcement for this script.
PRAGMA foreign_keys = ON;

-- =============================================================================
-- Dimension Tables
-- =============================================================================
-- DimUser: Stores current user profile information.
CREATE TABLE IF NOT EXISTS DimUser (
    UserKey TEXT PRIMARY KEY,
    DisplayName TEXT NOT NULL,
    Timezone TEXT DEFAULT 'America/Denver'
);

-- DimDate: A standard date dimension for time-based analysis.
CREATE TABLE IF NOT EXISTS DimDate (
    DateKey INTEGER PRIMARY KEY, -- YYYYMMDD format
    FullDate TEXT NOT NULL, -- YYYY-MM-DD format
    DayOfWeekName TEXT NOT NULL,
    MonthName TEXT NOT NULL,
    Year INTEGER NOT NULL
);

-- DimExercise: Stores the default, static attributes of an exercise.
CREATE TABLE IF NOT EXISTS DimExercise (
    ExerciseKey TEXT PRIMARY KEY,
    ExerciseName TEXT NOT NULL UNIQUE, -- The default, global name
    BodyGroup TEXT,
    EquipmentNeeded TEXT
);

-- DimUserExercisePreferences: Stores user-specific aliases for exercises.
CREATE TABLE IF NOT EXISTS DimUserExercisePreferences (
    UserKey TEXT NOT NULL,
    ExerciseKey TEXT NOT NULL,
    UserExerciseAlias TEXT NOT NULL,
    PRIMARY KEY (UserKey, ExerciseKey),
    FOREIGN KEY (UserKey) REFERENCES DimUser (UserKey),
    FOREIGN KEY (ExerciseKey) REFERENCES DimExercise (ExerciseKey)
);

-- DimExercisePlan: Consolidates the user's *current* progression state.
CREATE TABLE IF NOT EXISTS DimExercisePlan (
    ExercisePlanKey TEXT PRIMARY KEY,
    UserKey TEXT NOT NULL,
    ExerciseKey TEXT NOT NULL,
    TemplateName TEXT, -- The default, global template name
    UserTemplateAlias TEXT, -- The user's custom name for this template
    IsActive INTEGER NOT NULL DEFAULT 1, -- 1 for active, 0 for archived/restarted
    CurrentStepNumber INTEGER,
    Current1RMEstimate REAL,
    TargetSets INTEGER,
    TargetReps INTEGER,
    FOREIGN KEY (UserKey) REFERENCES DimUser (UserKey),
    FOREIGN KEY (ExerciseKey) REFERENCES DimExercise (ExerciseKey)
);

-- =============================================================================
-- Fact Table
-- =============================================================================
-- FactWorkoutHistory: The central fact table. Each row represents one set
-- performed by a user. This is the ultimate source of truth for all calculations.
CREATE TABLE IF NOT EXISTS FactWorkoutHistory (
    WorkoutHistoryKey TEXT PRIMARY KEY,
    UserKey TEXT NOT NULL,
    ExerciseKey TEXT NOT NULL,
    DateKey INTEGER NOT NULL,
    ExercisePlanKey TEXT NOT NULL,
    SetNumber INTEGER NOT NULL,
    RepsPerformed INTEGER NOT NULL,
    WeightUsed REAL NOT NULL,
    RPE_Recorded REAL,
    CreatedTimestamp INTEGER NOT NULL, -- Unix timestamp of when the set was first logged
    LastModifiedTimestamp INTEGER NOT NULL, -- Unix timestamp, updated anytime the record is edited
    FOREIGN KEY (UserKey) REFERENCES DimUser (UserKey),
    FOREIGN KEY (ExerciseKey) REFERENCES DimExercise (ExerciseKey),
    FOREIGN KEY (DateKey) REFERENCES DimDate (DateKey),
    FOREIGN KEY (ExercisePlanKey) REFERENCES DimExercisePlan (ExercisePlanKey)
);

-- =============================================================================
-- Indexes for Performance
-- =============================================================================
-- Indexes on the fact table foreign keys are critical for query performance.
CREATE INDEX IF NOT EXISTS idx_fact_workout_history_user_key ON FactWorkoutHistory (UserKey);

CREATE INDEX IF NOT EXISTS idx_fact_workout_history_exercise_key ON FactWorkoutHistory (ExerciseKey);

CREATE INDEX IF NOT EXISTS idx_fact_workout_history_date_key ON FactWorkoutHistory (DateKey);

CREATE INDEX IF NOT EXISTS idx_fact_workout_history_plan_key ON FactWorkoutHistory (ExercisePlanKey);

-- Index to quickly find a user's active plans.
CREATE INDEX IF NOT EXISTS idx_dim_exercise_plan_user_active ON DimExercisePlan (UserKey, IsActive);
