-- migrations/003_add_timezone_to_users.sql
----------------------------------------------------
-- MIGRATION METADATA
----------------------------------------------------
-- Description: Adds a 'timezone' column to the 'users' table to store user-specific
--              timezone preferences for accurate date and time display.
-- Date: 2025-06-30
----------------------------------------------------
-- STEP 1: SCHEMA CHANGES
----------------------------------------------------
-- Add the new column to the users table.
-- We will handle the case where the column already exists by simply letting
-- the migration runner script manage whether this file has been run.
ALTER TABLE users ADD COLUMN timezone TEXT DEFAULT 'America/Denver';

----------------------------------------------------
-- STEP 2: REBUILD ALL APPLICATION VIEWS
-- This is the most critical step to prevent your application from breaking.
----------------------------------------------------
-- Drop existing views to ensure a clean slate.
DROP VIEW IF EXISTS FullWorkoutHistory;
DROP VIEW IF EXISTS UserExerciseProgressionTargets;
DROP VIEW IF EXISTS WorkoutTemplateDetails;
DROP VIEW IF EXISTS V_ProgressionHistorySummary;
DROP VIEW IF EXISTS V_Exercise1RM_Chart;

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

-- Recreate new `V_ProgressionHistorySummary` VIEW
CREATE VIEW V_ProgressionHistorySummary AS
SELECT
    ueph.ProgressionHistoryID,
    ueph.UserID,
    datetime(ueph.ChangeTimestamp, 'unixepoch', 'localtime') as ChangeDate,
    el.ExerciseName,
    ueph.ReasonForChange,
    ueph.OldStepNumber,
    ueph.NewStepNumber,
    CAST(ueph.OldCycle1RMEstimate AS INTEGER) as Old1RM,
    CAST(ueph.NewCycle1RMEstimate AS INTEGER) as New1RM,
    ueph.LogID
FROM
    UserExerciseProgressionHistory ueph
JOIN
    ExerciseLibrary el ON ueph.ExerciseID = el.ExerciseID
ORDER BY
    ueph.ChangeTimestamp DESC;

-- Recreate new `V_Exercise1RM_Chart` VIEW
CREATE VIEW V_Exercise1RM_Chart AS
SELECT
    ueph.UserID,
    ueph.ExerciseID,
    el.ExerciseName,
    date(ueph.ChangeTimestamp, 'unixepoch') as Date,
    ueph.NewCycle1RMEstimate as Estimated1RM
FROM
    UserExerciseProgressionHistory ueph
JOIN
    ExerciseLibrary el ON ueph.ExerciseID = el.ExerciseID
WHERE
    ueph.NewCycle1RMEstimate IS NOT NULL
ORDER BY
    ueph.ChangeTimestamp ASC;
