/**
 * @filename      action_update_progression.sql
 * @description   A pure action script that handles the form submission from `index.sql` to manually
 * update a user's progression for a specific exercise (e.g., current step, 1RM, or max reps).
 * @created       2025-07-09
 * @requires      - `index.sql` (as the source of the form submission).
 * - `dimExercisePlan` and `sessions` tables.
 * @param         current_step [form] The new step number for the user's progression.
 * @param         current_1rm [form, optional] The new estimated 1-Rep-Max for weight-based models.
 * @param         current_max_reps [form, optional] The new estimated max reps for rep-based models.
 * @param         exercise_plan_id [form] The ID of the exercise plan to update.
 * @param         template_id [form] The ID of the workout template, used for the redirect link.
 */
-- =============================================================================
-- Step 1: Get Current User ID
-- =============================================================================
SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

-- =============================================================================
-- Step 2: Update Progression Record in Database
-- =============================================================================
UPDATE dimExercisePlan
SET
    currentStepNumber=:current_step,
    -- Use a CASE statement to update the correct "max" estimate column
    current1rmEstimate=CASE
        WHEN :current_1rm IS NOT NULL THEN :current_1rm
        ELSE current1rmEstimate
    END,
    currentMaxRepsEstimate=CASE
        WHEN :current_max_reps IS NOT NULL THEN :current_max_reps
        ELSE currentMaxRepsEstimate
    END
WHERE
    exercisePlanId=:exercise_plan_id
    -- This new condition ensures you can only update your own plans
    AND userId=$current_user_id;

-- =============================================================================
-- Step 3: Redirect User
-- =============================================================================
-- Redirect back to the index page with the correct parameters to restore the user's view.
SELECT
    'redirect' AS component,
    '/index.sql?template_id='||:template_id||'&exercise_plan_id='||:exercise_plan_id AS link;