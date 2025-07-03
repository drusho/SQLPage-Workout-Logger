/**
 * @filename     auth_signup_action.sql
 * @description  Handles the new user registration form submission. It securely hashes
 * the password and inserts the new user record into the 'dimUser' table.
 * @created      2025-06-14
 * @last-updated 2025-07-03
 * @requires     The `dimUser` table.
 * @param        :username     The desired user ID for the new account.
 * @param        :displayName  The public-facing name for the new user.
 * @param        :password      The user's chosen password (in plain text).
 * @redirects-to auth_login_form.sql (with a success message)
 */
------------------------------------------------------
-- STEP 1: Insert the new user into the database.
-- The sqlpage.hash_password() function creates a secure, one-way hash
-- of the user's password before it is stored.
------------------------------------------------------
INSERT INTO
    dimUser (userId, displayName, passwordHash)
VALUES
    (
        :username,
        :displayName,
        sqlpage.hash_password (:password)
    );

------------------------------------------------------
-- STEP 2: Redirect to the login page.
-- A 'title' URL parameter is added to show a success message to the new user.
------------------------------------------------------    
SELECT
    'redirect' AS component,
    'auth_login_form.sql?title=Account created successfully! Please log in.' AS link;
