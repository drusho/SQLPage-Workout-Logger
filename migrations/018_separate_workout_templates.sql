-- migrations/018_separate_workout_templates.sql
----------------------------------------------------
-- MIGRATION METADATA
----------------------------------------------------
-- Description: Corrects an issue where multiple workout plans were grouped under a single templateId.
--              This script manually assigns new, unique templateIds to distinct sets of exercises.
-- Date: 2025-07-06
----------------------------------------------------
-- STEP 1: DATA CORRECTION
-- Manually assign unique templateIds to each distinct workout plan.
----------------------------------------------------

-- IMPORTANT: You must edit the list of exercise IDs in the WHERE clauses below
-- to match the actual exercises in each of your plans.

-- Plan 1: Full Body A
UPDATE dimExercisePlan
SET templateId = 'plan_A_uuid' -- Assign a unique ID for this plan
WHERE exerciseId IN (
    -- List all exerciseIds that belong to "Full Body A"
    'UUID001',
    'UUID002',
    'UUID003',
    'UUID004'
);

-- Plan 2: Full Body B
UPDATE dimExercisePlan
SET templateId = 'plan_B_uuid' -- Assign a unique ID for this plan
WHERE exerciseId IN (
    -- List all exerciseIds that belong to "Full Body B"
    'UUID005',
    'UUID006',
    'UUID007',
    'UUID008'
);

-- Plan 3: Full Body C
UPDATE dimExercisePlan
SET templateId = 'plan_C_uuid' -- Assign a unique ID for this plan
WHERE exerciseId IN (
    -- List all exerciseIds that belong to "Full Body C"
    'UUID009',
    'UUID010',
    'UUID011'
);

-- Add more UPDATE blocks here if you have more plans to separate.
