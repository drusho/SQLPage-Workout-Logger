/**
 * @filename      action_delete_history.sql
 * @description   A self-submitting page that displays a confirmation form to prevent accidental deletion of a workout log. It also handles reverting any progression changes that were triggered by the deleted log.
 * @created       2025-07-01
 * @last-updated  2025-07-02
 * @requires      - layouts/layout_main.sql: Provides the main UI shell and authentication.
 * @requires      - WorkoutLog, WorkoutSetLog, UserExerciseProgression, UserExerciseProgressionHistory, sessions (tables).
 * @param         $id [url] The LogID of the record to be deleted, passed in the URL.
 * @param         action [form] A hidden field with the value 'delete_log' that triggers the DELETE logic on POST.
 * @param         id [form] A hidden field containing the LogID to delete, passed during the POST request.
 * @param         confirmation [form] The user-typed exercise name, which must match the actual name to confirm the deletion.
 * @returns       On a GET request, returns a UI page with the confirmation form. On a successful POST, returns a redirect component.
 * @see           - /views/view_history.sql: The page the user is returned to after a successful deletion.
 * @see           - /actions/action_edit_history.sql: The page that links to this confirmation page.
 * @note          This script performs a "hard delete" by permanently removing the record from WorkoutLog. Associated sets in WorkoutSetLog are removed automatically via a cascading delete trigger in the database.
 * @note          Before deleting the log, the script checks the UserExerciseProgressionHistory table. If the log being deleted had previously triggered a progression, the script reverts the changes in the UserExerciseProgression table to restore the user's progression to its prior state.
 */
------------------------------------------------------
-- Step 0: Authentication Guard
-- This block protects the action from being executed by unauthenticated users.
----------------------------------------------------
-- First, identify the current user based on the session cookie
SET
    current_user = (
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token = sqlpage.cookie ('session_token')
    );

SELECT
    'redirect' AS component,
    '/auth/auth_guest_prompt.sql' AS link
WHERE
    $current_user IS NULL;

------------------------------------------------------
-- STEP 1: Process Form Submission (POST Request)
-- This block executes only when the confirmation form is submitted.
------------------------------------------------------
-- STEP 1.0: Check for and Revert Progression Changes before Deletion
-- Find the progression change that was triggered by the log we are about to delete.
SET
    history_to_revert = (
        SELECT
            JSON_OBJECT(
                'UserID',
                UserID,
                'ExerciseID',
                ExerciseID,
                'TemplateID',
                TemplateID,
                'OldStepNumber',
                OldStepNumber,
                'Old1RMEstimate',
                OldCycle1RMEstimate
            )
        FROM
            UserExerciseProgressionHistory
        WHERE
            LogID = :id
    );

-- If a history record was found, it means we need to revert the main progression table.
UPDATE UserExerciseProgression
SET
    CurrentStepNumber = JSON_EXTRACT($history_to_revert, '$.OldStepNumber'),
    CurrentCycle1RMEstimate = JSON_EXTRACT($history_to_revert, '$.Old1RMEstimate')
WHERE
    UserID = JSON_EXTRACT($history_to_revert, '$.UserID')
    AND ExerciseID = JSON_EXTRACT($history_to_revert, '$.ExerciseID')
    AND TemplateID = JSON_EXTRACT($history_to_revert, '$.TemplateID')
    AND $history_to_revert IS NOT NULL;

-- 1.1: First, delete any progression history records linked to this workout log.
-- This must be done before deleting the WorkoutLog entry itself to avoid violating foreign key constraints if they were enforced.
DELETE FROM UserExerciseProgressionHistory
WHERE
    LogID = :id
    AND :action = 'delete_log'
    AND :confirmation = (
        SELECT
            el.ExerciseName
        FROM
            WorkoutLog AS wl
            JOIN ExerciseLibrary AS el ON wl.ExerciseID = el.ExerciseID
        WHERE
            wl.LogID = :id
    );

-- 1.2: Second, perform the hard delete on the WorkoutLog table.
-- The WHERE clause includes a critical safety check to ensure the user-typed
-- :confirmation text exactly matches the exercise's name in the database for the given LogID.
DELETE FROM WorkoutLog
WHERE
    LogID = :id
    AND :action = 'delete_log'
    AND :confirmation = (
        SELECT
            el.ExerciseName
        FROM
            WorkoutLog AS wl
            JOIN ExerciseLibrary AS el ON wl.ExerciseID = el.ExerciseID
        WHERE
            wl.LogID = :id
    );

-- 1.3: After a successful deletion, redirect back to the main history page.
SELECT
    'redirect' AS component,
    '/views/view_history.sql?deleted=true' AS link
WHERE
    :action = 'delete_log';

------------------------------------------------------
-- STEP 2: RENDER THE CONFIRMATION PAGE
-- This block runs on a normal GET request to display the page.
------------------------------------------------------
-- First, get the name and date of the log we are about to delete, using the $id from the URL.
SET
    log_details = (
        SELECT
            JSON_OBJECT(
                'ExerciseName',
                el.ExerciseName,
                'WorkoutDate',
                STRFTIME('%Y-%m-%d', wl.ExerciseTimestamp, 'unixepoch')
            )
        FROM
            WorkoutLog wl
            JOIN ExerciseLibrary el ON wl.ExerciseID = el.ExerciseID
        WHERE
            wl.LogID = $id
    );

SET
    exercise_name_to_delete = JSON_EXTRACT($log_details, '$.ExerciseName');

SET
    workout_date_to_delete = JSON_EXTRACT($log_details, '$.WorkoutDate');

-- Load the main page layout.
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

-- Page title and subtitle section.
SELECT
    'text' AS component,
    'Delete Workout Log' AS title;

SELECT
    'text' AS component,
    'You are about to permanently delete the workout log for **' || $exercise_name_to_delete || '** from **' || $workout_date_to_delete || '**. This action cannot be undone and will also remove any progression history triggered by this specific workout. To proceed, please type the full name of the exercise into the box below and click the delete button.' AS content_md;

-- Define the confirmation form.
SELECT
    'form' AS component,
    'action_delete_history.sql' AS ACTION,
    'post' AS method,
    'Delete Log for ' || $exercise_name_to_delete AS validate,
    'red' AS validate_color;

-- Hidden fields to pass the action and id back to the action handler.
SELECT
    'hidden' AS type,
    'delete_log' AS value,
    'action' AS name;

SELECT
    'hidden' AS type,
    $id AS value,
    'id' AS name;

-- The confirmation text input.
-- The 'pattern' property uses browser validation to ensure the user types the exact name.
SELECT
    'text' AS type,
    'confirmation' AS name,
    'Type "' || $exercise_name_to_delete || '" to confirm' AS label,
    TRUE AS required,
    $exercise_name_to_delete AS pattern;

-- A standalone 'Cancel' button that links back to the main history view.
SELECT
    'button' AS component;

SELECT
    'Cancel' AS title,
    '/views/view_history.sql' AS link,
    'cancel' AS icon,
    'yellow' AS outline;