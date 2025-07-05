/**
 * @filename      action_edit_workout.sql
 * @description   A page for managing the exercises and their assigned progression models within a single workout routine.
 * @created       2025-07-04
 * @last-updated  2025-07-04
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - All `dim` tables for fetching and updating plan data.
 * @param         id [url] The exercisePlanId that was clicked to identify the routine.
 * @param         action [form] The action to perform (e.g., 'remove_exercise', 'add_exercise', 'update_progression').
 * @param         plan_id [form] The ID of the exercise plan record to modify or remove.
 * @param         exercise_id [form] The ID of the exercise to add to the routine.
 * @param         progression_model_id [form] The ID of the progression model to assign.
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

-- Step 2: Handle all incoming form actions BEFORE rendering any page content.
-- Action to remove an exercise from the routine.
DELETE FROM dimExercisePlan
WHERE
    exercisePlanId=:plan_id
    AND userId=$current_user_id
    AND :action='remove_exercise';

-- Action to add a new exercise to the routine.
INSERT INTO
    dimExercisePlan (
        exercisePlanId,
        userId,
        exerciseId,
        templateName,
        isActive,
        currentStepNumber
    )
SELECT
    HEX(RANDOMBLOB(16)),
    $current_user_id,
    :exercise_id,
    :template_name,
    1,
    1
WHERE
    :action='add_exercise';

-- Action to update the assigned progression model for an exercise.
UPDATE dimExercisePlan
SET
    progressionModelId=:progression_model_id
WHERE
    exercisePlanId=:plan_id
    AND userId=$current_user_id
    AND :action='update_progression';

-- After any action, redirect back to the correct edit page using the plan_id to find the template name.
SET
    redirect_template_name=(
        SELECT
            templateName
        FROM
            dimExercisePlan
        WHERE
            exercisePlanId=:plan_id
    );

-- SELECT
--     'redirect' as component,
--     FORMAT(
--         '/actions/action_edit_workout.sql?template_name=%s',
--         $redirect_template_name
--     ) as link
-- WHERE
--     :action IS NOT NULL;

-- Step 3: Load layout and get the template name from the URL ID.
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

SET
    template_name=(
        SELECT
            templateName
        FROM
            dimExercisePlan
        WHERE
            exercisePlanId=$id
            AND userId=$current_user_id
    );

-- Step 4: Validate that a valid routine was found for the user.
-- SELECT
--     'redirect' as component,
--     '/views/view_workouts.sql?error=Routine+not+found' as link
-- WHERE
--     $template_name IS NULL;

-- Step 5: Display the page header.
SELECT
    'text' as component,
    'Edit Routine: '||$template_name as title;

SELECT
    'text' as component,
    'Assign a progression model to each exercise in this routine.' as description;

-- Step 6: Fetch all exercises for this routine to render them dynamically.
SET
    exercises_in_routine=(
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT(
                    'exerciseName',
                    ex.exerciseName,
                    'exercisePlanId',
                    plan.exercisePlanId,
                    'progressionModelId',
                    plan.progressionModelId,
                    'progressionModelName',
                    COALESCE(pm.modelName, 'None Assigned')
                )
            )
        FROM
            dimExercisePlan AS plan
            JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
            LEFT JOIN dimProgressionModel AS pm ON plan.progressionModelId=pm.progressionModelId
        WHERE
            plan.userId=$current_user_id
            AND plan.templateName=$template_name
    );

-- Step 7: Use a dynamic component to render a form for each exercise.
SELECT
    'dynamic' as component,
    'views/edit_workout_item.sql' as item_component,
    $exercises_in_routine as properties;

-- Step 8: Display a form to add a new exercise to the routine.
SELECT
    'divider' as component;

SELECT
    'form' as component,
    'Add Exercise to Routine' as title,
    'post' as method;

SELECT
    'hidden' as type,
    'template_name' as name,
    $template_name as value;

SELECT
    'hidden' as type,
    'action' as name,
    'add_exercise' as value;

SELECT
    'select' as type,
    'exercise_id' as name,
    'Select an Exercise' as label,
    'Choose an exercise to add' as placeholder,
    TRUE as required,
    TRUE as searchable,
    (
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT('label', exerciseName, 'value', exerciseId)
            )
        FROM
            dimExercise
        ORDER BY
            exerciseName
    ) as options;

SELECT
    'submit' as component,
    'Add Exercise' as title;
