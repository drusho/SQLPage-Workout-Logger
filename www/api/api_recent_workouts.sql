-- www/api/api_recent_workouts.sql
-- This page returns the 5 most recent workout sessions for the user as JSON data.

SET current_user_id = (SELECT username FROM sessions WHERE session_token = sqlpage.cookie('session_token'));
SELECT 'json' AS component;

SELECT
    d.fullDate AS "Date",
    e.exerciseName AS "Exercise",
    GROUP_CONCAT(
        'Set '||fwh.setNumber||': '||fwh.repsPerformed||'x'||fwh.weightUsed,
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
    fwh.createdAt DESC
LIMIT 5;