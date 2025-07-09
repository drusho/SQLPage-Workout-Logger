-- migrations/018_add_max_reps_estimate.sql
----------------------------------------------------
-- MIGRATION METADATA
----------------------------------------------------
-- Description: Adds a 'currentMaxRepsEstimate' column to the dimExercisePlan table
--              to support progression for non-weighted exercises.
-- Date: 2025-07-08
----------------------------------------------------
-- STEP 1: SCHEMA CHANGES
----------------------------------------------------
-- Add the new column to the table.
ALTER TABLE dimExercisePlan
ADD COLUMN currentMaxRepsEstimate INTEGER;