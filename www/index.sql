/**
 * @filename      index.sql
 * @description   The main dashboard for logging workouts. Guides the user through selecting a routine and exercise,
 * displays a summary of their targets and previous performance, and provides forms to log their
 * current workout and manually update their progression.
 * @created       2025-07-09
 * @requires      - layouts/layout_main.sql, All dim tables, action_edit_history.sql, action_update_progression.sql
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
    'Step 1: Select Workout' AS label,
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
                ORDER BY
                    templateName
            )
    ) AS options,
    4 AS width;

WITH
    SortedExercises AS (
        -- First, create a temporary, sorted list of the exercises for the selected routine
        SELECT
            ex.exerciseName,
            plan.exercisePlanId
        FROM
            dimExercisePlan AS plan
            JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
        WHERE
            plan.templateId=$template_id
            AND plan.userId=$current_user_id
        ORDER BY
            TRIM(ex.exerciseName) COLLATE NOCASE
    )
SELECT
    'select' AS type,
    'exercise_plan_id' AS name,
    'Step 2: Select Exercise' AS label,
    'Select an Exercise' AS empty_option,
    $exercise_plan_id AS value,
    (
        -- Then, build the JSON array from this pre-sorted list
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT('label', exerciseName, 'value', exercisePlanId)
            )
        FROM
            SortedExercises
    ) AS options,
    4 as width;

-- =============================================================================
-- Step 3: Data Preparation for Forms
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
                model.modelType,
                'targetSets',
                COALESCE(step.targetSets, 3),
                'targetReps',
                CASE -- If the model is rep-based, calculate target reps
                    WHEN model.modelType='reps' THEN CAST(
                        ROUND(
                            plan.currentMaxRepsEstimate*(step.percentOfMax/100.0)
                        ) AS INTEGER
                    )
                    ELSE COALESCE(step.targetReps, 5) -- Otherwise, use the fixed target reps
                END,
                'targetWeight',
                ROUND(
                    COALESCE(plan.current1rmEstimate, 0)*(COALESCE(step.percentOfMax, 0)/100.0),
                    1
                ),
                'currentStepNumber',
                plan.currentStepNumber,
                'current1rmEstimate',
                plan.current1rmEstimate,
                'currentMaxRepsEstimate',
                plan.currentMaxRepsEstimate
            )
        FROM
            dimExercisePlan AS plan
            JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
            LEFT JOIN dimProgressionModel AS model ON plan.progressionModelId=model.progressionModelId
            LEFT JOIN dimProgressionModelStep AS step ON plan.progressionModelId=step.progressionModelId
            AND step.stepNumber=plan.currentStepNumber
        WHERE
            plan.exercisePlanId=$exercise_plan_id
    );

SELECT
    'html' as component;

-- =============================================================================
-- Step 4: Page Content and Summaries
-- =============================================================================
WITH
    TemplateExercises AS (
        SELECT
            ex.exerciseName,
            plan.exerciseId,
            model.modelType,
            COALESCE(step.targetSets, 3) as targetSets,
            -- This logic correctly calculates target reps for different model types
            CASE
                WHEN model.modelType='reps'
                AND plan.currentMaxRepsEstimate IS NOT NULL
                AND step.percentOfMax IS NOT NULL THEN CAST(
                    ROUND(
                        plan.currentMaxRepsEstimate*(step.percentOfMax/100.0)
                    ) AS INTEGER
                )
                ELSE COALESCE(step.targetReps, 5)
            END AS targetReps,
            -- Safely calculate the target weight
            ROUND(
                COALESCE(plan.current1rmEstimate, 0)*(COALESCE(step.percentOfMax, 0)/100.0),
                1
            ) as targetWeight,
            plan.currentStepNumber
        FROM
            dimExercisePlan AS plan
            JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
            LEFT JOIN dimProgressionModel AS model ON plan.progressionModelId=model.progressionModelId
            LEFT JOIN dimProgressionModelStep AS step ON plan.progressionModelId=step.progressionModelId
            AND plan.currentStepNumber=step.stepNumber
        WHERE
            plan.templateId=$template_id
            AND plan.userId=$current_user_id
    ),
    -- Second, get the performance details for any exercises logged today, with summarization.
    PerformanceToday AS (
        SELECT
            fwh.exerciseId,
            CASE
                WHEN MAX(model.modelType)='reps' THEN CASE
                    WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)
                    ELSE GROUP_CONCAT(CAST(fwh.repsPerformed AS TEXT), '; ')
                END
                WHEN MAX(fwh.exercisePlanId) IS NULL
                AND MAX(fwh.weightUsed)=0 THEN CASE
                    WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)
                    ELSE GROUP_CONCAT(CAST(fwh.repsPerformed AS TEXT), '; ')
                END
                ELSE CASE
                    WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed)
                    AND MIN(fwh.weightUsed)=MAX(fwh.weightUsed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)||'x'||CAST(MIN(fwh.weightUsed) AS INTEGER)||' lbs'
                    ELSE GROUP_CONCAT(
                        fwh.repsPerformed||'x'||CAST(fwh.weightUsed AS INTEGER)||' lbs',
                        '; '
                    )
                END
            END as performanceString
        FROM
            factWorkoutHistory AS fwh
            LEFT JOIN dimExercisePlan AS plan ON fwh.exercisePlanId=plan.exercisePlanId
            LEFT JOIN dimProgressionModel AS model ON plan.progressionModelId=model.progressionModelId
        WHERE
            fwh.userId=$current_user_id
            AND fwh.dateId=STRFTIME('%Y%m%d', 'now', 'localtime')
        GROUP BY
            fwh.exerciseId
    )
    -- Finally, join targets with performance and generate the final HTML list.
SELECT
    CASE
        WHEN $exercise_plan_id IS NOT NULL THEN '<details>'
        ELSE '<details open>'
    END||'<summary>Today''s Workout Targets</summary><div style="margin-top: 0.5rem; padding-left: 1rem; line-height: 1.7;">'||GROUP_CONCAT(
        CASE
        -- If performance details exist, show them with a green checkmark.
            WHEN perf.performanceString IS NOT NULL THEN FORMAT(
                '<div style="color: green;">✅ %s &rarr; %s</div>',
                ex.exerciseName,
                perf.performanceString
            )
            -- Otherwise, show the correctly formatted target information.
            ELSE CASE
            -- If model is 'reps' or target weight is 0, use the simple format
                WHEN ex.modelType='reps'
                OR ex.targetWeight=0 THEN FORMAT(
                    '<div>%s<small>&nbsp; &rarr; </b> %s x %s</small></div>',
                    ex.exerciseName,
                    ex.targetSets,
                    ex.targetReps
                )
                -- Otherwise, use the format with weight
                ELSE FORMAT(
                    '<div>%s<small>&nbsp; &rarr; </b> %s x %s x %s lbs</small></div>',
                    ex.exerciseName,
                    ex.targetSets,
                    ex.targetReps,
                    CAST(ex.targetWeight AS INTEGER)
                )
            END
        END,
        '' -- No separator
        ORDER BY
            ex.exerciseName
    )||'</div></details>' AS html
FROM
    TemplateExercises AS ex
    LEFT JOIN PerformanceToday AS perf ON ex.exerciseId=perf.exerciseId
WHERE
    $template_id IS NOT NULL;

SET
    last_workout_date_id=(
        SELECT
            MAX(fwh.dateId)
        FROM
            factWorkoutHistory AS fwh
        WHERE
            fwh.exerciseId=JSON_EXTRACT($current_exercise_data, '$.exerciseId')
            AND fwh.userId=$current_user_id
            AND fwh.dateId<STRFTIME('%Y%m%d', 'now', 'localtime')
    );

-- Only build the HTML component if a valid last workout date was found.
SELECT
    -- Use FORMAT to wrap the output in a styled div, creating a highlighted callout box
    FORMAT(
        '<div style="background-color: #e7f3ff; border-left: 5px solid #0d6efd; padding: 1rem; margin-bottom: 1rem; border-radius: 0.25rem;"><b>Previous Workout:</b><br/>On %s, you performed: <b>%s</b> with an RPE of <b>%s</b>.</div>',
        d.fullDate,
        -- Summarization logic for sets
        CASE
            WHEN MAX(model.modelType)='reps' THEN CASE
                WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)
                ELSE GROUP_CONCAT(CAST(fwh.repsPerformed AS TEXT), '; ')
            END
            WHEN MAX(fwh.exercisePlanId) IS NULL
            AND MAX(fwh.weightUsed)=0 THEN CASE
                WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)
                ELSE GROUP_CONCAT(CAST(fwh.repsPerformed AS TEXT), '; ')
            END
            ELSE CASE
                WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed)
                AND MIN(fwh.weightUsed)=MAX(fwh.weightUsed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)||'x'||CAST(MIN(fwh.weightUsed) AS INTEGER)||' lbs'
                ELSE GROUP_CONCAT(
                    fwh.repsPerformed||'x'||CAST(fwh.weightUsed AS INTEGER)||' lbs',
                    '; '
                )
            END
        END,
        MAX(fwh.rpeRecorded)
    ) as html
FROM
    factWorkoutHistory AS fwh
    JOIN dimDate AS d ON fwh.dateId=d.dateId
    LEFT JOIN dimExercisePlan AS plan ON fwh.exercisePlanId=plan.exercisePlanId
    LEFT JOIN dimProgressionModel AS model ON plan.progressionModelId=model.progressionModelId
WHERE
    fwh.dateId=$last_workout_date_id
    AND fwh.exerciseId=JSON_EXTRACT($current_exercise_data, '$.exerciseId')
    AND fwh.userId=$current_user_id
    AND $last_workout_date_id IS NOT NULL -- This condition prevents the query from running if no history is found
GROUP BY
    d.fullDate;

-- =============================================================================
-- Step 5: Workout Logging Form
-- =============================================================================
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
            $exercise_plan_id IS NOT NULL
            and set_number<(
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
WHERE
    $exercise_plan_id IS NOT NULL
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
WHERE
    $exercise_plan_id IS NOT NULL
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
    and $exercise_plan_id IS NOT NULL
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
WHERE
    $exercise_plan_id IS NOT NULL
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
WHERE
    $exercise_plan_id IS NOT NULL
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
WHERE
    $exercise_plan_id IS NOT NULL
UNION ALL
SELECT
    'textarea' as type,
    'notes_recorded' as name,
    'Notes' as label,
    '' as prefix,
    '' as value,
    8 as width,
    '' as max,
    '' as step
WHERE
    $exercise_plan_id IS NOT NULL;

-- =============================================================================
-- Step 6: Manual Progression Update Form
-- =============================================================================
SELECT
    'divider' as component,
    'Manual Progression Update' as contents
WHERE
    $exercise_plan_id IS NOT NULL;

SELECT
    'text' as component,
    '1RM Calculation: Weight * (1 + (Reps / 30))' as contents_md
WHERE
    JSON_EXTRACT($current_exercise_data, '$.modelType')='weight'
    and $exercise_plan_id IS NOT NULL;

SELECT
    'form' as component,
    'post' as method,
    '/actions/action_update_progression.sql' as action,
    'Save Progression' as validate,
    'green' as validate_color
WHERE
    $exercise_plan_id IS NOT NULL
    and $exercise_plan_id IS NOT NULL;

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
    1 as step
WHERE
    $exercise_plan_id IS NOT NULL;

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
    JSON_EXTRACT($current_exercise_data, '$.modelType')='weight'
    and $exercise_plan_id IS NOT NULL;

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
    JSON_EXTRACT($current_exercise_data, '$.modelType')='reps'
    and $exercise_plan_id IS NOT NULL;

SELECT
    'redirect' AS component,
    '/index.sql?template_id' AS link
WHERE
    :action='save_log';