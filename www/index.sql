/**
 * @filename      index.sql
 * @description   The main dashboard for logging workouts. Guides the user through selecting a
 * routine and an exercise, then displays their targets and a form to log their performance.
 * @created       2025-06-14
 * @last-updated  2025-07-05
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - All `dim` and `fact` tables to drive the workout logging process.
 * @param         template_name [url, optional] The name of the routine to log.
 * @param         exercise_id [url, optional] The ID of the exercise to log.
 */
-- Step 1: Load the main layout and get the current user's ID.
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

-- Step 2: Display a success alert if a workout was just saved.
SELECT
    'alert' as component,
    'Success!' as title,
    'Your workout has been saved.' as description,
    'check' as icon,
    'green' as color,
    5 as close_after
WHERE
    $saved='true';

-- Step 3: Display the Routine Selector form.
SELECT
    'form' as component,
    'index.sql' as action,
    'true' as auto_submit;

SELECT
    'select' as type,
    'template_name' as name,
    'Select a Routine' as label,
    'Choose a routine to start...' as placeholder,
    :template_name as value,
    -- UPDATED: Replaced the faulty MAX() query with a more robust CTE to get unique routine names.
    (
        WITH
            RankedNames AS (
                SELECT
                    templateName,
                    COALESCE(userTemplateAlias, templateName) as displayName,
                    -- This ranks rows, giving priority to ones with a custom alias.
                    ROW_NUMBER() OVER (
                        PARTITION BY
                            templateName
                        ORDER BY
                            userTemplateAlias DESC
                    ) as rn
                FROM
                    dimExercisePlan
                WHERE
                    userId=$current_user_id
                    AND isActive=1
            )
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT('label', displayName, 'value', templateName)
            )
        FROM
            RankedNames
        WHERE
            rn=1
        ORDER BY
            templateName
    ) as options;

-- =============================================================================
-- This section only renders if a routine has been selected.
-- =============================================================================
-- Step 4: Display the Exercise Selector form.
SELECT
    'form' as component,
    'index.sql' as action,
    'true' as auto_submit
WHERE
    $template_name IS NOT NULL;

SELECT
    'hidden' as type,
    'template_name' as name,
    $template_name as value;

SELECT
    'select' as type,
    'exercise_id' as name,
    'Select an Exercise' as label,
    'Choose an exercise to log...' as placeholder,
    :exercise_id as value,
    (
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT(
                    'label',
                    COALESCE(duep.userExerciseAlias, de.exerciseName),
                    'value',
                    de.exerciseId
                )
            )
        FROM
            dimExercisePlan AS dep
            JOIN dimExercise AS de ON dep.exerciseId=de.exerciseId
            LEFT JOIN dimUserExercisePreferences AS duep ON dep.exerciseId=duep.exerciseId
            AND dep.userId=$current_user_id
        WHERE
            dep.userId=$current_user_id
            AND dep.templateName=$template_name
    ) as options;

-- =============================================================================
-- This section only renders if an exercise has been selected.
-- =============================================================================
-- Step 5: Fetch all necessary data for the selected exercise plan and its progression.
SET
    plan_data=(
        SELECT
            JSON_OBJECT(
                'exercisePlanId',
                plan.exercisePlanId,
                'currentStepNumber',
                plan.currentStepNumber,
                'current1rmEstimate',
                plan.current1rmEstimate,
                'progressionModelId',
                plan.progressionModelId,
                'targetSets',
                step.targetSets,
                'targetReps',
                step.targetReps,
                'percentOfMax',
                step.percentOfMax
            )
        FROM
            dimExercisePlan AS plan
            JOIN dimProgressionModelStep AS step ON plan.progressionModelId=step.progressionModelId
            AND plan.currentStepNumber=step.stepNumber
        WHERE
            plan.userId=$current_user_id
            AND plan.exerciseId=$exercise_id
    );

-- Step 6: Display the user's target for today's workout.
SELECT
    'alert' as component,
    'Target for Today' as title,
    FORMAT(
        'Your goal is **%s sets** of **%s reps** at **%s lbs**.',
        JSON_EXTRACT($plan_data, '$.targetSets'),
        JSON_EXTRACT($plan_data, '$.targetReps'),
        CAST(
            JSON_EXTRACT($plan_data, '$.current1rmEstimate')*JSON_EXTRACT($plan_data, '$.percentOfMax') AS INTEGER
        )
    ) as description,
    'info' as color,
    'target' as icon
WHERE
    $exercise_id IS NOT NULL
    AND $plan_data IS NOT NULL;

-- Step 7: Display the main form for logging the workout.
SELECT
    'form' as component,
    '/actions/action_save_workout.sql' as action,
    'Log Workout' as validate,
    'green' as validate_color,
    'post' as method
WHERE
    $exercise_id IS NOT NULL
    AND $plan_data IS NOT NULL;

-- Pass all necessary IDs and data to the action script as hidden fields.
SELECT
    'hidden' as type,
    'exercise_plan_id' as name,
    JSON_EXTRACT($plan_data, '$.exercisePlanId') as value;

SELECT
    'hidden' as type,
    'num_sets' as name,
    JSON_EXTRACT($plan_data, '$.targetSets') as value;

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
            set_number<CAST(
                JSON_EXTRACT($plan_data, '$.targetSets') AS INTEGER
            )
    )
SELECT
    set_number,
    'number' as type,
    'reps_'||set_number as name,
    'Set '||set_number||' Reps' as label,
    3 as width
FROM
    series
UNION ALL
SELECT
    set_number,
    'number' as type,
    'weight_'||set_number as name,
    'Weight (lbs)' as label,
    3 as width
FROM
    series
ORDER BY
    set_number;

-- Add fields for RPE and notes.
SELECT
    'number' as type,
    'rpe_recorded' as name,
    'RPE (Overall)' as label,
    8 as value,
    10 as max,
    6 as width;

SELECT
    'textarea' as type,
    'notes_recorded' as name,
    'Workout Notes' as label,
    6 as width;
