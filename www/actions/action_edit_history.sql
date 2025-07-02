/**
 * @filename      action_edit_history.sql
 * @description   A self-submitting page that allows a user to edit the details of a previously logged workout.
 * It fetches a workout log by its ID and displays the sets, reps, weight, RPE, notes, and progression
 * details in an editable form. It also displays the user's 1-Rep Max history for the exercise.
 * @created       2025-06-30
 * @last-updated  2025-06-30
 * @requires      - layouts/layout_main.sql: Provides the main UI shell and authentication.
 * @requires      - WorkoutLog, WorkoutSetLog, UserExerciseProgression (tables): For reading and writing log/progression data.
 * @requires      - V_Exercise1RM_Chart (view): To display the user's strength progression history.
 * @param         id [url] The LogID of the workout entry to be edited, passed from view_history.sql.
 * @param         action [form] Hidden field with value 'update_log' to trigger the POST logic.
 * @param         log_id [form] Hidden field containing the LogID for the update queries.
 * @param         reps_*, weight_* [form] Dynamically named fields for each set's reps and weight.
 * @param         rpe_recorded [form] The overall RPE for the workout.
 * @param         workout_notes [form] The user-provided notes for the workout.
 * @param         new_step_number [form] The new progression step number for the user's exercise plan.
 * @returns       On a GET request, returns a UI page with a pre-filled form. On a POST request, it processes all
 * updates and redirects the user back to the main workout history page.
 * @see           - /views/view_history.sql: The page that links to this edit page and is the destination after an update.
 * @note          This script follows the Post-Redirect-Get (PRG) pattern. It ensures a minimum of 4 set
 * input rows are displayed, even if the original workout had fewer. The update process
 * completely replaces the old sets with the new data from the form.
 */
------------------------------------------------------
-- STEP 1: Process POST Request (Update the Log)
-- This block executes only when the form is submitted.
------------------------------------------------------
-- 1.1: Update the parent WorkoutLog table with notes
UPDATE WorkoutLog
SET
    WorkoutNotes = :workout_notes,
    ExerciseTimestamp = STRFTIME('%s', :workout_date),
    LastModifiedTimestamp = STRFTIME('%s', 'now')
WHERE
    LogID = :log_id
    AND :action = 'update_log';

-- 1.2: Delete all the old sets for this log entry to prepare for the new ones.
DELETE FROM WorkoutSetLog
WHERE
    LogID = :log_id
    AND :action = 'update_log';

-- 1.3: Insert the newly submitted sets.
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
    :log_id,
    1,
    :reps_1,
    :weight_1,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
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
    :log_id,
    2,
    :reps_2,
    :weight_2,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
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
    :log_id,
    3,
    :reps_3,
    :weight_3,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
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
    :log_id,
    4,
    :reps_4,
    :weight_4,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
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
    :log_id,
    5,
    :reps_5,
    :weight_5,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
    AND :reps_5 IS NOT NULL
    AND :reps_5 != '';

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
    :log_id,
    6,
    :reps_6,
    :weight_6,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
    AND :reps_6 IS NOT NULL
    AND :reps_6 != '';

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
    :log_id,
    7,
    :reps_7,
    :weight_7,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
    AND :reps_7 IS NOT NULL
    AND :reps_7 != '';

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
    :log_id,
    8,
    :reps_8,
    :weight_8,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
    AND :reps_8 IS NOT NULL
    AND :reps_8 != '';

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
    :log_id,
    9,
    :reps_9,
    :weight_9,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
    AND :reps_9 IS NOT NULL
    AND :reps_9 != '';

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
    :log_id,
    10,
    :reps_10,
    :weight_10,
    :rpe_recorded,
    'lbs'
WHERE
    :action = 'update_log'
    AND :reps_10 IS NOT NULL
    AND :reps_10 != '';

-- 1.4: Update the UserExerciseProgression table with the new step number if it was provided
UPDATE UserExerciseProgression
SET
    CurrentStepNumber = :new_step_number
WHERE
    UserID = (
        SELECT
            UserID
        FROM
            WorkoutLog
        WHERE
            LogID = :log_id
    )
    AND ExerciseID = (
        SELECT
            ExerciseID
        FROM
            WorkoutLog
        WHERE
            LogID = :log_id
    )
    AND TemplateID = (
        SELECT
            LinkedTemplateID
        FROM
            WorkoutLog
        WHERE
            LogID = :log_id
    )
    AND :action = 'update_log'
    AND :new_step_number IS NOT NULL
    AND :new_step_number != '';

-- 1.5: After all updates are complete, redirect the user to the history page.
SELECT
    'redirect' AS component,
    '/views/view_history.sql' AS link
