/**
 * @filename      action_edit_workout.sql
 * @description   Manages a workout routine. A single form is used to edit all exercises in the plan at once,
 * with separate forms for updating the plan's name and adding new exercises.
 * @created       2025-07-06
 * @last-updated  2025-07-07
 * @requires      - layouts/layout_main.sql, All dim tables.
 * @param         template_id [url] The unique ID of the workout routine to edit.
 * @param         action [form] The server-side action to perform, e.g., 'update_all_exercises', 'update_details', 'add_exercise'.
 */

-- =============================================================================
-- Step 1: Handle all POST actions before rendering the page.
-- =============================================================================

SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

INSERT INTO
    dimExercisePlan (
        exercisePlanId,
        userId,
        exerciseId,
        templateName,
        templateId,
        isActive,
        currentStepNumber
    )
SELECT
    HEX(RANDOMBLOB(16)),
    $current_user_id,
    :exercise_id,
    -- This subquery makes the INSERT self-reliant and robust
    (
        SELECT
            MIN(T.templateName)
        FROM
            dimExercisePlan T
        WHERE
            T.templateId=:template_id
    ),
    :template_id,
    1,
    1
WHERE
    :action='add_exercise';

-- Step 1a: Handle Deletions. This runs if any "Mark for Deletion" boxes were checked.
-- First, safely unlink any workout history from the plan entries we are about to delete.
UPDATE factWorkoutHistory
SET
    exercisePlanId=NULL
WHERE
    :action='update_all_exercises'
    AND :delete_plan_id IS NOT NULL
    AND exercisePlanId IN (
        SELECT
            value
        FROM
            JSON_EACH(:delete_plan_id)
    );

-- Second, now that they are unlinked, delete the exercise entries from the plan.
DELETE FROM dimExercisePlan
WHERE
    :action='update_all_exercises'
    AND :delete_plan_id IS NOT NULL
    AND exercisePlanId IN (
        SELECT
            value
        FROM
            JSON_EACH(:delete_plan_id)
    );

-- Step 1b: Handle Updates using the "delete-and-replace" strategy.
-- This will now ignore any exercises that were marked for deletion.
REPLACE INTO
    dimExercisePlan (
        exercisePlanId,
        exerciseId,
        progressionModelId,
        -- Preserved Values
        userId,
        isActive,
        currentStepNumber,
        templateId,
        templateName,
        userTemplateAlias,
        current1rmEstimate,
        targetSets,
        targetReps
    )
WITH RECURSIVE
    Cte (idx) AS (
        VALUES
            (0)
        UNION ALL
        SELECT
            idx+1
        FROM
            Cte
        WHERE
            idx+1<JSON_ARRAY_LENGTH(:plan_id)
    )
SELECT
    JSON_EXTRACT(:plan_id, '$['||Cte.idx||']') AS exercisePlanId,
    JSON_EXTRACT(:exercise_id, '$['||Cte.idx||']') AS exerciseId,
    NULLIF(
        JSON_EXTRACT(:progression_model_id, '$['||Cte.idx||']'),
        ''
    ) AS progressionModelId,
    $current_user_id AS userId,
    (
        SELECT
            T.isActive
        FROM
            dimExercisePlan T
        WHERE
            T.exercisePlanId=JSON_EXTRACT(:plan_id, '$['||Cte.idx||']')
    ) AS isActive,
    (
        SELECT
            T.currentStepNumber
        FROM
            dimExercisePlan T
        WHERE
            T.exercisePlanId=JSON_EXTRACT(:plan_id, '$['||Cte.idx||']')
    ) AS currentStepNumber,
    :template_id AS templateId,
    (
        SELECT
            T.templateName
        FROM
            dimExercisePlan T
        WHERE
            T.exercisePlanId=JSON_EXTRACT(:plan_id, '$['||Cte.idx||']')
    ) AS templateName,
    (
        SELECT
            T.userTemplateAlias
        FROM
            dimExercisePlan T
        WHERE
            T.exercisePlanId=JSON_EXTRACT(:plan_id, '$['||Cte.idx||']')
    ) AS userTemplateAlias,
    (
        SELECT
            T.current1rmEstimate
        FROM
            dimExercisePlan T
        WHERE
            T.exercisePlanId=JSON_EXTRACT(:plan_id, '$['||Cte.idx||']')
    ) AS current1rmEstimate,
    (
        SELECT
            T.targetSets
        FROM
            dimExercisePlan T
        WHERE
            T.exercisePlanId=JSON_EXTRACT(:plan_id, '$['||Cte.idx||']')
    ) AS targetSets,
    (
        SELECT
            T.targetReps
        FROM
            dimExercisePlan T
        WHERE
            T.exercisePlanId=JSON_EXTRACT(:plan_id, '$['||Cte.idx||']')
    ) AS targetReps
FROM
    Cte
WHERE
    :action='update_all_exercises'
    -- This condition ensures we only UPDATE exercises that were NOT marked for deletion
    AND (
        :delete_plan_id IS NULL
        OR JSON_EXTRACT(:plan_id, '$['||Cte.idx||']') NOT IN (
            SELECT
                value
            FROM
                JSON_EACH(:delete_plan_id)
        )
    );

-- =============================================================================
-- Step 2: Render the page content for GET requests.
-- =============================================================================
-- Load layout and set variables
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

SET
    template_id=$template_id;

SET
    template_name=(
        SELECT
            MIN(templateName)
        FROM
            dimExercisePlan
        WHERE
            templateId=$template_id
    );

