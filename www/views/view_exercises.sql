/**
 * @filename      view_exercises.sql
 * @description   A management page for the Exercise Library. It displays all exercises in a
 * table, provides a form to add new custom exercises, and includes links
 * to delete existing ones. This script serves as both the view and its own
 * form handler for add/delete actions.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `ExerciseLibrary` table, which this page reads from and writes to.
 * @param         delete_id [url, optional] The ID of an exercise to be deleted.
 * @param         new_exercise_name [form, optional] The name of a new custom exercise to add.
 * @returns       A full UI page containing a form and a table. If an action parameter is
 * provided (`delete_id` or `new_exercise_name`), it returns a `redirect`
 * component instead to reload the page with fresh data.
 * @note          This page uses the Post-Redirect-Get (PRG) pattern. When an action is
 * submitted, it processes the request and then issues a redirect to itself.
 * This prevents duplicate form submissions if the user refreshes the page.
 * @todo          - Expand the "Add New Exercise" form to include all relevant fields from the
 * `ExerciseLibrary` table (e.g., Body Group, Equipment Type).
 * @todo          - Add an "Edit" button or link for each exercise to allow modification
 * of existing entries.
 */
 ------------------------------------------------------
-- STEP 1: INCLUDE MAIN LAYOUT & AUTHENTICATION
-- This command runs 'layout_main.sql' to apply the standard page design and security.
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 2: HANDLE PAGE ACTIONS (DELETES & INSERTS)
-- This section processes any actions submitted to the page before the content is rendered.
------------------------------------------------------
-- Handle deleting an exercise.
DELETE FROM ExerciseLibrary
WHERE ExerciseID = :delete_id;
-- Handle adding a new exercise.
-- A unique ID is generated, and the 'IsCustom' flag is set to 1.
INSERT INTO ExerciseLibrary (ExerciseID, ExerciseName, LastModified, IsCustom)
SELECT 'EX_' || sqlpage.random_string(16) AS ExerciseID,
    :new_exercise_name AS ExerciseName,
    strftime('%Y-%m-%d %H:%M:%S', 'now') as LastModified,
    1 as IsCustom
WHERE :new_exercise_name IS NOT NULL
    AND :new_exercise_name != '';
-- **FIX**: Redirect after an add or delete action to refresh the page.
-- This ensures the user immediately sees the result of their action.
SELECT 'redirect' as component,
    'view_exercises.sql' as link
WHERE :delete_id IS NOT NULL
    OR (
        :new_exercise_name IS NOT NULL
        AND :new_exercise_name != ''
    );
------------------------------------------------------
-- STEP 3: RENDER THE PAGE CONTENT
------------------------------------------------------
-- Add a title for the page
SELECT 'text' as component,
    '## Exercise Library' as contents_md;
-- Display a form to add a new exercise. It submits back to this same page.
SELECT 'form' as component,
    'Add New Exercise' as title,
    'view_exercises.sql' as action,
    'POST' as method;
SELECT 'text' as type,
    'new_exercise_name' as name,
    'Exercise Name' as label,
    TRUE as required;
-- Display a table of all existing exercises from the ExerciseLibrary
SELECT 'table' as component,
    'Existing Exercises' as title,
    -- Tells SQLPage to render the 'Action' column as Markdown for clickable links.
    JSON_ARRAY('Action') AS markdown;
-- Query to fetch and display all exercises, ordered alphabetically.
SELECT ExerciseName AS "Exercise",
    BodyGroup AS "Body Group",
    EquipmentType AS "Equipment",
    '[Delete](?delete_id=' || ExerciseID || ')' as "Action"
FROM ExerciseLibrary
ORDER BY ExerciseName;