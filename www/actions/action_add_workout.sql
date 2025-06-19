/**
 * @filename      action_add_workout.sql
 * @description   A pure action script with no visible UI. It creates a new, empty, and disabled Workout Template record and then immediately redirects the user to the edit page for that new template.
 * @created       2025-06-16
 * @last-updated  2025-06-18
 * @requires      - WorkoutTemplates (table): The target table for the new workout template record.
 * @requires      - sessions (table): Used to identify the current user for the 'CreatedByUserID' field and to protect the page from guest access.
 * @param         sqlpage.cookie('session_token') [cookie]: Implicitly used to identify the logged-in user. This script takes no other parameters.
 * @returns       A `redirect` component that sends the user to the edit page for the newly created workout.
 * @see           - /views/view_workouts.sql: The page that should contain the link that triggers this action.
 * @see           - /actions/action_edit_workout.sql: The destination page where the user is redirected to complete the workout setup.
 * @note          The new workout template is created with a default name and is disabled (`IsEnabled = 0`) by default.
 */
------------------------------------------------------
-- Step 0: Authentication Guard
-- This block protects the action from being executed by unauthenticated users.
----------------------------------------------------
-- First, identify the current user based on the session cookie.
SELECT username
FROM sessions
WHERE session_token = sqlpage.cookie('session_token')
);
SELECT 'redirect' AS component,
    '/auth/auth_guest_prompt.sql' AS link
WHERE $current_user IS NULL;
------------------------------------------------------
-- STEP 1: GENERATE A UNIQUE ID
-- We generate a unique ID first so we can use it in both the INSERT and the redirect.
------------------------------------------------------
SET new_template_id = 'WT_' || sqlpage.random_string(16);
------------------------------------------------------
-- STEP 2: Insert a New Workout Template Record
-- This creates a placeholder record in the database with a temporary name.
-- The template is created in a disabled state (`IsEnabled = 0`) by default.
------------------------------------------------------
INSERT INTO WorkoutTemplates (
        TemplateID,
        TemplateName,
        CreatedByUserID,
        LastModified,
        IsEnabled
    )
VALUES (
        $new_template_id,
        'New Workout ' || strftime('%Y-%m-%d %H:%M', 'now'),
        (
            SELECT username
            FROM sessions
            WHERE session_token = sqlpage.cookie('session_token')
        ),
        strftime('%Y-%m-%d %H:%M:%S', 'now'),
        0 -- We start it as disabled. The user can enable it on the edit page.
    );
------------------------------------------------------
-- STEP 3: Redirect to the Edit Page
-- This script's only output is a redirect, immediately taking the user to the
-- edit page and passing the ID of the newly created template in the URL.
------------------------------------------------------
SELECT 'redirect' as component,
    format(
        '/actions/action_edit_workout.sql?id=%s',
        $new_template_id
    ) as link;