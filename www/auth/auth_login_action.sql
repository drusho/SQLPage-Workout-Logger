/**
 * @filename      auth_login_action.sql
 * @description   Handles the user login form submission. It manually verifies the
 * password against the stored hash, creates a session record on success,
 * sets a session cookie, and redirects the user.
 * @created       2025-06-14
 * @last-updated  2025-07-03
 * @requires      - The `dimUser` table to retrieve the stored password hash.
 * @requires      - The `sessions` table to insert a new session record.
 * @param         username [form] The userId submitted by the user.
 * @param         password [form] The raw password submitted for verification.
 * @redirects-to  On success, redirects to the main application page ('/').
 * @redirects-to  On failure, redirects to the login form with an error message.
 */
-- ------------------------------------------------------------------
-- STEP 1: Perform the authentication.
-- This component handles the password check securely. If the password hash
-- from the database does not match the provided password, it will automatically
-- redirect to the specified link with an error message.
-- ------------------------------------------------------------------
SELECT
    'authentication' AS component,
    '/auth/auth_login_form.sql?error=Invalid User ID or password.' AS link,
    -- Use COALESCE to provide a dummy hash if the user is not found.
    -- This ensures the authentication component fails correctly instead of erroring.
    COALESCE(
        (
            SELECT
                passwordHash
            FROM
                dimUser
            WHERE
                userId = :username
        ),
        'invalid_hash'
    ) AS password_hash,
    :password AS password;

-- The code below ONLY runs if authentication was successful.
-------------------------------------------------------------------------
-- STEP 2: Create the session in the database.
-------------------------------------------------------------------------
SET
    session_id = sqlpage.random_string (32);

INSERT INTO
    sessions (session_token, username, expires_at)
VALUES
    ($session_id, :username, DATETIME('now', '+1 day'));

-------------------------------------------------------------------------
-- STEP 3: Set the session cookie in the user's browser.
-------------------------------------------------------------------------
SELECT
    'cookie' AS component,
    'session_token' AS name,
    $session_id AS value;

-------------------------------------------------------------------------
-- STEP 4: Redirect to the main application page.
-------------------------------------------------------------------------
SELECT
    'redirect' AS component,
    '/' AS link;
