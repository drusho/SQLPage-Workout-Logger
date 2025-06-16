/**
 * @filename      action_update_profile.sql
 * @description   Processes a form submission to update a user's profile information.
 * It uses the session cookie to identify the logged-in user and
 * updates their record in the `users` table with the new data.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @requires      - The `sessions` table to identify the current user.
 * @requires      - The `users` table, which this script updates.
 * @param         sqlpage.cookie('session_token') [cookie] The user's session identifier.
 * @param         display_name [form] The new display name submitted by the user.
 * @param         profile_picture_url [form] The new URL for the user's profile picture.
 * @param         bio [form] The new biography text for the user's profile.
 * @returns       A `redirect` component that sends the user back to their profile page,
 * displaying a success notification upon completion.
 * @see           `profile.sql` - The page that contains the form that initiates this action.
 * @note          This action requires an active user session to function correctly.
 * @todo          - Add server-side validation for input lengths (e.g., bio character limit).
 * @todo          - Implement a check to ensure a user session is valid before the `UPDATE`
 * and show an error message if the session is invalid or expired.
 */
--------------------------------------------------------------------
-- STEP 1: Get the current user's username from their session cookie
--------------------------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
-----------------------------------------------------------------
-- STEP 2 : Update the user's profile information in the database
-----------------------------------------------------------------
UPDATE users
SET display_name = :display_name,
    profile_picture_url = :profile_picture_url,
    bio = :bio
WHERE username = $current_user;
-------------------------------------------------------------------
-- STEP 3: Redirect back to the profile page with a success message
-------------------------------------------------------------------
SELECT 'redirect' as component,
    'profile.sql' as link,
    'Success' as title,
    'Your profile has been updated.' as description;