-- www/components/unplanned_workout_form.sql
-- This file contains only the form for logging an unplanned workout.
-- It will be embedded inside the modal on the index page.

-- Fetch the list of all exercises for the dropdown menu
SET all_exercises = (
    SELECT JSON_GROUP_ARRAY(JSON_OBJECT('label', exerciseName, 'value', exerciseId)) 
    FROM dimExercise 
    ORDER BY exerciseName
);

-- The form that will be displayed inside the modal
SELECT 
    'form' as component, 
    '/actions/action_edit_history.sql' as action, 
    'modal-log-form' as id, -- The javascript targets this ID
    'Save Workout' as validate;

    -- This form submits to the existing action page to save the data
    SELECT 'hidden' as type, 'action' as name, 'save_log' as value;

    -- Dropdown to select any exercise
    SELECT 'select' as type, 'exercise_id_new' as name, 'Exercise' as label, TRUE as required, TRUE as searchable, 'Select an Exercise' as empty_option, $all_exercises as options;
    
    -- Inputs for sets (example for 3 sets)
    SELECT 'header' as type, 'Set 1' as label;
    SELECT 'number' as type, 'reps_1' as name, 'Reps' as placeholder, 4 as width, 0.01 as step;
    SELECT 'number' as type, 'weight_1' as name, 'Weight' as placeholder, 4 as width, 0.01 as step;

    SELECT 'header' as type, 'Set 2' as label;
    SELECT 'number' as type, 'reps_2' as name, 'Reps' as placeholder, 4 as width, 0.01 as step;
    SELECT 'number' as type, 'weight_2' as name, 'Weight' as placeholder, 4 as width, 0.01 as step;

    SELECT 'header' as type, 'Set 3' as label;
    SELECT 'number' as type, 'reps_3' as name, 'Reps' as placeholder, 4 as width, 0.01 as step;
    SELECT 'number' as type, 'weight_3' as name, 'Weight' as placeholder, 4 as width, 0.01 as step;
    
    -- RPE and Notes
    SELECT 'number' as type, 'rpe_recorded' as name, 'RPE' as placeholder, 4 as width, 0.01 as step, 10 as max;
    SELECT 'textarea' as type, 'notes_recorded' as name, 'Notes' as placeholder;