-- www/actions/action_update_progression.sql
-- This script handles the manual update of a user's progression step and 1RM estimate.
-- Update the record in the database with the values from the form
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
    exercisePlanId=:exercise_plan_id;

-- Redirect back to the index page with the correct parameters to restore the user's view
SELECT
    'redirect' AS component,
    '/index.sql?template_id='||:template_id||'&exercise_plan_id='||:exercise_plan_id AS link;