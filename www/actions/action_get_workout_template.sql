/**
 * @filename      action_get_workout_template.sql
 * @description   A reusable helper script that retrieves the details of a specific workout template given its ID.
 * @created       2025-06-17
 * @last-updated  2025-06-18
 * @requires      - WorkoutTemplates (table): The source of the workout template data.
 * @param         $1 {string} - The TemplateID of the workout template to retrieve.
 * @returns       A single row containing the template name, description, and enabled status, which is consumed as a JSON object by the calling script.
 * @see           - /actions/action_edit_workout.sql: The script that calls this file to populate its edit form.
 * @note          This script is executed by `action_edit_workout.sql` via the `sqlpage.read_file_as_json()` function.
 */
SELECT TemplateName,
    Description,
    IsEnabled
FROM WorkoutTemplates
WHERE TemplateID = $1;