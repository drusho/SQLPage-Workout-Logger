-- -- Page: /admin/debug_user.sql
-- -- Description: A simple utility to display the raw password hash stored in the database for a user.
-- SELECT
--     'alert' AS component,
--     'Raw Password Hash Inspector' AS title,
--     'info' AS color,
--     'This page displays the exact value stored in the passwordHash column for the user `davidrusho`.' AS description;

-- SELECT
--     'table' AS component;

-- SELECT
--     userId,
--     displayName,
--     passwordHash
-- FROM
--     dimUser
-- WHERE
--     userId = 'davidrusho';

-- SELECT
--     'text' AS component,
--     '---' AS contents;

-- SELECT
--     'alert' AS component,
--     'Next Step: Analysis' AS title,
--     'If the `passwordHash` field above is empty or `NULL`, it means the `reset_admin_password.sql` script did not work correctly. If it contains a long string of text, then the hash exists, and the problem is in the `auth_login_action.sql` script.' AS description;
