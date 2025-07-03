/**
 * @filename      view_history.sql
 * @description   Displays a high-level summary of workout logs, grouping all sets for a given exercise and day into a single line.
 * @created       2025-06-18
 * @last-updated  2025-07-03
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - `factWorkoutHistory`, `dimDate`, `dimExercise`, `dimUser` tables.
 * @returns       A full UI page containing a searchable and sortable table of the aggregated workout history.
 * @see           - /actions/action_edit_history.sql: The page for editing a workout log.
 */
------------------------------------------------------
-- STEP 1: RENDER PAGE STRUCTURE
------------------------------------------------------
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

------------------------------------------------------
-- STEP 2: RENDER PAGE HEADER AND ACTIONS
------------------------------------------------------
SELECT
    'text' AS component,
    'Workout History' AS title;

-- The "Add Workout Log" button should link to the edit page without an ID to enter "create" mode.
SELECT
    'button' AS component,
    'md' AS size;

SELECT
    '/actions/action_edit_history.sql' AS link,
    'azure' AS outline,
    'Add Workout Log' AS title,
    'plus' AS icon;

------------------------------------------------------
-- STEP 3: RENDER THE WORKOUT HISTORY LIST
------------------------------------------------------
SELECT
    'table' AS component,
    'All Workouts' AS title,
    TRUE AS sort,
    TRUE AS small,
    'Action' AS markdown;

SELECT
    d.fullDate AS "Date",
    u.displayName AS "User",
    e.exerciseName AS "Exercise",
    -- Aggregate all sets for the workout into a single summary string
    GROUP_CONCAT(
        'Set ' || fwh.setNumber || ': ' || fwh.repsPerformed || 'x' || fwh.weightUsed || ' @' || fwh.rpeRecorded,
        ' | '
    ) AS "Sets",
    -- Generate the Edit link for each workout session
    FORMAT(
        '[Edit](/actions/action_edit_history.sql?user_id=%s&exercise_id=%s&date_id=%s)',
        fwh.userId,
        fwh.exerciseId,
        fwh.dateId
    ) AS "Action"
FROM
    factWorkoutHistory AS fwh
    JOIN dimDate AS d ON fwh.dateId = d.dateId
    JOIN dimExercise AS e ON fwh.exerciseId = e.exerciseId
    JOIN dimUser AS u ON fwh.userId = u.userId
GROUP BY
    d.fullDate,
    u.displayName,
    e.exerciseName,
    fwh.userId,
    fwh.exerciseId,
    fwh.dateId
ORDER BY
    d.fullDate DESC;
