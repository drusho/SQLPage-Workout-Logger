/**
 * @filename      index.sql
 * @description   The main application dashboard and a dynamic, multi-step, single-page interface for logging workouts. 
 It uses a progressive disclosure UI where components appear as the user makes selections.
 * @created       2025-06-14
 * @last-updated  2025-06-18
 * @requires      - layouts/layout_main.sql: Provides the main UI shell and handles user authentication.
 * @requires      - UserExerciseProgressionTargets (view): Used to fetch the target sets, reps, and weight for a user's current progression.
 * @requires      - WorkoutTemplateDetails (view): Used to populate the list of exercises for a given workout template.
 * @requires      - WorkoutLog, WorkoutSetLog (tables): Queried to display the user's last performance for a selected exercise.
 * @param         template_id [url, optional] Controls which workout's exercises are displayed. Set by the form in Step 3.
 * @param         selected_exercise_id [url, optional] Controls which exercise's logging form is displayed. Set by the form in Step 5.
 * @param         success [url, optional] A flag that triggers the display of the "Workout Saved!" alert.
 * @returns       A full UI page that progressively reveals more components as the user makes selections.
 * @see           - /actions/action_save_workout.sql: The script that the main workout logging form submits to.
 * @note          The page state is managed via URL parameters. Forms are set to 'auto_submit' to reload the page and reveal the next step in the workflow.
 * @note          The query for user targets is robust, using COALESCE to provide default values for exercises that have no prior user history.
 * @note          The set/rep/weight input form is generated dynamically using a recursive Common Table Expression (CTE).
 */

----------------------------------------------------
-- STEP 1: Identify Current User
-- Fetches the username from the session cookie into a variable for use in later queries.
----------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
------------------------------------------------------
-- STEP 2: Render Page Skeleton & Success Alert
-- Includes the main layout and displays a temporary success alert if the 'success'
-- URL parameter is present after a workout has been saved.
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
SELECT 'alert' as component,
    'Success!' as title,
    'Your workout has been saved.' as description,
    'check' as icon,
    'green' as color,
    '5' as close_after
WHERE :success = 'true';
------------------------------------------------------
-- STEP 3: Display Workout Template Selector
-- This form allows the user to choose a workout plan. It auto-submits on change,
-- reloading the page with the selected :template_id.
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

    json_group_array(
        json_object('value', TemplateID, 'label', TemplateName)
    ) as options
FROM WorkoutTemplates
WHERE IsEnabled = 1;
----------------------------------------------------
-- STEP 4: Display a compact, foldable list of exercises and their targets.
-- This section appears after a template is chosen and uses an HTML component
-- for a mobile-friendly layout. It uses a CASE statement to collapse
-- itself when an exercise is selected below.
----------------------------------------------------
SELECT 'html' as component;
SELECT 
    CASE
        WHEN :selected_exercise_id IS NOT NULL THEN '<details>'
        ELSE '<details open>'
    END || '<summary>Today''s Workout Targets</summary><div style="margin-top: 0.5rem; padding-left: 1rem; line-height: 1.7;">' || group_concat(
        format(
            '%s. %s<br><small> &nbsp; &rarr; %s x %s @ %s lbs, step: %s</small>',
            wtd.OrderInWorkout,
            wtd.ExerciseName,
            pt.TargetSetsFormula,
            pt.TargetRepsFormula,
            pt.TargetWeight,
            pt.TargetStepNumber
        ),
        '<br>'
    ) || '</div></details>' as html
FROM WorkoutTemplateDetails wtd
    JOIN UserExerciseProgressionTargets pt ON wtd.ExerciseID = pt.ExerciseID
    AND pt.UserID = $current_user
WHERE wtd.TemplateID = :template_id
    and :template_id IS NOT NULL;
------------------------------------------------------
-- STEP 5: Display Exercise Selector
-- This form appears after a template is chosen. Selecting an exercise reloads the
-- page with the :selected_exercise_id, which triggers the logging form below.
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
-- STEP 5.5: Display Last Workout Summary
-- This alert appears after an exercise is selected, providing the user with
-- contextual feedback on their last performance for that specific exercise.
-- It only renders if a prior workout exists in the log.
------------------------------------------------------
SELECT 'alert' as component,
    
    'history' as icon,
    'info' as color,
    
    format(
        '**%s:** %s x %s @ %s lbs, step: %s',
        date(wl.ExerciseTimestamp, 'unixepoch'),
        COUNT(wsl.SetID),
        CAST(AVG(wsl.RepsPerformed) AS INTEGER),
        CAST(AVG(wsl.WeightUsed) AS INTEGER),
        wl.PerformedAtStepNumber
    ) as description_md
FROM WorkoutLog wl
    JOIN WorkoutSetLog wsl ON wl.LogID = wsl.LogID
WHERE wl.UserID = $current_user
    AND wl.ExerciseID = :selected_exercise_id
    AND wl.LogID = (

        SELECT LogID
        FROM WorkoutLog
        WHERE UserID = $current_user
            AND ExerciseID = :selected_exercise_id
        ORDER BY ExerciseTimestamp DESC
        LIMIT 1
    )
GROUP BY wl.LogID,
    wl.ExerciseTimestamp;
------------------------------------------------------
-- STEP 6: Display Dynamic Workout Logging Form
-- All components in this step are conditionally rendered, appearing only after an
-- exercise is selected in Step 5.
------------------------------------------------------
SELECT 'form' as component,
    'actions/action_save_workout.sql' as action,
    'Log Workout' as validate,
    'green' as validate_color,
    'post' as method
WHERE :selected_exercise_id IS NOT NULL;
-- Fetch target data for the selected exercise into a variable.
-- COALESCE provides a default object (3 sets of 10 reps) if no progression
-- history exists for the user on this exercise.
SET target = COALESCE(
        (
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
        ),
        -- This is the default object used for exercises with no user history.
        json_object(
            'TargetSetsFormula',
            3,
            -- Default to 3 sets
            'TargetRepsFormula',
            10,
            -- Default to 10 reps
            'TargetWeight',
            0 -- Default to 0 weight
        )
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