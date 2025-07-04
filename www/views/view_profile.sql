/**
 * @filename      view_profile.sql
 * @description   Displays forms for the logged-in user to update their profile
 * information (display name, timezone) and change their password.
 * @created       2025-06-18
 * @last-updated  2025-07-03
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - The `dimUser` and `sessions` tables to fetch the current user's data.
 * @requires      - `assets/timezones.json` to populate the timezone dropdown.
 * @returns       A UI page with pre-filled forms for profile management.
 */
------------------------------------------------------
-- Step 1: Load the main layout.
------------------------------------------------------
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

------------------------------------------------------
-- Step 2: Get all necessary information for the current user in a single query.
-- This single query joins the sessions and user tables to fetch all data at once.
------------------------------------------------------
SET
    current_user_data=(
        SELECT
            JSON_OBJECT(
                'userId',
                s.username,
                'displayName',
                u.displayName,
                'timezone',
                u.timezone
            )
        FROM
            sessions s
            JOIN dimUser u ON s.username=u.userId
        WHERE
            s.session_token=sqlpage.cookie ('session_token')
            AND s.expires_at>CURRENT_TIMESTAMP
    );

-- Extract the needed values from the JSON object into variables.
SET
    current_user_id=JSON_EXTRACT($current_user_data, '$.userId');

SET
    current_user_display_name=JSON_EXTRACT($current_user_data, '$.displayName');

SET
    user_timezone=JSON_EXTRACT($current_user_data, '$.timezone');

------------------------------------------------------
-- Step 3: Display any success or error messages passed back from action scripts.
------------------------------------------------------
SELECT
    'alert' as component,
    'Success' as title,
    $message as description,
    'success' as color
WHERE
    $message IS NOT NULL;

SELECT
    'alert' as component,
    'Error' as title,
    $error as description,
    'danger' as color
WHERE
    $error IS NOT NULL;

------------------------------------------------------
-- Step 4: Display the page header.
------------------------------------------------------
SELECT
    'text' as component,
    'User Profile: '||$current_user_id as title;

------------------------------------------------------
-- Step 5: Display the form to update display name and timezone.
------------------------------------------------------
SELECT
    'form' as component,
    'Update Profile' as title,
    '/actions/action_update_profile.sql' as action,
    'Update Profile' as validate;

SELECT
    'text' as type,
    'displayName' as name,
    'Display Name' as label,
    $current_user_display_name as value,
    4 as width,
    true as required;

SELECT
    'select' as type,
    'timezone' as name,
    'Timezone' as label,
    'Select your timezone' as placeholder,
    4 as width,
    $user_timezone as value,
    -- A list of common IANA timezones to populate the dropdown.
    (
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT(
                    'value',
                    JSON_EXTRACT(value, '$.value'),
                    'label',
                    JSON_EXTRACT(value, '$.label')
                )
            )
        FROM
            JSON_EACH(
                sqlpage.read_file_as_text ('assets/timezones.json')
            )
    ) AS options;

------------------------------------------------------
-- Step 6: Display the form to change the password.
------------------------------------------------------
SELECT
    'form' as component,
    'Change Password' as title,
    '/actions/action_change_password.sql' as action,
    'Change Password' as validate;

SELECT
    'password' as type,
    'currentPassword' as name,
    'Current Password' as label,
    10 as width,
    true as required;

SELECT
    'password' as type,
    'newPassword' as name,
    'New Password' as label,
    5 as width,
    true as required;

SELECT
    'password' as type,
    'confirmPassword' as name,
    'Confirm New Password' as label,
    5 as width,
    true as required;
