/**
 * @filename      action_change_password.sql
 * @description   Securely handles a user's request to change their password from the profile page.
 * @created       2025-07-03
 * @requires      - The `dimUser` and `sessions` tables.
 * @param         currentPassword [form] The user's existing password for verification.
 * @param         newPassword     [form] The desired new password.
 * @param         confirmPassword [form] Confirmation of the new password.
 * @redirects-to  The profile page with a success or error message.
 */
-- Step 1: Get the current user's ID and stored password hash.
SET
    user_id = (
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token = sqlpage.cookie ('session_token')
    );

SET
    stored_hash = (
        SELECT
            passwordHash
        FROM
            dimUser
        WHERE
            userId = $user_id
    );

-- Step 2: Use the 'authentication' component to verify the user's current password.
-- If the password is incorrect, this will redirect back to the profile page with an error.
SELECT
    'authentication' as component,
    '/views/view_profile.sql?error=The "Current Password" you entered is incorrect.' as link,
    $stored_hash as password_hash,
    :currentPassword as password;

-- The code below only runs if the current password was correct.
-- Step 3: Verify that the new password and confirmation match.
-- If they don't match, redirect back with an error.
SELECT
    'redirect' as component,
    '/views/view_profile.sql?error=The "New Password" and "Confirm New Password" fields do not match.' as link
WHERE
    :newPassword != :confirmPassword;

-- Step 4: If all checks pass, hash the new password and update the database.
UPDATE dimUser
SET
    passwordHash = sqlpage.hash_password (:newPassword)
WHERE
    userId = $user_id;

-- Step 5: Redirect back to the profile page with a success message.
SELECT
    'redirect' as component,
    '/views/view_profile.sql?message=Your password has been updated successfully.' as link;
