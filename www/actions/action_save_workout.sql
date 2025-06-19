/**
 * @filename      action_save_workout.sql
 * @description   A pure action script that processes a multi-set workout form submission from index.sql. It creates a parent log entry, saves each individual set, and updates the user's progression to the next step in their plan.
 * @created       2025-06-17
 * @last-updated  2025-06-18
 * @requires      - sessions (table): To identify the current user.
 * @requires      - WorkoutLog (table): The parent table for a workout session.
 * @requires      - WorkoutSetLog (table): The child table for individual sets within a session.
 * @requires      - UserExerciseProgression (table): The table that tracks a user's progress on an exercise, which is updated by this script.
 * @param         template_id [form] The ID of the workout template being followed.
 * @param         exercise_id [form] The ID of the exercise being logged.
 * @param         num_sets [form] The total number of sets submitted from the form.
 * @param         reps_1, weight_1, ... [form] Dynamically named fields for each set's reps and weight (up to a max of 10).
 * @param         rpe_recorded [form] The user's Rate of Perceived Exertion for the session.
 * @param         notes_recorded [form, optional] Any user-provided notes for the workout.
 * @returns       A `redirect` component that sends the user back to the index page with a success flag.
 * @see           - /index.sql: The page containing the form that submits to this action.
 * @note          This script uses a series of conditional INSERTs to handle a variable number of sets.
 * @note          It uses an "upsert" (INSERT ON CONFLICT) pattern to robustly create or update the user's progression record.
 */
----------------------------------------------------
-- Step 0: Authentication Guard
-- This block protects the action from being executed by unauthenticated users.
----------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
SELECT 'redirect' AS component,
    '/auth/auth_guest_prompt.sql' AS link
WHERE $current_user IS NULL;
----------------------------------------------------
-- STEP 1: Prepare for Logging
-- Generate a single, unique LogID that will be used to link the parent log
-- record with all of its child set records.
----------------------------------------------------    
SET new_log_id = (
        SELECT lower(hex(randomblob(16)))
    );
----------------------------------------------------
-- STEP 2: Insert Parent Log Record
-- This creates a single record in the WorkoutLog table to represent the overall
-- workout session for this exercise.
----------------------------------------------------
INSERT INTO WorkoutLog (
        LogID,
        UserID,
        ExerciseTimestamp,
        ExerciseID,
        WorkoutNotes,
        LinkedTemplateID,
        LinkedProgressionModelID,
        PerformedAtStepNumber,
        Estimated1RM
    )
SELECT $new_log_id,
    $current_user,
    strftime('%s', 'now'),
    -- Use Unix timestamp for consistency
    :exercise_id,
    :notes_recorded,
    :template_id,
    -- Get the progression model from the user's current progression data
    (
        SELECT ProgressionModelID
        FROM UserExerciseProgression
        WHERE UserID = $current_user
            AND ExerciseID = :exercise_id
    ),
    -- Get the current step number, defaulting to 1 if no progression exists yet
    COALESCE(
        (
            SELECT CurrentStepNumber
            FROM UserExerciseProgression
            WHERE UserID = $current_user
                AND ExerciseID = :exercise_id
        ),
        1
    ),
    -- Calculate an estimated 1RM based on the first set's performance (Epley formula)
    CAST(:weight_1 AS REAL) * (1 + (CAST(:reps_1 AS REAL) / 30.0))
WHERE :num_sets IS NOT NULL;
------------------------------------------------------------------------------------
-- STEP 3: Insert Individual Set Records
-- This section uses a series of conditional INSERT statements. An INSERT for a given
-- set only occurs if the corresponding form field (e.g., :reps_1) was submitted.
-- This pattern reliably handles a variable number of sets up to a predefined maximum.
------------------------------------------------------------------------------------
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    1,
    :reps_1,
    :weight_1
WHERE :reps_1 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    2,
    :reps_2,
    :weight_2
WHERE :reps_2 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    3,
    :reps_3,
    :weight_3
WHERE :reps_3 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    4,
    :reps_4,
    :weight_4
WHERE :reps_4 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    5,
    :reps_5,
    :weight_5
WHERE :reps_5 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    6,
    :reps_6,
    :weight_6
WHERE :reps_6 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    7,
    :reps_7,
    :weight_7
WHERE :reps_7 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    8,
    :reps_8,
    :weight_8
WHERE :reps_8 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    9,
    :reps_9,
    :weight_9
WHERE :reps_9 IS NOT NULL;
INSERT INTO WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed
    )
SELECT lower(hex(randomblob(16))),
    $new_log_id,
    10,
    :reps_10,
    :weight_10
WHERE :reps_10 IS NOT NULL;
------------------------------------------------------------------------------------
-- STEP 4: Advance User Progression
-- This uses an "upsert" (INSERT ON CONFLICT) pattern. If a progression record for
-- this user and exercise already exists, it is updated with the latest data.
-- Otherwise, a new record is created. The CurrentStepNumber is incremented.
------------------------------------------------------------------------------------
INSERT INTO UserExerciseProgression (
        UserExerciseProgressionID,
        UserID,
        TemplateID,
        ExerciseID,
        ProgressionModelID,
        CurrentStepNumber,
        LastWorkoutRPE,
        DateOfLastAttempt,
        MaxReps,
        CurrentCycle1RMEstimate
    )
SELECT lower(hex(randomblob(16))),
    $current_user,
    :template_id,
    :exercise_id,
    (
        SELECT ProgressionModelID
        FROM UserExerciseProgression
        WHERE UserID = $current_user
            AND ExerciseID = :exercise_id
    ),
    -- Advance to the next step number
    COALESCE(
        (
            SELECT CurrentStepNumber
            FROM UserExerciseProgression
            WHERE UserID = $current_user
                AND ExerciseID = :exercise_id
        ),
        0
    ) + 1,
    :rpe_recorded,
    strftime('%s', 'now'),
    CAST(:reps_1 AS INTEGER),
    CAST(:weight_1 AS REAL) * (1 + (CAST(:reps_1 AS REAL) / 30.0))
WHERE :num_sets IS NOT NULL -- This ON CONFLICT clause now correctly targets the three columns in the UNIQUE constraint.
    ON CONFLICT(UserID, TemplateID, ExerciseID) DO
UPDATE
SET ProgressionModelID = excluded.ProgressionModelID,
    CurrentStepNumber = excluded.CurrentStepNumber,
    LastWorkoutRPE = excluded.LastWorkoutRPE,
    DateOfLastAttempt = excluded.DateOfLastAttempt,
    MaxReps = excluded.MaxReps,
    CurrentCycle1RMEstimate = excluded.CurrentCycle1RMEstimate;
----------------------------------------------------
-- STEP 5: Redirect on Success
-- Redirects the user back to the index page with a success flag, which
-- will trigger the "Workout Saved!" alert.
----------------------------------------------------
SELECT 'redirect' as component,
    '/index.sql?success=true' as link;