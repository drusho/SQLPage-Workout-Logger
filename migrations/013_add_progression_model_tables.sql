-- Migration: 013_add_progression_model_tables
-- Description: Adds new tables to support structured, user-definable progression models
-- for both weight-based and calisthenics exercises.
PRAGMA foreign_keys=ON;

-- =============================================================================
-- Step 1: Create the Progression Model Tables
-- =============================================================================
-- This table stores the high-level details of a progression model.
CREATE TABLE IF NOT EXISTS dimProgressionModel (
    progressionModelId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    modelName TEXT NOT NULL,
    modelType TEXT NOT NULL, -- 'weight' or 'reps'
    description TEXT,
    FOREIGN KEY (userId) REFERENCES dimUser (userId)
);

-- This table stores the specific details for each step (e.g., week) within a model.
CREATE TABLE IF NOT EXISTS dimProgressionModelStep (
    progressionModelStepId TEXT PRIMARY KEY,
    progressionModelId TEXT NOT NULL,
    stepNumber INTEGER NOT NULL,
    description TEXT, -- e.g., "75% of 1RM" or "75% of Max Reps"
    percentOfMax REAL, -- The percentage of 1RM or Max Reps to use
    targetSets INTEGER,
    targetReps INTEGER,
    FOREIGN KEY (progressionModelId) REFERENCES dimProgressionModel (progressionModelId) ON DELETE CASCADE
);

-- =============================================================================
-- Step 2: Update the Exercise Plan Table
-- =============================================================================
-- Add a column to dimExercisePlan to link it to a specific progression model.
ALTER TABLE dimExercisePlan
ADD COLUMN progressionModelId TEXT REFERENCES dimProgressionModel (progressionModelId);
