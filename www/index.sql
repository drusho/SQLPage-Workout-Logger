/**
 * @filename      index.sql
 * @description   The main application dashboard, functioning as a multi-step, self-reloading
 * form to guide the user through logging a workout. It conditionally displays
 * information based on user selections: first templates, then exercises with
 * progression targets, and finally a detailed logging form for a specific exercise.
 * @created       2025-06-14
 * @last-updated  2025-06-15 16:58:42 MDT
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `sessions` table to identify the current user.
 * @requires      - All tables related to templates and progression: `WorkoutTemplates`,
 * `TemplateExerciseList`, `ExerciseLibrary`, `UserExerciseProgression`,
 * and `ProgressionModelSteps`.
 * @param         sqlpage.cookie('session_token') [cookie] Used to identify the current user.
 * @param         template_id [url, optional] The ID of the currently selected workout template.
 * Controls the display of the exercise list and selector.
 * @param         selected_exercise_id [url, optional] The ID of the chosen exercise. Controls
 * the display of the final workout logging form.
 * @returns       A full UI page that progressively reveals more components as the user makes
 * selections. The final state includes selectors and the detailed logging form.
 * @see           - `action_save_workout.sql` - The script that the final logging form submits to.
 * @note          - This page heavily uses auto-submitting forms and conditional rendering to
 * create a dynamic, single-page application experience.
 * @note          - The progression targets shown in the exercise list and pre-filled into the
 * final form are calculated with complex, multi-table joins.
 * @todo          - Refactor the complex progression-target queries into a single database
 * `VIEW` to simplify the SQL in this file and reduce redundancy.
 * @todo          - Add more graceful handling for cases where a user has no progression data
 * for a selected exercise, preventing potential errors or empty fields.
 */
----------------------------------------------------
-- STEP 1: First, get the current user's username into a variable.
-- $current_user
----------------------------------------------------
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
------------------------------------------------------
-- STEP 2: Include the main application layout and authentication check.
-- This command runs 'layout_main.sql' which contains the navigation menu and
-- the site-wide security check to ensure the user is logged in.
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 3: Display the Workout Template selection dropdown.
-- This form allows the user to choose a workout plan. It is configured to
-- automatically submit (and reload the page) as soon as a selection is made.
------------------------------------------------------
SELECT 'form' as component,
    'index.sql' as action,
    'true' as auto_submit;
SELECT 'select' as type,
    'template_id' as name,
    'Workout Template' as label,
    'Select a workout' as empty_option,
    true as searchable,
    :template_id as value,
    json_group_array(
        json_object('value', TemplateID, 'label', TemplateName)
    ) as options
FROM WorkoutTemplates;
------------------------------------------------------
-- STEP 4: Display the list of exercises for the selected template.
-- This section only appears after a template has been chosen. It dynamically
-- builds an HTML list of exercises, showing the user's current targeted
-- sets, reps, and weight based on their progression model.
------------------------------------------------------
SELECT 'html' as component;
SELECT -- This CASE statement keeps the exercise list open until an exercise is selected.
    '<details ' || CASE
        WHEN :selected_exercise_id IS NULL THEN 'open'
        ELSE ''
    END || '>
        <summary>Exercises</summary>
        <div style="margin-top: 1rem; padding-left: 1rem; line-height: 1.5;">' || (
        SELECT COALESCE(
                group_concat(
                    CASE
                        WHEN uep.UserID IS NULL THEN lib.ExerciseAlias || ' - <small>No past workouts yet.</small>'
                        ELSE lib.ExerciseAlias || ' - <b>' || IFNULL(pms.TargetSetsFormula, '?') || 'x' || CASE
                            WHEN pms.RepsType = 'FIXED' THEN CAST(pms.RepsValue AS INTEGER)
                            WHEN pms.RepsType = 'AMRAP' THEN 'AMRAP'
                            WHEN pms.RepsType = 'PERCENT_OF_MAX' THEN CAST(
                                MAX(1, ROUND(IFNULL(uep.MaxReps, 5) * pms.RepsValue)) AS INTEGER
                            )
                            ELSE '?'
                        END || '</b>' || CASE
                            WHEN lib.DefaultLogType != 'RepsOnly' THEN ' @ ' || ROUND(
                                IFNULL(uep.CurrentCycle1RMEstimate, 0) * IFNULL(pms.TargetWeightPercentage, 0),
                                2
                            ) || ' lbs'
                            ELSE ' reps'
                        END || ' <small>(Step ' || IFNULL(uep.CurrentStepNumber, '?') || ')</small>'
                    END,
                    '<br>'
                ),
                'No exercises found in this template.'
            )
        FROM TemplateExerciseList AS tel
            JOIN ExerciseLibrary AS lib ON tel.ExerciseID = lib.ExerciseID
            LEFT JOIN UserExerciseProgression AS uep ON tel.ExerciseID = uep.ExerciseID
            AND uep.UserID = $current_user
            LEFT JOIN ProgressionModelSteps AS pms ON tel.ProgressionModelID = pms.ProgressionModelID
            AND uep.CurrentStepNumber = pms.StepNumber
        WHERE tel.TemplateID = :template_id
    ) || '</div>
    </details>' as html
