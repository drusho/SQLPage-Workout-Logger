/**
 * @filename      view_workouts.sql
 * @description   Displays a list of all workout plans for the current user.
 * @created       2025-06-18
 * @last-updated  2025-07-06
 * @requires      - `layouts/layout_main.sql` for the page shell and session variables.
 * @requires      - `dimExercisePlan` table.
 * @returns       A UI page with a list of the user's workout plans.
 */
-- Step 1: Load the main layout and get the current user's ID.
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
            AND expires_at>CURRENT_TIMESTAMP
    );

-- Step 2: Display the page header and "Add" button.
SELECT
    'text' as component,
    'Workout Plans' as title;

SELECT
    'button' as component,
    'md' as size;

SELECT
    '/actions/action_add_workout.sql' as link,
    'green' as color,
    'Add Workout Plan' as title,
    'plus' as icon;

-- Step 3: Display the table of workout plans.
SELECT
    'table' as component,
    'Your Plans' as title,
    TRUE as sort,
    TRUE as small,
    'action_link' as markdown;

-- Select all workout plans for the current user, grouped by template name.
SELECT
    templateName AS "Plan Name",
    COUNT(exerciseId) AS "Exercises",
    -- Link to the updated edit page, passing the template name
    '[Edit](/actions/action_edit_workout.sql?template_id='||templateId||')' AS action_link
FROM
    dimExercisePlan
WHERE
    userId=$current_user_id
GROUP BY
    templateName
ORDER BY
    templateName;
