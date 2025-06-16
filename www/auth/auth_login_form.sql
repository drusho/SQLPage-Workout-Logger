/**
 * @filename      auth_login_form.sql
 * @description   Renders the user login page. It displays a `form` with `username` and
 * `password` fields that submits to the login action script, and provides
 * a link for new users to navigate to the signup page.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @param         error [url, optional] A message to display in an error alert, passed
 * from the login action upon a failed attempt.
 * @returns       A UI page composed of a `form` component for user login and a `text`
 * component with a link to the signup form.
 * @see           - `auth_login_action.sql` - The action script this form `POST`s to.
 * @see           - `auth_signup_form.sql` - The signup page this page links to.
 * @note          This page is intended for public access by unauthenticated users.
 * @todo          - Implement a conditional `alert` component to display the `error`
 * parameter's contents when it exists in the URL.
 * @todo          - Add a "Forgot Password?" link to a future password recovery page.
 */
----------------------------------
-- STEP 1: Display user login form
----------------------------------
SELECT 'form' as component,
    'Login' as title,
    'Log in' as validate,
    'auth_login_action.sql' as action;
SELECT 'text' as type,
    'username' as name,
    'Username' as label,
    'Enter username' as placeholder,
    true as required;
SELECT 'password' as type,
    'password' as name,
    'Password' as label,
    'Enter password' as placeholder,
    true as required;
----------------------------------
-- STEP 2: Link to the signup page
----------------------------------
SELECT 'text' as component,
    'Don''t have an account? [Sign up here](auth_signup_form.sql).' as contents_md;