WHERE :template_id IS NOT NULL;
------------------------------------------------------
-- STEP 5: Display the "Select an Exercise" dropdown.
-- This form allows the user to pick one exercise from the list to log.
-- It also auto-submits, reloading the page to show the logging form below.
------------------------------------------------------
SELECT 'form' as component,
    'index.sql' as action,
    'true' as auto_submit
WHERE :template_id IS NOT NULL;
SELECT 'select' as type,
    'selected_exercise_id' as name,
    'Exercise' as label,
    'Choose an exercise to log...' as empty_option,
    true as searchable,
    :selected_exercise_id as value,
    json_group_array(
        json_object('value', ExerciseID, 'label', ExerciseAlias)
    ) as options
FROM TemplateExerciseList
WHERE TemplateID = :template_id;
------------------------------------------------------
-- STEP 6: Display the final workout logging form.
-- This form only appears after a user has selected an exercise. It is
-- pre-filled with the day's targeted workout values and submits the
-- user's actual performance to 'action_save_workout.sql'.
------------------------------------------------------
SELECT 'form' as component,
    'action_save_workout.sql' as action,
    'Log Workout' as validate,
    'green' as validate_color,
    'post' as method
WHERE :selected_exercise_id IS NOT NULL;
SELECT 'hidden' as type,
    'template_id' as name,
    :template_id as value;
SELECT 'hidden' as type,
    'exercise_id' as name,
    :selected_exercise_id as value;
-- The 'Sets' input field
SELECT 'number' as type,
    'sets_recorded' as name,
    'Sets' as label,
    2 as width,
    2 as maxlength,
    10 as max,
    (
        SELECT TargetSetsFormula
        FROM ProgressionModelSteps
        WHERE ProgressionModelStepID = (
                SELECT pms.ProgressionModelStepID
                FROM TemplateExerciseList tel
                    JOIN UserExerciseProgression uep ON tel.ExerciseID = uep.ExerciseID
                    JOIN ProgressionModelSteps pms ON uep.ProgressionModelID = pms.ProgressionModelID
                    AND uep.CurrentStepNumber = pms.StepNumber
                WHERE tel.ExerciseID = :selected_exercise_id
                    AND uep.UserID = $current_user
            )
    ) as value
WHERE :selected_exercise_id IS NOT NULL;
-- The 'Reps' input field
SELECT 'number' as type,
    'reps_recorded' as name,
    'Reps' as label,
    2 as width,
    25 as max,
    2 as maxlength,
    (
        SELECT CASE
                WHEN pms.RepsType = 'FIXED' THEN CAST(pms.RepsValue AS INTEGER)
                WHEN pms.RepsType = 'AMRAP' THEN 'AMRAP'
                WHEN pms.RepsType = 'PERCENT_OF_MAX' THEN CAST(
                    MAX(1, ROUND(IFNULL(uep.MaxReps, 5) * pms.RepsValue)) AS INTEGER
                )
                ELSE '?'
            END
        FROM TemplateExerciseList tel
            JOIN UserExerciseProgression uep ON tel.ExerciseID = uep.ExerciseID
            JOIN ProgressionModelSteps pms ON uep.ProgressionModelID = pms.ProgressionModelID
            AND uep.CurrentStepNumber = pms.StepNumber
        WHERE tel.ExerciseID = :selected_exercise_id
            AND uep.UserID = $current_user
    ) as value
WHERE :selected_exercise_id IS NOT NULL;
-- The 'Weight' input field with conditional integer formatting.
SELECT 'number' as type,
    'weight_recorded' as name,
    'Weight (lbs)' as label,
    2 as width,
    (
        WITH weight_calc AS (
            SELECT CASE
                    WHEN lib.DefaultLogType != 'RepsOnly' THEN ROUND(
                        IFNULL(uep.CurrentCycle1RMEstimate, 0) * IFNULL(pms.TargetWeightPercentage, 0),
                        2
                    )
                    ELSE 0
                END as calculated_val
            FROM TemplateExerciseList tel
                JOIN UserExerciseProgression uep ON tel.ExerciseID = uep.ExerciseID
                JOIN ProgressionModelSteps pms ON uep.ProgressionModelID = pms.ProgressionModelID
                AND uep.CurrentStepNumber = pms.StepNumber
                JOIN ExerciseLibrary lib ON tel.ExerciseID = lib.ExerciseID
            WHERE tel.ExerciseID = :selected_exercise_id
                AND uep.UserID = $current_user
        )
        SELECT CASE
                WHEN wc.calculated_val = CAST(wc.calculated_val AS INTEGER) THEN CAST(wc.calculated_val AS INTEGER)
                ELSE wc.calculated_val
            END
        FROM weight_calc AS wc
    ) as value
WHERE :selected_exercise_id IS NOT NULL;
-- The 'RPE' input field
SELECT 'number' as type,
    'rpe_recorded' as name,
    'RPE' as label,
    2 as width,
    8 as value,
    0.5 as step,
    1 as min,
    10 as max
WHERE :selected_exercise_id IS NOT NULL;
-- The 'Notes' text area
SELECT 'textarea' as type,
    'notes_recorded' as name,
    'Notes' as label,
    12 as width,
    'Add any exercise notes...' as placeholder
WHERE :selected_exercise_id IS NOT NULL;
-- This new button submits the form in the background.
SELECT 'button' as component;