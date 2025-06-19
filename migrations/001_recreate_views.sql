/**----------------------------------------------------
 -- Recreate the views to ensure it reflects the new structure.
 -- Migration Script: 005_recreate_views.sql
 -- Description: Drops and recreates all required application views to resolve errors
 --              from missing or outdated view definitions. This includes the recreation
 --              of the WorkoutTemplateDetails view.
 -- Date: 2025-06-18
 ----------------------------------------------------*/
----------------------------------------------------
-- STEP 1: DROP EXISTING VIEWS
-- This ensures a clean state before recreating them.
----------------------------------------------------
DROP VIEW IF EXISTS FullWorkoutHistory;
DROP VIEW IF EXISTS UserExerciseProgressionTargets;
DROP VIEW IF EXISTS WorkoutTemplateDetails;
----------------------------------------------------
-- STEP 2: RECREATE `FullWorkoutHistory` VIEW
-- Combines workout logs with set and exercise details for a comprehensive history.
----------------------------------------------------
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
----------------------------------------------------
-- STEP 3: RECREATE `UserExerciseProgressionTargets` VIEW
-- Calculates the next target sets, reps, and weight for a user's exercise progression.
----------------------------------------------------
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
    -- This CASE statement performs the calculation for the target weight
    CASE
        WHEN pms.TargetWeightFormula LIKE '%*%' THEN -- Manually parse the multiplier from the formula string and multiply
        uep.CurrentCycle1RMEstimate * CAST(
            trim(
                substr(
                    pms.TargetWeightFormula,
                    instr(pms.TargetWeightFormula, '*') + 1
                )
            ) AS REAL
        )
        ELSE -- Handle simple weight values that don't have a formula
        CAST(pms.TargetWeightFormula AS REAL)
    END as "TargetWeight",
    pms.StepNotes
FROM UserExerciseProgression uep
    JOIN ProgressionModels pm ON uep.ProgressionModelID = pm.ProgressionModelID
    JOIN ProgressionModelSteps pms ON uep.ProgressionModelID = pms.ProgressionModelID
WHERE -- This crucial WHERE clause finds the *next* step for the user
    pms.StepNumber = uep.CurrentStepNumber;
----------------------------------------------------
-- STEP 4: CREATE THE MISSING `WorkoutTemplateDetails` VIEW
-- This view is required by index.sql to list exercises for a selected workout.
----------------------------------------------------
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