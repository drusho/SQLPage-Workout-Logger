-- Migration: 006_populate_plans_and_facts
-- Description: Populates the DimExercisePlan and FactWorkoutHistory tables.
-- It creates a default, active plan for each user/exercise combination
-- and then migrates all historical workout data into the fact table.
-- =============================================================================
-- 1. Populate DimExercisePlan
-- =============================================================================
-- This statement creates an initial, active plan for every unique combination
-- of a user and an exercise found in the old template tables.
-- Each plan starts at Step 1, as per user requirements.
INSERT OR IGNORE INTO
    DimExercisePlan (
        ExercisePlanKey,
        UserKey,
        ExerciseKey,
        TemplateName,
        IsActive,
        CurrentStepNumber
    )
SELECT
    -- Generate a new unique key for the exercise plan
    HEX(RANDOMBLOB(16)),
    wt.CreatedByUserID,
    tel.ExerciseID,
    wt.TemplateName,
    1, -- IsActive
    1 -- CurrentStepNumber
FROM
    WorkoutTemplates wt
    JOIN TemplateExerciseList tel ON wt.TemplateID = tel.TemplateID
GROUP BY
    wt.CreatedByUserID,
    tel.ExerciseID;

-- =============================================================================
-- 2. Populate FactWorkoutHistory
-- =============================================================================
-- This statement migrates all historical sets from the old logging tables
-- into the new central fact table.
INSERT OR IGNORE INTO
    FactWorkoutHistory (
        WorkoutHistoryKey,
        UserKey,
        ExerciseKey,
        DateKey,
        ExercisePlanKey,
        SetNumber,
        RepsPerformed,
        WeightUsed,
        RPE_Recorded,
        CreatedTimestamp,
        LastModifiedTimestamp
    )
SELECT
    -- Generate a new unique key for each historical set
    wsl.SetID,
    wl.UserID,
    wl.ExerciseID,
    -- Convert the Unix timestamp to a YYYYMMDD integer key
    CAST(
        STRFTIME('%Y%m%d', wl.ExerciseTimestamp, 'unixepoch') AS INTEGER
    ),
    -- Look up the key for the active plan for this user and exercise
    (
        SELECT
            dep.ExercisePlanKey
        FROM
            DimExercisePlan dep
        WHERE
            dep.UserKey = wl.UserID
            AND dep.ExerciseKey = wl.ExerciseID
            AND dep.IsActive = 1
    ),
    wsl.SetNumber,
    wsl.RepsPerformed,
    wsl.WeightUsed,
    wsl.RPE_Recorded,
    wl.ExerciseTimestamp, -- CreatedTimestamp
    wl.LastModifiedTimestamp
FROM
    WorkoutLog wl
    JOIN WorkoutSetLog wsl ON wl.LogID = wsl.LogID;
