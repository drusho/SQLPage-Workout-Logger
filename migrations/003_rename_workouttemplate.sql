--modification date: 2025-06-16
-- Rename the current table to back it up.
ALTER TABLE WorkoutTemplates
    RENAME TO WorkoutTemplates_old;
-- Create a new, corrected WorkoutTemplates table. (This version correctly defines the foreign key).
CREATE TABLE WorkoutTemplates (
    TemplateID TEXT PRIMARY KEY,
    TemplateName TEXT,
    ProgressionModelID TEXT,
    Description TEXT,
    Focus TEXT,
    Frequency TEXT,
    CreatedByUserID TEXT,
    LastModified TEXT,
    IsEnabled INTEGER DEFAULT 1,
    FOREIGN KEY (CreatedByUserID) REFERENCES users (username)
);
-- Copy all your data from the old table into the new one.
INSERT INTO WorkoutTemplates (
        TemplateID,
        TemplateName,
        ProgressionModelID,
        Description,
        Focus,
        Frequency,
        CreatedByUserID,
        LastModified,
        IsEnabled
    )
SELECT TemplateID,
    TemplateName,
    ProgressionModelID,
    Description,
    Focus,
    Frequency,
    CreatedByUserID,
    LastModified,
    IsEnabled
FROM WorkoutTemplates_old;
-- Drop the old backup table.
DROP TABLE WorkoutTemplates_old;