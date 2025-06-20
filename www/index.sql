/**
 * @filename      index.sql
 * @description   The main application dashboard and a dynamic, multi-step, single-page interface for logging workouts. 
 It uses a progressive disclosure UI where components appear as the user makes selections.
 * @created       2025-06-14
 * @last-updated  2025-06-19
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
-- STEP 4: Render Workout Exercise List
-- Renders a list of exercises for the selected template. If an exercise has been logged
-- recently, its completed performance is shown in green. Otherwise, the target is shown.
----------------------------------------------------
SELECT 'html' as component;
----------------------------------------------------
-- 4.1: Get the base list of target exercises for the selected template
----------------------------------------------------
WITH TemplateExercises AS (
    SELECT wtd.OrderInWorkout,
        wtd.ExerciseName,
        wtd.ExerciseID,
        pt.TargetSetsFormula,
        pt.TargetRepsFormula,
        pt.TargetWeight,
        pt.TargetStepNumber
    FROM WorkoutTemplateDetails wtd
        JOIN UserExerciseProgressionTargets pt ON wtd.ExerciseID = pt.ExerciseID
        AND pt.UserID = $current_user
    WHERE wtd.TemplateID = :template_id
),
----------------------------------------------------
-- 4.2: Find the latest log for each exercise completed today
----------------------------------------------------
RecentLogs AS (
    SELECT ExerciseID,
        MAX(ExerciseTimestamp) as LastTimestamp
    FROM WorkoutLog
    WHERE UserID = $current_user
        AND date(ExerciseTimestamp, 'unixepoch') = date('now')
        AND ExerciseTimestamp >= (strftime('%s', 'now') - 14400) -- 14400 seconds = 4 hours  
    GROUP BY ExerciseID
),
----------------------------------------------------
-- 4.3: Get the concatenated performance details (e.g., 1x10@100) for those logs
----------------------------------------------------
PerformanceDetails AS (
    SELECT wl.ExerciseID,
        wl.ExerciseTimestamp,
        (
            SELECT GROUP_CONCAT(
                    RepsPerformed || 'r @ ' || WeightUsed || ' ' || COALESCE(WeightUnit, 'lbs'),
                    '; '
                )
            FROM WorkoutSetLog
            WHERE LogID = wl.LogID
            ORDER BY SetNumber
        ) as PerformanceString
    FROM WorkoutLog wl
        JOIN RecentLogs rl ON wl.ExerciseID = rl.ExerciseID
        AND wl.ExerciseTimestamp = rl.LastTimestamp
    WHERE wl.UserID = $current_user
)
SELECT CASE
        ----------------------------------------------------
        -- 4.4: Join targets with actual performance and generate the final HTML list
        ----------------------------------------------------
        WHEN :selected_exercise_id IS NOT NULL THEN '<details>'
        ELSE '<details open>'
    END || '<summary>Today''s Workout Targets</summary><div style="margin-top: 0.5rem; padding-left: 1rem; line-height: 1.7;">' || group_concat(
        CASE
            -- If performance details exist, show them
            WHEN pd.PerformanceString IS NOT NULL THEN format(
                '<div style="color: green;">✅ %s. %s &rarr; %s</div>',
                te.OrderInWorkout,
                te.ExerciseName,
                pd.PerformanceString
            ) -- Otherwise, show the original target information
            ELSE format(
                '<div>%s. %s<br><small> &nbsp; &rarr; <b>Target:</b> %s x %s @ %s lbs, step: %s</small></div>',
                te.OrderInWorkout,
                te.ExerciseName,
                te.TargetSetsFormula,
                te.TargetRepsFormula,
                -- *** THIS LINE IS THE FIX ***
                COALESCE(te.TargetWeight, 0),
                te.TargetStepNumber
            )
        END,
        '' -- No separator, div handles newlines
    ) || '</div></details>' AS html
FROM TemplateExercises te
    LEFT JOIN PerformanceDetails pd ON te.ExerciseID = pd.ExerciseID
WHERE :template_id IS NOT NULL
ORDER BY te.OrderInWorkout;
------------------------------------------------------
-- STEP 5: Render Exercise Logging Components
-- Conditionally renders the exercise selector and the last workout summary when a
-- workout template has been selected.
------------------------------------------------------
-- 5.1: Render the Exercise Selector Dropdown
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
-- 5.2: Display the User's Last Performance for the Selected Exercise
------------------------------------------------------
SELECT 'alert' as component,
    'history' as icon,
    'info' as color,
    format(
        '**%s:** %s x %s @ %s lbs, step: %s',
        date(wl.ExerciseTimestamp, 'unixepoch', 'localtime'),
        COUNT(wsl.SetID),
        wsl.RepsPerformed,
        wsl.WeightUsed,
        wl.PerformedAtStepNumber
    ) as description_md
FROM WorkoutLog wl
    JOIN WorkoutSetLog wsl ON wl.LogID = wsl.LogID
WHERE wl.UserID = $current_user
    AND wl.ExerciseID = :selected_exercise_id
    AND wsl.RepsPerformed IS NOT NULL
    AND wsl.RepsPerformed > 0
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
-- STEP 6: Render Dynamic Workout Logging Form
-- Renders the main form for logging sets, reps, and weight for the selected exercise.
----------------------------------------------------
-- 6.1: Render the main <form> element
SELECT 'form' as component,
    'actions/action_save_workout.sql' as action,
    'Log Workout' as validate,
    'green' as validate_color,
    'post' as method
WHERE :selected_exercise_id IS NOT NULL;
------------------------------------------------------
-- 6.2: Fetch target data for the selected exercise into a variable
------------------------------------------------------
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
    ) -- 6.3: Pass hidden data to the action script
SELECT 'hidden' as type,
    'template_id' as name,
    :template_id as value
WHERE :selected_exercise_id IS NOT NULL;
;
SELECT 'hidden' as type,
    'exercise_id' as name,
    :selected_exercise_id as value
WHERE :selected_exercise_id IS NOT NULL;
;
-- Pass the number of sets to the action script so it knows how many fields to process
SELECT 'hidden' as type,
    'num_sets' as name,
    json_extract($target, '$.TargetSetsFormula') as value
WHERE :selected_exercise_id IS NOT NULL;
;
----------------------------------------------------
-- 6.4: Dynamically generate Reps & Weight inputs using a recursive CTE
----------------------------------------------------
WITH RECURSIVE series(set_number) AS (
    SELECT 1
    UNION ALL
    SELECT set_number + 1
    FROM series
    WHERE set_number < CAST(
            json_extract($target, '$.TargetSetsFormula') AS INTEGER
        )
),
-- Create a helper that defines our two input types
input_types(type_name, sort_order) AS (
    SELECT 'reps',
        1
    UNION ALL
    SELECT 'weight',
        2
)
SELECT 'number' as type,
    type_name || '_' || set_number as name,
    CASE
        WHEN type_name = 'reps' THEN 'Set ' || set_number
        ELSE 'Set ' || set_number
    END as label,
    CASE
        WHEN type_name = 'reps' THEN 'Reps'
        ELSE 'Wt'
    END as prefix,
    CASE
        WHEN type_name = 'reps' THEN json_extract($target, '$.TargetRepsFormula')
        ELSE json_extract($target, '$.TargetWeight')
    END as value,
    2 as width
FROM series,
    input_types
WHERE :selected_exercise_id IS NOT NULL
ORDER BY set_number,
    sort_order;
----------------------------------------------------
-- 6.5: Render standard RPE and Notes inputs
----------------------------------------------------
SELECT 'number' as type,
    'rpe_recorded' as name,
    'RPE (Overall)' as label,
    8 as value,
    10 as max,
    6 as width
WHERE :selected_exercise_id IS NOT NULL;
;
SELECT 'textarea' as type,
    'notes_recorded' as name,
    'Workout Notes' as label,
    6 as width
WHERE :selected_exercise_id IS NOT NULL;