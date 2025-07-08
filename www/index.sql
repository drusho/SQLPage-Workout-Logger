/**
 * @filename      index.sql
 * @description   The main dashboard for logging workouts. Guides the user through selecting a routine and exercise,
 * then displays their targets and a form to log their performance.
 * @created       2025-07-07
 * @requires      - layouts/layout_main.sql, All dim tables, action_edit_history.sql
 */
-- =============================================================================
-- Step 1: Initial Setup
-- =============================================================================
-- Load the main layout and get the current user's ID
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

-- Get the selected routine and exercise from the URL parameters
SET
    template_id=$template_id;

SET
    exercise_plan_id=$exercise_plan_id;

-- Display the main page title
SELECT
    'text' AS component,
    'Log a Workout' AS title;

-- =============================================================================
-- Step 2: Routine Selection Form
-- This form is always visible.
-- =============================================================================
SELECT
    'form' AS component,
    'get' AS method,
    'index.sql' as action,
    TRUE as auto_submit;

SELECT
    'select' AS type,
    'template_id' AS name,
    'Step 1: Select Your Routine' AS label,
    'Select a Routine' AS empty_option,
    $template_id AS value,
    (
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT('label', templateName, 'value', templateId)
            )
        FROM
            (
                SELECT DISTINCT
                    templateName,
                    templateId
                FROM
                    dimExercisePlan
                WHERE
                    userId=$current_user_id
                    AND isActive=1
            )
        ORDER BY
            templateName
    ) AS options;

-- =============================================================================
-- Step 3: Exercise Selection Form
-- This form appears only after a routine has been selected.
-- =============================================================================
SELECT
    'form' AS component,
    'get' AS method,
    'index.sql' as action,
    TRUE as auto_submit
WHERE
    $template_id IS NOT NULL;

-- Pass the selected template_id through so we don't lose it on the next reload
SELECT
    'hidden' as type,
    'template_id' as name,
    $template_id as value;

SELECT
    'select' AS type,
    'exercise_plan_id' AS name,
    'Step 2: Select Your Exercise' AS label,
    'Select an Exercise' AS empty_option,
    $exercise_plan_id AS value,
    (
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT(
                    'label',
                    ex.exerciseName,
                    'value',
                    plan.exercisePlanId
                )
            )
        FROM
            dimExercisePlan AS plan
            JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
        WHERE
            plan.templateId=$template_id
            AND plan.userId=$current_user_id
        ORDER BY
            ex.exerciseName
    ) AS options;

-- =============================================================================
-- Step 4: Workout Logging Form
-- This section appears only after both a routine and an exercise have been selected.
-- =============================================================================
SET
    current_exercise_data=(
        SELECT
            JSON_OBJECT(
                'exerciseName',
                ex.exerciseName,
                'exerciseId',
                plan.exerciseId,
                'targetSets',
                COALESCE(step.targetSets, 3),
                'targetReps',
                COALESCE(step.targetReps, 5),
                'targetWeight',
                ROUND(
                    plan.current1rmEstimate*(step.percentOfMax/100),
                    1
                )
            )
        FROM
            dimExercisePlan AS plan
            JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
            LEFT JOIN dimProgressionModelStep AS step ON plan.progressionModelId=step.progressionModelId
            AND plan.currentStepNumber=step.stepNumber
        WHERE
            plan.exercisePlanId=$exercise_plan_id
    );

-- Display the targets for the selected exercise
SELECT
    'foldable' AS component
WHERE
    $exercise_plan_id IS NOT NULL;

SELECT
    'Exercise Targets' as title,
    JSON_EXTRACT($current_exercise_data, '$.targetSets')||'x'||JSON_EXTRACT($current_exercise_data, '$.targetReps') as description_md
WHERE
    $exercise_plan_id IS NOT NULL;

-- Display the final form to log performance
SELECT
    'form' AS component,
    'post' AS method,
    'action_edit_history.sql' AS action
WHERE
    $exercise_plan_id IS NOT NULL;

-- Hidden fields to pass all necessary data to the action page
SELECT
    'hidden' AS type,
    'action' AS name,
    'save_log' AS value;

SELECT
    'hidden' AS type,
    'exercise_plan_id' AS name,
    $exercise_plan_id AS value;

SELECT
    'hidden' AS type,
    'exercise_id' AS name,
    JSON_EXTRACT($current_exercise_data, '$.exerciseId') AS value;

SELECT
    'hidden' AS type,
    'date_id' AS name,
    STRFTIME('%Y%m%d', 'now') AS value;

SELECT
    'hidden' AS type,
    'user_id' AS name,
    $current_user_id AS value;

-- Generate input fields for 5 sets
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
            set_number<5
    )
    -- Header for each set
SELECT
    set_number,
    'header' AS type,
    'Set '||set_number AS label,
    NULL AS name,
    NULL AS prefix,
    6 AS width,
    NULL AS step
FROM
    series
UNION ALL
-- 'Reps' input for each set
SELECT
    set_number,
    'number' AS type,
    '' AS label,
    'reps_'||set_number AS name,
    'Reps' AS prefix,
    3 AS width,
    1 AS step -- Allow whole number increments for reps
FROM
    series
UNION ALL
-- 'Weight' input for each set
SELECT
    set_number,
    'number' AS type,
    '' AS label,
    'weight_'||set_number AS name,
    'Wt' AS prefix,
    3 AS width,
    0.01 AS step -- Allow fractional increments for weight
FROM
    series
ORDER BY
    set_number,
    type;
