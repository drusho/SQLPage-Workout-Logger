--modification date: 2025-06-17
-- Step 1: Rename the current broken table.
ALTER TABLE TemplateExerciseList
    RENAME TO TemplateExerciseList_temp;
-- Step 2: Create the new, corrected table. 
-- (This version is tailored to your exact schema, 
-- with the foreign key pointing to the correct WorkoutTemplates table).
CREATE TABLE TemplateExerciseList (
    TemplateExerciseListID TEXT PRIMARY KEY,
    TemplateID TEXT NOT NULL,
    ExerciseID TEXT NOT NULL,
    ExerciseAlias TEXT,
    ProgressionModelID TEXT,
    OrderInWorkout INTEGER,
    LastModified TEXT,
    IsEnabled INTEGER DEFAULT 1,
    FOREIGN KEY (TemplateID) REFERENCES WorkoutTemplates (TemplateID),
    FOREIGN KEY (ExerciseID) REFERENCES ExerciseLibrary (ExerciseID),
    FOREIGN KEY (ProgressionModelID) REFERENCES ProgressionModels (ProgressionModelID)
);
-- Step 3: Copy data from the old table to the new one.
INSERT INTO TemplateExerciseList (
        TemplateExerciseListID,
        TemplateID,
        ExerciseID,
        ExerciseAlias,
        ProgressionModelID,
        OrderInWorkout,
        LastModified,
        IsEnabled
    )
SELECT TemplateExerciseListID,
    TemplateID,
    ExerciseID,
    ExerciseAlias,
    ProgressionModelID,
    OrderInWorkout,
    LastModified,
    IsEnabled
FROM TemplateExerciseList_temp;
-- Step 4: Drop the temporary table.
DROP TABLE TemplateExerciseList_temp;
