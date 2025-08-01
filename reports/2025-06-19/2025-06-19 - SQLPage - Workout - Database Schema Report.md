# 2025-06-19 - Database Schema Report\n\n**summary:**\n"Schema and data samples for the database powering the SQLPage - Workout application."\n\n>[!tip]+ Tip
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.
\n\n---\n
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
| `idx_exerciselib_equipment` | `EquipmentType` |  |
| `idx_exerciselib_category` | `Category` |  |
| `idx_exerciselib_bodygroup` | `BodyGroup` |  |
| `sqlite_autoindex_ExerciseLibrary_2` | `ExerciseID` | ✅ |
| `sqlite_autoindex_ExerciseLibrary_1` | `ExerciseName` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "ExerciseLibrary" (
	"ExerciseID"	TEXT,
	"ExerciseName"	TEXT NOT NULL UNIQUE,
	"ExerciseAlias"	TEXT,
	"BodyLocation"	TEXT,
	"BodyGroup"	TEXT,
	"PrimaryMuscles"	TEXT,
	"SecondaryMuscle"	TEXT,
	"EquipmentType"	TEXT,
	"EquipmentNeeded"	TEXT,
	"Category"	TEXT,
	"DefaultLogType"	TEXT,
	"Instructions"	TEXT,
	"VideoURL"	TEXT,
	"ImageURL"	TEXT,
	"UnitOfMeasurement"	TEXT,
	"IsCustom"	INTEGER,
	"IsEnabled"	INTEGER NOT NULL DEFAULT 1,
	"LastModified"	INTEGER DEFAULT (strftime('%s', 'now')),
	"NotesOrVariations"	TEXT,
	PRIMARY KEY("ExerciseID")
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
| `sqlite_autoindex_ProgressionModelSteps_2` | `ProgressionModelStepID` | ✅ |
| `sqlite_autoindex_ProgressionModelSteps_1` | `ProgressionModelID`, `StepNumber` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "ProgressionModelSteps" (
	"ProgressionModelStepID"	TEXT,
	"ProgressionModelID"	TEXT NOT NULL,
	"StepNumber"	INTEGER NOT NULL,
	"TargetSetsFormula"	TEXT,
	"TargetRepsFormula"	TEXT,
	"TargetWeightFormula"	TEXT,
	"StepNotes"	TEXT,
	"LastModified"	INTEGER DEFAULT (strftime('%s', 'now')),
	"SuccessCriteriaRPE"	REAL,
	"FailureCriteriaType"	TEXT,
	"FailureCriteriaValue"	TEXT,
	"TargetWeightPercentage"	REAL,
	"RepsType"	TEXT,
	"RepsValue"	REAL,
	UNIQUE("ProgressionModelID","StepNumber"),
	PRIMARY KEY("ProgressionModelStepID"),
	FOREIGN KEY("ProgressionModelID") REFERENCES "ProgressionModels"("ProgressionModelID") ON DELETE CASCADE
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
| `sqlite_autoindex_ProgressionModels_2` | `ProgressionModelID` | ✅ |
| `sqlite_autoindex_ProgressionModels_1` | `ProgressionModelName` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "ProgressionModels" (
	"ProgressionModelID"	TEXT,
	"ProgressionModelName"	TEXT NOT NULL UNIQUE,
	"Description"	TEXT,
	"TriggerConditionLogic"	TEXT,
	"FailureConditionLogic"	TEXT,
	"CycleCompletionConditionLogic"	TEXT,
	"CycleCompletionNextAction"	TEXT,
	"NewCycleBaseWeightFormula"	TEXT,
	"DefaultTotalSteps"	INTEGER,
	"Notes"	TEXT,
	"LastModified"	INTEGER DEFAULT (strftime('%s', 'now')),
	PRIMARY KEY("ProgressionModelID")
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
| `LastModifiedTimestamp` | INTEGER |  | `strftime('%s', 'now')` |  |
| `IsEnabled` | INTEGER |  | `1` |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `TemplateID` | `WorkoutTemplates` | `TemplateID` |
| `ProgressionModelID` | `ProgressionModels` | `ProgressionModelID` |
| `ExerciseID` | `ExerciseLibrary` | `ExerciseID` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_TemplateExerciseList_1` | `TemplateExerciseListID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "TemplateExerciseList" (
	"TemplateExerciseListID"	TEXT,
	"TemplateID"	TEXT NOT NULL,
	"ExerciseID"	TEXT NOT NULL,
	"ExerciseAlias"	TEXT,
	"ProgressionModelID"	TEXT,
	"OrderInWorkout"	INTEGER,
	"LastModifiedTimestamp"	INTEGER DEFAULT (strftime('%s', 'now')),
	"IsEnabled"	INTEGER DEFAULT 1,
	PRIMARY KEY("TemplateExerciseListID"),
	FOREIGN KEY("ExerciseID") REFERENCES "ExerciseLibrary"("ExerciseID"),
	FOREIGN KEY("ProgressionModelID") REFERENCES "ProgressionModels"("ProgressionModelID"),
	FOREIGN KEY("TemplateID") REFERENCES "WorkoutTemplates"("TemplateID")
)
```

**Data Samples (First 3 Rows)**

| TemplateExerciseListID | TemplateID | ExerciseID | ExerciseAlias | ProgressionModelID | OrderInWorkout | LastModifiedTimestamp | IsEnabled |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| ET_UUID001 | WT_UUID001 | UUID001 | DB Incline | PM_8StepRPE_002 | 1 | 1750289568 | 1 |
| ET_UUID002 | WT_UUID001 | UUID002 | SL Leg Press | PM_8StepRPE_002 | 2 | 1750289568 | 1 |
| ET_UUID003 | WT_UUID001 | UUID003 | Lat Pulldowns | PM_8StepRPE_002 | 3 | 1750289568 | 1 |


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
| `UserID` | `users` | `username` |
| `TemplateID` | `WorkoutTemplates` | `TemplateID` |
| `ProgressionModelID` | `ProgressionModels` | `ProgressionModelID` |
| `ExerciseID` | `ExerciseLibrary` | `ExerciseID` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_UserExerciseProgression_2` | `UserID`, `TemplateID`, `ExerciseID` | ✅ |
| `sqlite_autoindex_UserExerciseProgression_1` | `UserExerciseProgressionID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "UserExerciseProgression" (
	"UserExerciseProgressionID"	TEXT,
	"UserID"	TEXT NOT NULL,
	"TemplateID"	TEXT NOT NULL,
	"ExerciseID"	TEXT NOT NULL,
	"ProgressionModelID"	TEXT,
	"CurrentStepNumber"	INTEGER,
	"CurrentCycle1RMEstimate"	REAL,
	"LastWorkoutRPE"	REAL,
	"AMRAPRepsAtStep8"	REAL,
	"DateOfLastAttempt"	INTEGER,
	"CycleStartDate"	INTEGER,
	"MaxReps"	INTEGER,
	PRIMARY KEY("UserExerciseProgressionID"),
	UNIQUE("UserID","TemplateID","ExerciseID"),
	FOREIGN KEY("ExerciseID") REFERENCES "ExerciseLibrary"("ExerciseID"),
	FOREIGN KEY("ProgressionModelID") REFERENCES "ProgressionModels"("ProgressionModelID"),
	FOREIGN KEY("TemplateID") REFERENCES "WorkoutTemplates"("TemplateID"),
	FOREIGN KEY("UserID") REFERENCES "users"("username")
)
```

**Data Samples (First 3 Rows)**

| UserExerciseProgressionID | UserID | TemplateID | ExerciseID | ProgressionModelID | CurrentStepNumber | CurrentCycle1RMEstimate | LastWorkoutRPE | AMRAPRepsAtStep8 | DateOfLastAttempt | CycleStartDate | MaxReps |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| UEP_1df55c38-38d5-4f5a-b28b-a42b0daa7f41 | davidrusho | WT_UUID001 | UUID001 | PM_8StepRPE_002 | 4 | NULL | 8.0 | NULL | 1750301269 | NULL | NULL |
| 8919bd4d2ee66690b8bc9ae35195afa9 | davidrusho | WT_UUID001 | UUID002 | PM_8StepRPE_002 | 3 | 126.0 | 8.0 | NULL | NULL | NULL | NULL |
| 9741549c9c95e296f2837275f2dc3ce5 | davidrusho | WT_UUID001 | UUID003 | PM_8StepRPE_002 | 4 | NULL | 8.0 | NULL | 1750302316 | NULL | NULL |


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
| `LastModifiedTimestamp` | INTEGER |  | `strftime('%s', 'now')` |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `UserID` | `users` | `username` |
| `ExerciseID` | `ExerciseLibrary` | `ExerciseID` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_WorkoutLog_1` | `LogID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "WorkoutLog" (
	"LogID"	TEXT,
	"UserID"	TEXT NOT NULL,
	"ExerciseTimestamp"	INTEGER NOT NULL,
	"ExerciseID"	TEXT NOT NULL,
	"Estimated1RM"	REAL,
	"WorkoutNotes"	TEXT,
	"LinkedTemplateID"	TEXT,
	"LinkedProgressionModelID"	TEXT,
	"PerformedAtStepNumber"	INTEGER,
	"LastModifiedTimestamp"	INTEGER DEFAULT (strftime('%s', 'now')),
	PRIMARY KEY("LogID"),
	FOREIGN KEY("ExerciseID") REFERENCES "ExerciseLibrary"("ExerciseID"),
	FOREIGN KEY("UserID") REFERENCES "users"("username")
)
```

**Data Samples (First 3 Rows)**

| LogID | UserID | ExerciseTimestamp | ExerciseID | Estimated1RM | WorkoutNotes | LinkedTemplateID | LinkedProgressionModelID | PerformedAtStepNumber | LastModifiedTimestamp |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WLOG_UUID001 | davidrusho | 1746053682 | UUID001 | 84.0 | NULL | NULL | NULL | NULL | 1746899129 |
| WLOG_UUID002 | davidrusho | 1746054770 | UUID002 | 151.2 | NULL | NULL | NULL | NULL | 1746899129 |
| WLOG_UUID003 | davidrusho | 1746055694 | UUID003 | 180.0 | NULL | NULL | NULL | NULL | 1746899129 |


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
| `LogID` | `WorkoutLog` | `LogID` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_WorkoutSetLog_1` | `SetID` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "WorkoutSetLog" (
	"SetID"	TEXT,
	"LogID"	TEXT NOT NULL,
	"SetNumber"	INTEGER NOT NULL,
	"RepsPerformed"	INTEGER,
	"WeightUsed"	REAL,
	"WeightUnit"	TEXT,
	"RPE_Recorded"	REAL,
	PRIMARY KEY("SetID"),
	FOREIGN KEY("LogID") REFERENCES "WorkoutLog"("LogID") ON DELETE CASCADE
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
| `LastModifiedTimestamp` | INTEGER |  | `strftime('%s', 'now')` |  |
| `IsEnabled` | INTEGER | ✅ | `1` |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `CreatedByUserID` | `users` | `username` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_WorkoutTemplates_2` | `TemplateID` | ✅ |
| `sqlite_autoindex_WorkoutTemplates_1` | `TemplateName` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "WorkoutTemplates" (
	"TemplateID"	TEXT,
	"TemplateName"	TEXT NOT NULL UNIQUE,
	"ProgressionModelID"	TEXT,
	"Description"	TEXT,
	"Focus"	TEXT,
	"Frequency"	TEXT,
	"CreatedByUserID"	TEXT NOT NULL,
	"LastModifiedTimestamp"	INTEGER DEFAULT (strftime('%s', 'now')),
	"IsEnabled"	INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY("TemplateID"),
	FOREIGN KEY("CreatedByUserID") REFERENCES "users"("username")
)
```

**Data Samples (First 3 Rows)**

| TemplateID | TemplateName | ProgressionModelID | Description | Focus | Frequency | CreatedByUserID | LastModifiedTimestamp | IsEnabled |
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
CREATE TABLE "sessions" (
	"session_token"	TEXT,
	"username"	TEXT NOT NULL,
	"expires_at"	DATETIME NOT NULL,
	PRIMARY KEY("session_token"),
	FOREIGN KEY("username") REFERENCES "users"("username") ON DELETE CASCADE
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
CREATE TABLE "users" (
	"username"	TEXT,
	"password_hash"	TEXT NOT NULL,
	"display_name"	TEXT,
	"profile_picture_url"	TEXT,
	"bio"	TEXT,
	"created_at"	DATETIME DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("username")
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
| `UserID` | TEXT |  |  |  |
| `WorkoutDate` |  |  |  |  |
| `ExerciseName` | TEXT |  |  |  |
| `SetNumber` | INTEGER |  |  |  |
| `RepsPerformed` | INTEGER |  |  |  |
| `WeightUsed` | REAL |  |  |  |
| `WeightUnit` | TEXT |  |  |  |
| `RPE_Recorded` | REAL |  |  |  |
| `WorkoutNotes` | TEXT |  |  |  |
| `LastModifiedTimestamp` | INTEGER |  |  |  |

**Creation SQL**

```sql
CREATE VIEW FullWorkoutHistory AS
SELECT
    wl.LogID,
    wl.UserID,
    datetime(wl.ExerciseTimestamp, 'unixepoch') as WorkoutDate,
    el.ExerciseName,
    wsl.SetNumber,
    wsl.RepsPerformed,
    wsl.WeightUsed,
    wsl.WeightUnit,
    wsl.RPE_Recorded,
    wl.WorkoutNotes,
    wl.LastModifiedTimestamp
FROM
    WorkoutLog wl
JOIN
    WorkoutSetLog wsl ON wl.LogID = wsl.LogID
JOIN
    ExerciseLibrary el ON wl.ExerciseID = el.ExerciseID
ORDER BY
    wl.ExerciseTimestamp DESC, wsl.SetNumber ASC
```

**Data Samples (First 3 Rows)**

| LogID | UserID | WorkoutDate | ExerciseName | SetNumber | RepsPerformed | WeightUsed | WeightUnit | RPE_Recorded | WorkoutNotes | LastModifiedTimestamp |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WLOG_7bdfd235-4560-4cac-bc1f-f3da37cdcef9 | davidrusho | 2025-05-30 22:26:17 | Deficit Push-up | 1 | 0 | 0.0 | Reps | 8.0 | 18, 10, 10 | 1748643977 |
| WLOG_7bdfd235-4560-4cac-bc1f-f3da37cdcef9 | davidrusho | 2025-05-30 22:26:17 | Deficit Push-up | 2 | 0 | 0.0 | Reps | 8.0 | 18, 10, 10 | 1748643977 |
| WLOG_7bdfd235-4560-4cac-bc1f-f3da37cdcef9 | davidrusho | 2025-05-30 22:26:17 | Deficit Push-up | 3 | 0 | 0.0 | Reps | 8.0 | 18, 10, 10 | 1748643977 |


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
    -- This CASE statement performs the calculation for the target weight
    CASE
        WHEN pms.TargetWeightFormula LIKE '%*%' THEN
            -- Manually parse the multiplier from the formula string and multiply
            uep.CurrentCycle1RMEstimate * CAST(trim(substr(pms.TargetWeightFormula, instr(pms.TargetWeightFormula, '*') + 1)) AS REAL)
        ELSE
            -- Handle simple weight values that don't have a formula
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
| davidrusho | WT_UUID001 | UUID001 | 4 | NULL | 8-Step High Rep RPE Cycle | 4 | 4 | 10 | NULL | Week 4: 75-80% 1RM target (using 80% as base) |
| davidrusho | WT_UUID001 | UUID002 | 3 | 126.0 | 8-Step High Rep RPE Cycle | 3 | 3 | 12 | 94.5 | Week 3. 70-75% 1RM target |
| davidrusho | WT_UUID001 | UUID003 | 4 | NULL | 8-Step High Rep RPE Cycle | 4 | 4 | 10 | NULL | Week 4: 75-80% 1RM target (using 80% as base) |


---
### WorkoutTemplateDetails

**Columns**

| Name | Type | Not Null | Default | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| `TemplateID` | TEXT |  |  |  |
| `TemplateName` | TEXT |  |  |  |
| `TemplateExerciseListID` | TEXT |  |  |  |
| `OrderInWorkout` | INTEGER |  |  |  |
| `ExerciseID` | TEXT |  |  |  |
| `ExerciseName` | TEXT |  |  |  |
| `ExerciseAlias` |  |  |  |  |
| `ProgressionModelID` | TEXT |  |  |  |
| `ProgressionModelName` | TEXT |  |  |  |
| `IsEnabled` | INTEGER |  |  |  |

**Creation SQL**

```sql
CREATE VIEW WorkoutTemplateDetails AS
SELECT
    wt.TemplateID,
    wt.TemplateName,
    tel.TemplateExerciseListID,
    tel.OrderInWorkout,
    tel.ExerciseID,
    el.ExerciseName,
    COALESCE(tel.ExerciseAlias, el.ExerciseAlias) AS ExerciseAlias,
    tel.ProgressionModelID,
    pm.ProgressionModelName,
    tel.IsEnabled
FROM
    WorkoutTemplates wt
JOIN
    TemplateExerciseList tel ON wt.TemplateID = tel.TemplateID
JOIN
    ExerciseLibrary el ON tel.ExerciseID = el.ExerciseID
LEFT JOIN
    ProgressionModels pm ON tel.ProgressionModelID = pm.ProgressionModelID
ORDER BY 
    wt.TemplateName, tel.OrderInWorkout
```

**Data Samples (First 3 Rows)**

| TemplateID | TemplateName | TemplateExerciseListID | OrderInWorkout | ExerciseID | ExerciseName | ExerciseAlias | ProgressionModelID | ProgressionModelName | IsEnabled |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WT_UUID001 | Full Body A | ET_UUID001 | 1 | UUID001 | Dumbbell Incline Chest Press | DB Incline | PM_8StepRPE_002 | 8-Step High Rep RPE Cycle | 1 |
| WT_UUID001 | Full Body A | ET_UUID002 | 2 | UUID002 | Single Leg Press | SL Leg Press | PM_8StepRPE_002 | 8-Step High Rep RPE Cycle | 1 |
| WT_UUID001 | Full Body A | ET_UUID003 | 3 | UUID003 | Lat Pulldown | Lat Pulldowns | PM_8StepRPE_002 | 8-Step High Rep RPE Cycle | 1 |

