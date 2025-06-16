/**
 * @filename      auth_login_action.sql
 * @description   Handles the user login form submission. It validates credentials using
 * SQLPage's built-in `authentication` component. On failure, it redirects to the
 * login form with an error. On success, it creates a new record in the
 * `sessions` table, sets a session cookie, and redirects to the main application.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @requires      - The `users` table to retrieve the stored password hash for verification.
 * @requires      - The `sessions` table to insert a new session record on success.
 * @param         username [form] The username submitted by the user.
 * @param         password [form] The raw password submitted for verification.
 * @returns       A series of components with conditional logic:
 * - **On failure:** An immediate `redirect` to the login form with an error message.
 * - **On success:** A `cookie` component to set the session token, followed by a
 * `redirect` component to the application's root page (`/`).
 * @see           - `auth_login_form.sql` - The form that `POST`s to this action.
 * @see           - `index.sql` - The page the user is redirected to on success.
 * @todo          - Implement logging for failed login attempts to monitor for security threats.
 * @todo          - Make the session duration (`+1 day`) a configurable application setting.
 */
--------------------------------------------------------------------
-- STEP 1: Perform the authentication.
-- If the username is not found OR the password is wrong, this 
-- redirects back to the login page with an error.
--------------------------------------------------------------------
SELECT 'authentication' as component,
    'auth_login_form.sql?error=Invalid username or password. Please try again.' as link,
    (
        SELECT password_hash
        FROM users
        WHERE username = :username
    ) as password_hash,
    :password as password;
-- The code below ONLY runs if authentication was successful.
-------------------------------------------------------------------------
-- STEP 2: Create the session in the database, including the expiry date.
-------------------------------------------------------------------------
SET session_id = sqlpage.random_string(32);
INSERT INTO sessions (session_token, username, expires_at)
VALUES (
        $session_id,
        :username,
        DATETIME('now', '+1 day')
    );
-------------------------------------------------------------------------
-- STEP 3: Set the session cookie in the user's browser.
-------------------------------------------------------------------------
SELECT 'cookie' as component,
    'session_token' as name,
    $session_id as value;
-------------------------------------------------------------------------
-- STEP 4: Redirect to the main application page.
-------------------------------------------------------------------------
SELECT 'redirect' as component,
    '/' as link;
-- SELECT 'alert' as component,
--     'Login Successful!' as title,
--     'Your session has been created.' as description,
--     'success' as color;
-- SELECT 'text' as component,
--     '[Click here to continue to the application](index.sql)' as contents_md;