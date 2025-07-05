/**
 * @filename      action_edit_progression_step.sql
 * @description   A self-submitting page for bulk editing all steps of a single progression model.
 * @created       2025-07-04
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - `dimProgressionModel`, `dimProgressionModelStep`, `sessions` tables.
 * @param         model_id [url] The ID of the progression model whose steps are being edited.
 * @param         num_steps [url, optional] The number of step rows to display in the editor.
 * @param         action [form] The action to perform (e.g., 'save_steps').
 */
-- Step 1: Get current user ID and the model ID from the URL.
SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

SET
    model_id=$model_id;

-- Step 2: Handle the form submission to save all steps.
-- This uses a "delete and replace" strategy for simplicity and robustness.
DELETE FROM dimProgressionModelStep
WHERE
    progressionModelId=:model_id
    AND :action='save_steps';

-- UPDATED: This single INSERT statement replaces the 20 repetitive ones.
-- It uses UNION ALL to combine all form data into a single source, then inserts
-- only the rows where at least one value was provided.
INSERT INTO
    dimProgressionModelStep (
        progressionModelStepId,
        progressionModelId,
        stepNumber,
        description,
        targetSets,
        targetReps,
        percentOfMax
    )
SELECT
    HEX(RANDOMBLOB(16)),
    :model_id,
    step_data.stepNumber,
    step_data.description,
    step_data.sets,
    step_data.reps,
    step_data.percent
FROM
    (
        SELECT
            1 AS stepNumber,
            :description_1 AS description,
            :sets_1 AS sets,
            :reps_1 AS reps,
            :percent_1 AS percent
        UNION ALL
        SELECT
            2,
            :description_2,
            :sets_2,
            :reps_2,
            :percent_2
        UNION ALL
        SELECT
            3,
            :description_3,
            :sets_3,
            :reps_3,
            :percent_3
        UNION ALL
        SELECT
            4,
            :description_4,
            :sets_4,
            :reps_4,
            :percent_4
        UNION ALL
        SELECT
            5,
            :description_5,
            :sets_5,
            :reps_5,
            :percent_5
        UNION ALL
        SELECT
            6,
            :description_6,
            :sets_6,
            :reps_6,
            :percent_6
        UNION ALL
        SELECT
            7,
            :description_7,
            :sets_7,
            :reps_7,
            :percent_7
        UNION ALL
        SELECT
            8,
            :description_8,
            :sets_8,
            :reps_8,
            :percent_8
        UNION ALL
        SELECT
            9,
            :description_9,
            :sets_9,
            :reps_9,
            :percent_9
        UNION ALL
        SELECT
            10,
            :description_10,
            :sets_10,
            :reps_10,
            :percent_10
        UNION ALL
        SELECT
            11,
            :description_11,
            :sets_11,
            :reps_11,
            :percent_11
        UNION ALL
        SELECT
            12,
            :description_12,
            :sets_12,
            :reps_12,
            :percent_12
        UNION ALL
        SELECT
            13,
            :description_13,
            :sets_13,
            :reps_13,
            :percent_13
        UNION ALL
        SELECT
            14,
            :description_14,
            :sets_14,
            :reps_14,
            :percent_14
        UNION ALL
        SELECT
            15,
            :description_15,
            :sets_15,
            :reps_15,
            :percent_15
        UNION ALL
        SELECT
            16,
            :description_16,
            :sets_16,
            :reps_16,
            :percent_16
        UNION ALL
        SELECT
            17,
            :description_17,
            :sets_17,
            :reps_17,
            :percent_17
        UNION ALL
        SELECT
            18,
            :description_18,
            :sets_18,
            :reps_18,
            :percent_18
        UNION ALL
        SELECT
            19,
            :description_19,
            :sets_19,
            :reps_19,
            :percent_19
        UNION ALL
        SELECT
            20,
            :description_20,
            :sets_20,
            :reps_20,
            :percent_20
    ) AS step_data
WHERE
    :action='save_steps'
    AND (
        step_data.description IS NOT NULL
        OR step_data.sets IS NOT NULL
        OR step_data.reps IS NOT NULL
        OR step_data.percent IS NOT NULL
    );

-- After saving, redirect back to the main model editor page with a success message.
SELECT
    'redirect' as component,
    FORMAT(
        '/actions/action_edit_progression_model.sql?id=%s&message=Progression+steps+saved.',
        :model_id
    ) as link
