-- www/api/api_recent_workouts.sql
-- This page returns the 5 most recent workout sessions as JSON data.

-- Step 1: Get the current user
SET current_user_id = (SELECT username FROM sessions WHERE session_token = sqlpage.cookie('session_token'));

-- Step 2: Set the output type to JSON
SELECT 'json' AS component;

-- Step 3: Query the database and format the results as a JSON array
SELECT
    d.fullDate AS "Date",
    e.exerciseName AS "Exercise",
    GROUP_CONCAT(
        'Set '||fwh.setNumber||': '||fwh.repsPerformed||'x'||fwh.weightUsed||' @'||fwh.rpeRecorded,
        ' | '
    ) AS "Sets"
FROM
    factWorkoutHistory AS fwh
    JOIN dimDate AS d ON fwh.dateId=d.dateId
    JOIN dimExercise AS e ON fwh.exerciseId=e.exerciseId
WHERE
    fwh.userId=$current_user_id
GROUP BY
    d.fullDate, e.exerciseName, fwh.userId, fwh.exerciseId, fwh.dateId
ORDER BY
    d.fullDate DESC
LIMIT 5;