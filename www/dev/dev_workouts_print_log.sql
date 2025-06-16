/**
 * @filename      dev_workouts_print_log.sql
 * @description   A development script used for debugging. It displays the single most
 * recent entry from the `WorkoutLog` table that was added on the current day.
 * @created       2025-06-15
 * @last-updated  2025-06-15
 * @requires      - The `WorkoutLog` table.
 * @returns       A `table` component containing the most recent workout log entry
 * from the current day.
 * @note          This is a developer tool and is not part of the main application flow.
 * @todo          - Allow passing a date or `UserID` as a URL parameter to view other logs.
 */
SELECT 'table' as component;
SELECT *
FROM WorkoutLog
WHERE date(ExerciseTimestamp) = date('now')
ORDER BY ExerciseTimestamp DESC
LIMIT 1;