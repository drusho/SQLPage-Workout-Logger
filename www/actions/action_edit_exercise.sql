/**
 * @filename      action_edit_exercise.sql
 * @description   A self-submitting page for creating, editing, and deleting an exercise in the catalog.
 * @created       2025-07-05
 * @last-updated  2025-07-05
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - `dimExercise`, `dimUserExercisePreferences`, `sessions` tables.
 * @param         id [url, optional] The exerciseId to edit. If absent, the page is in "create" mode.
 * @param         action [form] The action to perform ('create', 'update').
 * @param         action2 [form] The action to perform for deletion ('delete').
 */
------------------------------------------------------
-- Step 1: Get the current user's ID from the session cookie.
------------------------------------------------------
SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

------------------------------------------------------
-- Step 2: Handle incoming POST requests for creating, updating, and deleting exercises.
-- This section follows the Post-Redirect-Get pattern, where any POST action
-- results in a redirect, preventing duplicate submissions on page refresh.
------------------------------------------------------

-- Action to CREATE a new exercise.
SET
    new_exercise_id=HEX(RANDOMBLOB(16));

INSERT INTO
    dimExercise (
        exerciseId,
        exerciseName,
        bodyGroup,
        equipmentNeeded
    )
SELECT
    $new_exercise_id,
    :exerciseName,
    :bodyGroup,
    :equipmentNeeded
WHERE
    :action='create';

-- After creating, set the user's alias for the new exercise if provided.
INSERT OR IGNORE INTO
    dimUserExercisePreferences (userId, exerciseId, userExerciseAlias)
SELECT
    $current_user_id,
    $new_exercise_id,
    :userExerciseAlias
WHERE
    :action='create'
    AND :userExerciseAlias IS NOT NULL
    AND :userExerciseAlias!='';

-- Action to UPDATE an existing exercise.
-- (Update and Delete logic is included but not the focus of this debug)
UPDATE dimExercise
SET
    exerciseName=:exerciseName,
    bodyGroup=:bodyGroup,
    equipmentNeeded=:equipmentNeeded
WHERE
    exerciseId=:id
    AND :action='update';

DELETE FROM dimUserExercisePreferences
WHERE
    userId=$current_user_id
    AND exerciseId=:id
    AND :action='update';

INSERT INTO
    dimUserExercisePreferences (userId, exerciseId, userExerciseAlias)
SELECT
    $current_user_id,
    :id,
    :userExerciseAlias
WHERE
    :action='update'
    AND :userExerciseAlias IS NOT NULL
    AND :userExerciseAlias!='';


DELETE FROM dimUserExercisePreferences
WHERE
    exerciseId=:id
    AND :action2='delete';

DELETE FROM factWorkoutHistory
WHERE
    exerciseId=:id
    AND :action2='delete';

DELETE FROM dimExercisePlan
WHERE
    exerciseId=:id
    AND :action2='delete';

DELETE FROM dimExercise
WHERE
    exerciseId=:id
    AND :action2='delete';

-- Redirect the user after any POST action.
SELECT
    'redirect' as component,
    '/views/view_exercises.sql?message=Exercise+created' as link
WHERE
    :action='create';

SELECT
    'redirect' as component,
    '/views/view_exercises.sql?message=Exercise+updated' as link
WHERE
    :action='update';

SELECT
    'redirect' as component,
    '/views/view_exercises.sql?message=Exercise+deleted' as link
WHERE
    :action2='delete';
-- =============================================================================
-- Page Rendering Logic (only runs on GET requests)
-- =============================================================================
------------------------------------------------------
-- Step 3: Load the main layout. This will only run if no redirect occurred.
------------------------------------------------------
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

------------------------------------------------------
-- Step 4: Fetch existing exercise data into a JSON object if we are in "Edit" mode.
------------------------------------------------------
SET
    exercise_data=(
        SELECT
            JSON_OBJECT(
                'exerciseName',
                de.exerciseName,
                'bodyGroup',
                de.bodyGroup,
                'equipmentNeeded',
                de.equipmentNeeded,
                'userAlias',
                duep.userExerciseAlias
            )
        FROM
            dimExercise AS de
            LEFT JOIN dimUserExercisePreferences AS duep ON de.exerciseId=duep.exerciseId
            AND duep.userId=$current_user_id
        WHERE
            de.exerciseId=$id
    );

------------------------------------------------------
-- Step 5: Display the page header, which changes based on create or edit mode.
------------------------------------------------------
SELECT
    'text' as component,
    CASE
        WHEN $id IS NULL THEN 'Add New Exercise'
        ELSE 'Edit Exercise'
    END as title;

------------------------------------------------------
-- Step 6: Display the main form for adding or editing exercise details.
------------------------------------------------------
SELECT
    'form' as component,
    'post' as method,
    CASE
        WHEN $id IS NULL THEN 'Create Exercise'
        ELSE 'Update Exercise'
    END as validate,
    'green' as validate_color;

SELECT
    'hidden' as type,
    'action' as name,
    CASE
        WHEN $id IS NULL THEN 'create'
        ELSE 'update'
    END as value;

SELECT
    'hidden' as type,
    'id' as name,
    $id as value
WHERE
    $id IS NOT NULL;

SELECT
    'text' as type,
    'exerciseName' as name,
    'Exercise Name' as label,
    JSON_EXTRACT($exercise_data, '$.exerciseName') as value,
    TRUE as required;

SELECT
    'text' as type,
    'userExerciseAlias' as name,
    'Your Alias (Optional)' as label,
    JSON_EXTRACT($exercise_data, '$.userAlias') as value;

SELECT
    'text' as type,
    'bodyGroup' as name,
    'Body Group' as label,
    JSON_EXTRACT($exercise_data, '$.bodyGroup') as value;

SELECT
    'text' as type,
    'equipmentNeeded' as name,
    'Equipment Needed' as label,
    JSON_EXTRACT($exercise_data, '$.equipmentNeeded') as value;

------------------------------------------------------
-- Step 7: Display the "Delete" form, but only when in "Edit" mode.
------------------------------------------------------
SELECT
    'divider' as component
WHERE
    $id IS NOT NULL;

select
    'form' as component,
    'form-delete-exercise' as id,
    '' as validate
WHERE
    $id IS NOT NULL;

SELECT
    'hidden' as type,
    'action2' as name,
    'delete' as value;

SELECT
    'hidden' as type,
    'id' as name,
    $id as value;

select
    'button' as component
WHERE
    $id IS NOT NULL;

SELECT
    '?action2=delete' as link,
    'form-delete-exercise' as form,
    'Delete Exercise' as title,
    'red' as color,
    'trash' as icon
WHERE
    $id IS NOT NULL;
