
# 2025-06-17 - Changelog
**updated:** 2025-06-17\
**summary:** A detailed log of the significant schema refactoring performed on the workout logger database to improve data integrity, performance, and overall reliability.

---

Today, the workout logger database underwent a significant overhaul to build a more robust and efficient foundation for the application. The primary goals were to enforce data integrity, improve query performance, and standardize data types across the schema.

This document serves as a detailed changelog of the changes made to each table.

> [!tip] 
> **Summary of Changes**
> - **Enforced Data Integrity:** Added `UNIQUE`, `NOT NULL`, and `FOREIGN KEY` constraints to prevent duplicate or invalid data.
> - **Standardized Data Types:** Converted `TEXT`-based timestamps to the more efficient `INTEGER` Unix timestamp format across all tables.
> - **Improved Query Performance:** Added indexes to key columns that are frequently used in search and filter operations.
> - **Normalized Key Tables:** Refactored the `WorkoutLog` table into a normalized parent/child structure for more flexible and accurate set tracking.

---

## Table-by-Table Refactoring

### `WorkoutLog` & `WorkoutSetLog` (Normalization)

The most significant change was the normalization of workout logging. The original `WorkoutLog` table stored set and rep information in a flat structure, which was inflexible. This was refactored into two related tables.

> [!note] 
> **What is Normalization?**\
> **Normalization** is the process of organizing columns and tables in a database to minimize data redundancy. By moving the repeating set data into its own WorkoutSetLog table, we reduce redundancy and make the data much easier and more powerful to query.

**`WorkoutLog` Refactor**

This table now acts as a parent container for a workout session. Columns related to individual sets were removed.

|**Change**|**Before**|**After**|
|---|---|---|
|Set Tracking|`TotalSetsPerformed` & `RepsPerformed` columns existed.|Columns removed; data moved to `WorkoutSetLog`.|
|Timestamp|`ExerciseTimestamp` was `TEXT`.|`ExerciseTimestamp` is `INTEGER` (Unix time).|
|Relationships|Implied relationships to users/exercises.|`FOREIGN KEY` constraints on `UserID` & `ExerciseID`.|

`WorkoutLog` Schema

```sql
CREATE TABLE WorkoutLog (
    LogID                      TEXT PRIMARY KEY,
    UserID                     TEXT NOT NULL,
    ExerciseTimestamp          INTEGER NOT NULL,
    ExerciseID                 TEXT NOT NULL,
    Estimated1RM               REAL,
    WorkoutNotes               TEXT,
    LinkedTemplateID           TEXT,
    LinkedProgressionModelID   TEXT,
    PerformedAtStepNumber      INTEGER,
    LastModified               TEXT,
    FOREIGN KEY (UserID)       REFERENCES users (username),
    FOREIGN KEY (ExerciseID)   REFERENCES ExerciseLibrary (ExerciseID)
);
```


**New Table: `WorkoutSetLog`**

This new table holds the data for each individual set, linked back to a single `WorkoutLog` entry.

**`WorkoutSetLog` Schema**
```sql
CREATE TABLE WorkoutSetLog (
    SetID                 TEXT PRIMARY KEY,
    LogID                 TEXT NOT NULL,
    SetNumber             INTEGER NOT NULL,
    RepsPerformed         INTEGER,
    WeightUsed            REAL,
    WeightUnit            TEXT,
    RPE_Recorded          REAL,
    FOREIGN KEY (LogID)   REFERENCES WorkoutLog (LogID) ON DELETE CASCADE
);
```


### `ExerciseLibrary`

The library of exercises was fortified to prevent duplicates and speed up filtering.

|   |   |   |
|---|---|---|
|**Change**|**Before**|**After**|
|Exercise Name|`ExerciseName` was `TEXT`.|`ExerciseName` is `TEXT UNIQUE NOT NULL`.|
|Timestamps|`LastModified` was `TEXT`.|`LastModified` is `INTEGER` (Unix time) with a default.|
|Status|`IsEnabled` was `INTEGER`.|`IsEnabled` is `INTEGER NOT NULL DEFAULT 1`.|

