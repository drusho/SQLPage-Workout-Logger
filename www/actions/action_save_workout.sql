/**
 * @filename      action_save_workout.sql
 * @description   Processes and saves a completed workout set from a form submission. It first
 * inserts a new record into the `WorkoutLog` table, then updates or creates a
 * record in `UserExerciseProgression` to advance the user's progress for that exercise.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @requires      - The `sessions` table to identify the current user.
 * @requires      - The `WorkoutLog` table for inserting new workout data.
 * @requires      - The `UserExerciseProgression` table to update the user's progress.
 * @requires      - The `ExerciseLibrary` table to check the exercise's log type.
 * @requires      - The `TemplateExerciseList` table to find the associated progression model.
 * @param         sqlpage.cookie('session_token') [cookie] The user's session identifier.
 * @param         exercise_id [form] The unique ID of the exercise being logged.
 * @param         template_id [form] The unique ID of the parent workout template.
 * @param         sets_recorded [form] The total number of sets performed.
 * @param         reps_recorded [form] Reps performed for a standard weighted exercise.
 * @param         weight_recorded [form] Weight used for a standard weighted exercise.
 * @param         reps_set_1 - reps_set_5 [form] Reps for 'RepsOnly' type exercises.
 * @param         rpe_recorded [form] The Rate of Perceived Exertion for the workout.
 * @param         notes_recorded [form, optional] User-provided notes for the log.
 * @returns       A `redirect` component that sends the user back to the main workout page for
 * the current template.
 * @see           - `index.sql` - The page where the workout form is displayed.
 * @see           - `views/view_workout_logs.sql` - A page that displays data saved by this script.
 * @todo          - Implement more complex progression logic based on `ProgressionModels` table.
 * @todo          - Add validation for required form parameters to prevent SQL errors.
 * @todo          - The 1RM estimation formula is hardcoded; consider making it dynamic.
 */
----------------------------------------------------
-- STEP 1: First, get the current user's username into a variable.
----------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
----------------------------------------------------
-- STEP 2: Insert the new workout record into WorkoutLog
-- INSERT PATH 1: For 'RepsOnly' exercises
----------------------------------------------------
INSERT INTO WorkoutLog (
        LogID,
        UserID,
        ExerciseTimestamp,
        ExerciseID,
        TotalSetsPerformed,
        RepsPerformed,
        WeightUsed,
        WeightUnit,
        RPE_Recorded,
        WorkoutNotes,
        LinkedTemplateID,
        LinkedProgressionModelID,
        PerformedAtStepNumber
    )
SELECT lower(hex(randomblob(16))),
    $current_user,
    datetime('now', 'localtime'),
    :exercise_id,
    :sets_recorded,
    trim(
        :reps_set_1 || ',' || :reps_set_2 || ',' || :reps_set_3 || ',' || :reps_set_4 || ',' || :reps_set_5
    ),
    0,
    'reps',
    :rpe_recorded,
    CAST(:notes_recorded AS TEXT),
    :template_id,
    (
        SELECT ProgressionModelID
        FROM TemplateExerciseList
        WHERE ExerciseID = :exercise_id
            AND TemplateID = :template_id
    ),
    -- If no previous step exists, default to 1.
    COALESCE(
        (
            SELECT CurrentStepNumber
            FROM UserExerciseProgression
            WHERE UserID = $current_user
                AND ExerciseID = :exercise_id
        ),
        1
    )
WHERE (
        SELECT DefaultLogType
        FROM ExerciseLibrary
        WHERE ExerciseID = :exercise_id
    ) = 'RepsOnly';
-- INSERT PATH 2: For all other (weighted) exercise types
INSERT INTO WorkoutLog (
        LogID,
        UserID,
        ExerciseTimestamp,
        ExerciseID,
        TotalSetsPerformed,
        RepsPerformed,
        WeightUsed,
        WeightUnit,
        RPE_Recorded,
        WorkoutNotes,
        LinkedTemplateID,
        LinkedProgressionModelID,
        PerformedAtStepNumber,
        Estimated1RM
    )
SELECT lower(hex(randomblob(16))),
    $current_user,
    datetime('now', 'localtime'),
    :exercise_id,
    :sets_recorded,
    :reps_recorded,
    :weight_recorded,
    'lbs',
    :rpe_recorded,
    CAST(:notes_recorded AS TEXT),
    :template_id,
    (
        SELECT ProgressionModelID
        FROM TemplateExerciseList
        WHERE ExerciseID = :exercise_id
            AND TemplateID = :template_id
    ),
    -- If no previous step exists, default to 1.
    COALESCE(
        (
            SELECT CurrentStepNumber
            FROM UserExerciseProgression
            WHERE UserID = $current_user
                AND ExerciseID = :exercise_id
        ),
        1
    ),
    :weight_recorded * (1 + (:reps_recorded / 30.0))
WHERE (
        SELECT DefaultLogType
        FROM ExerciseLibrary
        WHERE ExerciseID = :exercise_id
    ) != 'RepsOnly';
------------------------------------------------------------------------------------
-- STEP 3: Update the UserExerciseProgression table to the NEXT step.
------------------------------------------------------------------------------------
INSERT INTO UserExerciseProgression (
        UserExerciseProgressionID,
        UserID,
        ExerciseID,
        TemplateID,
        ProgressionModelID,
        CurrentStepNumber,
        LastWorkoutRPE,
        DateOfLastAttempt,
        MaxReps,
        CurrentCycle1RMEstimate
    )
SELECT lower(hex(randomblob(16))),
    ll.UserID,
    ll.ExerciseID,
    ll.LinkedTemplateID,
    ll.LinkedProgressionModelID,
    -- This is the key logic change: advance to the next step.
    ll.PerformedAtStepNumber + 1,
    ll.RPE_Recorded,
    ll.ExerciseTimestamp,
    CAST(
        substr(
            ll.RepsPerformed || ',',
            1,
            instr(ll.RepsPerformed || ',', ',') - 1
        ) AS INTEGER
    ),
    ll.Estimated1RM
FROM (
        -- This subquery finds the most recent workout log for the exercise we just updated.
        SELECT *,
            ROW_NUMBER() OVER(
                PARTITION BY UserID,
                ExerciseID
                ORDER BY ExerciseTimestamp DESC
            ) as rn
        FROM WorkoutLog
        WHERE UserID = $current_user
            AND ExerciseID = :exercise_id
    ) AS ll
WHERE ll.rn = 1
    AND ll.LinkedProgressionModelID IS NOT NULL ON CONFLICT(UserID, ExerciseID) DO
UPDATE
SET TemplateID = excluded.TemplateID,
    ProgressionModelID = excluded.ProgressionModelID,
    -- This is the key logic change: advance to the next step.
    CurrentStepNumber = excluded.CurrentStepNumber,
    LastWorkoutRPE = excluded.LastWorkoutRPE,
    DateOfLastAttempt = excluded.DateOfLastAttempt,
    MaxReps = excluded.MaxReps,
    CurrentCycle1RMEstimate = excluded.CurrentCycle1RMEstimate;
----------------------------------------------------
-- STEP 4: Redirect the user back to the index page.
----------------------------------------------------
SELECT 'redirect' as component,
    'index.sql?template_id=' || :template_id as link;