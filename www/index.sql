/**
 * @filename      index.sql
 * @description   The main application dashboard for logging a workout. This is a multi-step,
 * self-reloading form that uses the new database views to display progression
 * targets and a dynamic, multi-set form for logging.
 * @created       2025-06-14
 * @last-updated  2025-06-17
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - `views/UserExerciseProgressionTargets` VIEW for target calculations.
 * @requires      - `views/WorkoutTemplateDetails` VIEW for listing exercises.
 * @param         template_id [url, optional] The ID of the selected workout template.
 * @param         selected_exercise_id [url, optional] The ID of the chosen exercise to log.
 * @returns       A full UI page that progressively reveals more components as the user makes selections.
 * @see           - `actions/action_save_workout.sql` - The script that the new multi-set form will submit to.
 * @note          This page uses a progressive disclosure UI. The workout logging form (Step 6)
 * is hidden until an exercise is selected in Step 5.
 * @note          The target data query is now robust, providing default values if no pre-existing
 * progression is found for a user on a given exercise.
 * and `WorkoutSetLog` tables.
 */
----------------------------------------------------
-- STEP 1: Get the current user's username into a variable.
----------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
------------------------------------------------------
-- STEP 2: Include the main application layout and authentication check.
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 3: Display the Workout Template selection dropdown.
-- This form allows the user to choose a workout plan. It auto-submits on change.
------------------------------------------------------
SELECT 'form' as component,
    'index.sql' as action,
    'true' as auto_submit;
SELECT 'select' as type,
    'template_id' as name,
    'Workout Template' as label,
    'Select a workout' as empty_option,
    3 as width,
    TRUE as searchable,
    :template_id as value,
    -- Use json_group_array to build options from the WorkoutTemplates table
    json_group_array(
        json_object('value', TemplateID, 'label', TemplateName)
    ) as options
FROM WorkoutTemplates
WHERE IsEnabled = 1;
----------------------------------------------------
-- STEP 4: Display a compact, foldable list of exercises and their targets.
-- This section appears after a template is chosen and uses an HTML component
-- for a mobile-friendly layout. It uses the database VIEWs to simplify data fetching.
----------------------------------------------------
SELECT 'html' as component;
SELECT '<details open><summary>Today''s Workout Targets</summary><div style="margin-top: 0.5rem; padding-left: 1rem; line-height: 1.7;">' || group_concat(
        format(
            '%s. %s<br><small> &nbsp; &rarr; Target: %s x %s @ %s lbs</small>',
            wtd.OrderInWorkout,
            wtd.ExerciseName,
            pt.TargetSetsFormula,
            pt.TargetRepsFormula,
            pt.TargetWeight
        ),
        '<br>'
    ) || '</div></details>' as html
FROM WorkoutTemplateDetails wtd
    JOIN UserExerciseProgressionTargets pt ON wtd.ExerciseID = pt.ExerciseID
    AND pt.UserID = $current_user
WHERE wtd.TemplateID = :template_id
    and :template_id IS NOT NULL;
------------------------------------------------------
-- STEP 5: Display the "Select an Exercise" dropdown.
-- This form appears after a template is chosen. Selecting an exercise reveals the logging form below.
------------------------------------------------------
SELECT 'form' as component,
    'index.sql' as action,
    'true' as auto_submit
WHERE :template_id IS NOT NULL;
-- A hidden field is included to persist the template_id between selections.
SELECT 'hidden' as type,
    'template_id' as name,
    :template_id as value;
SELECT 'select' as type,
    'selected_exercise_id' as name,
    'Log Exercise' as label,
    'Choose an exercise to log...' as empty_option,
    :selected_exercise_id as value,
    3 as width,
    -- Use the WorkoutTemplateDetails view to simplify this query
    json_group_array(
        json_object('value', ExerciseID, 'label', ExerciseName)
    ) as options
FROM WorkoutTemplateDetails
WHERE TemplateID = :template_id
    and :template_id IS NOT NULL;
------------------------------------------------------
-- STEP 6: Display the dynamic, multi-set workout logging form.
-- All components in this step are conditionally rendered, appearing only after an
-- exercise is selected in Step 5.
------------------------------------------------------
-- The main form component. This acts as the master switch for the entire logging UI.
SELECT 'form' as component,
    'actions/action_save_workout.sql' as action,
    'Log Workout' as validate,
    'green' as validate_color,
    'post' as method
WHERE :selected_exercise_id IS NOT NULL;
-- Get the target workout data, providing default values if no progression exists.
-- This robust query ensures the form always has data to display.
SET target = (
        SELECT json_object(
                'TargetRepsFormula',
                TargetRepsFormula,
                'TargetWeight',
                TargetWeight,
                'TargetSetsFormula',
                TargetSetsFormula
            )
        FROM UserExerciseProgressionTargets
        WHERE UserID = $current_user
            AND ExerciseID = :selected_exercise_id
    );
-- Hidden fields to pass necessary IDs to the action script
SELECT 'hidden' as type,
    'template_id' as name,
    :template_id as value;
SELECT 'hidden' as type,
    'exercise_id' as name,
    :selected_exercise_id as value;
-- Pass the number of sets to the action script so it knows how many fields to process
SELECT 'hidden' as type,
    'num_sets' as name,
    json_extract($target, '$.TargetSetsFormula') as value;
-- Dynamically generate input rows for each set using a recursive CTE.
-- The 'dynamic' component creates a set of Reps and Weight inputs for each number in the series.
WITH RECURSIVE series(set_number) AS (
    SELECT 1
    UNION ALL
    SELECT set_number + 1
    FROM series
    WHERE set_number < CAST(
            json_extract($target, '$.TargetSetsFormula') AS INTEGER
        )
)
SELECT 'number' as type,
    'Set ' || set_number as label,
    --     set_number as description,
    -- Use description to pass the raw number (1, 2, 3...)
    'reps' as prefix,
    json_extract($target, '$.TargetRepsFormula') as value,
    2 as width
FROM series;
SELECT 'number' as type,
    'weight_' || $description as name,
    'Weight' as label,
    json_extract($target, '$.TargetWeight') as value,
    2 as width;
-- Standard RPE and Notes fields, placed correctly after the list definition, inside the form.
SELECT 'number' as type,
    'rpe_recorded' as name,
    'RPE (Overall)' as label,
    8 as value,
    0.5 as step,
    10 as max,
    2 as width;
SELECT 'textarea' as type,
    'notes_recorded' as name,
    'Workout Notes' as label,
    12 as width
WHERE :selected_exercise_id IS NOT NULL;