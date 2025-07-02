/**
 * @filename      action_edit_history.sql
 * @description   A self-submitting page that allows a user to create a new workout log or edit the details of a previously logged one.
 * @created       2025-06-30
 * @last-updated  2025-07-01
 * @requires      - layouts/layout_main.sql: Provides the main UI shell and authentication.
 * @requires      - WorkoutLog, WorkoutSetLog, UserExerciseProgression (tables): For reading and writing log/progression data.
 * @param         id [url, optional] The LogID of the workout entry to be edited. If absent, the page enters "create" mode.
 * @param         action [form] Hidden field with value 'update_log' or 'insert_log' to trigger the POST logic.
 * @param         log_id [form] Hidden field containing the LogID for the update queries.
 * @param         workout_exercise [form] The ExerciseID for the log.
 * @param         reps_*, weight_* [form] Dynamically named fields for each set's reps and weight.
 * @param         rpe_recorded [form] The overall RPE for the workout.
 * @param         workout_notes [form] The user-provided notes for the workout.
 * @param         new_step_number [form] The new progression step number for the user's exercise plan.
 * @returns       On a GET request, returns a UI page with a form (either blank or pre-filled). On a POST request, it processes all
 * updates/inserts and redirects the user back to the main workout history page.
 * @see           - /views/view_history.sql: The page that links to this page and is the destination after an action.
 * @note          This script follows the Post-Redirect-Get (PRG) pattern. It ensures a minimum of 5 set
 * input rows are displayed. The update process completely replaces the old sets with the new data from the form.
 */
------------------------------------------------------
-- STEP 0: Authentication Guard
------------------------------------------------------
SET
    current_user = (
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token = sqlpage.cookie ('session_token')
    );

SELECT
    'redirect' AS component,
    '/auth/auth_guest_prompt.sql' AS link
WHERE
    $current_user IS NULL;

------------------------------------------------------
-- STEP 1: Process POST Request (Create or Update Log)
------------------------------------------------------
-- STEP 1.1: Determine the Target Log ID
SET
    target_log_id = (
        SELECT
            CASE
                WHEN :action = 'insert_log' THEN LOWER(HEX(RANDOMBLOB(16)))
                ELSE :log_id
            END
    );

-- STEP 1.2: Handle INSERT for a new log
-- This now uses the reliable $target_log_id variable.
INSERT INTO
    WorkoutLog (
        LogID,
        UserID,
        ExerciseTimestamp,
        ExerciseID,
        WorkoutNotes,
        LastModifiedTimestamp
    )
SELECT
    $target_log_id,
    $current_user,
    STRFTIME('%s', :workout_date),
    :workout_exercise,
    :workout_notes,
    STRFTIME('%s', 'now')
WHERE
    :action = 'insert_log';

-- STEP 1.3: Handle UPDATE for an existing log
-- This also uses the reliable $target_log_id variable.
UPDATE WorkoutLog
SET
    WorkoutNotes = :workout_notes,
    ExerciseID = :workout_exercise,
    ExerciseTimestamp = STRFTIME('%s', :workout_date),
    LastModifiedTimestamp = STRFTIME('%s', 'now')
WHERE
    LogID = $target_log_id
    AND :action = 'update_log';

-- STEP 1.4: Delete old sets if we are updating an existing log
DELETE FROM WorkoutSetLog
WHERE
    LogID = $target_log_id
    AND :action = 'update_log';

-- STEP 1.5: Insert the newly submitted sets for both INSERT and UPDATE actions
-- This block remains the same, but it now uses the consistently defined $target_log_id.
INSERT INTO
    WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed,
        RPE_Recorded,
        WeightUnit
    )
SELECT
    LOWER(HEX(RANDOMBLOB(16))),
    $target_log_id,
    1,
    :reps_1,
    :weight_1,
    :rpe_recorded,
    'lbs'
WHERE
    (
        :action = 'update_log'
        OR :action = 'insert_log'
    )
    AND :reps_1 IS NOT NULL
    AND :reps_1 != '';

INSERT INTO
    WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed,
        RPE_Recorded,
        WeightUnit
    )
SELECT
    LOWER(HEX(RANDOMBLOB(16))),
    $target_log_id,
    2,
    :reps_2,
    :weight_2,
    :rpe_recorded,
    'lbs'
