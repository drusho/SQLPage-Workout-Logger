/**
 * @filename      view_workouts.sql
 * @description   Displays a filterable list of all configured workouts. Allows enabling/disabling of workouts directly from the list.
 * @created       2025-06-16
 * @last-updated  2025-06-16
 * @requires      - The TemplateExerciseList table, which must have an `IsEnabled` column.
 * @param         action [url, optional] The action to perform ('enable' or 'disable').
 * @param         id [url, optional] The ID of the workout to act upon.
 * @param         template_filter [url, optional] The TemplateID to filter the list by.
 * @param         status_filter [url, optional] The status (1 for Enabled, 0 for Disabled) to filter by.
 * @param         prog_model_filter [url, optional] The ProgressionModelID to filter by.
 * @todo          - Preserve filter settings in the URL after enabling/disabling a workout.
 */
------------------------------------------------------
-- STEP 1: HANDLE ACTIONS (ENABLE/DISABLE)
------------------------------------------------------
UPDATE TemplateExerciseList
SET IsEnabled = 1
WHERE TemplateExerciseListID = :id
    AND :action = 'enable';
UPDATE TemplateExerciseList
SET IsEnabled = 0
WHERE TemplateExerciseListID = :id
    AND :action = 'disable';
SELECT 'redirect' as component,
    '/views/view_workouts.sql' as link
WHERE :action IS NOT NULL;
------------------------------------------------------
-- STEP 2: RENDER PAGE STRUCTURE
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 3: RENDER PAGE HEADER AND ACTIONS
------------------------------------------------------
SELECT 'text' as component,
    'My Workouts' as title;
SELECT 'button' as component,
    'md' as size;
SELECT '/actions/action_add_workout.sql' as link,
    'azure' as outline,
    'Add Workout' as title,
    'plus' as icon;
------------------------------------------------------
-- STEP 4: RENDER THE FILTER FORM
------------------------------------------------------
SELECT 'form' as component,
    'view_workouts.sql' as action,
    'true' as auto_submit;
-- 'get' as method;
-- Dropdown for Template
SELECT 'select' as type,
    'template_filter' as name,
    'Filter by Template' as label,
    'Select a template' as empty_option,
    :template_filter as value,
    (
        SELECT json_group_array(
                json_object('label', TemplateName, 'value', TemplateID)
            )
        FROM WorkoutTemplates
        ORDER BY TemplateName
    ) as options,
    4 as width;
-- Dropdown for Status
SELECT 'select' as type,
    'status_filter' as name,
    'Filter by Status' as label,
    'Select a status' as empty_option,
    :status_filter as value,
    -- FIX: The 'value' for each option is now a string ("1", "0") to match the URL parameter type.
    json_array(
        json_object('label', 'Enabled', 'value', '1'),
        json_object('label', 'Disabled', 'value', '0')
    ) as options,
    3 as width;
-- Dropdown for Progression Model
SELECT 'select' as type,
    'prog_model_filter' as name,
    'Filter by Model' as label,
    'Select a model' as empty_option,
    :prog_model_filter as value,
    (
        SELECT json_group_array(
                json_object(
                    'label',
                    ProgressionModelName,
                    'value',
                    ProgressionModelID
                )
            )
        FROM ProgressionModels
        ORDER BY ProgressionModelName
    ) as options,
    3 as width;
-- This command ends the auto-submitting form.
-- FIX: Add a separate button to clear the filters. This is just a link to the page with no parameters.
SELECT 'button' as component;
select 'Clear Filters' as title,
    '/views/view_workouts.sql' as link,
    'outline' as style,
    'yellow' as outline,
    'restore' as icon;
------------------------------------------------------
-- STEP 5: RENDER THE WORKOUTS LIST
------------------------------------------------------
SELECT 'table' as component,
    'Configured Workouts' as title,
    TRUE as sort,
    json_array('Status', 'Action') as markdown;
SELECT wt.TemplateName AS "Template",
    tel.ExerciseAlias AS "Workout Name (Alias)",
    el.ExerciseName AS "Base Exercise",
    CASE
        WHEN tel.IsEnabled = 1 THEN format(
            '[✅ Enabled](/views/view_workouts.sql?action=disable&id=%s)',
            tel.TemplateExerciseListID
        )
        ELSE format(
            '[❌ Disabled](/views/view_workouts.sql?action=enable&id=%s)',
            tel.TemplateExerciseListID
        )
    END AS "Status",
    pm.ProgressionModelName AS "Progression Model",
    -- DEBUG: The 'Edit' link now points to the new debug page.
    format(
        '[Debug Edit](/dev/dev_debug_template_id.sql?id=%s)',
        wt.TemplateID
    ) || ' | ' || format(
        '[Delete](/views/delete_workout.sql?id=%s)',
        tel.TemplateExerciseListID
    ) AS "Action"
FROM TemplateExerciseList AS tel
    JOIN WorkoutTemplates AS wt ON tel.TemplateID = wt.TemplateID
    JOIN ExerciseLibrary AS el ON tel.ExerciseID = el.ExerciseID
    LEFT JOIN ProgressionModels AS pm ON tel.ProgressionModelID = pm.ProgressionModelID
WHERE (
        tel.TemplateID = :template_filter
        OR :template_filter IS NULL
        OR :template_filter = ''
    )
    AND (
        tel.IsEnabled = :status_filter
        OR :status_filter IS NULL
        OR :status_filter = ''
    )
    AND (
        COALESCE(tel.ProgressionModelID, '') = :prog_model_filter
        OR :prog_model_filter IS NULL
        OR :prog_model_filter = ''
    )
ORDER BY wt.TemplateName,
    tel.OrderInWorkout;