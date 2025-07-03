-- File: www/layouts/layout_main.sql (Final Corrected Version)
-- Description: The main application shell. Handles session validation and builds
-- the navigation menu dynamically based on the user's login status.
-- Step 1: Get the current user's ID and display name from the session cookie.
-- These variables will be NULL if the user is not logged in.
SET
    current_user_id = (
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token = sqlpage.cookie ('session_token')
            AND expires_at > CURRENT_TIMESTAMP
    );

SET
    current_user_display_name = (
        SELECT
            displayName
        FROM
            dimUser
        WHERE
            userId = $current_user_id
    );

-- Step 2: Define the main application shell and dynamically build the navigation menu.
SELECT
    'shell' AS component,
    'Workout Logger' AS title,
    'run-fast' as icon,
    '/' AS link,
    'en-US' as lang,
    'auto' as theme,
    -- Use a CASE statement to build the correct JSON for the menu based on login status.
    CASE
        WHEN $current_user_id IS NOT NULL THEN
        -- If the user is logged in, show this menu:
        JSON_ARRAY(
            JSON_OBJECT(
                'title',
                'Workouts',
                'link',
                '/',
                'icon',
                'activity'
            ),
            JSON_OBJECT(
                'title',
                'History',
                'link',
                '/views/view_history.sql',
                'icon',
                'history'
            ),
            JSON_OBJECT(
                'title',
                'Exercises',
                'link',
                '/views/view_exercises.sql',
                'icon',
                'weight'
            ),
            JSON_OBJECT(
                'title',
                $current_user_display_name,
                'link',
                '/views/view_profile.sql',
                'icon',
                'user-circle'
            ),
            JSON_OBJECT(
                'title',
                'Logout',
                'link',
                '/auth/auth_logout.sql',
                'icon',
                'logout'
            )
        )
        ELSE
        -- If the user is a guest, show this menu:
        JSON_ARRAY(
            JSON_OBJECT(
                'title',
                'Workouts',
                'link',
                '/',
                'icon',
                'activity'
            ),
            JSON_OBJECT(
                'title',
                'History',
                'link',
                '/views/view_history.sql',
                'icon',
                'history'
            ),
            JSON_OBJECT(
                'title',
                'Exercises',
                'link',
                '/views/view_exercises.sql',
                'icon',
                'weight'
            ),
            JSON_OBJECT(
                'title',
                'Login',
                'link',
                '/auth/auth_login_form.sql',
                'icon',
                'login'
            ),
            JSON_OBJECT(
                'title',
                'Sign Up',
                'link',
                '/auth/auth_signup_form.sql',
                'icon',
                'user-plus'
            )
        )
    END as menu_item;
