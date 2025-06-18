/**
 * @filename      view_exercises.sql
 * @description   Displays a list of all enabled exercises from the `ExerciseLibrary`. This is the main page for exercise management.
 * @created       2025-06-15
 * @last-updated  2025-06-15
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `ExerciseLibrary` table to populate the list.
 * @returns       A UI page containing a button to add new exercises and a table listing all existing exercises.
 * @see           - `/actions/action_add_exercise.sql` - Page for creating new exercises.
 * @see           - `/actions/action_edit_exercise.sql` - Page for editing an existing exercise.
 * @see           - `/actions/action_delete_exercise.sql` - Page for confirming the deletion of an exercise.
 * @note          This page links to other pages for specific actions (add, edit, delete), following a multi-page application pattern.
 */
------------------------------------------------------
-- STEP 1: RENDER PAGE STRUCTURE
-- This block sets up the basic visual shell for the page.
------------------------------------------------------
-- Load the main layout, which includes the navigation menu and footer.
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 2: RENDER PAGE HEADER AND ACTIONS
-- This block displays the page title and primary action buttons.
------------------------------------------------------
-- Display the main title for the page.
SELECT 'text' as component,
    'Exercise Library' as title;
-- Display the "Add Exercise" button, which links to the form page.
select 'button' as component,
    'md' as size;
select '/actions/action_add_exercise.sql' as link,
    -- FIX: This must link to the form page, not the action script.
    'azure' as outline,
    'Add Exercise' as title,
    'plus' as icon;
------------------------------------------------------
-- STEP 3: RENDER THE EXERCISE LIST
-- This block defines and populates the main data table.
------------------------------------------------------
-- Define the table component and specify that the 'Action' column will contain Markdown links.
SELECT 'table' as component,
    'Existing Exercises' as title,
    TRUE as sort,
    'Action' as markdown;
-- Select the data for the table.
SELECT ExerciseName AS "Exercise",
    ExerciseAlias AS "Alias",
    BodyGroup AS "Body Group",
    EquipmentType AS "Equipment",
    -- FIX: Links must point to the view/edit/delete pages in the '/views/' folder, not the action scripts.
    format(
        '[Edit](/actions/action_edit_exercise.sql?id=%s)',
        ExerciseID
    ) || ' | ' || format(
        '[Delete](/actions/action_delete_exercise.sql?id=%s)',
        ExerciseID
    ) AS "Action"
FROM ExerciseLibrary
WHERE IsEnabled = 1
ORDER BY ExerciseName;