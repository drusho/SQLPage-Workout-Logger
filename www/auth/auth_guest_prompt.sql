/**
 * @filename      guest_prompt.sql
 * @description   An interstitial page shown to guests who try to perform an action that
 * requires an account. It explains why they should log in or sign up.
 * @created       2025-06-18
 */
------------------------------------------------------
-- Use the main layout for a consistent look and feel
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- Display a card with the explanation and call-to-action buttons
------------------------------------------------------

SELECT 'text' as component,
    "# You're logged in as a Guest
    " as contents_md,
    -- 'https://sqlpage.com/images/guest.png' as image_url,
    -- 'https://sqlpage.com/images/guest.png' as image_alt,
    -- 'chart-infographic' as icon,
    false as center;
SELECT 'text' as component,
    'You''ve discovered a feature for registered users! \
    Creating a free account allows you to log your workouts, track your progress over time, and build custom routines.' as contents_md;
-- Use a list component to display buttons in a row
SELECT 'list' as component,
    'actions' as class;
SELECT 'Create a Free Account' as title,
    '/auth/auth_signup_form.sql' as link,
    'user-plus' as icon,
    'green' as color;
SELECT 'Login to Your Account' as title,
    '/auth/auth_login_form.sql' as link,
    'login' as icon,
    'blue' as color;
SELECT 'Continue Browse as a Guest' as title,
    '/' as link,
    'arrow-left' as icon,
    'gray' as color;