WHERE
    (
        :action = 'update_log'
        OR :action = 'insert_log'
    )
    AND :reps_2 IS NOT NULL
    AND :reps_2 != '';

INSERT INTO
    WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed,
        RPE_Recorded,
        WeightUnit
    )
SELECT
    LOWER(HEX(RANDOMBLOB(16))),
    $target_log_id,
    3,
    :reps_3,
    :weight_3,
    :rpe_recorded,
    'lbs'
WHERE
    (
        :action = 'update_log'
        OR :action = 'insert_log'
    )
    AND :reps_3 IS NOT NULL
    AND :reps_3 != '';

INSERT INTO
    WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed,
        RPE_Recorded,
        WeightUnit
    )
SELECT
    LOWER(HEX(RANDOMBLOB(16))),
    $target_log_id,
    4,
    :reps_4,
    :weight_4,
    :rpe_recorded,
    'lbs'
WHERE
    (
        :action = 'update_log'
        OR :action = 'insert_log'
    )
    AND :reps_4 IS NOT NULL
    AND :reps_4 != '';

INSERT INTO
    WorkoutSetLog (
        SetID,
        LogID,
        SetNumber,
        RepsPerformed,
        WeightUsed,
        RPE_Recorded,
        WeightUnit
    )
SELECT
    LOWER(HEX(RANDOMBLOB(16))),
    $target_log_id,
    5,
    :reps_5,
    :weight_5,
    :rpe_recorded,
    'lbs'
WHERE
    (
        :action = 'update_log'
        OR :action = 'insert_log'
    )
    AND :reps_5 IS NOT NULL
    AND :reps_5 != '';

-- STEP 1.6: After all actions, redirect the user to the history page.
SELECT
    'redirect' AS component,
    '/views/view_history.sql?saved=true' AS link
WHERE
    :action = 'update_log'
    OR :action = 'insert_log';

------------------------------------------------------------------------------------------------------------
-- STEP 2: Render Page Skeleton & Get User/Log Data
------------------------------------------------------
-- 2.1: Include the main layout
-- STEP 2.1: Include the main layout
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties
WHERE
    :action IS NULL;

-- 2.2: Fetch the workout log details, defaulting to a new, empty log if no ID is provided
SET
    log_data = COALESCE(
        (
            SELECT
                JSON_OBJECT(
                    'LogID',
                    wl.LogID,
                    'ExerciseID',
                    wl.ExerciseID,
                    'ExerciseName',
                    el.ExerciseName,
                    'WorkoutDate',
                    STRFTIME('%Y-%m-%d', wl.ExerciseTimestamp, 'unixepoch'),
                    'WorkoutNotes',
                    wl.WorkoutNotes,
                    'RPE',
                    (
                        SELECT
                            RPE_Recorded
                        FROM
                            WorkoutSetLog
                        WHERE
                            LogID = wl.LogID
                        LIMIT
                            1
                    )
                )
            FROM
                WorkoutLog wl
                LEFT JOIN ExerciseLibrary el ON wl.ExerciseID = el.ExerciseID
            WHERE
                wl.LogID = $id
        ),
        JSON_OBJECT('WorkoutDate', STRFTIME('%Y-%m-%d', 'now'))
    );

-- 2.3: Fetch the existing sets for this log into a variable
SET
    existing_sets = COALESCE(
        (
            SELECT
                JSON_GROUP_ARRAY(
                    JSON_OBJECT(
                        'SetNumber',
                        SetNumber,
                        'Reps',
                        RepsPerformed,
                        'Weight',
                        WeightUsed
                    )
                )
            FROM
                WorkoutSetLog
            WHERE
                LogID = $id
                -- ORDER BY
                --     SetNumber
        ),
        '[]'
    );

-- 2.4: Determine the number of set rows to display (minimum of 5)
SET
    num_rows_to_display = (
        SELECT
            MAX(cnt)
        FROM
            (
                SELECT
                    4 AS cnt
                UNION ALL
                SELECT
                    JSON_ARRAY_LENGTH($existing_sets) AS cnt
            )
    );

-- 2.5 Set Page properties
SET
    page_title = CASE
        WHEN $id IS NULL THEN 'Add'
        ELSE 'Edit'
    END || ' Workout Log';

