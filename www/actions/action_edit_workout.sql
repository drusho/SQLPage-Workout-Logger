/**
 * @filename      action_edit_workout.sql
 * @description   A complex, self-submitting page for managing a single Workout Template. It handles updating the template's main details and allows for adding, removing, and updating exercises within the template.
 * @created       2025-06-16
 * @last-updated  2025-06-18
 * @requires      - layouts/layout_main.sql: For the main UI shell and authentication.
 * @requires      - actions/action_get_workout_template.sql: A helper script used to fetch template data as JSON.
 * @requires      - WorkoutTemplates, TemplateExerciseList, ExerciseLibrary, ProgressionModels, sessions (tables): Used for various read/write operations.
 * @param         $id [url] The TemplateID of the workout being edited.
 * @param         action [url/form] Determines which database operation to perform (e.g., 'update_details', 'remove_exercise').
 * @param         remove_id [url] The TemplateExerciseListID of the exercise link to delete.
 * @param         workout_name, workout_description, is_enabled [form] Parameters for updating the template details.
 * @param         tel_id, exercise_id, progression_model_id, order_in_workout [form] Parameters for updating an exercise in the list.
 * @returns       A UI page for editing the workout. All database actions result in a redirect back to this same page.
 * @note          This script is a "single-page CRUD" interface that handles multiple distinct actions, all routing back to itself using the Post-Redirect-Get (PRG) pattern.
 */
----------------------------------------------------
-- Step 0: Authentication Guard
----------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
SELECT 'redirect' AS component,
    '/auth/auth_guest_prompt.sql' AS link
WHERE $current_user IS NULL;
----------------------------------------------------
-- Step 0.5: Validate Template ID
-- This entire page depends on a valid TemplateID from the URL ($id) or form (:id).
-- If it's missing or empty, redirect the user back to the main workout list page.
----------------------------------------------------
SELECT 'redirect' as component,
    '/views/view_workouts.sql?error=No+template+selected' as link
WHERE (
        $id IS NULL
        OR $id = ''
    )
    AND (
        :id IS NULL
        OR :id = ''
    );
-- Use the ID from the form if available, otherwise use the one from the URL.
SET id = COALESCE(:id, $id);
----------------------------------------------------
-- STEP 1: Handle Incoming Actions (Post-Redirect-Get Pattern)
----------------------------------------------------
-- Action to update the main workout template details from the form in Step 3.
UPDATE WorkoutTemplates
SET TemplateName = :workout_name,
    Description = :workout_description,
    IsEnabled = COALESCE(:is_enabled, 0),
    LastModifiedTimestamp = strftime('%s', 'now')
WHERE TemplateID = :id
    AND :action = 'update_details';
-- Action to remove an exercise's association from this template.
DELETE FROM TemplateExerciseList
WHERE TemplateExerciseListID = :remove_id
    AND :action = 'remove_exercise';
-- Action to update a single exercise's properties in the list.
UPDATE TemplateExerciseList
SET ProgressionModelID = :progression_model_id,
    ExerciseID = :exercise_id,
    OrderInWorkout = :order_in_workout,
    LastModifiedTimestamp = strftime('%s', 'now')
WHERE TemplateExerciseListID = :tel_id
    AND :action = 'update_exercise';
-- Action to add a new, empty exercise slot to the template's list.
INSERT INTO TemplateExerciseList (
        TemplateExerciseListID,
        TemplateID,
        OrderInWorkout,
        IsEnabled,
        LastModifiedTimestamp
    )
SELECT 'ET_' || sqlpage.random_string(16),
    :id,
    COALESCE(MAX(OrderInWorkout), 0) + 1,
    1,
    strftime('%s', 'now')
FROM TemplateExerciseList
WHERE TemplateID = :id
    AND :action = 'add_slot';
-- After any action, redirect back to this same edit page to show the changes.
SELECT 'redirect' as component,
    format('/actions/action_edit_workout.sql?id=%s', :id) as link
WHERE :action IS NOT NULL;
----------------------------------------------------
-- STEP 2: Load Page Skeleton (GET Request)
----------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
----------------------------------------------------
-- STEP 3: Render Workout Details Form (GET Request)
----------------------------------------------------
SELECT 'text' as component,
    'Edit Workout Template' as title,
    2 as level;
