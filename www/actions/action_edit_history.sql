/**
 * @filename      action_edit_history.sql
 * @description   A self-submitting page for creating a new workout log or editing an existing one.
 * @created       2025-07-05
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - All `dim` and `fact` tables.
 * @param         user_id, exercise_id, date_id [url, optional] A composite key to identify the workout session to edit. If absent, the page is in "create" mode.
 * @param         action [form] The action to perform (e.g., 'save_log').
 */
-- =============================================================================
-- Ensure the current date exists in the dimDate table
-- =============================================================================
INSERT OR IGNORE INTO
    dimDate (dateId, fullDate, dayOfWeek, monthName, year)
VALUES
    (
        CAST(STRFTIME('%Y%m%d', 'now') AS INTEGER),
        STRFTIME('%Y-%m-%d', 'now'),
        CASE STRFTIME('%w', 'now')
            WHEN '0' THEN 'Sunday'
            WHEN '1' THEN 'Monday'
            WHEN '2' THEN 'Tuesday'
            WHEN '3' THEN 'Wednesday'
            WHEN '4' THEN 'Thursday'
            WHEN '5' THEN 'Friday'
            WHEN '6' THEN 'Saturday'
        END,
        CASE STRFTIME('%m', 'now')
            WHEN '01' THEN 'January'
            WHEN '02' THEN 'February'
            WHEN '03' THEN 'March'
            WHEN '04' THEN 'April'
            WHEN '05' THEN 'May'
            WHEN '06' THEN 'June'
            WHEN '07' THEN 'July'
            WHEN '08' THEN 'August'
            WHEN '09' THEN 'September'
            WHEN '10' THEN 'October'
            WHEN '11' THEN 'November'
            WHEN '12' THEN 'December'
        END,
        CAST(STRFTIME('%Y', 'now') AS INTEGER)
    );

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
-- This uses a "delete and replace" strategy for robustness.
-- First, delete all existing sets for this workout session.
DELETE FROM factWorkoutHistory
WHERE
    userId=:user_id
    AND exerciseId=:exercise_id
    AND dateId=:date_id
    AND :action='save_log';

-- Then, insert the new sets from the form, ignoring any rows where reps or weight are blank.
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
        notes,
        createdAt,
        updatedAt
    )
SELECT
    HEX(RANDOMBLOB(16)),
    :user_id,
    :exercise_id,
    :date_id,
    NULLIF(:exercise_plan_id, ''),
    step_data.setNumber,
    step_data.reps,
    step_data.weight,
    :rpe_recorded,
    :notes_recorded,
    STRFTIME('%s', 'now'),
    STRFTIME('%s', 'now')
FROM
    (
        SELECT
            1 AS setNumber,
            :reps_1 AS reps,
            :weight_1 AS weight
        UNION ALL
        SELECT
            2,
            :reps_2,
            :weight_2
        UNION ALL
        SELECT
            3,
            :reps_3,
            :weight_3
        UNION ALL
        SELECT
            4,
            :reps_4,
            :weight_4
        UNION ALL
        SELECT
            5,
            :reps_5,
            :weight_5
    ) AS step_data
WHERE
    :action='save_log'
    AND (
        step_data.reps IS NOT NULL
        AND step_data.reps!=''
    )
    AND (
        step_data.weight IS NOT NULL
        AND step_data.weight!=''
    );

-- After saving the sets, handle the progression logic.
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
-- Handle the delete request
-- =============================================================================
-- Step 2a: Before deleting, check if this workout caused a progression and revert it.
-- This block runs only if the submitted action is 'delete_log'.
UPDATE dimExercisePlan
SET
    currentStepNumber=currentStepNumber - 1
