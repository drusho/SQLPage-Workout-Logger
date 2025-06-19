-- migrations/000_migration_template.sql
-- This is a template for creating new, robust database migration scripts.
--
-- How to use:
-- 1. Copy this file and rename it with the next sequential number (e.g., 006_add_user_preferences.sql).
-- 2. Update the description below.
-- 3. BEFORE running, make a manual backup of your 'workouts.db' file.
-- 4. Fill in the 'SCHEMA CHANGES' section with your desired alterations.
-- 5. Run the script against your database.
----------------------------------------------------
-- MIGRATION METADATA
----------------------------------------------------
-- Description: A brief, clear description of what this migration does.
--              (e.g., "Adds a 'theme' preference column to the 'users' table.")
-- Date: YYYY-MM-DD
----------------------------------------------------
-- STEP 1: SCHEMA CHANGES
-- Place all your table alterations here. Use "IF NOT EXISTS" guards
-- to make the script safely rerunnable.
----------------------------------------------------
-- EXAMPLE: Creating a new table safely.
CREATE TABLE IF NOT EXISTS UserPreferences (
    UserID TEXT NOT NULL,
    Theme TEXT DEFAULT 'dark',
    PRIMARY KEY (UserID),
    FOREIGN KEY (UserID) REFERENCES users(username)
);
-- EXAMPLE: Adding a new column safely.
-- SQLite's ALTER TABLE doesn't support "IF NOT EXISTS" for adding columns.
-- This is an advanced technique to add the column only if it's missing.
-- NOTE: You would need a more complex setup to run this check directly in a simple SQL script.
-- For simplicity in SQLPage, you might skip this check and rely on your numbered
-- migration files to prevent running the same script twice.
-- However, for the sake of a robust template, the check is included for reference.
-- A simpler approach is to just be careful not to re-run migrations.
/*
 -- Advanced check (for reference, may not be needed for your workflow):
 -- This requires a host language (like Python/JS) to run the check then the ALTER.
 -- For a pure SQL workflow, simply ensure you don't run migrations twice.
 ALTER TABLE users ADD COLUMN last_active_date INTEGER;
 */
----------------------------------------------------
-- STEP 2: REBUILD ALL APPLICATION VIEWS
-- This is the most critical step to prevent your application from breaking.
-- It ensures that all views are updated to reflect the schema changes from Step 1.
----------------------------------------------------
-- Drop existing views to ensure a clean slate.
DROP VIEW IF EXISTS FullWorkoutHistory;
DROP VIEW IF EXISTS UserExerciseProgressionTargets;
DROP VIEW IF EXISTS WorkoutTemplateDetails;
-- Recreate `FullWorkoutHistory` VIEW
CREATE VIEW FullWorkoutHistory AS
SELECT wl.LogID,
    wl.UserID,
    datetime(wl.ExerciseTimestamp, 'unixepoch') as WorkoutDate,
    el.ExerciseName,
    wsl.SetNumber,
    wsl.RepsPerformed,
    wsl.WeightUsed,
    wsl.WeightUnit,
    wsl.RPE_Recorded,
    wl.WorkoutNotes,
    wl.LastModifiedTimestamp
FROM WorkoutLog wl
    JOIN WorkoutSetLog wsl ON wl.LogID = wsl.LogID
    JOIN ExerciseLibrary el ON wl.ExerciseID = el.ExerciseID
ORDER BY wl.ExerciseTimestamp DESC,
    wsl.SetNumber ASC;
-- Recreate `UserExerciseProgressionTargets` VIEW
CREATE VIEW UserExerciseProgressionTargets AS
SELECT uep.UserID,
    uep.TemplateID,
    uep.ExerciseID,
    uep.CurrentStepNumber,
    uep.CurrentCycle1RMEstimate,
    pm.ProgressionModelName,
    pms.StepNumber as TargetStepNumber,
    pms.TargetSetsFormula,
    pms.TargetRepsFormula,
    CASE
        WHEN pms.TargetWeightFormula LIKE '%*%' THEN uep.CurrentCycle1RMEstimate * CAST(
            trim(
                substr(
                    pms.TargetWeightFormula,
                    instr(pms.TargetWeightFormula, '*') + 1
                )
            ) AS REAL
        )
        ELSE CAST(pms.TargetWeightFormula AS REAL)
    END as "TargetWeight",
    pms.StepNotes
FROM UserExerciseProgression uep
    JOIN ProgressionModels pm ON uep.ProgressionModelID = pm.ProgressionModelID
    JOIN ProgressionModelSteps pms ON uep.ProgressionModelID = pms.ProgressionModelID
WHERE pms.StepNumber = uep.CurrentStepNumber;
-- Recreate `WorkoutTemplateDetails` VIEW
CREATE VIEW WorkoutTemplateDetails AS
SELECT wt.TemplateID,
    wt.TemplateName,
    tel.TemplateExerciseListID,
    tel.OrderInWorkout,
    tel.ExerciseID,
    el.ExerciseName,
    COALESCE(tel.ExerciseAlias, el.ExerciseAlias) AS ExerciseAlias,
    tel.ProgressionModelID,
    pm.ProgressionModelName,
    tel.IsEnabled
FROM WorkoutTemplates wt
    JOIN TemplateExerciseList tel ON wt.TemplateID = tel.TemplateID
    JOIN ExerciseLibrary el ON tel.ExerciseID = el.ExerciseID
    LEFT JOIN ProgressionModels pm ON tel.ProgressionModelID = pm.ProgressionModelID
ORDER BY wt.TemplateName,
    tel.OrderInWorkout;