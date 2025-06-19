/**
 * @filename      action_edit_exercise.sql
 * @description   A self-submitting page that displays a form pre-filled with an exercise's current data and processes the UPDATE submission.
 * @created       2025-06-15
 * @last-updated  2025-06-18
 * @requires      - layouts/layout_main.sql: Provides the main UI shell and handles user authentication.
 * @requires      - ExerciseLibrary (table): The source for the exercise data and the target for the UPDATE statement.
 * @requires      - sessions (table): Used to identify the current user and protect the page from guest access.
 * @param         $id [url] The ExerciseID of the record to be edited, passed in the URL on the initial GET request.
 * @param         action [form] A hidden field with the value 'update_exercise' that triggers the UPDATE logic on POST.
 * @param         id [form] A hidden field containing the ExerciseID to update, passed during the POST request.
 * @param         name [form] The new name for the exercise.
 * @param         alias [form, optional] The new alias for the exercise.
 * @param         equipment [form, optional] The new equipment needed for the exercise.
 * @param         body_group [form, optional] The new body group for the exercise.
 * @returns       On a GET request, returns a UI page with the pre-filled form. On a successful POST, returns a redirect component.
 * @see           - /views/view_exercises.sql: The page that links to this edit page and is the destination after a successful update.
 * @note          This script follows the Post-Redirect-Get (PRG) pattern. An authentication check is performed at the start.
 * @note          Each form field is pre-populated by running its own individual query against the database.
 */
 ----------------------------------------------------
-- Step 0: Authentication Guard
-- This block protects the action from being executed by unauthenticated users.
----------------------------------------------------
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
-- This block executes only when the page receives a POST request from the form submission.
------------------------------------------------------
-- This UPDATE statement applies the submitted form data to the correct database record.
-- It also updates the timestamp to reflect the latest modification.
UPDATE ExerciseLibrary
SET ExerciseName = :name,
    ExerciseAlias = :alias,
    BodyGroup = :body_group,
    EquipmentType = :equipment,
    LastModified = strftime('%Y-%m-%d %H:%M:%S', 'now')
WHERE ExerciseID = :id
    AND :action = 'update_exercise';
-- After a successful update, redirect back to the main list.
SELECT 'redirect' as component,
    '/views/view_exercises.sql' as link
WHERE :action = 'update_exercise';
------------------------------------------------------
-- STEP 2: Render Page Skeleton (GET Request)
-- This block sets up the main page structure and title on an initial page load.
------------------------------------------------------
-- Load the main layout, which includes the navigation menu and footer.
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
-- Display a dynamic page title using the name of the exercise being edited.
SELECT 'text' as component,
    'Edit Exercise: ' || (
        SELECT ExerciseName
        FROM ExerciseLibrary
        WHERE ExerciseID = $id
    ) as title;
------------------------------------------------------
-- STEP 3: Render Edit Form (GET Request)
-- This block defines the data entry form. Each field runs a separate query
-- to pre-fill its value with the exercise's current data.
------------------------------------------------------
-- Define the main <form> element.
SELECT 'form' as component,
    'action_edit_exercise.sql' as action,
    'post' as method,
    'green' as validate_color,
    'Update Exercise' as validate,
    'Clear' as reset;
-- Define hidden fields to pass the 'action' and the 'id' to the processing script.
SELECT 'hidden' as type,
    'update_exercise' as value,
    'action' as name;
SELECT 'hidden' as type,
    $id as value,
    'id' as name;
-- Define the visible form fields, pre-filling each with a direct query.
SELECT 'text' as type,
    'name' as name,
    'Exercise Name' as label,
    TRUE as required,
    ExerciseName as value
FROM ExerciseLibrary
WHERE ExerciseID = $id;
SELECT 'text' as type,
    'alias' as name,
    'Alias' as label,
    ExerciseAlias as value
FROM ExerciseLibrary
WHERE ExerciseID = $id;
SELECT 'text' as type,
    'equipment' as name,
    'Equipment' as label,
    EquipmentType as value
FROM ExerciseLibrary
WHERE ExerciseID = $id;
SELECT 'select' as type,
    'body_group' as name,
    'Body Group' as label,
    BodyGroup as value,
    (
        SELECT json_group_array(
                json_object('label', BodyGroup, 'value', BodyGroup)
            )
        FROM (
                SELECT DISTINCT BodyGroup
                FROM ExerciseLibrary
                WHERE BodyGroup IS NOT NULL
                ORDER BY BodyGroup
            )
    ) as options
FROM ExerciseLibrary
WHERE ExerciseID = $id;
-- Define a standalone 'Cancel' button that links back to the main exercise list.
SELECT 'button' as component;
-- 'outline' as style;
SELECT 'Cancel' as title,
    '/views/view_exercises.sql' as link,
    'cancel' as icon,
    'yellow' as outline;