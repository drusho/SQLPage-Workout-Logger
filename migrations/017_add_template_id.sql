-- migrations/017_add_template_id.sql
----------------------------------------------------
-- MIGRATION METADATA
----------------------------------------------------
-- Description: Adds a unique, non-changing templateId to each workout plan.
--              This is safer for use in URLs than the templateName.
-- Date: 2025-07-06
----------------------------------------------------
-- STEP 1: SCHEMA CHANGES
----------------------------------------------------
-- Add the new column, allowing NULLs initially.
ALTER TABLE dimExercisePlan ADD COLUMN templateId TEXT;

-- Generate a unique ID for each existing workout plan.
-- This groups all exercises with the same templateName under a single new ID.
UPDATE dimExercisePlan SET
    templateId = (
        SELECT HEX(RANDOMBLOB(16))
    )
WHERE
    rowid IN (
        SELECT MIN(rowid)
        FROM dimExercisePlan
        GROUP BY templateName
    );

UPDATE dimExercisePlan SET
    templateId = (
        SELECT MAX(T2.templateId)
        FROM dimExercisePlan T2
        WHERE T2.templateName = dimExercisePlan.templateName
    )
WHERE
    templateId IS NULL;

-- NOTE: You would ideally make this column NOT NULL after populating it,
-- but that requires a more complex table rebuild in SQLite. For now,
-- application logic will ensure it's populated for new plans.

----------------------------------------------------
-- STEP 2: REBUILD ALL APPLICATION VIEWS
-- Not strictly necessary as we only added a column, but it is good practice.
----------------------------------------------------