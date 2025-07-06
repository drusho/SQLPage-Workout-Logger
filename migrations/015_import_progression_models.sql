-- migrations/015_import_progression_models.sql
--
----------------------------------------------------
-- MIGRATION METADATA
----------------------------------------------------
-- Description: Inserts three default progressive overload programs: 
--              '8 Step RPE High Reps', '8 Step RPE Low Reps', and '8 Step Calisthenics'.
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
REPLACE INTO
    dimProgressionModel (progressionModelId, userId, modelName, modelType)
VALUES
    (
        'prog_model_high_reps_uuid',
        'davidrusho',
        '8 Step RPE High Reps',
        'weight'
    );

REPLACE INTO
    dimProgressionModelStep (
        progressionModelStepId,
        progressionModelId,
        stepNumber,
        targetSets,
        targetReps,
        percentOfMax
    )
VALUES
    (
        'step_high_reps_1',
        'prog_model_high_reps_uuid',
        1,
        3,
        10,
        75
    ),
    (
        'step_high_reps_2',
        'prog_model_high_reps_uuid',
        2,
        4,
        10,
        75
    ),
    (
        'step_high_reps_3',
        'prog_model_high_reps_uuid',
        3,
        3,
        12,
        75
    ),
    (
        'step_high_reps_4',
        'prog_model_high_reps_uuid',
        4,
        4,
        10,
        80
    ),
    (
        'step_high_reps_5',
        'prog_model_high_reps_uuid',
        5,
        3,
        12,
        75
    ),
    (
        'step_high_reps_6',
        'prog_model_high_reps_uuid',
        6,
        4,
        12,
        75
    ),
    (
        'step_high_reps_7',
        'prog_model_high_reps_uuid',
        7,
        3,
        12,
        80
    ),
    (
        'step_high_reps_8',
        'prog_model_high_reps_uuid',
        8,
        1,
        NULL,
        85
    );

-- AMRAP (As Many Reps As Possible) is stored as NULL reps
--
-- Program 2: 8 Step RPE Low Reps (Weight-based)
--
REPLACE INTO
    dimProgressionModel (progressionModelId, userId, modelName, modelType)
VALUES
    (
        'prog_model_low_reps_uuid',
        'davidrusho',
        '8 Step RPE Low Reps',
        'weight'
    );

REPLACE INTO
    dimProgressionModelStep (
        progressionModelStepId,
        progressionModelId,
        stepNumber,
        targetSets,
        targetReps,
        percentOfMax
    )
VALUES
    (
        'step_low_reps_1',
        'prog_model_low_reps_uuid',
        1,
        3,
        6,
        75
    ),
    (
        'step_low_reps_2',
        'prog_model_low_reps_uuid',
        2,
        4,
        6,
        75
    ),
    (
        'step_low_reps_3',
        'prog_model_low_reps_uuid',
        3,
        3,
        7,
        75
    ),
    (
        'step_low_reps_4',
        'prog_model_low_reps_uuid',
        4,
        4,
        6,
        80
    ),
    (
        'step_low_reps_5',
        'prog_model_low_reps_uuid',
        5,
        3,
        7,
        75
    ),
    (
        'step_low_reps_6',
        'prog_model_low_reps_uuid',
        6,
        4,
        7,
        75
    ),
    (
        'step_low_reps_7',
        'prog_model_low_reps_uuid',
        7,
        3,
        7,
        80
    ),
    (
        'step_low_reps_8',
        'prog_model_low_reps_uuid',
        8,
        1,
        NULL,
        85
    );

-- AMRAP is stored as NULL reps
--
-- Program 3: 8 Step Calisthenics (Rep-based)
--
REPLACE INTO
    dimProgressionModel (progressionModelId, userId, modelName, modelType)
VALUES
    (
        'prog_model_calisthenics_uuid',
        'davidrusho',
        '8 Step Calisthenics',
        'reps'
    );

REPLACE INTO
    dimProgressionModelStep (
        progressionModelStepId,
        progressionModelId,
        stepNumber,
        targetSets,
        targetReps,
        percentOfMax
    )
VALUES
    (
        'step_calisthenics_1',
        'prog_model_calisthenics_uuid',
        1,
        3,
        NULL,
        60
    ),
    (
        'step_calisthenics_2',
        'prog_model_calisthenics_uuid',
        2,
        4,
        NULL,
        60
    ),
    (
        'step_calisthenics_3',
        'prog_model_calisthenics_uuid',
        3,
        3,
        NULL,
        70
    ),
    (
        'step_calisthenics_4',
        'prog_model_calisthenics_uuid',
        4,
        3,
        NULL,
        75
    ),
    (
        'step_calisthenics_5',
        'prog_model_calisthenics_uuid',
        5,
        4,
        NULL,
        75
    ),
    (
        'step_calisthenics_6',
        'prog_model_calisthenics_uuid',
        6,
        3,
        NULL,
        80
    ),
    (
        'step_calisthenics_7',
        'prog_model_calisthenics_uuid',
        7,
        4,
        NULL,
        80
    ),
    (
        'step_calisthenics_8',
        'prog_model_calisthenics_uuid',
        8,
        1,
        NULL,
        90
    );

----------------------------------------------------
-- STEP 2: REBUILD ALL APPLICATION VIEWS
-- View recreation is not necessary for a data-only migration.
-- This step is critical after schema changes (ALTER, DROP, etc.), but can be skipped here.
----------------------------------------------------