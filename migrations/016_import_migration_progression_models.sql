-- migrations/016_import_progression_models.sql
--
----------------------------------------------------
-- MIGRATION METADATA
----------------------------------------------------
-- Description: Inserts three default progressive overload programs with descriptions.
-- Date: 2025-07-06
----------------------------------------------------
-- STEP 1: DATA INSERTION
-- Inserts the new progression models and their steps.
-- Using "REPLACE INTO" makes this script safely rerunnable without causing errors.
----------------------------------------------------

-- NOTE: The userId 'davidrusho' is used as a placeholder. Change if necessary.

--
-- Program 1: 8 Step RPE High Reps (Weight-based)
--
REPLACE INTO dimProgressionModel (progressionModelId, userId, modelName, modelType, description)
VALUES ('prog_model_high_reps_uuid', 'davidrusho', '8 Step RPE High Reps', 'weight', 'A weight-based progression model focusing on hypertrophy, moving from 10 to 12 reps.');

REPLACE INTO dimProgressionModelStep (progressionModelStepId, progressionModelId, stepNumber, targetSets, targetReps, percentOfMax, description) VALUES
    ('step_high_reps_1', 'prog_model_high_reps_uuid', 1, 3, 10, 75, '3 sets of 10 reps @ 75% of 1RM'),
    ('step_high_reps_2', 'prog_model_high_reps_uuid', 2, 4, 10, 75, '4 sets of 10 reps @ 75% of 1RM'),
    ('step_high_reps_3', 'prog_model_high_reps_uuid', 3, 3, 12, 75, '3 sets of 12 reps @ 75% of 1RM'),
    ('step_high_reps_4', 'prog_model_high_reps_uuid', 4, 4, 10, 80, '4 sets of 10 reps @ 80% of 1RM'),
    ('step_high_reps_5', 'prog_model_high_reps_uuid', 5, 3, 12, 75, '3 sets of 12 reps @ 75% of 1RM (Deload)'),
    ('step_high_reps_6', 'prog_model_high_reps_uuid', 6, 4, 12, 75, '4 sets of 12 reps @ 75% of 1RM'),
    ('step_high_reps_7', 'prog_model_high_reps_uuid', 7, 3, 12, 80, '3 sets of 12 reps @ 80% of 1RM'),
    ('step_high_reps_8', 'prog_model_high_reps_uuid', 8, 1, NULL, 90, '1 set of AMRAP @ 85% of 1RM to test max'); -- AMRAP is stored as NULL reps

--
-- Program 2: 8 Step RPE Low Reps (Weight-based)
--
REPLACE INTO dimProgressionModel (progressionModelId, userId, modelName, modelType, description)
VALUES ('prog_model_low_reps_uuid', 'davidrusho', '8 Step RPE Low Reps', 'weight', 'A weight-based progression model focusing on strength, moving from 6 to 7 reps.');

REPLACE INTO dimProgressionModelStep (progressionModelStepId, progressionModelId, stepNumber, targetSets, targetReps, percentOfMax, description) VALUES
    ('step_low_reps_1', 'prog_model_low_reps_uuid', 1, 3, 6, 75, '3 sets of 6 reps @ 75% of 1RM'),
    ('step_low_reps_2', 'prog_model_low_reps_uuid', 2, 4, 6, 75, '4 sets of 6 reps @ 75% of 1RM'),
    ('step_low_reps_3', 'prog_model_low_reps_uuid', 3, 3, 7, 75, '3 sets of 7 reps @ 75% of 1RM'),
    ('step_low_reps_4', 'prog_model_low_reps_uuid', 4, 4, 6, 80, '4 sets of 6 reps @ 80% of 1RM'),
    ('step_low_reps_5', 'prog_model_low_reps_uuid', 5, 3, 7, 75, '3 sets of 7 reps @ 75% of 1RM (Deload)'),
    ('step_low_reps_6', 'prog_model_low_reps_uuid', 6, 4, 7, 75, '4 sets of 7 reps @ 75% of 1RM'),
    ('step_low_reps_7', 'prog_model_low_reps_uuid', 7, 3, 7, 80, '3 sets of 7 reps @ 80% of 1RM'),
    ('step_low_reps_8', 'prog_model_low_reps_uuid', 8, 1, NULL, 90, '1 set of AMRAP @ 85% of 1RM to test max'); -- AMRAP is stored as NULL reps

--
-- Program 3: 8 Step Calisthenics (Rep-based)
--
REPLACE INTO dimProgressionModel (progressionModelId, userId, modelName, modelType, description)
VALUES ('prog_model_calisthenics_uuid', 'davidrusho', '8 Step Calisthenics', 'reps', 'A bodyweight progression model focusing on increasing rep capacity by adjusting the percentage of max reps performed.');

REPLACE INTO dimProgressionModelStep (progressionModelStepId, progressionModelId, stepNumber, targetSets, targetReps, percentOfMax, description) VALUES
    ('step_calisthenics_1', 'prog_model_calisthenics_uuid', 1, 3, NULL, 60, '3 sets @ 60% of Max Reps'),
    ('step_calisthenics_2', 'prog_model_calisthenics_uuid', 2, 4, NULL, 60, '4 sets @ 60% of Max Reps'),
    ('step_calisthenics_3', 'prog_model_calisthenics_uuid', 3, 3, NULL, 70, '3 sets @ 70% of Max Reps'),
    ('step_calisthenics_4', 'prog_model_calisthenics_uuid', 4, 3, NULL, 75, '3 sets @ 75% of Max Reps'),
    ('step_calisthenics_5', 'prog_model_calisthenics_uuid', 5, 4, NULL, 75, '4 sets @ 75% of Max Reps'),
    ('step_calisthenics_6', 'prog_model_calisthenics_uuid', 6, 3, NULL, 80, '3 sets @ 80% of Max Reps'),
    ('step_calisthenics_7', 'prog_model_calisthenics_uuid', 7, 4, NULL, 80, '4 sets @ 80% of Max Reps'),
    ('step_calisthenics_8', 'prog_model_calisthenics_uuid', 8, 1, NULL, 90, '1 set @ 90% of Max Reps to test max');


----------------------------------------------------
-- STEP 2: REBUILD ALL APPLICATION VIEWS
-- View recreation is not necessary for a data-only migration.
-- This step is critical after schema changes (ALTER, DROP, etc.), but can be skipped here.
----------------------------------------------------