/**
 * @filename      action_save_workout.sql
 * @description   Processes a multi-set workout form submission from index.sql. It first creates
 * a single parent entry in the `WorkoutLog` table, then saves each submitted
 * set individually into the `WorkoutSetLog` table, and finally updates the user's
 * progression record to advance them to the next step.
 * @created       2025-06-17
 * @last-updated  2025-06-18
 * @requires      - The `WorkoutLog` and `WorkoutSetLog` tables for saving workout data.
 * @requires      - The `UserExerciseProgression` table to track and update user progress.
 * @param         template_id [form] The ID of the parent workout template.
 * @param         exercise_id [form] The ID of the exercise being logged.
 * @param         num_sets [form] The total number of sets submitted from the form.
 * @param         reps_1, weight_1, ... [form] The dynamically named form fields for each set's reps and weight.
 * @param         rpe_recorded [form] The overall Rate of Perceived Exertion for the workout session.
 * @param         notes_recorded [form, optional] User-provided notes for the entire workout.
 * @returns       A `redirect` component that sends the user back to the main workout page,
 * keeping the current workout template selected.
 * @see           - `index.sql` - The page that contains the form that submits to this action.
 * @see           - `views/view_full_workout_history.sql` - A page that displays data saved by this script.
 * @note          This script uses a series of conditional INSERTs to save each set. This is a
 * reliable pattern in SQLPage for handling a variable number of form fields.
 */

----------------------------------------------------
-- STEP 1: Get user info and generate a unique ID for the main log entry.
----------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
SET new_log_id = (
        SELECT lower(hex(randomblob(16)))
    );
----------------------------------------------------
-- STEP 2: Insert a single record into the parent WorkoutLog table.
-- This entry represents the overall workout session for the selected exercise,
-- linking all subsequent sets together with the generated LogID.
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
-- STEP 3: Insert each individual set into the WorkoutSetLog table.
-- This uses a series of conditional INSERT statements. An INSERT only occurs if the
-- corresponding form field (e.g., :reps_1) exists and is not null. This pattern
-- reliably handles a variable number of sets up to a predefined maximum (10 in this case).
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
-- STEP 4: Update the UserExerciseProgression table to advance the user to the NEXT step.
-- This uses an "upsert" (INSERT ON CONFLICT) pattern. If a progression record for this user
-- and exercise already exists, it is updated. Otherwise, a new record is created.
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
-- STEP 5: Redirect the user back to the index page with the template selected.
-- This creates a seamless workflow, allowing the user to select their next exercise manually.
----------------------------------------------------
SELECT 'redirect' as component,
    '/index.sql?template_id=' || :template_id || COALESCE(
        '&selected_exercise_id=' || $next_exercise_id,
        ''
    ) as link;