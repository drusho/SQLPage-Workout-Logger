/**
 * @filename      auth_logout.sql
 * @description   Logs a user out by terminating their current session. It deletes the
 * session record from the `sessions` table and clears the session cookie.
 * @created       2025-06-14
 * @last-updated  2025-07-03
 * @requires      - The `sessions` table, from which the user's session is deleted.
 * @param         sqlpage.cookie('session_token') [cookie] The token used to identify which
 * session record to delete from the database.
 * @redirects-to  auth_login_form.sql
 */
------------------------------------------------------
-- STEP 1: Delete the user's session from the database
------------------------------------------------------
DELETE FROM sessions
WHERE
    session_token = sqlpage.cookie ('session_token');

-------------------------------------------------------
-- STEP 2: Clear the cookie from the browser by setting
-- its value to empty and expiring it
-------------------------------------------------------
SELECT
    'cookie' AS component,
    'session_token' AS name,
    '' AS value,
    0 AS max_age;

-------------------------------------------------------
-- STEP 3: Redirect to the login page
-------------------------------------------------------    
SELECT
    'redirect' AS component,
    'auth_login_form.sql' AS link;
