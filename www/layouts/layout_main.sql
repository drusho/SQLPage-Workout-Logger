/**
 * @filename      layout_main.sql
 * @description   The main application shell. It handles session validation and
 * dynamically builds the navigation menu from an external JSON file.
 * @created       2025-07-03
 * @last-updated  2025-07-03
 * @requires      - `assets/navigation.json` to define the menu structure.
 * @requires      - `sessions` and `dimUser` tables for authentication.
 */
-- Step 1: Get the current user's ID and display name. These will be NULL if not logged in.
SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
            AND expires_at>CURRENT_TIMESTAMP
    );

SET
    current_user_display_name=(
        SELECT
            displayName
        FROM
            dimUser
        WHERE
            userId=$current_user_id
    );

-- Step 2: Read the navigation configuration file into a variable.
SET
    nav_config=sqlpage.read_file_as_text ('assets/navigation.json');

-- Step 3: Define the main application shell and dynamically build the navigation menu.
SELECT
    'shell' AS component,
    'Workout Logger' AS title,
    'barbell' as icon,
    '/' AS link,
    'en-US' as lang,
    'auto' as theme,
    '/assets/custom_form_layout.css' as css,
    -- Use a CASE statement to select the correct menu and personalize it.
    CASE
        WHEN $current_user_id IS NOT NULL THEN
        -- For logged-in users, get the user_menu and replace the placeholder with their name.
        REPLACE(
            JSON_EXTRACT($nav_config, '$.user_menu'),
            '"PROFILE_PLACEHOLDER"',
            '"'||$current_user_display_name||'"'
        )
        ELSE
        -- For guests, just use the guest_menu as-is.
        JSON_EXTRACT($nav_config, '$.guest_menu')
    END as menu_item;
