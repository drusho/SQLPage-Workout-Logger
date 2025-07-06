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

-- Step 2: Display the page header and "Add" button.
SELECT
    'text' as component,
    'Training Log' as title;

SELECT
    'button' as component,
    'md' as size;

SELECT
    '/actions/action_edit_history.sql' as link,
    'azure' as outline,
    'Add Workout Log' as title,
    'plus' as icon;

-- Step 3: Display the workout history table for the current user.
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
    e.exerciseName AS "Exercise",
    -- Aggregate all sets for the workout into a single summary string
    CONCAT (
        GROUP_CONCAT(
            ' '||fwh.setNumber||'x'||fwh.repsPerformed||'@'||fwh.weightUsed
        ),
        ' rpe:'||fwh.rpeRecorded
    ) AS "Sets",
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
    JOIN dimExercise AS e ON fwh.exerciseId=e.exerciseId
WHERE
    -- Only show workouts for the currently logged-in user.
    fwh.userId=$current_user_id
GROUP BY
    d.fullDate,
    e.exerciseName,
    fwh.userId,
    fwh.exerciseId,
    fwh.dateId
ORDER BY
    d.fullDate DESC;
