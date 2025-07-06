/**
 * @filename      action_edit_history.sql
 * @description   A self-submitting page for creating a new workout log or editing an existing one.
 * @created       2025-07-05
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - All `dim` and `fact` tables.
 * @param         user_id, exercise_id, date_id [url, optional] A composite key to identify the workout session to edit. If absent, the page is in "create" mode.
 * @param         action [form] The action to perform (e.g., 'save_log').
 */
-- Step 1: Get current user ID.
SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

-- Step 2: Handle the form submission to save the workout log.
-- This section uses a "delete and replace" strategy for robustness.
-- First, delete all existing sets for this workout session.
DELETE FROM factWorkoutHistory
WHERE
    userId=:user_id
    AND exerciseId=:exercise_id
    AND dateId=:date_id
    AND :action='save_log';

-- Then, insert the new sets from the form.
INSERT INTO
    factWorkoutHistory (
        workoutHistoryId,
        userId,
        exerciseId,
        dateId,
        exercisePlanId,
        setNumber,
        repsPerformed,
        weightUsed,
        rpeRecorded,
        createdAt,
        updatedAt
    )
SELECT
    HEX(RANDOMBLOB(16)),
    :user_id,
    :exercise_id,
    :date_id,
    :exercise_plan_id,
    1,
    :reps_1,
    :weight_1,
    :rpe_recorded,
    STRFTIME('%s', 'now'),
    STRFTIME('%s', 'now')
WHERE
    :action='save_log'
    AND :reps_1 IS NOT NULL;

INSERT INTO
    factWorkoutHistory (
        workoutHistoryId,
        userId,
        exerciseId,
        dateId,
        exercisePlanId,
        setNumber,
        repsPerformed,
        weightUsed,
        rpeRecorded,
        createdAt,
        updatedAt
    )
SELECT
    HEX(RANDOMBLOB(16)),
    :user_id,
    :exercise_id,
    :date_id,
    :exercise_plan_id,
    2,
    :reps_2,
    :weight_2,
    :rpe_recorded,
    STRFTIME('%s', 'now'),
    STRFTIME('%s', 'now')
WHERE
    :action='save_log'
    AND :reps_2 IS NOT NULL;

INSERT INTO
    factWorkoutHistory (
        workoutHistoryId,
        userId,
        exerciseId,
        dateId,
        exercisePlanId,
        setNumber,
        repsPerformed,
        weightUsed,
        rpeRecorded,
        createdAt,
        updatedAt
    )
SELECT
    HEX(RANDOMBLOB(16)),
    :user_id,
    :exercise_id,
    :date_id,
    :exercise_plan_id,
    3,
    :reps_3,
    :weight_3,
    :rpe_recorded,
    STRFTIME('%s', 'now'),
    STRFTIME('%s', 'now')
WHERE
    :action='save_log'
    AND :reps_3 IS NOT NULL;

INSERT INTO
    factWorkoutHistory (
        workoutHistoryId,
        userId,
        exerciseId,
        dateId,
        exercisePlanId,
        setNumber,
        repsPerformed,
        weightUsed,
        rpeRecorded,
        createdAt,
        updatedAt
    )
SELECT
    HEX(RANDOMBLOB(16)),
    :user_id,
    :exercise_id,
    :date_id,
    :exercise_plan_id,
    4,
    :reps_4,
    :weight_4,
    :rpe_recorded,
    STRFTIME('%s', 'now'),
    STRFTIME('%s', 'now')
WHERE
    :action='save_log'
    AND :reps_4 IS NOT NULL;

INSERT INTO
    factWorkoutHistory (
        workoutHistoryId,
        userId,
        exerciseId,
        dateId,
        exercisePlanId,
        setNumber,
        repsPerformed,
        weightUsed,
        rpeRecorded,
        createdAt,
        updatedAt
    )
SELECT
    HEX(RANDOMBLOB(16)),
    :user_id,
    :exercise_id,
    :date_id,
    :exercise_plan_id,
    5,
    :reps_5,
    :weight_5,
    :rpe_recorded,
    STRFTIME('%s', 'now'),
    STRFTIME('%s', 'now')
WHERE
    :action='save_log'
    AND :reps_5 IS NOT NULL;

-- After saving the sets, handle the progression logic.
-- If the RPE was 8 or lower, increment the current step number for this exercise plan.
UPDATE dimExercisePlan
SET
    currentStepNumber=currentStepNumber+1
WHERE
    exercisePlanId=:exercise_plan_id
    AND :rpe_recorded<=8
    AND :action='save_log';

