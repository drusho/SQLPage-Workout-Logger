/**
 * @filename      view_workout_logs.sql
 * @description   Provides a full CRUD (Create, Read, Update, Delete) interface for the
 * `WorkoutLog` table. Users can view all past workouts, select an entry
 * to edit its details in a form, or delete it entirely.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `WorkoutLog` and `ExerciseLibrary` tables.
 * @param         action [url, optional] Controls the page mode. Can be `edit` (show form),
 * `save_edit` (process update), or `delete` (process delete).
 * @param         log_id [url, optional] The ID of the `WorkoutLog` entry to act upon.
 * @param         ... [form, optional] Various form fields are submitted when saving an edit.
 * @returns       A full UI page containing a table of all workout logs. If `action=edit`,
 * it also displays a pre-filled form. If a `delete` or `save_edit`
 * action is processed, it returns a `redirect` to reload the page.
 * @see           - `action_save_workout.sql` - The primary action that creates the data managed here.
 * @note          - This page uses the Post-Redirect-Get (PRG) pattern for all data modifications.
 * @note          - The edit form is rendered conditionally based on the `action=edit` URL parameter.
 * @note          - A single JSON object (`$log_data`) is used to cleanly pre-fill the edit form.
 * @todo          - The "Delete" button is instant, should be handled by dedicated scripts in the actions/ folder
 * @todo          - Add a "Create New Log" button to allow for manual entry of historical data.
 * @todo          - Implement pagination for the main table to handle a large workout history.
 */
-- Add this block at the top of any page that saves data.
-- It will check if a user is logged in. If not, it redirects them.
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
SELECT 'redirect' AS component,
    '/auth/auth_guest_prompt.sql' AS link
WHERE $current_user IS NULL;
----------------------------------
-- STEP 1: INCLUDE MAIN LAYOUT & AUTHENTICATION
----------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
----------------------------------------------------
-- STEP 2: PROCESS ACTIONS (UPDATE & DELETE)
-- This section runs first to handle any submitted actions before the page content
-- is displayed. It looks for an 'action' parameter in the URL.
----------------------------------------------------
-- Handle the 'delete' action to remove a log entry.
DELETE FROM WorkoutLog
WHERE LogID = :log_id
    AND :action = 'delete';
-- Handle the 'save_edit' action to update a log entry with new values from the form.
UPDATE WorkoutLog
SET TotalSetsPerformed = :sets_recorded,
    RepsPerformed = :reps_recorded,
    WeightUsed = :weight_recorded,
    RPE_Recorded = :rpe_recorded,
    WorkoutNotes = :notes_recorded,
    ExerciseTimestamp = :timestamp
WHERE LogID = :log_id
    AND :action = 'save_edit';
-- After a delete or save, redirect back to this page without URL parameters.
-- This prevents accidental re-submission and provides a clean user experience.
SELECT 'redirect' as component,
    'view_workout_logs.sql' as link
WHERE :action IS NOT NULL;
----------------------------------------------------
-- STEP 3: DISPLAY THE 'EDIT' FORM (CONDITIONAL)
-- This entire form only appears when a user clicks an "Edit" button, which
-- sets the URL parameter ':action' to 'edit'.
----------------------------------------------------
SELECT 'form' as component,
    'view_workout_logs.sql' as action,
    'Save Changes' as validate,
    'post' as method
WHERE :action = 'edit';
-- Hidden fields to pass necessary info back when the form is submitted.
SELECT 'hidden' as type,
    'action' as name,
    'save_edit' as value;
SELECT 'hidden' as type,
    'log_id' as name,
    :log_id as value;
-- Display a title for the edit form, fetching the exercise name dynamically.
SELECT 'text' as component,
    'Editing Log for: ' || (
        SELECT ExerciseName
        FROM ExerciseLibrary
        WHERE ExerciseID = (
                SELECT ExerciseID
                FROM WorkoutLog
                WHERE LogID = :log_id
            )
    ) as title;
-- **REFACTORED**: Fetch all data for the log entry into a single JSON object.
-- This is a cleaner and safer way to handle potentially NULL values.
SET log_data = (
        SELECT json_object(
                'timestamp',
                ExerciseTimestamp,
                'sets',
                TotalSetsPerformed,
                'reps',
                RepsPerformed,
                'weight',
                WeightUsed,
                'rpe',
                RPE_Recorded,
                'notes',
                WorkoutNotes
            )
        FROM WorkoutLog
        WHERE LogID = :log_id
    );
-- Pre-fill the form fields with the existing data extracted from the JSON object.
SELECT 'datetime-local' as type,
    'timestamp' as name,
    'Date & Time' as label,
    json_extract($log_data, '$.timestamp') as value,
    12 as width;
SELECT 'number' as type,
    'sets_recorded' as name,
    'Sets' as label,
    3 as width,
    json_extract($log_data, '$.sets') as value;
SELECT 'text' as type,
    'reps_recorded' as name,
    'Reps (comma-separated)' as label,
    3 as width,
    json_extract($log_data, '$.reps') as value;
SELECT 'number' as type,
    'weight_recorded' as name,
    'Weight (lbs)' as label,
    3 as width,
    json_extract($log_data, '$.weight') as value;
SELECT 'number' as type,
    'rpe_recorded' as name,
    'RPE' as label,
    3 as width,
    json_extract($log_data, '$.rpe') as value;
SELECT 'textarea' as type,
    'notes_recorded' as name,
    'Notes' as label,
    12 as width,
    json_extract($log_data, '$.notes') as value;
----------------------------------------------------
-- STEP 4: DISPLAY THE MAIN WORKOUT LOG TABLE
-- This table is the default view of the page, showing all recorded workouts.
----------------------------------------------------
SELECT 'table' as component,
    'Workout History' as title,
    TRUE as sort,
    TRUE as search;
-- Query to fetch and display all log entries, with action buttons for each row.
SELECT strftime('%Y-%m-%d %H:%M', log.ExerciseTimestamp) as "Date",
    lib.ExerciseName as "Exercise",
    'Sets: ' || log.TotalSetsPerformed || ' Reps: ' || log.RepsPerformed || ' Weight: ' || log.WeightUsed || ' ' || log.WeightUnit || ' RPE: ' || log.RPE_Recorded as "Performance",
    log.WorkoutNotes as "Notes",
    -- This special column creates a button group for edit and delete actions.
    sqlpage.button_group(
        sqlpage.button(
            'Edit',
            'view_workout_logs.sql?action=edit&log_id=' || log.LogID
        ),
        sqlpage.button(
            'Delete',
            'view_workout_logs.sql?action=delete&log_id=' || log.LogID,
            'danger',
            TRUE
        )
    ) as _sqlpage_actions
FROM WorkoutLog as log
    JOIN ExerciseLibrary as lib ON log.ExerciseID = lib.ExerciseID
ORDER BY log.ExerciseTimestamp DESC;