/**
 * @filename      view_exercises.sql
 * @description   Displays a list of all exercises from the dimExercise table. This is the main page for exercise management.
 * @created       2025-06-15
 * @last-updated  2025-07-02
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `dimExercise` and `dimUserExercisePreferences` tables.
 * @returns       A UI page containing a button to add new exercises and a table listing all existing exercises.
 * @see           - `/actions/action_add_exercise.sql` - Page for creating new exercises.
 * @see           - `/actions/action_edit_exercise.sql` - Page for editing an existing exercise.
 * @see           - `/actions/action_delete_exercise.sql` - Page for confirming the deletion of an exercise.
 */
------------------------------------------------------
-- STEP 1: RENDER PAGE STRUCTURE
------------------------------------------------------
-- Load the main layout, which includes the navigation menu and footer.
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;

------------------------------------------------------
-- STEP 2: RENDER PAGE HEADER AND ACTIONS
------------------------------------------------------
-- Display the main title for the page.
SELECT 'text' as component,
    'Exercise Library' as title;

-- Display the "Add Exercise" button, which links to the form page.
select 'button' as component,
    'md' as size;
select '/actions/action_add_exercise.sql' as link,
    'azure' as outline,
    'Add Exercise' as title,
    'plus' as icon;

------------------------------------------------------
-- STEP 3: RENDER THE EXERCISE LIST
------------------------------------------------------
-- Define the table component and specify that the 'Action' column will contain Markdown links.
SELECT 'table' as component,
    'Existing Exercises' as title,
    TRUE as sort,
    TRUE as small,
    'Action' as markdown;

-- Select the data for the table, joining to get user-specific aliases.
SELECT 
    de.exerciseName AS "Exercise",
    -- Show the user's custom alias if it exists
    duep.userExerciseAlias AS "Your Alias",
    de.bodyGroup AS "Body Group",
    de.equipmentNeeded AS "Equipment",
    -- Generate the Edit and Delete links for each exercise
    format(
        '[Edit](/actions/action_edit_exercise.sql?id=%s)',
        de.exerciseId
    ) || ' | ' || format(
        '[Delete](/actions/action_delete_exercise.sql?id=%s)',
        de.exerciseId
    ) AS "Action"
FROM 
    dimExercise AS de
LEFT JOIN 
    dimUserExercisePreferences AS duep ON de.exerciseId = duep.exerciseId AND duep.userId = sqlpage.username
ORDER BY 
    de.exerciseName;
