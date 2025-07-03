

-- Migration: 009_restore_from_backup
-- Description: Restores data from a backup of the old schema into the new
-- camelCase star schema tables.

-- !!! IMPORTANT !!!
-- BEFORE RUNNING: Update the path below to point to your backup database file.
ATTACH DATABASE '/Volumes/Public/Container_Settings/sqlpage/backups/workouts-backup-2025-06-30_184258.db' AS backup_db;

PRAGMA foreign_keys = ON;

-- =============================================================================
-- Step 1: Populate Dimension Tables from the Backup
-- =============================================================================

INSERT OR IGNORE INTO dimUser (userId, displayName)
SELECT username, display_name FROM backup_db.users;

INSERT OR IGNORE INTO dimExercise (exerciseId, exerciseName, bodyGroup, equipmentNeeded)
SELECT ExerciseID, ExerciseName, BodyGroup, EquipmentNeeded FROM backup_db.ExerciseLibrary;

-- NOTE: dimDate is already populated by the previous migration and does not need data from the backup.

-- =============================================================================
-- Step 2: Populate Plan and Fact Tables from the Backup
-- =============================================================================

INSERT OR IGNORE INTO dimExercisePlan (
    exercisePlanId, userId, exerciseId, templateName, isActive, currentStepNumber
)
SELECT
    hex(randomblob(16)),
    wt.CreatedByUserID,
    tel.ExerciseID,
    wt.TemplateName,
    1, -- isActive
    1  -- currentStepNumber
FROM 
    backup_db.WorkoutTemplates wt
JOIN 
    backup_db.TemplateExerciseList tel ON wt.TemplateID = tel.TemplateID
GROUP BY
    wt.CreatedByUserID, tel.ExerciseID;

-- Step 2a: Insert historical data into the fact table, leaving exercisePlanId NULL for now.
INSERT OR IGNORE INTO factWorkoutHistory (
    workoutHistoryId, userId, exerciseId, dateId, exercisePlanId,
    setNumber, repsPerformed, weightUsed, rpeRecorded, createdAt, updatedAt
)
SELECT
    wsl.SetID,
    wl.UserID,
    wl.ExerciseID,
    CAST(strftime('%Y%m%d', wl.ExerciseTimestamp, 'unixepoch') AS INTEGER),
    NULL, -- Leave exercisePlanId empty for now
    wsl.SetNumber,
    wsl.RepsPerformed,
    wsl.WeightUsed,
    wsl.RPE_Recorded,
    wl.ExerciseTimestamp,
    wl.LastModifiedTimestamp
FROM
    backup_db.WorkoutLog wl
JOIN
    backup_db.WorkoutSetLog wsl ON wl.LogID = wsl.LogID;

-- Step 2b: Now, update the fact table to set the correct exercisePlanId.
UPDATE factWorkoutHistory
SET exercisePlanId = (
    SELECT dep.exercisePlanId
    FROM dimExercisePlan dep
    WHERE 
        dep.userId = factWorkoutHistory.userId 
        AND dep.exerciseId = factWorkoutHistory.exerciseId
        AND dep.isActive = 1
)
WHERE exercisePlanId IS NULL;


-- =============================================================================
-- Step 3: Clean up
-- =============================================================================
DETACH DATABASE backup_db;

