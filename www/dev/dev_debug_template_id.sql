-- - dev / debug_template_id.sql -- This page is for debugging purposes to inspect parameters passed to it.
-- It displays all GET and POST variables it receives, with a special focus on the 'id' parameter.
------------------------------------------------------
-- STEP 1: RENDER PAGE SKELETON
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 2: RENDER PAGE HEADER
------------------------------------------------------
SELECT 'text' as component,
    'Parameter Debugger' as title,
    'This page shows all the data that was sent to it from the previous page.' as description,
    2 as level;
SELECT 'divider' as component;
------------------------------------------------------
-- STEP 3: HIGHLIGHT THE TEMPLATE ID
------------------------------------------------------
SELECT 'text' as component,
    'Template ID Received' as title,
    4 as level;
-- This card will prominently display the 'id' parameter's value.
-- If this value is empty, you've confirmed the ID is not being sent correctly.
SELECT 'card' as component;
SELECT 'The value of the `id` parameter is:' as description;
SELECT coalesce($id, '!!! ID IS MISSING !!!') as title,
    CASE
        WHEN $id IS NULL THEN 'red'
        ELSE 'green'
    END as color;
------------------------------------------------------
-- STEP 4: DISPLAY ALL RECEIVED VARIABLES
------------------------------------------------------
SELECT 'text' as component,
    'All Received Parameters' as title,
    4 as level;
-- This table lists every single GET and POST variable sent to the page.
SELECT 'table' as component,
    TRUE as sort,
    TRUE as search;
SELECT key as "Parameter Name",
    value as "Parameter Value"
FROM json_each(sqlpage.all_variables());
------------------------------------------------------
-- STEP 5: PROVIDE A WAY BACK
------------------------------------------------------
SELECT 'button' as component;
SELECT 'Go Back to Workouts List' as title,
    '/views/view_workouts.sql' as link,
    'arrow-left' as icon,
    'outline' as style;