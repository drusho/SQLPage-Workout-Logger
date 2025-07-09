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

-- Handle 1RM Calculator Submission
SET
    calculated_1rm=(
        SELECT
            CAST(:calc_weight AS REAL)*(1+(CAST(:calc_reps AS REAL)/30.0))
        WHERE
            :calc_weight IS NOT NULL
            AND :calc_reps IS NOT NULL
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

UPDATE dimExercisePlan
SET
    currentStepNumber=:current_step,
    current1rmEstimate=:current_1rm
WHERE
    exercisePlanId=:exercise_plan_id
    AND :action='manual_progression_update';

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
-- Step 2a: Display a dynamic, collapsible summary of the selected workout plan
-- =============================================================================
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
                'modelType',
                model.modelType, -- Get the model type ('weight' or 'reps')
                'targetSets',
                COALESCE(step.targetSets, 3),
                'targetReps',
                CASE -- If the model is rep-based, calculate target reps
                    WHEN model.modelType='reps' THEN ROUND(
                        plan.currentMaxRepsEstimate*(step.percentOfMax/100)
                    )
                    ELSE COALESCE(step.targetReps, 5) -- Otherwise, use the fixed target reps
                END,
                'targetWeight',
                ROUND(
                    COALESCE(:current_1rm, plan.current1rmEstimate, 0)*(COALESCE(step.percentOfMax, 0)/100),
                    1
                ),
                'currentStepNumber',
                plan.currentStepNumber,
                'current1rmEstimate',
                plan.current1rmEstimate
            )
        FROM
            dimExercisePlan AS plan
            JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
            LEFT JOIN dimProgressionModel AS model ON plan.progressionModelId=model.progressionModelId
            LEFT JOIN dimProgressionModelStep AS step ON plan.progressionModelId=step.progressionModelId
            AND step.stepNumber=COALESCE(:current_step, plan.currentStepNumber)
        WHERE
            plan.exercisePlanId=$exercise_plan_id
    );

SELECT
    'html' as component;

-- This query builds the HTML for the workout summary.
-- It first gets all targets for the selected plan, then checks for any workouts
-- logged today, and finally constructs the HTML list.
WITH
    -- First, get all exercise targets for the selected workout plan.
    TemplateExercises AS (
        SELECT
            ex.exerciseName,
            plan.exerciseId,
            COALESCE(step.targetSets, 3) as targetSets,
            COALESCE(step.targetReps, 5) as targetReps,
            -- Safely calculate the target weight
            ROUND(
                COALESCE(plan.current1rmEstimate, 0)*(COALESCE(step.percentOfMax, 0)/100),
                1
            ) as targetWeight,
            plan.currentStepNumber
        FROM
            dimExercisePlan AS plan
            JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
            LEFT JOIN dimProgressionModelStep AS step ON plan.progressionModelId=step.progressionModelId
            AND plan.currentStepNumber=step.stepNumber
        WHERE
            plan.templateId=$template_id
            AND plan.userId=$current_user_id
    ),
    -- Second, get the performance details for any exercises logged today.
    PerformanceToday AS (
        SELECT
            exerciseId,
            GROUP_CONCAT(repsPerformed||'x'||weightUsed||'lbs', '; ') as performanceString
        FROM
            factWorkoutHistory
        WHERE
            userId=$current_user_id
            AND dateId=STRFTIME('%Y%m%d', 'now')
        GROUP BY
            exerciseId
    )
    -- Finally, join targets with today's performance and generate the final HTML list.
SELECT
    -- If an exercise is already selected, keep the summary collapsed. Otherwise, open it by default.
    CASE
        WHEN $exercise_plan_id IS NOT NULL THEN '<details>'
        ELSE '<details open>'
    END||'<summary>Today''s Workout Targets</summary><div style="margin-top: 0.5rem; padding-left: 1rem; line-height: 1.7;">'||GROUP_CONCAT(
        CASE
        -- If performance details exist for this exercise, show them with a green checkmark.
            WHEN perf.performanceString IS NOT NULL THEN FORMAT(
                '<div style="color: green;">✅ %s &rarr; %s</div>',
                ex.exerciseName,
                perf.performanceString
            )
            -- Otherwise, show the original target information.
            ELSE FORMAT(
                '<div>%s<br><small>&nbsp; &rarr; <b>Target:</b> %s x %s @ %s lbs</small></div>',
                ex.exerciseName,
                ex.targetSets,
                ex.targetReps,
                ex.targetWeight
            )
        END,
        '' -- No separator, the <div> tags handle newlines
    )||'</div></details>' AS html
FROM
    TemplateExercises AS ex
    LEFT JOIN PerformanceToday AS perf ON ex.exerciseId=perf.exerciseId
