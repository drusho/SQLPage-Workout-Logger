-- Migration: 007_decommission_old_tables
-- Description: The final step of the schema overhaul. This script drops all of
-- the old snowflake schema tables AND views that have been replaced by the new star schema.
-- WARNING: Run this only after all application pages have been successfully
-- refactored to use the new schema.
-- =============================================================================
-- Drop Old Views
-- =============================================================================
DROP VIEW IF EXISTS FullWorkoutHistory;

DROP VIEW IF EXISTS UserExerciseProgressionTargets;

DROP VIEW IF EXISTS V_Exercise1RM_Chart;

DROP VIEW IF EXISTS V_ProgressionHistorySummary;

DROP VIEW IF EXISTS WorkoutTemplateDetails;

-- =============================================================================
-- Drop Old Tables
-- =============================================================================
DROP TABLE IF EXISTS WorkoutSetLog;

DROP TABLE IF EXISTS WorkoutLog;

DROP TABLE IF EXISTS UserExerciseProgressionHistory;

DROP TABLE IF EXISTS UserExerciseProgression;

DROP TABLE IF EXISTS TemplateExerciseList;

DROP TABLE IF EXISTS WorkoutTemplates;

DROP TABLE IF EXISTS ProgressionModelSteps;

DROP TABLE IF EXISTS ProgressionModels;

DROP TABLE IF EXISTS ExerciseLibrary;

DROP TABLE IF EXISTS users;

-- =============================================================================
-- Note on Kept Tables
-- =============================================================================
-- The '_migrations' table is kept because it is essential for the migration
-- runner to track which scripts have been applied.
--
-- The 'sessions' table is kept because it is still required for the application's
-- user authentication system and is not part of the old workout data model.
