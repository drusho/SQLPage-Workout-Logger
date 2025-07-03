-- File: www/layouts/user_menu.sql
-- Description: Displays the user-specific part of the navigation menu
-- when a user is logged in.
-- This query uses the $user variable that was set in layout_main.sql
SELECT
    'nav' as component,
    'end' as justify;

SELECT
    $user -> displayName as title,
    '/views/view_profile.sql' as link,
    'user-circle' as icon;

SELECT
    'Logout' as title,
    '/auth/auth_logout.sql' as link,
    'logout' as icon;
