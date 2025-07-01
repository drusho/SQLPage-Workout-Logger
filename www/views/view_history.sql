/**
 * @filename      view_history.sql
 * @description   Displays a high-level summary of workout logs, grouping all sets for a given
 * exercise into a single, readable line. This provides a user-friendly,
 * aggregated view of the entire training history.
 * @created       2025-06-14
 * @last-updated  2025-06-29
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `WorkoutLog` table to fetch workout data.
 * @requires      - The `ExerciseLibrary` table to display exercise names.
 * @requires      - The `WorkoutSetLog` table for specific set metrics.
 * @returns       A full UI page containing a searchable and sortable `table` of the
 * aggregated workout history. Each row represents a full workout session.
 * @see           - `action_edit_workout_log.sql` - The action that this page links to.
 * @note          This page aggregates data. The `Summary` column is a concatenation
 * of all sets performed for that workout instance.
 * @todo          - Add server-side pagination to improve performance when the log history grows large.
 * @todo          - Implement advanced filtering options, such as by date range or by exercise.
 */
------------------------------------------------------
-- STEP 1: Include the main application layout and authentication check.
------------------------------------------------------
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;


SELECT 'text' as component,
    'Exericse History' as title;
------------------------------------------------------
-- STEP 2: Create the table component.
------------------------------------------------------   
SELECT
    'table' as component,
    'Workout Logs' as title,
    TRUE as sort,
    TRUE as small,
    json_array ('Action') as markdown;

------------------------------------------------------
-- STEP 3: Fetch and display the workout data.
-- This query joins workout logs with exercises and aggregates the data
-- from individual sets to display a summary for each workout.
------------------------------------------------------      
SELECT
    strftime ('%Y.%m.%d', wl.ExerciseTimestamp, 'unixepoch') AS "Date",
    el.ExerciseAlias AS "Name",
    CASE wsl.WeightUsed
        WHEN 0 THEN GROUP_CONCAT (wsl.SetNumber || 'x' || wsl.RepsPerformed, ' - ')
        ELSE GROUP_CONCAT (
            wsl.SetNumber || 'x' || wsl.RepsPerformed || ':' || CAST(ROUND(wsl.WeightUsed) as INTEGER),
            ' - '
        )
    END AS "Summary (SxR:wt)",
    wl.PerformedAtStepNumber as Step,
    wsl.RPE_Recorded as RPE,
    wl.WorkoutNotes as Notes,
    format (
        '[Edit](/actions/action_edit_workout_log.sql?id=%s)',
        wl.LogID
    ) AS "Action"
FROM
    WorkoutLog AS wl
    JOIN ExerciseLibrary AS el ON wl.ExerciseID = el.ExerciseID
    LEFT JOIN WorkoutSetLog AS wsl ON wl.LogID = wsl.LogID
WHERE
    wsl.RepsPerformed != ''
GROUP BY
    wl.LogID
    -- "Date"
    -- "Name"
    -- "Action",
    -- "Step"
    -- "RPE"
ORDER BY
    wl.ExerciseTimestamp DESC;