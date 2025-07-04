/**
 * @filename      action_update_profile.sql
 * @description   Handles the form submission from the profile page to update a
 * user's display name and timezone.
 * @created       2025-06-18
 * @last-updated  2025-07-03
 * @requires      - The `dimUser` and `sessions` tables.
 * @param         displayName [form] The user's new desired display name.
 * @param         timezone    [form] The user's new desired timezone.
 * @redirects-to  The profile page with a success message.
 */
-- Step 1: Get the current user's ID from their session cookie.
SET
    user_id_to_update = (
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token = sqlpage.cookie ('session_token')
            AND expires_at > CURRENT_TIMESTAMP
    );

-- Step 2: Update the user's record in the dimUser table with the new information.
UPDATE dimUser
SET
    displayName = :displayName,
    timezone = :timezone
WHERE
    userId = $user_id_to_update;

-- Step 3: Redirect back to the profile page with a success message.
SELECT
    'redirect' as component,
    '/views/view_profile.sql?message=Your profile has been updated successfully.' as link;