SET
    form_action = 'action_edit_history.sql' || CASE
        WHEN $id IS NOT NULL THEN '?id=' || $id
        ELSE ''
    END;

SET
    action_verb = CASE
        WHEN $id IS NULL THEN 'insert_log'
        ELSE 'update_log'
    END;

SET
    button_text = CASE
        WHEN $id IS NULL THEN 'Add Log'
        ELSE 'Update Log'
    END;

------------------------------------------------------
-- STEP 3: Render the Edit/Add Form
------------------------------------------------------
SELECT
    'text' AS component,
    $page_title AS title
WHERE
    :action IS NULL;

SELECT
    'form' AS component,
    $button_text AS validate,
    'green' AS validate_color,
    'post' AS method,
    $form_action AS ACTION
WHERE
    :action IS NULL;

-- Hidden fields to manage state
SELECT
    'hidden' AS type,
    'action' AS name,
    $action_verb AS value
WHERE
    :action IS NULL;

SELECT
    'hidden' AS type,
    'log_id' AS name,
    $id AS value
WHERE
    :action IS NULL;

-- Date and Exercise Selection
SELECT
    'date' AS type,
    '' AS label,
    'workout_date' AS name,
    'calendar' AS prefix_icon,
    JSON_EXTRACT($log_data, '$.WorkoutDate') AS value,
    '' AS options,
    3 AS width
UNION ALL
SELECT
    'select' AS type,
    '' AS label,
    'workout_exercise' AS name,
    '' AS prefix_icon,
    JSON_EXTRACT($log_data, '$.ExerciseID') AS value,
    JSON_GROUP_ARRAY(
        JSON_OBJECT('value', ExerciseID, 'label', ExerciseAlias)
    ) AS options,
    4 AS width
FROM
    ExerciseLibrary
WHERE
    IsEnabled = 1
    -- ORDER BY
    --     ExerciseName
;

-- Dynamically generate Reps & Weight inputs
WITH RECURSIVE
    series (set_number) AS (
        SELECT
            1
        UNION ALL
        SELECT
            set_number + 1
        FROM
            series
        WHERE
            set_number < $num_rows_to_display
    )
SELECT
    set_number,
    1 AS sort,
    'header' AS type,
    'Set ' || set_number AS label,
    NULL AS name,
    NULL AS prefix,
    '' AS prefix_icon,
    NULL AS value,
    2 AS width
FROM
    series
UNION ALL
SELECT
    set_number,
    2 AS sort,
    'number' AS type,
    '' AS label,
    'reps_' || set_number AS name,
    'Reps:' AS prefix,
    '' AS prefix_icon,
    JSON_EXTRACT(
        $existing_sets,
        '$[' || (set_number - 1) || '].Reps'
    ) AS value,
    3 AS width
FROM
    series
UNION ALL
SELECT
    set_number,
    3 AS sort,
    'number' AS type,
    '' AS label,
    'weight_' || set_number AS name,
    '' AS prefix,
    'weight' AS prefix_icon,
    JSON_EXTRACT(
        $existing_sets,
        '$[' || (set_number - 1) || '].Weight'
    ) AS value,
    3 AS width
FROM
    series
ORDER BY
    set_number,
    sort;

-- RPE and Notes
SELECT
    'header' AS type,
    'Overall' AS label,
    '' AS name,
    '' AS prefix,
    NULL AS value,
    2 AS width
UNION ALL
SELECT
    'number' AS type,
    '' AS label,
    'rpe_recorded' AS name,
    'RPE' AS prefix,
    JSON_EXTRACT($log_data, '$.RPE') AS value,
    3 AS width
UNION ALL
SELECT
    'textarea' AS type,
    'Notes' AS label,
    'workout_notes' AS name,
    '' AS prefix,
    JSON_EXTRACT($log_data, '$.WorkoutNotes') AS value,
    4 AS width;

-- Delete button (only in edit mode)
SELECT
    'divider' AS component
WHERE
    $id IS NOT NULL;

SELECT
    'button' AS component,
    'md' AS size
WHERE
    $id IS NOT NULL
    AND :action IS NULL;

SELECT
    '/actions/action_delete_history.sql?id=' || $id AS link,
    'red' AS color,
    'Delete Workout' AS title,
    'trash' AS icon
WHERE
    $id IS NOT NULL;