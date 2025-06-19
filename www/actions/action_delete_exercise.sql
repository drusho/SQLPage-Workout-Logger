/**
 * @filename      action_delete_exercise.sql
 * @description   A self-submitting page that displays a confirmation form to prevent accidental deletion and processes a "soft delete" (by setting IsEnabled = 0) upon user confirmation.
 * @created       2025-06-15
 * @last-updated  2025-06-18
 * @requires      - layouts/layout_main.sql: Provides the main UI shell and handles user authentication.
 * @requires      - ExerciseLibrary (table): The source for the exercise name and the target for the UPDATE statement.
 * @requires      - sessions (table): Used to identify the current user and protect the page from guest access.
 * @param         $id [url] The ExerciseID of the record to be deleted, passed in the URL on the initial GET request.
 * @param         action [form] A hidden field with the value 'delete_exercise' that triggers the UPDATE logic on POST.
 * @param         id [form] A hidden field containing the ExerciseID to delete, passed during the POST request.
 * @param         confirmation [form] The user-typed exercise name, which must match the actual name to confirm the deletion.
 * @returns       On a GET request, returns a UI page with the confirmation form. On a successful POST, returns a redirect component.
 * @see           - /views/view_exercises.sql: The page that links to this confirmation page and is the destination after a successful deletion.
 * @note          This script performs a "soft delete" by setting the `IsEnabled` flag to 0, not by permanently removing the record.
 * @note          It includes a safety mechanism requiring the user to type the full exercise name to confirm the action.
 */
------------------------------------------------------
-- Step 0: Authentication Guard
-- This block protects the action from being executed by unauthenticated users.
----------------------------------------------------
-- First, identify the current user based on the session cookie
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
SELECT 'redirect' AS component,
    '/auth/auth_guest_prompt.sql' AS link
WHERE $current_user IS NULL;
------------------------------------------------------
-- STEP 1: Process Form Submission (POST Request)
-- This block executes only when the confirmation form is submitted.
------------------------------------------------------
-- This UPDATE statement performs the soft delete by setting IsEnabled = 0.
-- The WHERE clause includes a critical safety check to ensure the user-typed
-- :confirmation text exactly matches the exercise's name in the database.
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