**`ExerciseLibrary` Schema**
```sql
CREATE TABLE ExerciseLibrary (
    ExerciseID          TEXT PRIMARY KEY,
    ExerciseName        TEXT UNIQUE NOT NULL,
    ExerciseAlias       TEXT,
    BodyLocation        TEXT,
    BodyGroup           TEXT,
    PrimaryMuscles      TEXT,
    SecondaryMuscle     TEXT,
    EquipmentType       TEXT,
    EquipmentNeeded     TEXT,
    Category            TEXT,
    DefaultLogType      TEXT,
    Instructions        TEXT,
    VideoURL            TEXT,
    ImageURL            TEXT,
    UnitOfMeasurement   TEXT,
    IsCustom            INTEGER,
    IsEnabled           INTEGER NOT NULL DEFAULT 1,
    LastModified        INTEGER DEFAULT (strftime('%s', 'now')),
    NotesOrVariations   TEXT
);
```


### `WorkoutTemplates`

The workout templates were updated to ensure names are unique and that every template has a valid creator.

|   |   |   |
|---|---|---|
|**Change**|**Before**|**After**|
|Template Name|`TemplateName` was `TEXT`.|`TemplateName` is `TEXT UNIQUE NOT NULL`.|
|User Link|`CreatedByUserID` was `TEXT`.|`CreatedByUserID` is `TEXT NOT NULL` with a `FOREIGN KEY`.|

**`WorkoutTemplates` Schema**
```sql
CREATE TABLE WorkoutTemplates (
    TemplateID          TEXT PRIMARY KEY,
    TemplateName        TEXT UNIQUE NOT NULL,
    ProgressionModelID  TEXT,
    Description         TEXT,
    Focus               TEXT,
    Frequency           TEXT,
    CreatedByUserID     TEXT NOT NULL,
    LastModified        INTEGER DEFAULT (strftime('%s', 'now')),
    IsEnabled           INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (CreatedByUserID) REFERENCES users (username)
);
```

### `ProgressionModels` & `ProgressionModelSteps`

The rules governing progressions were made more robust. Model names are now unique, and steps are intrinsically linked to their parent model.

| **Table**                   | **Change**      | **Before**                         | **After**                                                      |
| --------------------------- | --------------- | ---------------------------------- | -------------------------------------------------------------- |
| **`ProgressionModels`**     | Model Name      | `ProgressionModelName` was `TEXT`. | `ProgressionModelName` is `TEXT UNIQUE NOT NULL`.              |
| **`ProgressionModelSteps`** | Step Uniqueness | No uniqueness enforced.            | `UNIQUE` constraint on (`ProgressionModelID`, `StepNumber`).   |
| **`ProgressionModelSteps`** | Model Link      | Implied relationship.              | `FOREIGN KEY` to `ProgressionModels` with `ON DELETE CASCADE`. |

**New Schemas for Progression Tables**

```sql
-- New ProgressionModels Schema
CREATE TABLE ProgressionModels (
    ProgressionModelID              TEXT PRIMARY KEY,
    ProgressionModelName            TEXT UNIQUE NOT NULL,
    /* ... other columns ... */
    LastModified                    INTEGER DEFAULT (strftime('%s', 'now'))
);

-- New ProgressionModelSteps Schema
CREATE TABLE ProgressionModelSteps (
    ProgressionModelStepID  TEXT PRIMARY KEY,
    ProgressionModelID      TEXT NOT NULL,
    StepNumber              INTEGER NOT NULL,
    /* ... other columns ... */
    FOREIGN KEY (ProgressionModelID) REFERENCES ProgressionModels (ProgressionModelID) ON DELETE CASCADE,
    UNIQUE (ProgressionModelID, StepNumber)
);
```

### `UserExerciseProgression`

This critical junction table, which tracks user progress, received significant integrity upgrades to ensure all links are valid.

