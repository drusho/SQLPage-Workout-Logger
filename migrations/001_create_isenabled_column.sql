--modification date: 2025-06-16
-- Command 1: Add the new IsEnabled column to the table.
ALTER TABLE TemplateExerciseList
ADD COLUMN IsEnabled INTEGER DEFAULT 1;
-- Command 2: Ensure all your existing workouts are set to enabled (value = 1).
UPDATE TemplateExerciseList
SET IsEnabled = 1
WHERE IsEnabled IS NULL;