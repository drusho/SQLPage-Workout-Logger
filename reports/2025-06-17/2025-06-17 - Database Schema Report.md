# 2025-06-17 - Database Schema Report

**Summary:** \
Schema and data samples for the database powering the SQLPage - Workout application.

>[!tip]
> **Tip**
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.

---

## Table of Contents

**Tables**
- [ExerciseLibrary](#exerciselibrary)
- [ProgressionModelSteps](#progressionmodelsteps)
- [ProgressionModels](#progressionmodels)
- [TemplateExerciseList](#templateexerciselist)
- [UserExerciseProgression](#userexerciseprogression)
- [WorkoutLog](#workoutlog)
- [WorkoutSetLog](#workoutsetlog)
- [WorkoutTemplates](#workouttemplates)
- [sessions](#sessions)
- [users](#users)

**Views**
- [FullWorkoutHistory](#fullworkouthistory)
- [UserExerciseProgressionTargets](#userexerciseprogressiontargets)
- [WorkoutTemplateDetails](#workouttemplatedetails)

## Database Properties

| Property | Value |
| :--- | :--- |
| Encoding | UTF-8 |
| Page Size | 4096 bytes |
| Foreign Key Enforcement | Off |
| Journal Mode | DELETE |
| User Version | 0 |

## Table Schemas

---
### ExerciseLibrary

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `ExerciseID` | TEXT |  |  | ✅ |
| `ExerciseName` | TEXT | ✅ |  |  |
| `ExerciseAlias` | TEXT |  |  |  |
| `BodyLocation` | TEXT |  |  |  |
| `BodyGroup` | TEXT |  |  |  |
| `PrimaryMuscles` | TEXT |  |  |  |
| `SecondaryMuscle` | TEXT |  |  |  |
| `EquipmentType` | TEXT |  |  |  |
| `EquipmentNeeded` | TEXT |  |  |  |
| `Category` | TEXT |  |  |  |
| `DefaultLogType` | TEXT |  |  |  |
| `Instructions` | TEXT |  |  |  |
| `VideoURL` | TEXT |  |  |  |
| `ImageURL` | TEXT |  |  |  |
| `UnitOfMeasurement` | TEXT |  |  |  |
| `IsCustom` | INTEGER |  |  |  |
| `IsEnabled` | INTEGER | ✅ | `1` |  |
| `LastModified` | INTEGER |  | `strftime('%s', 'now')` |  |
| `NotesOrVariations` | TEXT |  |  |  |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idx_exerciselib_category` | `Category` |  |
| `idx_exerciselib_equipment` | `EquipmentType` |  |
| `idx_exerciselib_bodygroup` | `BodyGroup` |  |
| `sqlite_autoindex_ExerciseLibrary_2` | `ExerciseName` | ✅ |
| `sqlite_autoindex_ExerciseLibrary_1` | `ExerciseID` | ✅ |

**Creation SQL**

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
)
```

**Data Samples (First 3 Rows)**

| ExerciseID | ExerciseName | ExerciseAlias | BodyLocation | BodyGroup | PrimaryMuscles | SecondaryMuscle | EquipmentType | EquipmentNeeded | Category | DefaultLogType | Instructions | VideoURL | ImageURL | UnitOfMeasurement | IsCustom | IsEnabled | LastModified | NotesOrVariations |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| UUID001 | Dumbbell Incline Chest Press | DB Incline | Upper | Chest | Pectorals Major | Deltoids (Anterior), Triceps | Dumbbell | Dumbbells, Adjustable Bench | Strength, Compound | WeightAndReps | NULL | NULL | NULL | lbs | 0 | 1 | 1746835200 | Adjust incline for different upper chest emphasis. |
| UUID002 | Single Leg Press | SL Leg Press | Lower | Legs | Quadriceps | Glutes, Hamstrings, Adductors | Machine - Stack | Leg Press Machine | Strength, Unilateral | WeightAndReps | NULL | NULL | NULL | lbs | 0 | 1 | 1746835200 | Focus on controlled movement for each leg. |
| UUID003 | Lat Pulldown | Lat Pulldowns | Upper | Back | Latissimus Dorsi | Biceps, Rhomboids, Middle Trapezius | Machine - Stack | Lat Pulldown Machine, Attachment (e.g., Wide Bar) | Strength, Compound | WeightAndReps | NULL | NULL | NULL | lbs | 0 | 1 | 1746835200 | Vary grip width and type for different back focus. |


---
### ProgressionModelSteps

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `ProgressionModelStepID` | TEXT |  |  | ✅ |
| `ProgressionModelID` | TEXT | ✅ |  |  |
| `StepNumber` | INTEGER | ✅ |  |  |
| `TargetSetsFormula` | TEXT |  |  |  |
| `TargetRepsFormula` | TEXT |  |  |  |
| `TargetWeightFormula` | TEXT |  |  |  |
| `StepNotes` | TEXT |  |  |  |
| `LastModified` | INTEGER |  | `strftime('%s', 'now')` |  |
| `SuccessCriteriaRPE` | REAL |  |  |  |
| `FailureCriteriaType` | TEXT |  |  |  |
| `FailureCriteriaValue` | TEXT |  |  |  |
| `TargetWeightPercentage` | REAL |  |  |  |
| `RepsType` | TEXT |  |  |  |
| `RepsValue` | REAL |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `ProgressionModelID` | `ProgressionModels` | `ProgressionModelID` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_ProgressionModelSteps_2` | `ProgressionModelID`, `StepNumber` | ✅ |
| `sqlite_autoindex_ProgressionModelSteps_1` | `ProgressionModelStepID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE ProgressionModelSteps (
    ProgressionModelStepID  TEXT PRIMARY KEY,
    ProgressionModelID      TEXT NOT NULL,
    StepNumber              INTEGER NOT NULL,
    TargetSetsFormula       TEXT,
    TargetRepsFormula       TEXT,
    TargetWeightFormula     TEXT,
    StepNotes               TEXT,
    LastModified            INTEGER DEFAULT (strftime('%s', 'now')),
    SuccessCriteriaRPE      REAL,
    FailureCriteriaType     TEXT,
    FailureCriteriaValue    TEXT,
    TargetWeightPercentage  REAL,
    RepsType                TEXT,
    RepsValue               REAL,
    FOREIGN KEY (ProgressionModelID) REFERENCES ProgressionModels (ProgressionModelID) ON DELETE CASCADE,
    UNIQUE (ProgressionModelID, StepNumber)
)
```

**Data Samples (First 3 Rows)**

| ProgressionModelStepID | ProgressionModelID | StepNumber | TargetSetsFormula | TargetRepsFormula | TargetWeightFormula | StepNotes | LastModified | SuccessCriteriaRPE | FailureCriteriaType | FailureCriteriaValue | TargetWeightPercentage | RepsType | RepsValue |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| PMS_8S_High_Rep_001 | PM_8StepRPE_002 | 1 | 3 | 10 | CurrentCycle1RMEstimate * 0.75 | Week 1: 70-75% 1RM target (using 75% as base) | 1746895095 | NULL | NULL | NULL | 0.75 | FIXED | 10.0 |
| PMS_8S_High_Rep_002 | PM_8StepRPE_002 | 2 | 4 | 10 | CurrentCycle1RMEstimate * 0.75 | Week 2: 70-75% 1RM target | 1746895095 | NULL | NULL | NULL | 0.75 | FIXED | 10.0 |
| PMS_8S_High_Rep_003 | PM_8StepRPE_002 | 3 | 3 | 12 | CurrentCycle1RMEstimate * 0.75 | Week 3. 70-75% 1RM target | 1746895095 | NULL | NULL | NULL | 0.75 | FIXED | 12.0 |


---
### ProgressionModels

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `ProgressionModelID` | TEXT |  |  | ✅ |
| `ProgressionModelName` | TEXT | ✅ |  |  |
| `Description` | TEXT |  |  |  |
| `TriggerConditionLogic` | TEXT |  |  |  |
| `FailureConditionLogic` | TEXT |  |  |  |
| `CycleCompletionConditionLogic` | TEXT |  |  |  |
| `CycleCompletionNextAction` | TEXT |  |  |  |
| `NewCycleBaseWeightFormula` | TEXT |  |  |  |
| `DefaultTotalSteps` | INTEGER |  |  |  |
| `Notes` | TEXT |  |  |  |
| `LastModified` | INTEGER |  | `strftime('%s', 'now')` |  |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_ProgressionModels_2` | `ProgressionModelName` | ✅ |
| `sqlite_autoindex_ProgressionModels_1` | `ProgressionModelID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE ProgressionModels (
    ProgressionModelID              TEXT PRIMARY KEY,
    ProgressionModelName            TEXT UNIQUE NOT NULL,
    Description                     TEXT,
    TriggerConditionLogic           TEXT,
    FailureConditionLogic           TEXT,
    CycleCompletionConditionLogic   TEXT,
    CycleCompletionNextAction       TEXT,
    NewCycleBaseWeightFormula       TEXT,
    DefaultTotalSteps               INTEGER,
    Notes                           TEXT,
    LastModified                    INTEGER DEFAULT (strftime('%s', 'now'))
)
```

**Data Samples (First 3 Rows)**

| ProgressionModelID | ProgressionModelName | Description | TriggerConditionLogic | FailureConditionLogic | CycleCompletionConditionLogic | CycleCompletionNextAction | NewCycleBaseWeightFormula | DefaultTotalSteps | Notes | LastModified |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| PM_UUID002 | Linear Periodization - Simple Weight Add | Each week, add a small amount of weight if all reps are completed. | AllRepsCompleted = TRUE | AllRepsCompleted = FALSE | Week 4 Completed | Reset to Week 1, Increase Base | currentCycleBaseWeight + 2.5 kg | 4 | Simpler linear model. | 1746894920 |
| PM_8StepRPE_001 | 8-Step Undulating 1RM% Cycle | An 8-step cycle progressing sets, reps, and 1RM%. RPE performance dictates advancement. Cycle culminates in an AMRAP test to update 1RM. | LoggedRPE <= 8 | LoggedRPE > 8 | CurrentStepNumber = 8 AND LoggedRPE <= 8 AND AMRAPReps > 0 | Reset to Step 1 | ( (CurrentCycle1RMEstimate * 0.90) * (1 + AMRAPRepsAtStep8 / 30) ) | 8 | Implements the user-provided 8-week table. New 1RM based on Epley from Step 8 AMRAP. | 1746894920 |
| PM_8StepRPE_002 | 8-Step High Rep RPE Cycle | An 8-step cycle focused on higher repetitions, progressing sets, reps, and 1RM%. RPE dictates advancement. AMRAP test on Step 8 at 80% 1RM. | LoggedRPE <= 8 | LoggedRPE > 8 | CurrentStepNumber = 8 AND LoggedRPE <= 8 AND AMRAPReps > 0 | Reset to Step 1 | ( (CurrentCycle1RMEstimate * 0.80) * (1 + AMRAPRepsAtStep8 / 30) ) | 8 | Implements the user-provided 8-week table. New 1RM based on Epley from Step 8 AMRAP. | 1746894920 |


---
### TemplateExerciseList

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `TemplateExerciseListID` | TEXT |  |  | ✅ |
| `TemplateID` | TEXT | ✅ |  |  |
| `ExerciseID` | TEXT | ✅ |  |  |
| `ExerciseAlias` | TEXT |  |  |  |
| `ProgressionModelID` | TEXT |  |  |  |
| `OrderInWorkout` | INTEGER |  |  |  |
| `LastModified` | TEXT |  |  |  |
| `IsEnabled` | INTEGER |  | `1` |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `ProgressionModelID` | `ProgressionModels_temp` | `ProgressionModelID` |
| `ExerciseID` | `ExerciseLibrary_temp` | `ExerciseID` |
| `TemplateID` | `WorkoutTemplates_temp` | `TemplateID` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_TemplateExerciseList_1` | `TemplateExerciseListID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE TemplateExerciseList (
    TemplateExerciseListID TEXT PRIMARY KEY,
    TemplateID TEXT NOT NULL,
    ExerciseID TEXT NOT NULL,
    ExerciseAlias TEXT,
    ProgressionModelID TEXT,
    OrderInWorkout INTEGER,
    LastModified TEXT,
    IsEnabled INTEGER DEFAULT 1,
    FOREIGN KEY (TemplateID) REFERENCES "WorkoutTemplates_temp" (TemplateID),
    FOREIGN KEY (ExerciseID) REFERENCES "ExerciseLibrary_temp" (ExerciseID),
    FOREIGN KEY (ProgressionModelID) REFERENCES "ProgressionModels_temp" (ProgressionModelID)
)
```

**Data Samples (First 3 Rows)**

| TemplateExerciseListID | TemplateID | ExerciseID | ExerciseAlias | ProgressionModelID | OrderInWorkout | LastModified | IsEnabled |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| ET_UUID001 | WT_UUID001 | UUID001 | DB Incline | PM_8StepRPE_002 | 1 | NULL | 1 |
| ET_UUID002 | WT_UUID001 | UUID002 | SL Leg Press | PM_8StepRPE_002 | 2 | NULL | 1 |
| ET_UUID003 | WT_UUID001 | UUID003 | Lat Pulldowns | PM_8StepRPE_002 | 3 | NULL | 1 |


---
### UserExerciseProgression

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `UserExerciseProgressionID` | TEXT |  |  | ✅ |
| `UserID` | TEXT | ✅ |  |  |
| `TemplateID` | TEXT | ✅ |  |  |
| `ExerciseID` | TEXT | ✅ |  |  |
| `ProgressionModelID` | TEXT |  |  |  |
| `CurrentStepNumber` | INTEGER |  |  |  |
| `CurrentCycle1RMEstimate` | REAL |  |  |  |
| `LastWorkoutRPE` | REAL |  |  |  |
| `AMRAPRepsAtStep8` | REAL |  |  |  |
| `DateOfLastAttempt` | INTEGER |  |  |  |
| `CycleStartDate` | INTEGER |  |  |  |
| `MaxReps` | INTEGER |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `ProgressionModelID` | `ProgressionModels` | `ProgressionModelID` |
| `ExerciseID` | `ExerciseLibrary` | `ExerciseID` |
| `TemplateID` | `WorkoutTemplates` | `TemplateID` |
| `UserID` | `users` | `username` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idx_userprog_userid` | `UserID` |  |
| `sqlite_autoindex_UserExerciseProgression_2` | `UserID`, `TemplateID`, `ExerciseID` | ✅ |
| `sqlite_autoindex_UserExerciseProgression_1` | `UserExerciseProgressionID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE UserExerciseProgression (
    UserExerciseProgressionID   TEXT PRIMARY KEY,
    UserID                      TEXT NOT NULL,
    TemplateID                  TEXT NOT NULL,
    ExerciseID                  TEXT NOT NULL,
    ProgressionModelID          TEXT,
    CurrentStepNumber           INTEGER,
    CurrentCycle1RMEstimate     REAL,
    LastWorkoutRPE              REAL,
    AMRAPRepsAtStep8            REAL,
    DateOfLastAttempt           INTEGER,
    CycleStartDate              INTEGER,
    MaxReps                     INTEGER,
    FOREIGN KEY (UserID) REFERENCES users (username),
    FOREIGN KEY (TemplateID) REFERENCES WorkoutTemplates (TemplateID),
    FOREIGN KEY (ExerciseID) REFERENCES ExerciseLibrary (ExerciseID),
    FOREIGN KEY (ProgressionModelID) REFERENCES ProgressionModels (ProgressionModelID),
    UNIQUE (UserID, TemplateID, ExerciseID)
)
```

**Data Samples (First 3 Rows)**

| UserExerciseProgressionID | UserID | TemplateID | ExerciseID | ProgressionModelID | CurrentStepNumber | CurrentCycle1RMEstimate | LastWorkoutRPE | AMRAPRepsAtStep8 | DateOfLastAttempt | CycleStartDate | MaxReps |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| UEP_1df55c38-38d5-4f5a-b28b-a42b0daa7f41 | davidrusho | WT_UUID001 | UUID001 | PM_8StepRPE_002 | 3 | 84.0 | 8.0 | NULL | 1748472852 | 1748472852 | NULL |
| 8919bd4d2ee66690b8bc9ae35195afa9 | davidrusho | WT_UUID001 | UUID002 | PM_8StepRPE_002 | 3 | 126.0 | 8.0 | NULL | 1748473690 | 1748473690 | NULL |
| 9741549c9c95e296f2837275f2dc3ce5 | davidrusho | WT_UUID001 | UUID003 | PM_8StepRPE_002 | 3 | 182.0 | 8.0 | NULL | 1748474449 | 1748474449 | NULL |


---
### WorkoutLog

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `LogID` | TEXT |  |  | ✅ |
| `UserID` | TEXT | ✅ |  |  |
| `ExerciseTimestamp` | INTEGER | ✅ |  |  |
| `ExerciseID` | TEXT | ✅ |  |  |
| `Estimated1RM` | REAL |  |  |  |
| `WorkoutNotes` | TEXT |  |  |  |
| `LinkedTemplateID` | TEXT |  |  |  |
| `LinkedProgressionModelID` | TEXT |  |  |  |
| `PerformedAtStepNumber` | INTEGER |  |  |  |
| `LastModified` | TEXT |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `ExerciseID` | `ExerciseLibrary_temp` | `ExerciseID` |
| `UserID` | `users` | `username` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idx_workoutlog_timestamp` | `ExerciseTimestamp` |  |
| `idx_workoutlog_exercise_id` | `ExerciseID` |  |
| `idx_workoutlog_user_id` | `UserID` |  |
| `sqlite_autoindex_WorkoutLog_1` | `LogID` | ✅ |

**Creation SQL**

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
    FOREIGN KEY (ExerciseID)   REFERENCES "ExerciseLibrary_temp" (ExerciseID)
)
```

**Data Samples (First 3 Rows)**

| LogID | UserID | ExerciseTimestamp | ExerciseID | Estimated1RM | WorkoutNotes | LinkedTemplateID | LinkedProgressionModelID | PerformedAtStepNumber | LastModified |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WLOG_UUID001 | davidrusho | 1746053682 | UUID001 | 84.0 | NULL | NULL | NULL | NULL | 2025-05-10 17:45:29 |
| WLOG_UUID002 | davidrusho | 1746054770 | UUID002 | 151.2 | NULL | NULL | NULL | NULL | 2025-05-10 17:45:29 |
| WLOG_UUID003 | davidrusho | 1746055694 | UUID003 | 180.0 | NULL | NULL | NULL | NULL | 2025-05-10 17:45:29 |


---
### WorkoutSetLog

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `SetID` | TEXT |  |  | ✅ |
| `LogID` | TEXT | ✅ |  |  |
| `SetNumber` | INTEGER | ✅ |  |  |
| `RepsPerformed` | INTEGER |  |  |  |
| `WeightUsed` | REAL |  |  |  |
| `WeightUnit` | TEXT |  |  |  |
| `RPE_Recorded` | REAL |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `LogID` | `WorkoutLog_temp` | `LogID` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idx_workoutsetlog_log_id` | `LogID` |  |
| `sqlite_autoindex_WorkoutSetLog_1` | `SetID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE WorkoutSetLog (
    SetID                 TEXT PRIMARY KEY,
    LogID                 TEXT NOT NULL,
    SetNumber             INTEGER NOT NULL,
    RepsPerformed         INTEGER,
    WeightUsed            REAL,
    WeightUnit            TEXT,
    RPE_Recorded          REAL,
    FOREIGN KEY (LogID)   REFERENCES "WorkoutLog_temp" (LogID) ON DELETE CASCADE
)
```

**Data Samples (First 3 Rows)**

| SetID | LogID | SetNumber | RepsPerformed | WeightUsed | WeightUnit | RPE_Recorded |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 9aa54afe80e4786f58f71727f73fa7c0 | WLOG_0190d5f8-4693-47a9-a42e-b826511c4705 | 1 | 12 | 40.0 | lbs | 8.0 |
| 96029ed67c9413ebae0d6389c94cd6b4 | WLOG_0190d5f8-4693-47a9-a42e-b826511c4705 | 2 | 12 | 40.0 | lbs | 8.0 |
| a9ee5163304a3cee181bff8a78f674cc | WLOG_0190d5f8-4693-47a9-a42e-b826511c4705 | 3 | 12 | 40.0 | lbs | 8.0 |


---
### WorkoutTemplates

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `TemplateID` | TEXT |  |  | ✅ |
| `TemplateName` | TEXT | ✅ |  |  |
| `ProgressionModelID` | TEXT |  |  |  |
| `Description` | TEXT |  |  |  |
| `Focus` | TEXT |  |  |  |
| `Frequency` | TEXT |  |  |  |
| `CreatedByUserID` | TEXT | ✅ |  |  |
| `LastModified` | INTEGER |  | `strftime('%s', 'now')` |  |
| `IsEnabled` | INTEGER | ✅ | `1` |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `CreatedByUserID` | `users` | `username` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idx_workouttemplates_createdby` | `CreatedByUserID` |  |
| `sqlite_autoindex_WorkoutTemplates_2` | `TemplateName` | ✅ |
| `sqlite_autoindex_WorkoutTemplates_1` | `TemplateID` | ✅ |

**Creation SQL**

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
)
```

**Data Samples (First 3 Rows)**

| TemplateID | TemplateName | ProgressionModelID | Description | Focus | Frequency | CreatedByUserID | LastModified | IsEnabled |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WT_UUID001 | Full Body A | PM_8StepRPE_002 | 3-day routine focusing on compound movements. | Strength | 3 times a week | davidrusho | 1746835200 | 1 |
| WT_UUID002 | Full Body B | PM_8StepRPE_002 | 3-day routine focusing on compound movements. | Strength | 3 times a week | davidrusho | 1746835200 | 1 |
| WT_UUID003 | Full Body C | PM_8StepRPE_002 | 3-day routine focusing on compound movements. | Strength | 3 times a week | davidrusho | 1746835200 | 1 |


---
### sessions

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `session_token` | TEXT |  |  | ✅ |
| `username` | TEXT | ✅ |  |  |
| `expires_at` | DATETIME | ✅ |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `username` | `users` | `username` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_sessions_1` | `session_token` | ✅ |

**Creation SQL**

```sql
CREATE TABLE sessions (
    session_token TEXT PRIMARY KEY,
    username TEXT NOT NULL REFERENCES users(username) ON DELETE CASCADE,
    expires_at DATETIME NOT NULL
)
```

**Data Samples (First 3 Rows)**

| session_token | username | expires_at |
| :--- | :--- | :--- |
| nuvEHVKY0ErE0RRsSLmw7kpIallW4uJe | Salaried8674 | 2025-06-15 02:22:21 |
| lyb27vQ4pAxrmdkBqhthZtZPZaz6wFu1 | Salaried8674 | 2025-06-15 02:25:29 |
| HvsMdmbHxJHrGJl7DyNs8bvXKGpRswks | Salaried8674 | 2025-06-15 02:26:11 |


---
### users

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `username` | TEXT |  |  | ✅ |
| `password_hash` | TEXT | ✅ |  |  |
| `display_name` | TEXT |  |  |  |
| `profile_picture_url` | TEXT |  |  |  |
| `bio` | TEXT |  |  |  |
| `created_at` | DATETIME |  | `CURRENT_TIMESTAMP` |  |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_users_1` | `username` | ✅ |

**Creation SQL**

```sql
CREATE TABLE users (
    username TEXT PRIMARY KEY,
    password_hash TEXT NOT NULL,
    display_name TEXT,
    profile_picture_url TEXT,
    bio TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

**Data Samples (First 3 Rows)**

| username | password_hash | display_name | profile_picture_url | bio | created_at |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Salaried8674 | $argon2id$v=19$m=19456,t=2,p=1$qIhw6C/lUDsx+QvHhw1mPQ$7xdYsVGfwmNYbB1FqBoiL69LcP5ZoaNWxSwc6Dnp2bA | David | NULL | NULL | 2025-06-14 02:22:12 |
| test_user_1 | $argon2id$v=19$m=19456,t=2,p=1$8Hgg07NKTWutAMKh50laWQ$ByWauqecbd7qDoZqKUopg1sNkrxoHfS9KB11sSvjF7o | test_user_1 | NULL | NULL | 2025-06-14 02:45:47 |
| davidrusho | $argon2id$v=19$m=19456,t=2,p=1$x7pdgcw6RPgR9/tlPUA4oA$dzGPIyUQ2iEyLrZHEEpzQwne97dJ9NKlWRzIseOwQeo | David | NULL | NULL | 2025-06-15 01:47:41 |


## View Schemas

---
### FullWorkoutHistory

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `LogID` | TEXT |  |  |  |
| `ExerciseTimestamp` | INTEGER |  |  |  |
| `WorkoutTimeLocal` |  |  |  |  |
| `UserID` | TEXT |  |  |  |
| `UserName` | TEXT |  |  |  |
| `ExerciseID` | TEXT |  |  |  |
| `ExerciseName` | TEXT |  |  |  |
| `SetID` | TEXT |  |  |  |
| `SetNumber` | INTEGER |  |  |  |
| `RepsPerformed` | INTEGER |  |  |  |
| `WeightUsed` | REAL |  |  |  |
| `WeightUnit` | TEXT |  |  |  |
| `RPE_Recorded` | REAL |  |  |  |

**Creation SQL**

```sql
CREATE VIEW FullWorkoutHistory AS
SELECT
    wl.LogID,
    wl.ExerciseTimestamp,
    datetime(wl.ExerciseTimestamp, 'unixepoch', 'localtime') as "WorkoutTimeLocal",
    wl.UserID,
    u.display_name as "UserName",
    wl.ExerciseID,
    el.ExerciseName as "ExerciseName",
    ws.SetID,
    ws.SetNumber,
    ws.RepsPerformed,
    ws.WeightUsed,
    ws.WeightUnit,
    ws.RPE_Recorded
FROM 
    WorkoutLog wl
JOIN 
    WorkoutSetLog ws ON wl.LogID = ws.LogID
JOIN 
    users u ON wl.UserID = u.username
JOIN 
    ExerciseLibrary el ON wl.ExerciseID = el.ExerciseID
```

**Data Samples (First 3 Rows)**

| LogID | ExerciseTimestamp | WorkoutTimeLocal | UserID | UserName | ExerciseID | ExerciseName | SetID | SetNumber | RepsPerformed | WeightUsed | WeightUnit | RPE_Recorded |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WLOG_0190d5f8-4693-47a9-a42e-b826511c4705 | 1748475461 | 2025-05-28 17:37:41 | davidrusho | David | UUID004 | Preacher Curl | 9aa54afe80e4786f58f71727f73fa7c0 | 1 | 12 | 40.0 | lbs | 8.0 |
| WLOG_0190d5f8-4693-47a9-a42e-b826511c4705 | 1748475461 | 2025-05-28 17:37:41 | davidrusho | David | UUID004 | Preacher Curl | 96029ed67c9413ebae0d6389c94cd6b4 | 2 | 12 | 40.0 | lbs | 8.0 |
| WLOG_0190d5f8-4693-47a9-a42e-b826511c4705 | 1748475461 | 2025-05-28 17:37:41 | davidrusho | David | UUID004 | Preacher Curl | a9ee5163304a3cee181bff8a78f674cc | 3 | 12 | 40.0 | lbs | 8.0 |


---
### UserExerciseProgressionTargets

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `UserID` | TEXT |  |  |  |
| `TemplateID` | TEXT |  |  |  |
| `ExerciseID` | TEXT |  |  |  |
| `CurrentStepNumber` | INTEGER |  |  |  |
| `CurrentCycle1RMEstimate` | REAL |  |  |  |
| `ProgressionModelName` | TEXT |  |  |  |
| `TargetStepNumber` | INTEGER |  |  |  |
| `TargetSetsFormula` | TEXT |  |  |  |
| `TargetRepsFormula` | TEXT |  |  |  |
| `TargetWeight` |  |  |  |  |
| `StepNotes` | TEXT |  |  |  |

**Creation SQL**

```sql
CREATE VIEW UserExerciseProgressionTargets AS
SELECT
    uep.UserID,
    uep.TemplateID,
    uep.ExerciseID,
    uep.CurrentStepNumber,
    uep.CurrentCycle1RMEstimate,
    pm.ProgressionModelName,
    pms.StepNumber as TargetStepNumber,
    pms.TargetSetsFormula,
    pms.TargetRepsFormula,
    -- This CASE statement calculates the target weight based on the formula type
    CASE
        WHEN pms.TargetWeightFormula LIKE '%*%' THEN
            -- Handle formulas like 'CurrentCycle1RMEstimate * 0.75'
            CAST(REPLACE(pms.TargetWeightFormula, 'CurrentCycle1RMEstimate', uep.CurrentCycle1RMEstimate) AS REAL)
        ELSE
            -- Handle simple weight values or other formulas if needed
            CAST(pms.TargetWeightFormula AS REAL)
    END as "TargetWeight",
    pms.StepNotes
FROM
    UserExerciseProgression uep
JOIN
    ProgressionModels pm ON uep.ProgressionModelID = pm.ProgressionModelID
JOIN
    ProgressionModelSteps pms ON uep.ProgressionModelID = pms.ProgressionModelID
WHERE
    -- This crucial WHERE clause finds the *next* step for the user
    pms.StepNumber = uep.CurrentStepNumber
```

**Data Samples (First 3 Rows)**

| UserID | TemplateID | ExerciseID | CurrentStepNumber | CurrentCycle1RMEstimate | ProgressionModelName | TargetStepNumber | TargetSetsFormula | TargetRepsFormula | TargetWeight | StepNotes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| davidrusho | WT_UUID001 | UUID001 | 3 | 84.0 | 8-Step High Rep RPE Cycle | 3 | 3 | 12 | 84.0 | Week 3. 70-75% 1RM target |
| davidrusho | WT_UUID001 | UUID002 | 3 | 126.0 | 8-Step High Rep RPE Cycle | 3 | 3 | 12 | 126.0 | Week 3. 70-75% 1RM target |
| davidrusho | WT_UUID001 | UUID003 | 3 | 182.0 | 8-Step High Rep RPE Cycle | 3 | 3 | 12 | 182.0 | Week 3. 70-75% 1RM target |


---
### WorkoutTemplateDetails

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `TemplateID` | TEXT |  |  |  |
| `TemplateName` | TEXT |  |  |  |
| `TemplateDescription` | TEXT |  |  |  |
| `IsTemplateEnabled` | INTEGER |  |  |  |
| `TemplateExerciseListID` | TEXT |  |  |  |
| `OrderInWorkout` | INTEGER |  |  |  |
| `ExerciseID` | TEXT |  |  |  |
| `ExerciseName` | TEXT |  |  |  |
| `ProgressionModelID` | TEXT |  |  |  |
| `ProgressionModelName` | TEXT |  |  |  |

**Creation SQL**

```sql
CREATE VIEW WorkoutTemplateDetails AS
SELECT
    wt.TemplateID,
    wt.TemplateName,
    wt.Description as TemplateDescription,
    wt.IsEnabled as IsTemplateEnabled,
    tel.TemplateExerciseListID,
    tel.OrderInWorkout,
    el.ExerciseID,
    el.ExerciseName,
    pm.ProgressionModelID,
    pm.ProgressionModelName
FROM
    WorkoutTemplates wt
LEFT JOIN
    TemplateExerciseList tel ON wt.TemplateID = tel.TemplateID
LEFT JOIN
    ExerciseLibrary el ON tel.ExerciseID = el.ExerciseID
LEFT JOIN
    ProgressionModels pm ON tel.ProgressionModelID = pm.ProgressionModelID
WHERE
    tel.IsEnabled = 1
```

**Data Samples (First 3 Rows)**

| TemplateID | TemplateName | TemplateDescription | IsTemplateEnabled | TemplateExerciseListID | OrderInWorkout | ExerciseID | ExerciseName | ProgressionModelID | ProgressionModelName |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WT_UUID001 | Full Body A | 3-day routine focusing on compound movements. | 1 | ET_UUID001 | 1 | UUID001 | Dumbbell Incline Chest Press | PM_8StepRPE_002 | 8-Step High Rep RPE Cycle |
| WT_UUID001 | Full Body A | 3-day routine focusing on compound movements. | 1 | ET_UUID002 | 2 | UUID002 | Single Leg Press | PM_8StepRPE_002 | 8-Step High Rep RPE Cycle |
| WT_UUID001 | Full Body A | 3-day routine focusing on compound movements. | 1 | ET_UUID003 | 3 | UUID003 | Lat Pulldown | PM_8StepRPE_002 | 8-Step High Rep RPE Cycle |

