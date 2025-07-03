-- Migration: 007_decommission_old_tables
-- Description: The final step of the schema overhaul. This script drops all of
-- the old snowflake schema tables that have been replaced by the new star schema.
-- WARNING: Run this only after all application pages have been successfully
-- refactored to use the new schema.
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

-- Note: The '_migrations' and 'sessions' tables are not dropped as they are
-- still in use by the migration runner and the application's auth system.
