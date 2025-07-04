/**
 * @filename      library.sql
 * @description   A central landing page for managing application resources like exercises and workout plans.
 * @created       2025-07-03
 */
-- Step 1: Load the main layout.
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

-- Step 2: Display the page header.
SELECT
    'text' as component,
    'Resource Library' as title;

SELECT
    'text' as component,
    'Manage your exercises and workout routines from here.' as contents_md;

-- Step 3: Display navigation cards.
SELECT
    'card' as component,
    2 as columns;

-- Card for Exercise Catalog
SELECT
    'list' as component;

SELECT
    'Exercise Catalog' as title,
    'Browse, create, and manage all available exercises.' as description,
    '/views/view_exercises.sql' as link,
    'barbell' as icon,
    'blue' as color;

-- Card for My Routines
SELECT
    'list' as component;

SELECT
    'My Routines' as title,
    'Design, view, and manage your custom workout routines and templates.' as description,
    '/views/view_workouts.sql' as link,
    'notebook' as icon,
    'green' as color;
