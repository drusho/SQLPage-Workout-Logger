/**
 * @filename      auth_login_form.sql
 * @description   Renders the user login page. It displays a form for the user to
 * enter their User ID and password, and includes a component to display
 * any error messages passed in the URL.
 * @created       2025-06-14
 * @last-updated  2025-07-03
 * @param         error [url, optional] A message to display in an error alert, passed
 * from the login action upon a failed attempt.
 * @returns       A UI page composed of a form component for user login.
 * @see           - /auth/auth_login_action.sql - The action script this form POSTs to.
 * @see           - /auth/auth_signup_form.sql - The signup page this page links to.
 */
SELECT
    'form' AS component,
    'Login' AS title,
    'Log in' AS validate,
    'auth_login_action.sql' AS action;

SELECT
    'text' AS type,
    'username' AS name,
    'User ID' AS label,
    'Enter your User ID' AS placeholder,
    true AS required;

-- true AS required;
SELECT
    'password' AS type,
    'password' AS name,
    'Password' AS label,
    'Enter password' AS placeholder,
    true AS required;

-- Step 3: Link to the signup page
SELECT
    'text' AS component,
    'Don''t have an account? [Sign up here](/auth/auth_signup_form.sql).' AS contents_md;

SELECT
    'divider' AS component;

SELECT
    'text' AS component,
    '[Test Auth Action Page](auth_login_action.sql)' AS contents_md;