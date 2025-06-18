/**
 * @filename action_get_workout_template.sql
 * @description This SQL query retrieves the details of a specific workout template based on its ID.
 * @created 2025-06-17
 * @last-updated 2025-06-17
 * @requires - The `WorkoutTemplates` table, which contains the workout template data. 
 * @param {number} $1 - The ID of the workout template to retrieve.
 * @returns {object} - An object containing the template name, description, and enabled status.
 * @see - `action_edit_workout.sql` - The action script that uses this query to populate the edit form. 
 * @note This query is used to fetch the current details of a workout template for editing purposes.
 */
SELECT TemplateName,
    Description,
    IsEnabled
FROM WorkoutTemplates
WHERE TemplateID = $1;