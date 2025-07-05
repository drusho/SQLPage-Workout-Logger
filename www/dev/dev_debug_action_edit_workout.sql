SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

-- Step 1: Get current user ID. This is needed for all subsequent operations.
SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

-- Step 2: Use the 'id' from the URL to find the templateName for the selected routine.
SET
    routine_template_name=(
        SELECT
            templateName
        FROM
            dimExercisePlan
        WHERE
            exercisePlanId=$id
            AND userId=$current_user_id
    );

-- Step 3: Display the main debugging variables.
SELECT
    'card' as component,
    1 as "width-sm";

SELECT
    'Validation Debugger' as title,
    'bug' as icon,
    'red' as color;

SELECT
    'list' as component;

SELECT
    'URL Parameter ($id)' as title,
    COALESCE($id, 'NULL') as description;

SELECT
    'Session User ID ($current_user_id)' as title,
    COALESCE($current_user_id, 'NULL (Not Logged In)') as description;

SELECT
    'Template Name Found' as title,
    COALESCE(
        $routine_template_name,
        'NULL (No routine found for this ID and User)'
    ) as description;

-- Step 4: Display the progression details for all exercises in this routine.
SELECT
    'table' as component,
    'Progression Details for this Routine' as title
WHERE
    $routine_template_name IS NOT NULL;

SELECT
    ex.exerciseName as "Exercise",
    plan.currentStepNumber as "Current Step",
    plan.targetSets as "Target Sets",
    plan.targetReps as "Target Reps",
    plan.current1rmEstimate as "Est. 1RM",
    plan.exercisePlanId as "Plan ID"
FROM
    dimExercisePlan AS plan
    JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
WHERE
    plan.userId=$current_user_id
    AND plan.templateName=$routine_template_name
ORDER BY
    ex.exerciseName;