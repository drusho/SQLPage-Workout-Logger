--modification date: 2025-06-16
-- Command 1: Add the new IsEnabled column to the WorkoutTemplates table.
ALTER TABLE WorkoutTemplates
ADD COLUMN IsEnabled INTEGER DEFAULT 1;
-- Command 2: Ensure all your existing templates are set to enabled by default.
UPDATE WorkoutTemplates
SET IsEnabled = 1
WHERE IsEnabled IS NULL;