WHERE
    :action='save_steps';

-- =============================================================================
-- Page Rendering Logic (only runs on GET requests)
-- =============================================================================
-- Step 3: Load the main layout and validate the model ID.
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

SET
    model=(
        SELECT
            JSON_OBJECT('modelName', modelName)
        FROM
            dimProgressionModel
        WHERE
            progressionModelId=$model_id
            AND userId=$current_user_id
    );

SELECT
    'redirect' as component,
    '/views/view_progression_models.sql?error=Model+not+found' as link
WHERE
    $model IS NULL;

-- Step 4: Display the page header.
SELECT
    'text' as component,
    'Edit Steps for: '||JSON_EXTRACT($model, '$.modelName') as title;

-- Step 5: Fetch all existing steps for this model into a JSON object and count them.
SET
    existing_steps_data=(
        SELECT
            JSON_OBJECT(
                'steps',
                COALESCE(
                    JSON_GROUP_OBJECT(
                        'step_'||stepNumber,
                        JSON_OBJECT(
                            'description',
                            description,
                            'sets',
                            targetSets,
                            'reps',
                            targetReps,
                            'percent',
                            percentOfMax
                        )
                    ),
                    '{}'
                ),
                'count',
                COUNT(progressionModelStepId)
            )
        FROM
            dimProgressionModelStep
        WHERE
            progressionModelId=$model_id
    );

SET
    existing_steps=JSON_EXTRACT($existing_steps_data, '$.steps');

SET
    existing_step_count=JSON_EXTRACT($existing_steps_data, '$.count');

-- Step 6: Display a form to control the number of steps shown.
SELECT
    'form' as component,
    'get' as method,
    'true' as auto_submit;

SELECT
    'number' as type,
    'num_steps' as name,
    'Number of Steps to Display:' as label,
    COALESCE($num_steps, $existing_step_count, 12) as value;

-- Step 7: Display the bulk editor form, but only if the user has specified a number of steps.
SELECT
    'form' as component,
    'post' as method,
    'green' as validate_color,
    'Save Steps' as validate
WHERE
    $num_steps IS NOT NULL;

SELECT
    'hidden' as type,
    'action' as name,
    'save_steps' as value;

SELECT
    'hidden' as type,
    'model_id' as name,
    $model_id as value;

-- Use a recursive query to generate the requested number of step rows.
WITH RECURSIVE
    series (steps) AS (
        VALUES
            (1)
        UNION ALL
        SELECT
            steps+1
        FROM
            series
        WHERE
            steps<$num_steps
    )
SELECT
    '' as step,
    steps,
    'header' as type,
    '' as name,
    'Step '||steps as label,
    '' as prefix,
    '' as value,
    10 as width
FROM
    series
where
    $num_steps IS NOT NULL
UNION ALL
SELECT
    1 as step,
    steps,
    'number' as type,
    'sets_'||steps as name,
    '' as label,
    'Sets' as prefix,
    JSON_EXTRACT($existing_steps, '$.step_'||steps||'.sets') as value,
    3 as width
FROM
    series
where
    $num_steps IS NOT NULL
UNION ALL
SELECT
    1 as step,
    steps,
    'number' as type,
    'reps_'||steps as name,
    -- 'Reps' as label,
    ' ' as label,
    'Reps' as prefix,
    JSON_EXTRACT($existing_steps, '$.step_'||steps||'.reps') as value,
    3 as width
FROM
    series
where
    $num_steps IS NOT NULL
UNION ALL
SELECT
    0.01 as step,
    steps,
    'number' as type,
    'percent_'||steps as name,
    -- '% of Max' as label,
    '' as label,
    '% of Max' as prefix,
    JSON_EXTRACT($existing_steps, '$.step_'||steps||'.percent') as value,
    3 as width
FROM
    series
where
    $num_steps IS NOT NULL
UNION ALL
SELECT
    '' as step,
    steps,
    'text' as type,
    'description_'||steps as name,
    -- 'Step '||step||' Description' as label,
    '' as label,
    'Description' as prefix,
    JSON_EXTRACT(
        $existing_steps,
        '$.step_'||steps||'.description'
    ) as value,
    9 as width
FROM
    series
where
    $num_steps IS NOT NULL
ORDER BY
    steps;
