/**
 * @filename      action_edit_history.sql
 * @description   A self-submitting page for creating a new workout log or editing an existing one. It handles
 * workout data submission from the main logging page, updates user progression, and processes deletions.
 * When loaded directly (GET), it renders a form for manual editing or creation of a log entry.
 * @created       2025-07-09
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * - All `dim` and `fact` tables.
 * @param         user_id [url, optional] Part of the composite key to identify a workout session to edit.
 * @param         exercise_id [url, optional] Part of the composite key to identify a workout session to edit.
 * @param         date_id [url, optional] Part of the composite key to identify a workout session to edit. If absent, the page is in "create" mode.
 * @param         action [form] The server-side action to perform (e.g., 'save_log', 'delete_log').
 * @param         reps_1, weight_1, etc. [form] The performance data for each set.
 * @param         rpe_recorded [form] The user's Rate of Perceived Exertion for the workout.
 * @param         notes_recorded [form] Any notes for the workout session.
 * @param         original_date_id [form] The original date of the record being edited, to handle date changes correctly.
 */
-- =============================================================================
-- Step 1: Initial Setup
-- =============================================================================
-- Step 1a: Get Current User
SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

-- Step 1b: Ensure Date Dimension Exists
-- Ensures that an entry for the current local date is in the dimDate table before proceeding.
INSERT OR IGNORE INTO
    dimDate (dateId, fullDate, dayOfWeek, monthName, year)
VALUES
    (
        CAST(STRFTIME('%Y%m%d', 'now', 'localtime') AS INTEGER),
        STRFTIME('%Y-%m-%d', 'now', 'localtime'),
        CASE STRFTIME('%w', 'now', 'localtime')
            WHEN '0' THEN 'Sunday'
            WHEN '1' THEN 'Monday'
            WHEN '2' THEN 'Tuesday'
            WHEN '3' THEN 'Wednesday'
            WHEN '4' THEN 'Thursday'
            WHEN '5' THEN 'Friday'
            ELSE 'Saturday'
        END,
        CASE STRFTIME('%m', 'now', 'localtime')
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
            ELSE 'December'
        END,
        CAST(STRFTIME('%Y', 'now', 'localtime') AS INTEGER)
    );

-- =============================================================================
-- Step 2: Handle POST Requests (Saving a Workout)
-- =============================================================================
-- Step 2a: Update User Progression
-- If the RPE was 8 or less, advance the user's progression step and update their 1RM or Max Reps estimate.
UPDATE dimExercisePlan
SET
    currentStepNumber=CASE
        WHEN :action='save_log'
        AND CAST(COALESCE(:rpe_recorded, 0) AS REAL)<=8
        AND currentStepNumber>=(
            SELECT
                MAX(stepNumber)
            FROM
                dimProgressionModelStep
            WHERE
                progressionModelId=dimExercisePlan.progressionModelId
        ) THEN 1
        WHEN :action='save_log'
        AND CAST(COALESCE(:rpe_recorded, 0) AS REAL)<=8 THEN currentStepNumber+1
        ELSE currentStepNumber
    END,
    -- Update 1RM for weight models
    current1rmEstimate=CASE
        WHEN :action='save_log'
        AND CAST(COALESCE(:rpe_recorded, 0) AS REAL)<=8
        AND (
            SELECT
                modelType
            FROM
                dimProgressionModel
            WHERE
                progressionModelId=dimExercisePlan.progressionModelId
        )='weight' THEN
        -- If it's the last step, add 5 lbs to the 1RM estimate
        CASE
            WHEN currentStepNumber>=(
                SELECT
                    MAX(stepNumber)
                FROM
                    dimProgressionModelStep
                WHERE
                    progressionModelId=dimExercisePlan.progressionModelId
            ) THEN COALESCE(current1rmEstimate, :weight_1)+5
            -- Otherwise, calculate a new 1RM from Set 1's performance
            ELSE :weight_1*(1+(:reps_1/30.0))
        END
        ELSE current1rmEstimate
    END,
    -- Update Max Reps for rep-based models
    currentMaxRepsEstimate=CASE
        WHEN :action='save_log'
        AND CAST(COALESCE(:rpe_recorded, 0) AS REAL)<=8
        AND (
            SELECT
                modelType
            FROM
                dimProgressionModel
            WHERE
                progressionModelId=dimExercisePlan.progressionModelId
        )='reps'
        -- This simpler MAX function is cleaner and resolves the syntax error.
        -- It also includes the current value to ensure we only ever increase the max.
        THEN MAX(
            COALESCE(currentMaxRepsEstimate, 0),
            CAST(COALESCE(:reps_1, 0) AS INTEGER),
            CAST(COALESCE(:reps_2, 0) AS INTEGER),
            CAST(COALESCE(:reps_3, 0) AS INTEGER),
            CAST(COALESCE(:reps_4, 0) AS INTEGER),
            CAST(COALESCE(:reps_5, 0) AS INTEGER)
        )
        ELSE currentMaxRepsEstimate
    END
