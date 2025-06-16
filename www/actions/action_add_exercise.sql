/**
 * @filename      add_exercise.sql
 * @description   Displays a form to create a new entry in the `ExerciseLibrary` table and processes the form submission.
 * @created       2025-06-15
 * @last-updated  2025-06-15
 * @requires      - `../layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `ExerciseLibrary` table, which this script reads from (for dropdowns) and writes to.
 * @param         action [form] A hidden parameter with the value 'add_exercise' to trigger the INSERT statement.
 * @param         name [form] The name of the new exercise.
 * @param         alias [form, optional] An optional alias for the new exercise.
 * @param         body_group [form, optional] The body group for the new exercise, selected from a dropdown.
 * @param         equipment [form, optional] The equipment needed for the new exercise.
 * @returns       On successful submission, a `redirect` component that sends the user back to the main exercise list. Otherwise, returns a UI page with a `form`.
 * @see           - `view_exercises.sql` - The page that links to this one and to which this page redirects.
 * @note          This page is self-submitting and uses the Post-Redirect-Get (PRG) pattern.
 * @todo          - Add server-side validation to prevent creating exercises with duplicate names.
 */
------------------------------------------------------
-- STEP 1: HANDLE FORM SUBMISSION
-- This block runs first. It processes the submitted form data from a POST request
-- before any HTML is rendered.
------------------------------------------------------
-- Insert the new exercise into the database if the action is 'add_exercise'.
INSERT INTO ExerciseLibrary (
        ExerciseID,
        ExerciseName,
        ExerciseAlias,
        BodyGroup,
        EquipmentType,
        LastModified,
        IsCustom,
        IsEnabled
    )
SELECT 'EX_' || sqlpage.random_string(16),
    :name,
    :alias,
    :body_group,
    :equipment,
    strftime('%Y-%m-%d %H:%M:%S', 'now'),
    1,
    1
WHERE :action = 'add_exercise';
-- If the insert was successful, redirect the user back to the main list.
-- This follows the Post-Redirect-Get (PRG) pattern to prevent re-submissions.
SELECT 'redirect' as component,
    '/views/view_exercises.sql' as link
WHERE :action = 'add_exercise';
------------------------------------------------------
-- STEP 2: RENDER PAGE STRUCTURE
-- This block sets up the basic visual shell and title for the page.
-- It only runs on a GET request or after the action handlers above are complete.
------------------------------------------------------
-- Load the main layout, which includes the navigation menu and footer.
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
-- Display the main title for the page.
SELECT 'text' as component,
    'Add New Exercise' as title;
------------------------------------------------------
-- STEP 3: RENDER THE 'ADD EXERCISE' FORM
-- This block defines all the components that make up the input form.
------------------------------------------------------
-- Define the main <form> element and its properties.
-- It uses the built-in 'validate' and 'reset' properties to create the form buttons.
SELECT 'form' as component,
    'action_add_exercise.sql' as action,
    'post' as method,
    'green' as validate_color,
    'Add Exercise' as validate,
    'Clear' as reset;
-- Include a hidden field to identify the form submission.
-- This is what the 'WHERE :action = ...' clause in Step 1 checks for.
SELECT 'hidden' as type,
    'add_exercise' as value,
    'action' as name;
-- Define the visible form fields for user input.
SELECT 'text' as type,
    'name' as name,
    'Exercise Name' as label,
    TRUE as required;
SELECT 'text' as type,
    'alias' as name,
    'Alias' as label;
SELECT 'text' as type,
    'equipment' as name,
    'Equipment' as label;
SELECT 'select' as type,
    'body_group' as name,
    'Body Group' as label,
    (
        SELECT json_group_array(
                json_object('label', BodyGroup, 'value', BodyGroup)
            )
        FROM (
                SELECT DISTINCT BodyGroup
                FROM ExerciseLibrary
                WHERE BodyGroup IS NOT NULL
                ORDER BY BodyGroup
            )
    ) as options;
-- Define a standalone 'Cancel' button that links back to the main exercise list.
SELECT 'button' as component,
    'outline' as style;
SELECT 'Cancel' as title,
    '/views/view_exercises.sql' as link;