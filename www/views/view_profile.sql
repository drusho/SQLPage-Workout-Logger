/**
 * @filename      profile.sql
 * @description   Displays the user's profile information within an editable form.
 * Gracefully handles guest users by displaying "Guest" as the name.
 * @created       2025-06-14
 * @last-updated  2025-06-18 16:09:41 MDT
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `sessions` and `users` tables to fetch the current user's data.
 * @param         sqlpage.cookie('session_token') [cookie] Used to identify the logged-in user.
 * @returns       A full UI page containing the user's profile picture (if available) and a
 * form pre-filled with their current profile information.
 * @see           - `action_update_profile.sql` - The script that this page's form submits to.
 * @note          - It safely fetches all user data into a single JSON object (`$user_data`)
 * to prevent errors if some profile fields are empty (`NULL`).
 * @todo          - Consider adding an actual file upload component for the profile picture
 * instead of requiring a URL from the user.
 */
------------------------------------------------------
-- STEP 1: Include the main application layout and authentication check.
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 2: Identify the current user based on their session cookie.
------------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
------------------------------------------------------
-- STEP 3: Load all profile data into a single JSON variable.
-- This is a safe way to fetch data, as it prevents errors if some fields are empty (NULL).
------------------------------------------------------
SET user_data = (
        SELECT json_object(
                'display_name',
                display_name,
                'profile_picture_url',
                profile_picture_url,
                'bio',
                bio
            )
        FROM users
        WHERE username = $current_user
    );
------------------------------------------------------
-- STEP 4: Extract individual values from the JSON object into variables.
-- Use COALESCE to set the display_name to 'Guest' if the user is not logged in.
------------------------------------------------------    
SET display_name = COALESCE(
        json_extract($user_data, '$.display_name'),
        'Guest'
    );
SET profile_picture_url = json_extract($user_data, '$.profile_picture_url');
SET bio = json_extract($user_data, '$.bio');
------------------------------------------------------
-- STEP 5: Conditionally display the user's profile picture.
-- This 'image' component will only render if the user has provided a picture URL.
------------------------------------------------------
SELECT 'image' as component,
    $profile_picture_url as source,
    'Your Profile Picture' as alt,
    200 as width
WHERE $profile_picture_url IS NOT NULL;
------------------------------------------------------
-- STEP 6: Display the profile editing form.
-- The form is pre-filled with the user's current data from the variables we set above.
------------------------------------------------------
SELECT 'form' as component,
    'Edit Your Profile' as title,
    'action_update_profile.sql' as action;
SELECT 'text' as type,
    'display_name' as name,
    'Display Name' as label,
    $display_name as value;
SELECT 'url' as type,
    'profile_picture_url' as name,
    'Profile Picture URL' as label,
    'A link to a public image of you.' as description,
    $profile_picture_url as value;
-- Using 'textarea' for a multi-line bio field.    
SELECT 'textarea' as type,
    'bio' as name,
    'Bio' as label,
    'A short description about yourself.' as description,
    $bio as value;