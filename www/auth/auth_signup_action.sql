/**
 * @filename     auth_signup_action.sql (prev. create_user.sql)
 * @description  Handles the new user registration form submission from auth_signup_form.sql.
 * It takes the submitted username, display name, and password, securely hashes
 * the password using sqlpage.hash_password(), and inserts the new user
 * record into the 'users' table.
 * @note         This is a server-side action script with no visible output. Its only
 * function is to create a user and redirect.
 * @param        :username     The desired username for the new account.
 * @param        :display_name  The public-facing name for the new user.
 * @param        :password      The user's chosen password (in plain text).
 * @redirects-to auth_login_form.sql (with a success message)
 * @last-updated 2025-06-14
 */

------------------------------------------------------
-- STEP 1: Insert the new user into the database.
-- The sqlpage.hash_password() function creates a secure, one-way hash
-- of the user's password before it is stored.
------------------------------------------------------
INSERT INTO users (username, display_name, password_hash)
VALUES (
        :username,
        :display_name,
        sqlpage.hash_password(:password)
    );
------------------------------------------------------
-- STEP 2: Redirect to the login page.
-- A 'title' URL parameter is added to show a success message to the new user.
------------------------------------------------------    
SELECT 'redirect' as component,
    'auth_login_form.sql?title=Account created successfully! Please log in.' as link;