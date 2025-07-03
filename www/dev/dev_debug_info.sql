/**
 * @filename      debug_info.sql
 * @description   A reusable debugging partial that displays all available SQLPage
 * variables and the current user's session information.
 * @created       2025-07-03
 * @last-updated  2025-07-03
 * @usage         To use this on any page, add the following line near the top of the .sql file:
 * SELECT 'dynamic' AS component,
 * sqlpage.run_sql('dev/debug_info.sql') AS properties
 * WHERE $debug = 1;
 * Then, navigate to the page in your browser and append '?debug=1' to the URL.
 */
-- Get the current user's ID from the session cookie, if it exists.
SET
    current_user_id = (
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token = sqlpage.cookie ('session_token')
            AND expires_at > CURRENT_TIMESTAMP
    );

-- Display the debug information in a styled card component for visibility.
SELECT
    'card' as component,
    1 as "width-sm";

SELECT
    'Debug Information' as title,
    'orange' as color,
    'bug' as icon;

-- Display all available variables (GET, POST, Cookies) in a list.
-- The sqlpage.variables() function returns a JSON object of all variables.
SELECT
    'list' as component,
    'Page Variables' as title;

SELECT
    key as title,
    value as description
FROM
    JSON_EACH(sqlpage.variables ());

-- Display the current session information.
SELECT
    'list' as component,
    'Session Information' as title;

SELECT
    'Current User ID' as title,
    COALESCE($current_user_id, 'Not Logged In') as description,
    'user' as icon;

SELECT
    'Session Cookie' as title,
    COALESCE(sqlpage.cookie ('session_token'), 'Not Set') as description,
    'cookie' as icon;
