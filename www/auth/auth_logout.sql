/**
 * @filename      auth_logout.sql
 * @description   Logs a user out by terminating their current session. It deletes the
 * session record from the `sessions` table, sends a command to the browser
 * to clear the `session_token` cookie, and then redirects to the login page.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @requires      - The `sessions` table, from which the user's session is deleted.
 * @param         sqlpage.cookie('session_token') [cookie] The token used to identify which
 * session record to delete from the database.
 * @returns       A `cookie` component to clear the session token from the browser, followed
 * by a `redirect` component sending the user to the login page.
 * @see           - `auth_login_form.sql` - The page the user is redirected to after logout.
 * @see           - `layouts/layout_main.sql` - The likely location of the "Logout" link.
 * @note          This script requires a user to be logged in with a valid session cookie
 * to have any effect.
 * @todo          - Pass a success message to the login form (e.g., `?message=...`) and
 * update the form to be able to display it.
 * @todo          - Consider adding a "log out from all devices" feature, which would
 * require getting the username and deleting all of their associated sessions.
 */
------------------------------------------------------
-- STEP 1: Delete the user's session from the database
------------------------------------------------------
DELETE FROM sessions
WHERE session_token = sqlpage.cookie('session_token');
-------------------------------------------------------
-- STEP 2: Clear the cookie from the browser by setting
-- its value to empty and expiring it
-------------------------------------------------------
SELECT 'cookie' as component,
    'session_token' as name,
    '' as value,
    0 as max_age;
-------------------------------------------------------
-- STEP 3: Redirect to the login page
-------------------------------------------------------    
SELECT 'redirect' as component,
    'auth_login_form.sql' as link;