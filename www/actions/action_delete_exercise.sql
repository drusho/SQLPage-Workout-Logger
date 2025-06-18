/**
 * @filename      delete_exercise.sql
 * @description   Displays a confirmation form to prevent accidental deletion of an exercise. Processes the soft-delete action upon confirmation.
 * @created       2025-06-15
 * @last-updated  2025-06-15
 * @requires      - `../layouts/layout_main.sql` for the page shell.
 * @requires      - The `ExerciseLibrary` table, which this script reads from and updates.
 * @param         $id [url] The `ExerciseID` of the record to be deleted.
 * @param         action [form] A hidden parameter with the value 'delete_exercise' to trigger the UPDATE statement.
 * @param         id [form] A hidden parameter containing the ExerciseID to delete.
 * @param         confirmation [form] The user-typed exercise name, required to confirm the deletion.
 * @returns       On successful submission, a `redirect` component. Otherwise, returns a UI page with the confirmation form.
 * @see           - `view_exercises.sql` - The page that links to this delete page.
 * @note          This performs a "soft delete" by setting `IsEnabled = 0`, not a hard `DELETE` from the database.
 */
------------------------------------------------------
-- STEP 1: HANDLE FORM SUBMISSION (SOFT DELETE)
-- This block runs first and only processes a POST request from the confirmation form.
------------------------------------------------------
-- This UPDATE statement will only run if the submitted 'confirmation' text
-- exactly matches the exercise's name in the database.
UPDATE ExerciseLibrary
SET IsEnabled = 0,
    LastModified = strftime('%Y-%m-%d %H:%M:%S', 'now')
WHERE ExerciseID = :id
    AND :action = 'delete_exercise'
    AND :confirmation = (
        SELECT ExerciseName
        FROM ExerciseLibrary
        WHERE ExerciseID = :id
    );
-- After a successful deletion, redirect back to the main list page.
SELECT 'redirect' as component,
    '/views/view_exercises.sql' as link
WHERE :action = 'delete_exercise';
------------------------------------------------------
-- STEP 2: RENDER THE CONFIRMATION PAGE
-- This block runs on a normal GET request to display the page.
------------------------------------------------------
-- First, get the name of the exercise we are about to delete, using the $id from the URL.
SET exercise_name_to_delete = (
        SELECT ExerciseName
        FROM ExerciseLibrary
        WHERE ExerciseID = $id
    );
-- Load the main page layout.
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
-- UPDATED: New page title and subtitle section.
SELECT 'text' as component,
    'Delete Exercise: ' || (
        SELECT ExerciseName
        FROM ExerciseLibrary
        WHERE ExerciseID = $id
    ) as title;
SELECT 'text' as component,
    'You are about to delete the exercise: **' || $exercise_name_to_delete || '**. This is a safe "soft delete", but it will hide the exercise from lists. To proceed, please type the full name of the exercise into the box below and click the delete button.' as content_md;
-- Define the confirmation form.
SELECT 'form' as component,
    'action_delete_exercise.sql' as action,
    'post' as method,
    'Delete ' || $exercise_name_to_delete as validate,
    'red' as validate_color;
-- Hidden fields to pass the action and id back to the action handler.
SELECT 'hidden' as type,
    'delete_exercise' as value,
    'action' as name;
SELECT 'hidden' as type,
    $id as value,
    'id' as name;
-- The confirmation text input.
-- The 'pattern' property uses browser validation to ensure the user types the exact name.
SELECT 'text' as type,
    'confirmation' as name,
    'Type "' || $exercise_name_to_delete || '" to confirm' as label,
    TRUE as required,
    $exercise_name_to_delete as pattern;
-- A standalone 'Cancel' button that links back to the main exercise list.
SELECT 'button' as component;
-- 'outline' as style;
SELECT 'Cancel' as title,
    '/views/view_exercises.sql' as link,
    'cancel' as icon,
    'yellow' as outline;