WHERE
    -- Find the correct plan using the exercisePlanId from the workout we are about to delete
    exercisePlanId=(
        SELECT
            fwh.exercisePlanId
        FROM
            factWorkoutHistory AS fwh
        WHERE
            fwh.userId=:user_id
            AND fwh.exerciseId=:exercise_id
            AND fwh.dateId=:date_id
        LIMIT
            1
    )
    -- Only revert progression if the recorded RPE was 8 or less
    AND (
        SELECT
            MAX(fwh.rpeRecorded)
        FROM
            factWorkoutHistory AS fwh
        WHERE
            fwh.userId=:user_id
            AND fwh.exerciseId=:exercise_id
            AND fwh.dateId=:date_id
    )<=8
    AND :action='delete_log';

-- Step 2b: Delete all sets for this workout session.
DELETE FROM factWorkoutHistory
WHERE
    userId=:user_id
    AND exerciseId=:exercise_id
    AND dateId=:date_id
    AND :action='delete_log';

-- Step 2c: After deleting, redirect back to the Training Log page.
SELECT
    'redirect' as component,
    '/views/view_history.sql?deleted=true' as link
WHERE
    :action='delete_log';

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
                'fullDate',
                d.fullDate,
                'exercisePlanId',
                fwh.exercisePlanId,
                'rpe',
                MAX(fwh.rpeRecorded),
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
            JOIN dimDate AS d ON fwh.dateId=d.dateId
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
    JSON_EXTRACT($workout_session_data, '$.fullDate')||' | '||JSON_EXTRACT($workout_session_data, '$.exerciseName') as contents_md
WHERE
    $user_id IS NOT NULL;

-- Step 6: Display the main form.
SELECT
    'form' as component,
    'post' as method;

SELECT
    'hidden' as type,
    'action' as name,
    'save_log' as value;

SELECT
    'hidden' as type,
    'user_id' as name,
    COALESCE($user_id, $current_user_id) as value;

SELECT
    'hidden' as type,
    'exercise_id' as name,
    $exercise_id as value
WHERE
    $user_id IS NOT NULL;

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
    'exercise_id' as name, -- The name is now 'exercise_id'
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
    '' as step,
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
    0.01 as step,
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
    0.01 as step,
    3 as width
FROM
    series
ORDER BY
    set_number;

-- Add fields for RPE.
SELECT
    'header' as type,
    '' as name,
    '' as prefix,
    'RPE ' as label,
    '' as value,
    '' as step,
    0 as max,
    3 as width
UNION ALL
SELECT
    'number' as type,
    'rpe_recorded' as name,
    'RPE' as prefix,
    '' as label,
    JSON_EXTRACT($workout_session_data, '$.rpe') as value,
    0.01 as step,
    10 as max,
    3 as width
    -- Notes
UNION ALL
SELECT
    'header' as type,
    '' as name,
    '' as prefix,
    'Notes' as label,
    '' as value,
    '' as step,
    0 as max,
    3 as width
UNION ALL
SELECT
    'textarea' as type,
    'notes_recorded' as name,
    '' as prefix,
    '' as label,
    JSON_EXTRACT($workout_session_data, '$.notes') as value,
    '' as step,
    0 as max,
    5 as width;

SELECT
    'button' as component,
    'submit' as type,
    'Save Workout' as title;

-- =============================================================================
-- Display the Delete button (only in "Edit" mode)
-- =============================================================================
SELECT
    'divider' as component
WHERE
    $user_id IS NOT NULL;

SELECT
    'form' as component,
    'post' as method,
    -- 'delete_log_form' as id,
    'Delete Log' as validate,
    'red' as validate_color
WHERE
    $user_id IS NOT NULL;

-- Hidden fields to pass the necessary data for the delete action
SELECT
    'hidden' as type,
    'action' as name,
    'delete_log' as value;

SELECT
    'hidden' as type,
    'user_id' as name,
    $user_id as value;

SELECT
    'hidden' as type,
    'exercise_id' as name,
    $exercise_id as value;

SELECT
    'hidden' as type,
    'date_id' as name,
    $date_id as value;