/**
 * @filename      auth_signup_form.sql
 * @description   Renders a page with a form for new users to create an account. It collects
 * a `username`, a public `display_name`, and a `password`, then `POST`s the
 * data to the signup action script.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @returns       A UI page containing a `form` component for user registration.
 * @see           auth_signup_action.sql - The action script this form submits to for processing.
 * @see           auth_login_form.sql - The login page that typically links to this form.
 * @note          This page is for public access and does not require a user to be logged in.
 * @todo          - Add a `Confirm Password` field to the form to prevent user typos. The
 * action script must then be updated to verify the passwords match.
 * @todo          - Implement a mechanism to display errors returned from `auth_signup_action.sql`,
 * such as when a username is already taken.
 * @todo          - Add a text link for users who already have an account, pointing back
 * to `auth_login_form.sql`.
 */
------------------------------------------------------
-- STEP 1: Display the user registration form.
-- The 'action' parameter specifies that the form data will be sent
-- to 'auth_signup_action.sql' for processing.
------------------------------------------------------
SELECT 'form' as component,
    'Create an Account' as title,
    'auth_signup_action.sql' as action;
SELECT 'text' as type,
    'username' as name,
    'Username' as label,
    'A unique username for logging in.' as description,
    true as required;
SELECT 'text' as type,
    'display_name' as name,
    'Display Name' as label,
    'Your public name.' as description,
    true as required;
SELECT 'password' as type,
    'password' as name,
    'Password' as label,
    true as required;