SELECT 'divider' as component;
-- Form for editing the main workout properties.
SELECT 'form' as component,
    'Update Details' as title,
    'action_edit_workout.sql' as action,
    'post' as method;
SELECT 'hidden' as type,
    'id' as name,
    $id as value;
SELECT 'hidden' as type,
    'update_details' as name,
    'update_details' as value;
-- Fetch all workout data into a single JSON variable.
SELECT sqlpage.read_file_as_json('actions/action_get_workout_template.sql', $id) as workout;
SELECT 'text' as type,
    'workout_name' as name,
    'Workout Name' as label,
    TRUE as required,
    $workout.TemplateName as value;
SELECT 'textarea' as type,
    'workout_description' as name,
    'Description' as label,
    $workout.Description as value;
SELECT 'switch' as type,
    'is_enabled' as name,
    'Workout is Active' as label,
    'Enabled' as post_text,
    TRUE as value,
    CAST($workout.IsEnabled AS BOOLEAN) as checked;
----------------------------------------------------
-- STEP 4: Render Exercise Management List (GET Request)
----------------------------------------------------
SELECT 'text' as component,
    'Exercises in this Workout' as title,
    3 as level;
-- Use a LIST component to loop through each exercise associated with the template.
SELECT 'list' as component,
    'No exercises have been added to this template yet.' as empty_message;
SELECT format(
        '%s. %s',
        OrderInWorkout,
        COALESCE(el.ExerciseName, '!!! SELECT AN EXERCISE !!!')
    ) as title,
    tel.TemplateExerciseListID as description,
    'form' as item_component,
    'action_edit_workout.sql' as action,
    'Remove' as danger_button,
    format(
        '/actions/action_edit_workout.sql?id=%s&action=remove_exercise&remove_id=%s',
        $id,
        tel.TemplateExerciseListID
    ) as danger_button_link
FROM TemplateExerciseList tel
    LEFT JOIN ExerciseLibrary el ON tel.ExerciseID = el.ExerciseID
WHERE tel.TemplateID = $id
ORDER BY tel.OrderInWorkout;
-- These form fields render inside EACH list item created by the query above.
SELECT 'hidden' as type,
    'id' as name,
    $id as value;
SELECT 'hidden' as type,
    'update_exercise' as name,
    'update_exercise' as value;
SELECT 'hidden' as type,
    'tel_id' as name,
    $description as value;
-- Dropdown to select the EXERCISE from the library for this slot.
SELECT 'select' as type,
    'exercise_id' as name,
    'Exercise' as label,
    'Select an exercise' as placeholder,
    'SELECT ExerciseName as label, ExerciseID as value FROM ExerciseLibrary WHERE IsEnabled = 1 ORDER BY ExerciseName' as options,
    (
        SELECT ExerciseID
        from TemplateExerciseList
        WHERE TemplateExerciseListID = $description
    ) as value,
    'auto' as "submit-on-change";
-- Dropdown to select the PROGRESSION MODEL for this exercise.
SELECT 'select' as type,
    'progression_model_id' as name,
    'Progression Model' as label,
    'SELECT ProgressionModelName as label, ProgressionModelID as value FROM ProgressionModels ORDER BY ProgressionModelName' as options,
    (
        SELECT ProgressionModelID
        FROM TemplateExerciseList
        WHERE TemplateExerciseListID = $description
    ) as value,
    'auto' as "submit-on-change";
-- Number input for the ORDER of this exercise in the workout.
SELECT 'number' as type,
    'order_in_workout' as name,
    'Order' as label,
    1 as step,
    (
        SELECT OrderInWorkout
        FROM TemplateExerciseList
        WHERE TemplateExerciseListID = $description
    ) as value,
    'auto' as "submit-on-change";
----------------------------------------------------
-- STEP 5: Render "Add New Slot" Button (GET Request)
----------------------------------------------------
SELECT 'divider' as component;
-- This button is a simple link that reloads the page with an 'add_slot' action.
SELECT 'button' as component;
SELECT 'Add New Exercise Slot' as title,
    format(
        '/actions/action_edit_workout.sql?id=%s&action=add_slot',
        $id
    ) as link,
    'plus' as icon,
    'green' as color;