WHERE
    :action = 'update_log';

------------------------------------------------------
-- STEP 2: Render Page Skeleton & Get User/Log Data
-- This section runs on the initial GET request to build the page.
------------------------------------------------------
-- 2.1: Include the main layout
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

-- 2.2: Fetch the workout log details, now including progression data
SET
    log_data = COALESCE(
        (
            SELECT
                JSON_OBJECT(
                    'LogID',
                    wl.LogID,
                    'ExerciseID',
                    wl.ExerciseID, -- We need this to filter the chart
                    'ExerciseName',
                    COALESCE(
                        el.ExerciseName,
                        'Unknown Exercise (' || wl.ExerciseID || ')'
                    ),
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
                    ),
                    'CurrentStepNumber',
                    uep.CurrentStepNumber,
                    'CurrentCycle1RMEstimate',
                    uep.CurrentCycle1RMEstimate
                )
            FROM
                WorkoutLog wl
                LEFT JOIN ExerciseLibrary el ON wl.ExerciseID = el.ExerciseID
                LEFT JOIN UserExerciseProgression uep ON wl.UserID = uep.UserID
                AND wl.ExerciseID = uep.ExerciseID
                AND wl.LinkedTemplateID = uep.TemplateID
            WHERE
                wl.LogID = $id
        ),
        '{}'
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
            ORDER BY
                SetNumber
        ),
        '[]'
    );

-- 2.4: Determine the number of set rows to display (minimum of 4)
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

------------------------------------------------------
-- STEP 3: Render the Edit Form
------------------------------------------------------
-- 3.1: Display a header for the page
SELECT
    'alert' AS component,
    'Error: Not Found' AS title,
    'The requested workout log ID could not be found. Please go back to the history page and try again.' AS description,
    'alert-triangle' AS icon,
    'red' AS color
WHERE
    $log_data IS NULL;

SELECT
    'text' AS component,
    '## Edit Exercise Workout Log' AS contents_md;





-- 3.1: Render the main <form> element
SELECT
    'form' AS component,
    'Update Log' AS validate,
    'green' AS validate_color,
    'post' AS method;

-- 3.2: Pass hidden data to the action script on POST
SELECT
    'hidden' AS type,
    'action' AS name,
    'update_log' AS value;

SELECT
    'hidden' AS type,
    'log_id' AS name,
    $id AS value;

SELECT
    'date' AS type,
    '' AS label,
    'workout_date' AS name,
    '' AS prefix,
    'calendar' AS prefix_icon,
    JSON_EXTRACT($log_data, '$.WorkoutDate') AS value,
    '' AS options,
    3 AS width
UNION ALL
SELECT
    'select' AS type,
    '' AS label,
    'workout_exercise' AS name,
    '' AS prefix,
    '' AS prefix_icon,
    JSON_EXTRACT($log_data, '$.ExerciseName') AS value,
    JSON_GROUP_ARRAY(
        JSON_OBJECT('value', ExerciseID, 'label', ExerciseName)
    ) AS options,
    3 AS width
FROM
    ExerciseLibrary;

-- STEP 3.3: Dynamically generate Reps & Weight inputs in a stacked layout
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
    -- Use UNION ALL to create three components per set
SELECT
    set_number,
    1 AS sort_order,
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
    2 AS sort_order, -- Reps input second
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
    3 AS sort_order, -- Weight input third
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
    -- Order by the set number first, then by our custom sort order
ORDER BY
    set_number,
    sort_order;

-- 3.5: Add RPE and Notes inputs to the bottom of the form
SELECT
    'header' AS type,
    'Overall' AS label,
    NULL AS name,
    '' AS prefix,
    '' AS prefix_icon,
    NULL AS value,
    2 AS width
UNION ALL
SELECT
    'number' AS type,
    '' AS label,
    'rpe_recorded' AS name,
    'RPE' AS prefix,
    '' AS prefix_icon,
    JSON_EXTRACT($log_data, '$.RPE') AS value,
    3 AS width
UNION ALL
SELECT
    'number' AS type,
    '' AS label,
    'new_step_number' AS name,
    '' AS prefix,
    'stairs' AS prefix_icon,
    JSON_EXTRACT($log_data, '$.CurrentStepNumber') AS value,
    3 AS width
UNION ALL
-- Workout Notes input
SELECT
    'textarea' AS type,
    'Notes' AS label,
    'workout_notes' AS name,
    '' AS prefix,
    '' AS prefix_icon,
    JSON_EXTRACT($log_data, '$.WorkoutNotes') AS value,
    8 AS width;


