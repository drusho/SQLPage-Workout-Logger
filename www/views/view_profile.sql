/**
 * @filename      view_profile.sql
 * @description   Displays an editable form for the user's profile information. It allows the user
 * to update their display name, profile picture URL, bio, and timezone. The form is
 * pre-filled with the user's current data.
 * @created       2025-06-18
 * @last-updated  2025-06-30
 * @requires      - layouts/layout_main.sql: For the main UI shell and authentication.
 * @requires      - sessions (table): To identify the current logged-in user.
 * @requires      - users (table): To read and pre-fill the user's profile data.
 * @param         sqlpage.cookie('session_token') [cookie] Implicitly used to identify the logged-in user.
 * @returns       A full UI page containing a form pre-filled with the user's current profile information.
 * @see           - /actions/action_update_profile.sql: The script that this page's form submits to.
 * @note          It safely fetches all user data into a single JSON object (`$user_data`) to prevent
 * errors if some profile fields are empty (NULL).
 */
------------------------------------------------------
-- STEP 1: Include the main application layout and authentication check.
------------------------------------------------------
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

------------------------------------------------------
-- STEP 2: Identify the current user based on their session cookie.
------------------------------------------------------
SET
    current_user = (
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token = sqlpage.cookie ('session_token')
    );

------------------------------------------------------
-- STEP 3: Load all profile data into a single JSON variable.
-- This is a safe way to fetch data, as it prevents errors if some fields are empty (NULL).
------------------------------------------------------
SET
    user_data = (
        SELECT
            JSON_OBJECT(
                'username',
                username,
                'display_name',
                COALESCE(display_name, username),
                'profile_picture_url',
                profile_picture_url,
                'bio',
                bio,
                'timezone',
                timezone
            )
        FROM
            users
        WHERE
            username = $current_user
    );

------------------------------------------------------
-- STEP 4: Extract individual values from the JSON object into variables.
-- Use COALESCE to set the display_name to 'Guest' if the user is not logged in.
------------------------------------------------------    
SET
    display_name = COALESCE(
        JSON_EXTRACT($user_data, '$.display_name'),
        'Guest'
    );

SET
    profile_picture_url = JSON_EXTRACT($user_data, '$.profile_picture_url');

SET
    bio = JSON_EXTRACT($user_data, '$.bio');

------------------------------------------------------
-- STEP 5: Display the profile editing form.
-- The form is pre-filled with the user's current data from the variables we set above.
------------------------------------------------------
SELECT
    'form' AS component,
    'Edit Your Profile' AS title,
    '/actions/action_update_profile.sql' AS ACTION,
    'Update Profile' AS validate,
    'green' AS validate_color;

-- Form fields
SELECT
    'text' AS type,
    'display_name' AS name,
    'Display Name' AS label,
    JSON_EXTRACT($user_data, '$.display_name') AS value;

SELECT
    'text' AS type,
    'profile_picture_url' AS name,
    'Profile Picture URL' AS label,
    JSON_EXTRACT($user_data, '$.profile_picture_url') AS value;

SELECT
    'textarea' AS type,
    'bio' AS name,
    'Bio' AS label,
    JSON_EXTRACT($user_data, '$.bio') AS value;

-- Timezone selector dropdown
SELECT
    'select' AS type,
    'timezone' AS name,
    'Timezone' AS label,
    'Select your timezone' AS empty_option,
    TRUE AS searchable,
    JSON_EXTRACT($user_data, '$.timezone') AS value,
    -- A partial list of common timezones. You can expand this list as needed.
    JSON_GROUP_ARRAY(JSON_OBJECT('value', value, 'label', label)) AS options
FROM
    (
        SELECT
            'America/New_York' AS value,
            '(GMT-04:00) Eastern Time' AS label
        UNION ALL
        SELECT
            'America/Chicago',
            '(GMT-05:00) Central Time'
        UNION ALL
        SELECT
            'America/Denver',
            '(GMT-06:00) Mountain Time'
        UNION ALL
        SELECT
            'America/Los_Angeles',
            '(GMT-07:00) Pacific Time'
        UNION ALL
        SELECT
            'America/Anchorage',
            '(GMT-08:00) Alaska'
        UNION ALL
        SELECT
            'America/Honolulu',
            '(GMT-10:00) Hawaii'
        UNION ALL
        SELECT
            'Europe/London',
            '(GMT+01:00) London'
        UNION ALL
        SELECT
            'Europe/Paris',
            '(GMT+02:00) Paris'
        UNION ALL
        SELECT
            'Asia/Tokyo',
            '(GMT+09:00) Tokyo'
    );

SELECT
    'button' AS component,
    'sm' AS size,
    'pill' AS shape;

SELECT
    'Purple' AS title,
    'purple' AS outline;

SELECT
    'Orange' AS title,
    'orange' AS outline;

SELECT
    'Red' AS title,
    'red' AS outline;