-- After all actions, redirect back to the Training Log page.
SELECT
    'redirect' as component,
    '/views/view_history.sql?saved=true' as link
WHERE
    :action='save_log';

-- =============================================================================
-- Page Rendering Logic (only runs on GET requests)
-- =============================================================================
-- Step 3: Load the main layout.
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

-- Step 4: Fetch data for the workout session if we are in "Edit" mode.
SET
    workout_session_data=(
        SELECT
            JSON_OBJECT(
                'exerciseName',
                ex.exerciseName,
                'exercisePlanId',
                fwh.exercisePlanId,
                'rpe',
                MAX(fwh.rpeRecorded), -- Get a single RPE value for the session
                'sets',
                JSON_GROUP_ARRAY(
                    JSON_OBJECT(
                        'set',
                        fwh.setNumber,
                        'reps',
                        fwh.repsPerformed,
                        'weight',
                        fwh.weightUsed
                    )
                )
            )
        FROM
            factWorkoutHistory AS fwh
            JOIN dimExercise AS ex ON fwh.exerciseId=ex.exerciseId
        WHERE
            fwh.userId=$user_id
            AND fwh.exerciseId=$exercise_id
            AND fwh.dateId=$date_id
        GROUP BY
            ex.exerciseName,
            fwh.exercisePlanId
    );

-- Step 5: Display the page header.
SELECT
    'text' as component,
    CASE
        WHEN $user_id IS NULL THEN 'Add New Workout Log'
        ELSE 'Edit Workout Log'
    END as title;

SELECT
    'text' as component,
    CASE
        WHEN $user_id IS NOT NULL THEN JSON_EXTRACT($workout_session_data, '$.exerciseName')
    END as description;

-- Step 6: Display the main form.
SELECT
    'form' as component,
    'post' as method;

SELECT
    'hidden' as type,
    'action' as name,
    'save_log' as value;

-- Pass all parts of the composite key to the action.
SELECT
    'hidden' as type,
    'user_id' as name,
    COALESCE($user_id, $current_user_id) as value;

SELECT
    'hidden' as type,
    'exercise_id' as name,
    COALESCE($exercise_id, :exercise_id_new) as value;

SELECT
    'hidden' as type,
    'date_id' as name,
    COALESCE($date_id, STRFTIME('%Y%m%d', 'now')) as value;

SELECT
    'hidden' as type,
    'exercise_plan_id' as name,
    JSON_EXTRACT($workout_session_data, '$.exercisePlanId') as value;

-- If in "Create" mode, show a dropdown to select the exercise.
SELECT
    'select' as type,
    'exercise_id_new' as name,
    'Select Exercise' as label,
    TRUE as required,
    (
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT('label', exerciseName, 'value', exerciseId)
            )
        FROM
            dimExercise
    ) as options
WHERE
    $user_id IS NULL;

-- Dynamically generate the input fields for each set.
WITH RECURSIVE
    series (set_number) AS (
        SELECT
            1
        UNION ALL
        SELECT
            set_number+1
        FROM
            series
        WHERE
            set_number<5 -- Show 5 sets by default
    )
SELECT
    set_number,
    'header' as type,
    '' as name,
    'Set'||set_number as label,
    '' as prefix,
    '' as value,
    3 as width
FROM
    series
UNION ALL
SELECT
    set_number,
    'number' as type,
    'reps_'||set_number as name,
    '' as label,
    'Reps' as prefix, 
    JSON_EXTRACT(
        $workout_session_data,
        '$.sets['||(set_number - 1)||'].reps'
    ) as value,
    3 as width
FROM
    series
UNION ALL
SELECT
    set_number,
    'number' as type,
    'weight_'||set_number as name,
    '' as label,
    'Wt' as prefix,
    JSON_EXTRACT(
        $workout_session_data,
        '$.sets['||(set_number - 1)||'].weight'
    ) as value,
    3 as width
FROM
    series
ORDER BY
    set_number;

-- Add fields for RPE.
SELECT
    'header' as type,
    '' as name,
    'RPE (Rate of Perceived Exertion)' as label,
    '' as value,
    '' as prefix,
    0 as max,
    6 as width
UNION ALL
SELECT
    'number' as type,
    'rpe_recorded' as name,
    '' as label,
    'RPE' as prefix,
    JSON_EXTRACT($workout_session_data, '$.rpe') as value,
    10 as max,
    6 as width;

SELECT
    'button' as component,
    'submit' as type,
    'Save Workout' as title;
