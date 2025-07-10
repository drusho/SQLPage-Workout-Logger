/**
 * @filename      view_history.sql
 * @description   Displays a personal, aggregated summary of the logged-in user's past workouts.
 * @created       2025-06-18
 * @last-updated  2025-07-05
 * @requires      - `layouts/layout_main.sql` for the page shell and session variables.
 * @requires      - `factWorkoutHistory`, `dimDate`, `dimExercise` tables.
 * @returns       A UI page containing a searchable table of the user's workout history.
 * @see           - /actions/action_edit_history.sql: The page for editing a workout log.
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

-- =============================================================================
-- Step 2: Page Header
-- =============================================================================
SELECT
    'text' as component,
    'Training Log' as title;

SELECT
    'button' as component,
    'md' as size;

SELECT
    '/actions/action_edit_history.sql' as link,
    'green' as color,
    'Add Workout Log' as title,
    'plus' as icon;

-- =============================================================================
-- Step 3: Workout History Table
-- =============================================================================
SELECT
    'divider' as component;

SELECT
    'table' as component,
    'Your Past Workouts' as title,
    TRUE as sort,
    TRUE as small,
    'Action' as markdown;

SELECT
    d.fullDate AS "Date",
    ex.exerciseName AS "Exercise",
    -- Aggregate all sets for the workout into a single summary string
    CASE
    -- First, handle calisthenics (reps-only) exercises
        WHEN MAX(model.modelType)='reps' THEN CASE
            WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)
            ELSE GROUP_CONCAT(CAST(fwh.repsPerformed AS TEXT), ' | ')
        END
        -- Next, handle ad-hoc bodyweight exercises (no plan and weight is zero)
        WHEN MAX(fwh.exercisePlanId) IS NULL
        AND MAX(fwh.weightUsed)=0 THEN CASE
            WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)
            ELSE GROUP_CONCAT(CAST(fwh.repsPerformed AS TEXT), ' | ')
        END
        -- Finally, handle all weight-based exercises
        ELSE CASE
        -- If all sets are identical, summarize them
            WHEN MIN(fwh.repsPerformed)=MAX(fwh.repsPerformed)
            AND MIN(fwh.weightUsed)=MAX(fwh.weightUsed) THEN COUNT(fwh.workoutHistoryId)||'x'||MIN(fwh.repsPerformed)||'x'||CAST(MIN(fwh.weightUsed) AS INTEGER)||' lbs'
            -- Otherwise, list each set individually
            ELSE GROUP_CONCAT(
                fwh.repsPerformed||'x'||CAST(fwh.weightUsed AS INTEGER)||' lbs',
                ' | '
            )
        END
    END as "Sets",
    fwh.notes AS "Notes",
    -- Generate the Edit link for each workout session
    FORMAT(
        '[Edit](/actions/action_edit_history.sql?user_id=%s&exercise_id=%s&date_id=%s)',
        fwh.userId,
        fwh.exerciseId,
        fwh.dateId
    ) AS "Action"
FROM
    factWorkoutHistory AS fwh
    JOIN dimDate AS d ON fwh.dateId=d.dateId
    JOIN dimExercise AS ex ON fwh.exerciseId=ex.exerciseId
    -- LEFT JOIN to plan and model, as not all history entries may have a plan (ad-hoc workouts)
    LEFT JOIN dimExercisePlan AS plan ON fwh.exercisePlanId=plan.exercisePlanId
    LEFT JOIN dimProgressionModel AS model ON plan.progressionModelId=model.progressionModelId
WHERE
    fwh.userId=$current_user_id
GROUP BY
    d.dateId,
    ex.exerciseName,
    fwh.userId,
    fwh.exerciseId
ORDER BY
    d.dateId DESC;
