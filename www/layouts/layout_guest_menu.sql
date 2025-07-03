-- File: www/layouts/guest_menu.sql
-- Description: Displays the guest-specific part of the navigation menu
-- for users who are not logged in.
SELECT
    'nav' AS component,
    'end' AS justify;

SELECT
    'Login' AS title,
    '/auth/auth_login_form.sql' AS link,
    'login' AS icon;

SELECT
    'Sign Up' AS title,
    '/auth/auth_signup_form.sql' AS link,
    'user-plus' AS icon;
