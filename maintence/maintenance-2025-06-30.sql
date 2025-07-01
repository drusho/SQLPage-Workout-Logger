-- maintenance.sql
-- Description: A script for performing routine database maintenance.
--              This should be run periodically (e.g., monthly) or when the
--              application feels sluggish. It is NOT a migration script and
--              should not be run as part of the numbered migration process.
-- Date: 2025-06-30
----------------------------------------------------
-- STEP 1: OPTIMIZE DATABASE FILE AND INDEXES
----------------------------------------------------
-- Reclaims unused space from deleted data, defragments the database file,
-- and can improve performance.
VACUUM;
-- Rebuilds all indexes. This is useful if indexes have become fragmented
-- or corrupt over time.
REINDEX;
-- Gathers up-to-date statistics about tables and indexes, which helps the
-- query planner make better decisions for faster query execution.
ANALYZE;
----------------------------------------------------
-- STEP 2: REBUILD ALL APPLICATION VIEWS
-- This ensures that all views are up-to-date and not in a broken state.
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