-- Step 2b: Display page header
SELECT
    'text' AS component,
    'Edit Routine: '||$template_name AS title,
    3 as level;

-- Step 2c: Render the form for editing the routine's name
SELECT
    'form' AS component,
    'post' as method,
    'Save Name' as validate,
    4 as width;

SELECT
    'hidden' AS type,
    'action' AS name,
    'update_details' AS value;

SELECT
    'hidden' AS type,
    'template_id' AS name,
    $template_id AS value;

SELECT
    'text' AS type,
    'new_template_name' AS name,
    'Routine Name' AS label,
    $template_name AS value;

-- Step 2d: Prepare data for the main exercise form dropdowns
SET exercises_in_routine = (
    SELECT JSON_GROUP_ARRAY( JSON_OBJECT( 'exerciseName', ex.exerciseName, 'exercisePlanId', plan.exercisePlanId, 'progressionModelId', plan.progressionModelId, 'exerciseId', plan.exerciseId ))
    FROM dimExercisePlan AS plan JOIN dimExercise AS ex ON plan.exerciseId = ex.exerciseId
    WHERE plan.userId = $current_user_id AND plan.templateId = $template_id
);


SET all_exercises = (
    SELECT
        '[' || GROUP_CONCAT(
            -- Manually create a JSON object string for each row
            '{"label":"' || REPLACE(exerciseName, '"', '\"') || '","value":"' || exerciseId || '"}'
            -- This ORDER BY works inside GROUP_CONCAT
            ORDER BY exerciseName
        ) || ']'
    FROM
        dimExercise
);


SET all_models = (
    SELECT
        '[' || GROUP_CONCAT(
            '{"label":"' || REPLACE(modelName, '"', '\"') || '","value":"' || progressionModelId || '"}'
            ORDER BY modelName
        ) || ']'
    FROM
        dimProgressionModel
    WHERE
        userId = $current_user_id
);

-- Step 2e: Render the main form for editing all exercises
SELECT
    'form' AS component,
    'post' AS method,
    'Save All Changes' AS validate,
    'green' AS validate_color;

-- Hidden fields for the overall form
SELECT
    'hidden' AS type,
    'action' AS name,
    'update_all_exercises' AS value;

SELECT
    'hidden' AS type,
    'template_id' AS name,
    $template_id AS value;

-- Generate the form fields for each exercise using the recursive CTE
WITH RECURSIVE
    exercise_loop (idx) AS (
        VALUES
            (0)
        UNION ALL
        SELECT
            idx+1
        FROM
            exercise_loop
        WHERE
            idx+1<JSON_ARRAY_LENGTH($exercises_in_routine)
    )
    -- Header row
SELECT
    idx AS sort_order,
    1 as sub_order,
    'header' AS type,
    'Exercise '||(idx+1) AS label,
    '' AS name,
    '' AS value,
    '' AS options,
    '' as empty_option
FROM
    exercise_loop
UNION ALL
-- Dropdown to select the exercise
SELECT
    idx AS sort_order,
    2 AS sub_order,
    'select' AS type,
    'Exercise' AS label,
    'exercise_id[]' AS name,
    JSON_EXTRACT($exercises_in_routine, '$['||idx||'].exerciseId') AS value,
    $all_exercises AS options,
    'Select an exercise' as empty_option
FROM
    exercise_loop
UNION ALL
-- Dropdown to select the progression model
SELECT
    idx AS sort_order,
    3 AS sub_order,
    'select' AS type,
    'Progression Model' AS label,
    'progression_model_id[]' AS name,
    JSON_EXTRACT(
        $exercises_in_routine,
        '$['||idx||'].progressionModelId'
    ) AS value,
    $all_models AS options,
    'Select a progression model' as empty_option
FROM
    exercise_loop
UNION ALL
-- Hidden field with the unique plan ID for this exercise entry
SELECT
    idx AS sort_order,
    4 AS sub_order,
    'hidden' AS type,
    '' AS label,
    'plan_id[]' AS name,
    JSON_EXTRACT(
        $exercises_in_routine,
        '$['||idx||'].exercisePlanId'
    ) AS value,
    '' as options,
    '' as empty_option
FROM
    exercise_loop
UNION ALL
-- Step 2a: Add a checkbox for marking an exercise for deletion
SELECT
    idx AS sort_order,
    5 AS sub_order,
    'checkbox' AS type,
    'Mark for Deletion' AS label,
    'delete_plan_id[]' AS name,
    JSON_EXTRACT(
        $exercises_in_routine,
        '$['||idx||'].exercisePlanId'
    ) AS value,
    '' as options,
    '' as empty_option
FROM
    exercise_loop
ORDER BY
    sort_order,
    sub_order;

-- Step 2f: Render the form for adding a new exercise to the routine
SELECT
    'divider' AS component;

SELECT
    'form' AS component,
    'Add New Exercise' AS title,
    'post' AS method,
    'Add Exercise' AS validate;

SELECT
    'hidden' AS type,
    'action' AS name,
    'add_exercise' AS value;

SELECT
    'hidden' AS type,
    'template_name' AS name,
    $template_name AS value;

SELECT
    'hidden' AS type,
    'template_id' AS name,
    $template_id AS value;

-- This select component was missing from your file.
-- It provides the dropdown menu for selecting a new exercise.
SELECT
    'select' AS type,
    'exercise_id' AS name,
    'Exercise' AS label,
    'Select an exercise' AS empty_option,
    $all_exercises as options;