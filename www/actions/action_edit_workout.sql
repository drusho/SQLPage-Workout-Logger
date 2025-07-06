/**
 * @filename      action_edit_workout.sql
 * @description   A page for managing a workout routine's name, exercises, and progression models.
 * @created       2025-07-06
 * @requires      - layouts/layout_main.sql
 * @requires      - All dim tables.
 * @param         template_id [url] The unique ID of the workout routine to edit.
 * @param         action [form] The action to perform (e.g., remove_exercise, add_exercise, update_progression, update_details).
 */

-- =============================================================================
-- Step 1: Handle all POST actions before rendering the page.
-- =============================================================================
SET current_user_id = (SELECT username FROM sessions WHERE session_token = sqlpage.cookie('session_token'));

-- Action: Update the plan's main details
UPDATE dimExercisePlan SET
    templateName = :new_template_name,
    userTemplateAlias = :user_template_alias
WHERE
    templateId = :template_id AND userId = $current_user_id AND :action = 'update_details';

-- Action: Remove an exercise from the routine
DELETE FROM dimExercisePlan
WHERE
    exercisePlanId = :plan_id AND userId = $current_user_id AND :action = 'remove_exercise';

-- Action: Update the progression model for a single exercise
UPDATE dimExercisePlan SET
    progressionModelId = NULLIF(:progression_model_id, '')
WHERE
    exercisePlanId = :plan_id AND userId = $current_user_id AND :action = 'update_progression';

-- Action: Add a new exercise to the routine
INSERT INTO dimExercisePlan (exercisePlanId, userId, exerciseId, templateName, templateId, isActive, currentStepNumber)
SELECT
    HEX(RANDOMBLOB(16)),
    $current_user_id,
    :exercise_id,
    :template_name,
    :template_id,
    1,
    1
WHERE
    :action = 'add_exercise';

-- After any POST action, redirect back to the same edit page to show the changes
SELECT 'redirect' AS component, '/actions/action_edit_workout.sql?template_id=' || :template_id AS link
WHERE :action IS NOT NULL;


-- =============================================================================
-- Step 2: Render the page content for GET requests.
-- =============================================================================

-- Load layout
SELECT 'dynamic' AS component, sqlpage.run_sql('layouts/layout_main.sql') AS properties;

-- Get the template ID and current name from the URL
SET template_id = $template_id;
SET template_name = (SELECT MIN(templateName) FROM dimExercisePlan WHERE templateId = $template_id);

-- Display page header
SELECT 'text' AS component, 'Edit Routine: ' || $template_name AS title, 3 as level;

-- FORM 1: Edit Routine Name and Alias
SELECT 'form' AS component, 'post' as method, 4 as width;
SELECT 'hidden' AS type, 'action' AS name, 'update_details' AS value;
SELECT 'hidden' AS type, 'template_id' AS name, $template_id AS value;
SELECT 'text' AS type, 'new_template_name' AS name, 'Routine Name' AS label, $template_name AS value;
SELECT 'text' AS type, 'user_template_alias' AS name, 'Alias (Optional)' AS label;



-- Display Exercises in the Routine

-- Fetch all exercises for this routine into a JSON object for easier handling
SET exercises_in_routine = (
    SELECT
        JSON_GROUP_ARRAY(
            JSON_OBJECT(
                'exerciseName', ex.exerciseName,
                'exercisePlanId', plan.exercisePlanId,
                'progressionModelId', plan.progressionModelId
            )
        )
    FROM dimExercisePlan AS plan
    JOIN dimExercise AS ex ON plan.exerciseId = ex.exerciseId
    WHERE plan.userId = $current_user_id AND plan.templateId = $template_id
);

-- Fetch all available progression models for the user
SET available_models = (
    SELECT JSON_GROUP_ARRAY(JSON_OBJECT('label', modelName, 'value', progressionModelId))
    FROM dimProgressionModel
    WHERE userId = $current_user_id
);

SET all_exercises = (
    SELECT JSON_GROUP_ARRAY(JSON_OBJECT('label', exerciseName, 'value', exerciseId))
    FROM dimExercise
    ORDER BY exerciseName
);
SET all_models = (
    SELECT JSON_GROUP_ARRAY(JSON_OBJECT('label', modelName, 'value', progressionModelId))
    FROM dimProgressionModel
    WHERE userId = $current_user_id
    ORDER BY modelName
);


-- Step 3: Use a CTE and UNION ALL to generate all the form fields
WITH exercise_data AS (
    SELECT
        CAST(key AS INTEGER) AS idx,
        value
    FROM
        json_each($exercises_in_routine)
)
-- For each exercise, create a header
SELECT
    idx AS sort_order,
    'header' AS type,
    'Exercise ' || (idx + 1) AS label,
    '' AS name,
    '' AS value,
    '' AS options
FROM
    exercise_data

UNION ALL

-- For each exercise, create a dropdown to select the exercise itself
SELECT
    idx AS sort_order,
    'select' AS type,
    'Exercise' AS label,
    'exercise_id[]' AS name, -- Submit as an array
    json_extract(value, '$.exerciseId') AS value,
    $all_exercises AS options
FROM
    exercise_data

UNION ALL

-- For each exercise, create a dropdown to select the progression model
SELECT
    idx AS sort_order,
    'select' AS type,
    'Progression Model' AS label,
    'progression_model_id[]' AS name, -- Submit as an array
    json_extract(value, '$.progressionModelId') AS value,
    $all_models AS options
FROM
    exercise_data

UNION ALL

-- For each exercise, include a hidden field with its unique plan ID
SELECT
    idx AS sort_order,
    'hidden' AS type,
    '' AS label,
    'plan_id[]' AS name, -- Submit as an array
    json_extract(value, '$.exercisePlanId') AS value,
    '' as options
FROM
    exercise_data

ORDER BY
    sort_order, type DESC;


-- FORM 2: Add a new exercise to the routine
SELECT 'divider' AS component;
SELECT 'form' AS component, 'Add New Exercise to Routine' AS title, 'post' AS method;
SELECT 'hidden' AS type, 'action' AS name, 'add_exercise' AS value;
SELECT 'hidden' AS type, 'template_name' AS name, $template_name AS value;
SELECT 'hidden' AS type, 'template_id' AS name, $template_id AS value;
SELECT 'select' AS type, 'exercise_id' AS name, 'Exercise' AS label, 'Select an exercise' AS empty_option,
    (SELECT JSON_GROUP_ARRAY(JSON_OBJECT('label', exerciseName, 'value', exerciseId)) FROM dimExercise ORDER BY exerciseName) AS options;
