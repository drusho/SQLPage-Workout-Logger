/**
 * @filename      view_progression_models.sql
 * @description   Displays a list of all user-created progression models and provides a link to create new ones.
 * @created       2025-07-04
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - `dimProgressionModel` and `sessions` tables.
 * @returns       A UI page for viewing and managing progression models.
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
    );

-- Step 2: Display the page header and "Add" button.
SELECT
    'text' as component,
    'Progression Model Library' as title;

SELECT
    'text' as component,
    'Create and manage your reusable progression models.' as description;

SELECT
    'button' as component,
    'md' as size;

SELECT
    -- This links to the edit page without an ID, which puts it in "create" mode.
    '/actions/action_edit_progression_model.sql' as link,
    'green' as color,
    'Add Model' as title,
    'plus' as icon;

-- Step 3: Display the table of existing progression models.
SELECT
    'divider' as component;

SELECT
    'table' as component,
    'Your Models' as title,
    TRUE as sort,
    'Action' as markdown;

SELECT
    modelName AS "Model Name",
    modelType AS "Type",
    description AS "Description",
    FORMAT(
        '[Edit](/actions/action_edit_progression_model.sql?id=%s)',
        progressionModelId
    ) AS "Action"
FROM
    dimProgressionModel
WHERE
    userId=$current_user_id
ORDER BY
    modelName;