WHERE
    $template_id IS NOT NULL
ORDER BY
    ex.exerciseName;

-- Display the final form to log performance
SELECT
    'form' AS component,
    'post' AS method,
    '/actions/action_edit_history.sql' AS action
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
    STRFTIME('%Y%m%d', 'now', 'localtime') AS value;

SELECT
    'hidden' AS type,
    'user_id' AS name,
    $current_user_id AS value;

SELECT
    'hidden' AS type,
    'template_id' AS name,
    $template_id AS value;

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
            set_number<(
                SELECT
                    CAST(
                        JSON_EXTRACT($current_exercise_data, '$.targetSets') AS INTEGER
                    )
            )
    )
    -- Header for each set
SELECT
    set_number,
    'header' AS type,
    'Set '||set_number AS label,
    NULL AS name,
    NULL AS value, -- Add placeholder for value
    NULL AS prefix,
    6 AS width,
    NULL AS step
FROM
    series
UNION ALL
-- 'Reps' input for each set, pre-filled with the target reps
SELECT
    set_number,
    'number' AS type,
    '' AS label,
    'reps_'||set_number AS name,
    JSON_EXTRACT($current_exercise_data, '$.targetReps') AS value,
    'Reps' AS prefix,
    3 AS width,
    0.01 AS step
FROM
    series
UNION ALL
-- 'Weight' input for each set, pre-filled with the target weight
SELECT
    set_number,
    'number' AS type,
    '' AS label,
    'weight_'||set_number AS name,
    JSON_EXTRACT($current_exercise_data, '$.targetWeight') AS value,
    'Wt' AS prefix,
    3 AS width,
    0.01 AS step
FROM
    series
WHERE
    JSON_EXTRACT($current_exercise_data, '$.modelType')='weight'
ORDER BY
    set_number,
    type;

SELECT
    'header' as type,
    '' as name,
    'Overall' as label,
    '' as prefix,
    '' as value,
    6 as width,
    '' as max,
    '' as step
UNION ALL
SELECT
    'number' as type,
    'rpe_recorded' as name,
    '' as label,
    'RPE' as prefix,
    8 as value,
    3 as width,
    10 as max,
    0.01 as step
UNION ALL
SELECT
    'header' as type,
    '' as name,
    '' as label,
    '' as prefix,
    '' as value,
    4 as width,
    '' as max,
    '' as step
UNION ALL
SELECT
    'textarea' as type,
    'notes_recorded' as name,
    'Notes' as label,
    '' as prefix,
    '' as value,
    8 as width,
    '' as max,
    '' as step;

SELECT
    'divider' as component,
    'Manual Progression Update' as contents;

SELECT
    'text' as component,
    '1RM Calculation: Weight * (1 + (Reps / 30))' as contents_md
WHERE
    JSON_EXTRACT($current_exercise_data, '$.modelType')='weight';

SELECT
    'form' as component,
    'post' as method,
    '/actions/action_update_progression.sql' as action,
    'Save Progression' as validate,
    'green' as validate_color
WHERE
    $exercise_plan_id IS NOT NULL;

-- Hidden fields to identify the plan and the action
SELECT
    'hidden' as type,
    'action' as name,
    'manual_progression_update' as value;

SELECT
    'hidden' as type,
    'exercise_plan_id' as name,
    $exercise_plan_id as value;

SELECT
    'hidden' as type,
    'template_id' as name,
    $template_id as value;

-- Input for "Current Step", which is common to all models
SELECT
    'number' as type,
    'current_step' as name,
    'Current Step' as prefix,
    '' as label,
    JSON_EXTRACT($current_exercise_data, '$.currentStepNumber') as value,
    4 as width,
    1 as step;

-- Conditionally show the "Est. 1RM" input for WEIGHT based models
SELECT
    'number' as type,
    'current_1rm' as name,
    'est_1rm_input' as id,
    'Est. 1RM (lbs)' as prefix,
    '' as label,
    JSON_EXTRACT($current_exercise_data, '$.current1rmEstimate') as value,
    4 as width,
    0.5 as step
WHERE
    JSON_EXTRACT($current_exercise_data, '$.modelType')='weight';

-- Conditionally show the "Est. Max Reps" input for REP based models
SELECT
    'number' as type,
    'current_max_reps' as name,
    '' as label,
    'Est. Max Reps' as prefix,
    (
        SELECT
            currentMaxRepsEstimate
        FROM
            dimExercisePlan
        WHERE
            exercisePlanId=$exercise_plan_id
    ) as value,
    4 as width,
    1 as step
WHERE
    JSON_EXTRACT($current_exercise_data, '$.modelType')='reps';

SELECT
    'redirect' AS component,
    '/index.sql?template_id' AS link
WHERE
    :action='save_log';