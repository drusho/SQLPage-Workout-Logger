/**
 * @filename      view_workouts.sql
 * @description   Displays a filterable list of all exercise plans for the current user, allowing them to be enabled or disabled.
 * @created       2025-06-18
 * @last-updated  2025-07-03
 * @requires      - `layouts/layout_main.sql` for the page shell and session variables.
 * @requires      - `dimExercisePlan` and `dimExercise` tables.
 * @returns       A UI page with a filterable list of the user's workout plans.
 */
------------------------------------------------------
-- Step 1: Load the main layout and get the current user's ID.
------------------------------------------------------ 
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
            AND expires_at>CURRENT_TIMESTAMP
    );

------------------------------------------------------
-- Step 2: Handle Enable/Disable actions if an action parameter is present in the URL.
------------------------------------------------------ 
UPDATE dimExercisePlan
SET
    isActive=1
WHERE
    exercisePlanId=:enable_id
    AND userId=$current_user_id;

SELECT
    'redirect' as component,
    '/views/view_workouts.sql' as link
WHERE
    :enable_id IS NOT NULL;

UPDATE dimExercisePlan
SET
    isActive=0
WHERE
    exercisePlanId=:disable_id
    AND userId=$current_user_id;

SELECT
    'redirect' as component,
    '/views/view_workouts.sql' as link
WHERE
    :disable_id IS NOT NULL;

------------------------------------------------------
-- Step 3: Display the page header and "Add Workout" button.
------------------------------------------------------ 
SELECT
    'text' as component,
    'Workout Plans' as title;

SELECT
    'button' as component,
    'md' as size;

SELECT
    '/actions/action_add_workout.sql' as link,
    'green' as color,
    'Add Workout Plan' as title,
    'plus' as icon;

------------------------------------------------------
-- Step 4: Render the filter form.
------------------------------------------------------ 
SELECT
    'form' as component,
    'view_workouts.sql' as action,
    true as auto_submit;

-- Dropdown for Template Name
SELECT
    'select' as type,
    'template_filter' as name,
    'Filter by Template' as label,
    'Select a Template' as empty_option,
    :template_filter as value,
    -- UPDATED: Use SELECT DISTINCT in a subquery to ensure unique template names.
    (
        SELECT
            JSON_GROUP_ARRAY(
                JSON_OBJECT('label', T.templateName, 'value', T.templateName)
            )
        FROM
            (
                SELECT DISTINCT
                    templateName
                FROM
                    dimExercisePlan
                WHERE
                    userId=$current_user_id
                    AND templateName IS NOT NULL
                ORDER BY
                    templateName
            ) AS T
    ) as options,
    4 as width;

-- Dropdown for Status
SELECT
    'select' as type,
    'status_filter' as name,
    'Filter by Status' as label,
    'Select a Status' as empty_option,
    -- :status_filter as value,
    JSON_ARRAY(
        JSON_OBJECT('label', 'Active', 'value', '1'),
        JSON_OBJECT('label', 'Disabled', 'value', '0')
    ) as options,
    4 as width;

-- Button to clear filters
SELECT
    'button' as component,
    2 as width;

SELECT
    'Clear Filters' as title,
    '/views/view_workouts.sql' as link,
    'outline' as style,
    'yellow' as outline_color,
    'restore' as icon,
    'sm' as size;

------------------------------------------------------
-- Step 5: Display the table of workout plans.
------------------------------------------------------ 
SELECT
    'table' as component,
    'All Plans' as title,
    TRUE as sort,
    TRUE as small,
    'Action' as markdown;

-- Select all exercise plans for the current user, applying filters.
SELECT
    plan.templateName AS "Template",
    ex.exerciseName AS "Exercise",
    plan.currentStepNumber AS "Current Step",
    CASE plan.isActive
        WHEN 1 THEN 'Active'
        ELSE 'Disabled'
    END AS "Status",
    CASE plan.isActive
        WHEN 1 THEN FORMAT(
            '[Disable](/views/view_workouts.sql?disable_id=%s)',
            plan.exercisePlanId
        )
        ELSE FORMAT(
            '[Enable](/views/view_workouts.sql?enable_id=%s)',
            plan.exercisePlanId
        )
    END||' | '||FORMAT(
        '[Edit](/actions/action_edit_workout.sql?id=%s)',
        plan.exercisePlanId
    ) AS "Action"
FROM
    dimExercisePlan AS plan
    JOIN dimExercise AS ex ON plan.exerciseId=ex.exerciseId
WHERE
    plan.userId=$current_user_id
    AND (
        plan.templateName=:template_filter
        OR :template_filter IS NULL
        OR :template_filter=''
    )
    AND (
        plan.isActive=:status_filter
        OR :status_filter IS NULL
        OR :status_filter=''
    )
ORDER BY
    plan.templateName,
    ex.exerciseName;
