-- #############################################################################
-- STEP 1: HANDLE INCOMING ACTIONS (Post-Redirect-Get Pattern)
-- #############################################################################
-- Action to update the main workout template details
UPDATE WorkoutTemplates
SET TemplateName = :workout_name,
    Description = :workout_description,
    IsEnabled = COALESCE(:is_enabled, 0),
    LastModified = strftime('%Y-%m-%d %H:%M:%S', 'now')
WHERE TemplateID = :id
    AND :action = 'update_details';
-- Action to remove an exercise's association from this template
-- This performs a hard DELETE from the association table, not a soft delete.
-- The exercise will still exist in the ExerciseLibrary.
DELETE FROM TemplateExerciseList
WHERE TemplateExerciseListID = :remove_id
    AND :action = 'remove_exercise';
-- Action to update the progression model or order for a single exercise in the list
UPDATE TemplateExerciseList
SET ProgressionModelID = :progression_model_id,
    OrderInWorkout = :order_in_workout,
    LastModified = strftime('%Y-%m-%d %H:%M:%S', 'now')
WHERE TemplateExerciseListID = :tel_id
    AND :action = 'update_exercise';
-- Action to add a new, empty exercise slot to the template
-- It defaults to the highest order number + 1.
INSERT INTO TemplateExerciseList (
        TemplateExerciseListID,
        TemplateID,
        OrderInWorkout,
        IsEnabled,
        LastModified
    )
SELECT -- Generate a unique ID for the new entry
    lower(hex(randomblob(16))),
    :id,
    COALESCE(MAX(OrderInWorkout), 0) + 1,
    1,
    strftime('%Y-%m-%d %H:%M:%S', 'now')
FROM TemplateExerciseList
WHERE TemplateID = :id
    AND :action = 'add_slot';
-- After any action, redirect back to this same edit page to show the changes and clear the form variables.
SELECT 'redirect' as component,
    format('/actions/action_edit_workout.sql?id=%s', :id) as link
WHERE :action IS NOT NULL;
-- #############################################################################
-- STEP 2: LOAD THE MAIN PAGE LAYOUT
-- #############################################################################
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
-- #############################################################################
-- STEP 3: WORKOUT DETAILS FORM
-- #############################################################################
-- Display the page title and a separator.
SELECT 'text' as component,
    'Edit Workout Template' as title,
    2 as level;
SELECT 'divider' as component;
-- Form for editing the main workout properties.
SELECT 'form' as component,
    'Update Details' as title,
    format('/actions/action_edit_workout.sql?id=%s', $id) as action,
    'post' as method;
-- Hidden field to specify which action this form triggers
SELECT 'hidden' as type,
    'update_details' as name,
    'update_details' as value;
-- Fetch all workout data into a single variable to avoid multiple queries
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
    -- The IsEnabled column is an INTEGER in the database
    CAST($workout.IsEnabled AS BOOLEAN) as checked;
-- #############################################################################
-- STEP 4: MANAGE EXISTING EXERCISES (The part you needed help with)
-- #############################################################################
SELECT 'text' as component,
    'Exercises in this Workout' as title,
    3 as level;
-- Use a LIST component to loop through each exercise associated with the template.
-- Each item in the list will be its own mini-form for updating or a link for deleting.
SELECT 'list' as component,
    'No exercises have been added to this template yet.' as empty_message;
-- This query generates the content for each item in the list.
SELECT -- Display the exercise name and its current order
    format(
        '%s. %s',
        OrderInWorkout,
        COALESCE(el.ExerciseName, '!!! SELECT AN EXERCISE !!!')
    ) as title,
    tel.TemplateExerciseListID as description,
    -- for debugging
    -- This is the form for UPDATING the exercise's properties
    'form' as item_component,
    format('/actions/action_edit_workout.sql?id=%s', $id) as action,
    -- This is the link to REMOVE the exercise from the template
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
-- These are the form fields that will appear for EACH exercise listed above.
-- The context for these fields is the row returned by the query above.
SELECT 'hidden' as type,
    'update_exercise' as name,
    'update_exercise' as value;
SELECT 'hidden' as type,
    'tel_id' as name,
    $description as value;
-- $description holds the TemplateExerciseListID
-- Dropdown to select the EXERCISE from the library
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
-- Dropdown to select the PROGRESSION MODEL
SELECT 'select' as type,
    'progression_model_id' as name,
    'Progression Model' as label,
    'SELECT ProgressionModelName as label, ProgressionModelID as value FROM ProgressionModels ORDER BY ProgressionModelName' as options,
    (
        SELECT ProgressionModelID
        FROM TemplateExerciseList
        WHERE TemplateExerciseListID = $description
    ) as value,
    -- pre-selects current model
    'auto' as "submit-on-change";
-- Number input for the ORDER
SELECT 'number' as type,
    'order_in_workout' as name,
    'Order' as label,
    1 as step,
    $title as value,
    -- $title holds the formatted '1. Exercise Name' string, which works for the value
    'auto' as "submit-on-change";
-- #############################################################################
-- STEP 5: ADD NEW EXERCISE SLOT
-- #############################################################################
SELECT 'divider' as component;
-- A simple button that links to this same page with an action in the URL.
-- The action at the top of the file will catch this and run the INSERT statement.
SELECT 'button' as component;
SELECT 'Add New Exercise Slot' as title,
    format(
        '/actions/action_edit_workout.sql?id=%s&action=add_slot',
        $id
    ) as link,
    'plus' as icon,
    'green' as color;