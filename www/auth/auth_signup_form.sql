/**
 * @filename      auth_signup_form.sql
 * @description   Renders a page with a form for new users to create an account. It collects
 * a user ID, a public display name, and a password.
 * @created       2025-06-14
 * @last-updated  2025-07-03
 * @returns       A UI page containing a form component for user registration.
 * @see           auth_signup_action.sql - The action script this form submits to for processing.
 * @see           auth_login_form.sql - The login page that typically links to this form.
 */
------------------------------------------------------
-- STEP 1: Display the user registration form.
-- The 'action' parameter specifies that the form data will be sent
-- to 'auth_signup_action.sql' for processing.
------------------------------------------------------
SELECT
    'form' AS component,
    'Create an Account' AS title,
    'auth_signup_action.sql' AS ACTION;

SELECT
    'text' AS type,
    'username' AS name, -- This is received as :username in the action script
    'User ID' AS label,
    'A unique ID for logging in.' AS description,
    true AS required;

SELECT
    'text' AS type,
    'displayName' AS name, -- This is received as :displayName
    'Display Name' AS label,
    'Your public name.' AS description,
    true AS required;

SELECT
    'password' AS type,
    'password' AS name,
    'Password' AS label,
    true AS required;
