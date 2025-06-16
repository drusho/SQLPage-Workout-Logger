/**
 * @filename      view_history.sql
 * @description   Displays a comprehensive, searchable, and sortable table of all workout
 * logs. It joins workout data with the exercise library to provide a
 * user-friendly view of a user's complete training history.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `WorkoutLog` table to fetch workout data.
 * @requires      - The `ExerciseLibrary` table to display exercise names.
 * @returns       A full UI page containing a searchable and sortable `table` of the
 * entire workout history.
 * @see           - `action_save_workout.sql` - The action that creates the data displayed here.
 * @note          This page is read-only. The search and sort functionality is handled
 * client-side by the SQLPage `table` component.
 * @todo          - Add server-side pagination to improve performance when the log history grows large.
 * @todo          - Implement advanced filtering options, such as by date range or by exercise.
 */
------------------------------------------------------
-- STEP 1: Include the main application layout and authentication check.
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 2: Create the table component.
-- This defines a table with a title and enables the user to sort the data
-- by clicking on column headers and filter the results using a search box.
------------------------------------------------------   
SELECT 'table' as component,
    'Workout Logs' as title,
    TRUE as sort,
    -- Sort table by clicking on headers
    TRUE as search;
------------------------------------------------------
-- STEP 3: Fetch and display the workout data.
-- This query joins the workout log with the exercise library to show the
-- full exercise name instead of just its ID. The results are ordered
-- with the most recent workouts appearing first.
------------------------------------------------------      
SELECT el.ExerciseName AS "Exercise",
    wl.ExerciseTimestamp AS "Date",
    wl.WeightUsed AS "Weight",
    wl.WeightUnit AS "Unit",
    wl.RepsPerformed AS "Reps",
    wl.TotalSetsPerformed AS "Sets",
    wl.RPE_Recorded AS "RPE",
    wl.WorkoutNotes as "Notes"
FROM WorkoutLog wl
    JOIN ExerciseLibrary el ON wl.ExerciseID = el.ExerciseID
ORDER BY wl.ExerciseTimestamp DESC;