| **Change**        | **Before**                                          | **After**                                                      |
| ----------------- | --------------------------------------------------- | -------------------------------------------------------------- |
| Record Uniqueness | No uniqueness enforced.                             | `UNIQUE` constraint on (`UserID`, `TemplateID`, `ExerciseID`). |
| Relationships     | All relationships were implied.                     | `FOREIGN KEY` constraints added for all ID columns.            |
| Date Format       | `DateOfLastAttempt` & `CycleStartDate` were `TEXT`. | Changed to `INTEGER` (Unix time).                              |

**`UserExerciseProgression` Schema**
```sql
CREATE TABLE UserExerciseProgression (
    UserExerciseProgressionID   TEXT PRIMARY KEY,
    UserID                      TEXT NOT NULL,
    TemplateID                  TEXT NOT NULL,
    ExerciseID                  TEXT NOT NULL,
    /* ... other columns ... */
    FOREIGN KEY (UserID) REFERENCES users (username),
    FOREIGN KEY (TemplateID) REFERENCES WorkoutTemplates (TemplateID),
    FOREIGN KEY (ExerciseID) REFERENCES ExerciseLibrary (ExerciseID),
    FOREIGN KEY (ProgressionModelID) REFERENCES ProgressionModels (ProgressionModelID),
    UNIQUE (UserID, TemplateID, ExerciseID)
);
```

---

## Performance Boost: New Indexes

To ensure the application remains fast as data grows, the following indexes were added to speed up common queries.

```sql
-- For workout history lookups
CREATE INDEX idx_workoutlog_user_id ON WorkoutLog(UserID);
CREATE INDEX idx_workoutlog_exercise_id ON WorkoutLog(ExerciseID);
CREATE INDEX idx_workoutlog_timestamp ON WorkoutLog(ExerciseTimestamp);
CREATE INDEX idx_workoutsetlog_log_id ON WorkoutSetLog(LogID);

-- For filtering the exercise library
CREATE INDEX idx_exerciselib_bodygroup ON ExerciseLibrary(BodyGroup);
CREATE INDEX idx_exerciselib_equipment ON ExerciseLibrary(EquipmentType);
CREATE INDEX idx_exerciselib_category ON ExerciseLibrary(Category);

-- For finding user-created templates
CREATE INDEX idx_workouttemplates_createdby ON WorkoutTemplates(CreatedByUserID);

-- For finding a user's progression records
CREATE INDEX idx_userprog_userid ON UserExerciseProgression(UserID);
```


### Database Views

Three views were created to encapsulate complex `JOIN` logic, making the SQL in the application files much cleaner and easier to maintain.

1. **`FullWorkoutHistory`**: Provides a simple, flattened, and user-friendly history of every single workout set.
    
2. **`UserExerciseProgressionTargets`**: Calculates the _next_ target workout for a user based on their current progression.
    
3. **`WorkoutTemplateDetails`**: Provides a detailed list of all exercises within each workout template.

## Database Rebuild: The Final Fix

After all the table and view refactoring, a persistent error related to old `_temp` tables remained. This indicated that the database file itself was in an inconsistent state, with "ghost" references that could not be cleared by standard `ALTER` commands or view rebuilds.

> [!danger] The Problem
> Lingering Internal References Extensive `RENAME` and `ALTER` operations can sometimes leave a database's internal schema master record (`sqlite_master`) in a state where it still holds references to old, deleted objects. This results in persistent "no such table" errors even when the visible schema appears correct.

> [!success] The Solution
> Database Dump and Re-import The definitive solution was to perform a full database rebuild. This process exports the entire database—schema and data—to a clean `.sql` text file. This text file acts as a perfect blueprint, containing only the final, correct `CREATE` and `INSERT` statements.
>
> This blueprint was then imported into a brand new, empty database file. This rebuilds the database from scratch, completely purging any old, inconsistent internal references and resulting in a perfectly clean and reliable `workouts.db` file. This was accomplished using **DB Browser for SQLite**.