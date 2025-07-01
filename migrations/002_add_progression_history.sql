-- migrations/002_add_progression_history.sql
----------------------------------------------------
-- MIGRATION METADATA
----------------------------------------------------
-- Description: Creates the 'UserExerciseProgressionHistory' table to log all changes
--              to a user's progression. Also adds new views for analyzing this history.
-- Date: 2025-06-30
----------------------------------------------------
-- STEP 1: SCHEMA CHANGES
----------------------------------------------------
-- Create the new table to store a historical record of all progression changes.
CREATE TABLE IF NOT EXISTS "UserExerciseProgressionHistory" (
    "ProgressionHistoryID"  TEXT PRIMARY KEY,
    "UserID"                TEXT NOT NULL,
    "ExerciseID"            TEXT NOT NULL,
    "TemplateID"            TEXT,
    "LogID"                 TEXT, -- The specific workout that triggered this change
    "ChangeTimestamp"       INTEGER NOT NULL,
    "OldStepNumber"         INTEGER,
    "NewStepNumber"         INTEGER,
    "OldCycle1RMEstimate"   REAL,
    "NewCycle1RMEstimate"   REAL,
    "ReasonForChange"       TEXT, -- e.g., 'Completed workout', 'Failed RPE', 'Cycle Reset'
    FOREIGN KEY("UserID") REFERENCES "users"("username"),
    FOREIGN KEY("ExerciseID") REFERENCES "ExerciseLibrary"("ExerciseID"),
    FOREIGN KEY("LogID") REFERENCES "WorkoutLog"("LogID")
);

----------------------------------------------------
-- STEP 2: REBUILD ALL APPLICATION VIEWS
-- This is the most critical step to prevent your application from breaking.
-- It ensures that all views are updated to reflect the schema changes from Step 1.
----------------------------------------------------
-- Drop existing views to ensure a clean slate.
DROP VIEW IF EXISTS FullWorkoutHistory;
DROP VIEW IF EXISTS UserExerciseProgressionTargets;
DROP VIEW IF EXISTS WorkoutTemplateDetails;

-- Drop the new views if they exist to make this script rerunnable
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

-- Create new `V_ProgressionHistorySummary` VIEW
-- This view provides a user-friendly summary of progression changes.
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

-- Create new `V_Exercise1RM_Chart` VIEW
-- This view is specifically for creating charts, providing the date and the new 1RM.
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