WHERE
    exercisePlanId=:exercise_plan_id
    AND :action='save_log';

-- Step 2b: Delete Existing Sets (for Edits)
-- Using the original_date_id ensures the correct record is removed, even if the date was changed.
DELETE FROM factWorkoutHistory
WHERE
    userId=:user_id
    AND exerciseId=:exercise_id
    AND dateId=:original_date_id
    AND :action='save_log'
    AND :original_date_id IS NOT NULL;

-- Step 2c: Insert New/Updated Sets
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
    REPLACE(:date_id, '-', ''),
    NULLIF(:exercise_plan_id, ''),
    step_data.setNumber,
    step_data.reps,
    COALESCE(step_data.weight, 0),
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
        step_data.reps IS NOT NULL -- The check for weight has been removed
        AND step_data.reps!=''
    );

-- Step 2d: Redirect After Save
SELECT
    'redirect' as component,
    CASE
    -- If a template_id was passed, the user is logging a planned workout from the main page.
        WHEN :template_id IS NOT NULL
        AND :template_id!='' THEN '/index.sql?template_id='||:template_id
        -- Otherwise, the user was editing a log from the history view. Return there.
        ELSE '/views/view_history.sql?edited=true'
    END as link
WHERE
    :action='save_log';

-- =============================================================================
-- Step 3: Handle POST Requests (Deleting a Workout)
-- =============================================================================
-- Step 3a: Revert Progression
-- Before deleting, check if this workout caused a progression and revert it.
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

-- Step 3b: Delete Workout Log
DELETE FROM factWorkoutHistory
WHERE
    userId=:user_id
    AND exerciseId=:exercise_id
    AND dateId=:date_id
    AND :action='delete_log';

-- Step 3c: Redirect After Delete
SELECT
    'redirect' as component,
    '/views/view_history.sql?deleted=true' as link
WHERE
    :action='delete_log';

-- =============================================================================
-- Step 4: Page Rendering on GET Request
-- =============================================================================
-- Step 4a: Load Main Layout
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

-- Step 4b: Fetch Session Data for Editing
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
                'notes',
                MAX(fwh.notes),
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

-- Step 4c: Display Page Header
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

-- Step 4d: Display Main Edit/Create Form
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
    'date' as type,
    'date_id' as name,
    'Workout Date' as label,
    'Choose the date of the workout.' as description,
    COALESCE(
        JSON_EXTRACT($workout_session_data, '$.fullDate'),
        STRFTIME('%Y-%m-%d', 'now', 'localtime')
    ) as value,
    TRUE as required,
    4 as width;

SELECT
    'hidden' as type,
    'original_date_id' as name,
    $date_id as value -- The $date_id from the URL holds the original date
WHERE
    $date_id IS NOT NULL;

SELECT
    'hidden' as type,
    'exercise_plan_id' as name,
    JSON_EXTRACT($workout_session_data, '$.exercisePlanId') as value;

-- If in "Create" mode, show a dropdown to select the exercise.
SELECT
    'select' as type,
    'exercise_id' as name,
    'Select Exercise' as label,
    TRUE as required,
    (
        -- This subquery now manually builds a sorted JSON array
        SELECT
            '['||GROUP_CONCAT(
                '{"label":"'||REPLACE(exerciseName, '"', '\"')||'","value":"'||exerciseId||'"}'
                ORDER BY
                    exerciseName
            )||']'
        FROM
            dimExercise
    ) as options,
    'Select an Exercise' as empty_option
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

-- Step 4e: Display Delete Form (only in "Edit" mode)
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