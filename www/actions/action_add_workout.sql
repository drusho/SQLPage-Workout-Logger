/**
 * @filename      action_add_workout.sql
 * @description   Creates a new, empty, disabled Workout Template and then immediately redirects the user to the edit page for that new template.
 * @created       2025-06-16
 * @last-updated  2025-06-16
 * @requires      - Writes to the `WorkoutTemplates` table.
 * @returns       A `redirect` component to the edit page for the newly created workout.
 * @see           - ../views/view_workouts.sql - The page that links to this action.
 * @see           - ../views/edit_workout.sql - The page this action redirects to.
 */
------------------------------------------------------
-- STEP 1: GENERATE A UNIQUE ID
-- We generate a unique ID first so we can use it in both the INSERT and the redirect.
------------------------------------------------------
SET new_template_id = 'WT_' || sqlpage.random_string(16);
------------------------------------------------------
-- STEP 2: INSERT A NEW, EMPTY WORKOUT TEMPLATE
-- This creates the new workout with a temporary name and sets it to disabled by default.
------------------------------------------------------
INSERT INTO WorkoutTemplates (
        TemplateID,
        TemplateName,
        CreatedByUserID,
        LastModified,
        IsEnabled
    )
VALUES (
        $new_template_id,
        'New Workout ' || strftime('%Y-%m-%d %H:%M', 'now'),
        (
            SELECT username
            FROM sessions
            WHERE session_token = sqlpage.cookie('session_token')
        ),
        strftime('%Y-%m-%d %H:%M:%S', 'now'),
        0 -- We start it as disabled. The user can enable it on the edit page.
    );
------------------------------------------------------
-- STEP 3: REDIRECT TO THE EDIT PAGE
-- This immediately takes the user to the edit page for the workout they just created.
------------------------------------------------------
SELECT 'redirect' as component,
    format(
        '/actions/action_edit_workout.sql?id=%s',
        $new_template_id
    ) as link;