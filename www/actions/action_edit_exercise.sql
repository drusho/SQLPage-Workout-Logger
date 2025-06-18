/**
 * @filename      edit_exercise.sql
 * @description   Displays a form pre-filled with data for a specific exercise from the `ExerciseLibrary` table.
 * @created       2025-06-15
 * @last-updated  2025-06-15
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `ExerciseLibrary` table, which this script reads from to populate the form.
 * @param         $id [url] The `ExerciseID` of the record to be edited, passed in the URL.
 * @returns       A UI page containing a form pre-filled with the data for the specified exercise.
 * @see           - `view_exercises.sql` - The page that links to this edit page.
 * @see           - `../actions/action_edit_exercise.sql` - The script that processes this form's submission.
 * @note          The form fields are pre-populated using a separate, direct database query for each field.
 */
------------------------------------------------------
-- STEP 1: HANDLE FORM SUBMISSION
-- This block runs first when the form is POSTed.
------------------------------------------------------
-- The UPDATE statement uses the submitted form fields (e.g., :name, :alias)
-- and the hidden :id field to update the correct database row.
UPDATE ExerciseLibrary
SET ExerciseName = :name,
    ExerciseAlias = :alias,
    BodyGroup = :body_group,
    EquipmentType = :equipment,
    LastModified = strftime('%Y-%m-%d %H:%M:%S', 'now')
WHERE ExerciseID = :id
    AND :action = 'update_exercise';
-- After a successful update, redirect back to the main list.
SELECT 'redirect' as component,
    '/views/view_exercises.sql' as link
WHERE :action = 'update_exercise';
------------------------------------------------------
-- STEP 2: RENDER PAGE STRUCTURE
-- This block sets up the basic visual shell and title for the page.
------------------------------------------------------
-- Load the main layout, which includes the navigation menu and footer.
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
-- Display a dynamic page title using the name of the exercise being edited.
SELECT 'text' as component,
    'Edit Exercise: ' || (
        SELECT ExerciseName
        FROM ExerciseLibrary
        WHERE ExerciseID = $id
    ) as title;
------------------------------------------------------
-- STEP 3: RENDER THE 'EDIT EXERCISE' FORM
-- This block defines all the components that make up the input form.
------------------------------------------------------
-- Define the main <form> element. It now POSTs to a dedicated action script.
SELECT 'form' as component,
    'action_edit_exercise.sql' as action,
    'post' as method,
    'green' as validate_color,
    'Update Exercise' as validate,
    'Clear' as reset;
-- Define hidden fields to pass the 'action' and the 'id' to the processing script.
SELECT 'hidden' as type,
    'update_exercise' as value,
    'action' as name;
SELECT 'hidden' as type,
    $id as value,
    'id' as name;
-- Define the visible form fields, pre-filling each with a direct query.
SELECT 'text' as type,
    'name' as name,
    'Exercise Name' as label,
    TRUE as required,
    ExerciseName as value
FROM ExerciseLibrary
WHERE ExerciseID = $id;
SELECT 'text' as type,
    'alias' as name,
    'Alias' as label,
    ExerciseAlias as value
FROM ExerciseLibrary
WHERE ExerciseID = $id;
SELECT 'text' as type,
    'equipment' as name,
    'Equipment' as label,
    EquipmentType as value
FROM ExerciseLibrary
WHERE ExerciseID = $id;
SELECT 'select' as type,
    'body_group' as name,
    'Body Group' as label,
    BodyGroup as value,
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
    ) as options
FROM ExerciseLibrary
WHERE ExerciseID = $id;
-- Define a standalone 'Cancel' button that links back to the main exercise list.
SELECT 'button' as component;
-- 'outline' as style;
SELECT 'Cancel' as title,
    '/views/view_exercises.sql' as link,
    'cancel' as icon,
    'yellow' as outline;