# 2025-06-15 - Database Schema Report

**Summary:** \
Schema and data samples for the database powering the SQLPage - Workout application.

>[!tip]
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.

---

### ExerciseLibrary

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `ExerciseID` | TEXT |
| `ExerciseName` | TEXT |
| `ExerciseAlias` | TEXT |
| `BodyLocation` | TEXT |
| `BodyGroup` | TEXT |
| `PrimaryMuscles` | TEXT |
| `SecondaryMuscle` | TEXT |
| `EquipmentType` | TEXT |
| `EquipmentNeeded` | TEXT |
| `Category` | TEXT |
| `DefaultLogType` | TEXT |
| `Instructions` | TEXT |
| `VideoURL` | TEXT |
| `ImageURL` | TEXT |
| `UnitOfMeasurement` | TEXT |
| `IsCustom` | INTEGER |
| `IsEnabled` | INTEGER |
| `LastModified` | TEXT |
| `NotesOrVariations` | TEXT |

**Data Samples (First 3 Rows)**

| ExerciseID | ExerciseName | ExerciseAlias | BodyLocation | BodyGroup | PrimaryMuscles | SecondaryMuscle | EquipmentType | EquipmentNeeded | Category | DefaultLogType | Instructions | VideoURL | ImageURL | UnitOfMeasurement | IsCustom | IsEnabled | LastModified | NotesOrVariations |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| UUID001 | Dumbbell Incline Chest Press | DB Incline | Upper | Chest | Pectorals Major | Deltoids (Anterior), Triceps | Dumbbell | Dumbbells, Adjustable Bench | Strength, Compound | WeightAndReps | NULL | NULL | NULL | lbs | 0 | 1 | 2025-05-10 | Adjust incline for different upper chest emphasis. |
| UUID002 | Single Leg Press | SL Leg Press | Lower | Legs | Quadriceps | Glutes, Hamstrings, Adductors | Machine - Stack | Leg Press Machine | Strength, Unilateral | WeightAndReps | NULL | NULL | NULL | lbs | 0 | 1 | 2025-05-10 | Focus on controlled movement for each leg. |
| UUID003 | Lat Pulldown | Lat Pulldowns | Upper | Back | Latissimus Dorsi | Biceps, Rhomboids, Middle Trapezius | Machine - Stack | Lat Pulldown Machine, Attachment (e.g., Wide Bar) | Strength, Compound | WeightAndReps | NULL | NULL | NULL | lbs | 0 | 1 | 2025-05-10 | Vary grip width and type for different back focus. |


---
### WorkoutLog

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `LogID` | TEXT |
| `UserID` | TEXT |
| `ExerciseTimestamp` | TEXT |
| `ExerciseID` | TEXT |
| `TotalSetsPerformed` | INTEGER |
| `RepsPerformed` | TEXT |
| `WeightUsed` | REAL |
| `Estimated1RM` | REAL |
| `WeightUnit` | TEXT |
| `RPE_Recorded` | REAL |
| `WorkoutNotes` | TEXT |
| `LinkedTemplateID` | TEXT |
| `LinkedProgressionModelID` | TEXT |
| `PerformedAtStepNumber` | INTEGER |
| `LastModified` | TEXT |

**Data Samples (First 3 Rows)**

| LogID | UserID | ExerciseTimestamp | ExerciseID | TotalSetsPerformed | RepsPerformed | WeightUsed | Estimated1RM | WeightUnit | RPE_Recorded | WorkoutNotes | LinkedTemplateID | LinkedProgressionModelID | PerformedAtStepNumber | LastModified |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WLOG_UUID001 | davidrusho | 2025-04-30 22:54:42 | UUID001 | 3 | 12 | 60.0 | 84.0 | lbs | 6.0 | NULL | NULL | NULL | NULL | 2025-05-10 17:45:29 |
| WLOG_UUID002 | davidrusho | 2025-04-30 23:12:50 | UUID002 | 3 | 12 | 108.0 | 151.2 | lbs | 6.0 | NULL | NULL | NULL | NULL | 2025-05-10 17:45:29 |
| WLOG_UUID003 | davidrusho | 2025-04-30 23:28:14 | UUID003 | 3 | 10 | 135.0 | 180.0 | lbs | 9.0 | NULL | NULL | NULL | NULL | 2025-05-10 17:45:29 |


---
### ProgressionModels

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `ProgressionModelID` | TEXT |
| `ProgressionModelName` | TEXT |
| `Description` | TEXT |
| `TriggerConditionLogic` | TEXT |
| `FailureConditionLogic` | TEXT |
| `CycleCompletionConditionLogic` | TEXT |
| `CycleCompletionNextAction` | TEXT |
| `NewCycleBaseWeightFormula` | TEXT |
| `DefaultTotalSteps` | INTEGER |
| `Notes` | TEXT |
| `LastModified` | TEXT |

**Data Samples (First 3 Rows)**

| ProgressionModelID | ProgressionModelName | Description | TriggerConditionLogic | FailureConditionLogic | CycleCompletionConditionLogic | CycleCompletionNextAction | NewCycleBaseWeightFormula | DefaultTotalSteps | Notes | LastModified |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| PM_UUID002 | Linear Periodization - Simple Weight Add | Each week, add a small amount of weight if all reps are completed. | AllRepsCompleted = TRUE | AllRepsCompleted = FALSE | Week 4 Completed | Reset to Week 1, Increase Base | currentCycleBaseWeight + 2.5 kg | 4 | Simpler linear model. | 2025-05-10 16:35:20 |
| PM_8StepRPE_001 | 8-Step Undulating 1RM% Cycle | An 8-step cycle progressing sets, reps, and 1RM%. RPE performance dictates advancement. Cycle culminates in an AMRAP test to update 1RM. | LoggedRPE <= 8 | LoggedRPE > 8 | CurrentStepNumber = 8 AND LoggedRPE <= 8 AND AMRAPReps > 0 | Reset to Step 1 | ( (CurrentCycle1RMEstimate * 0.90) * (1 + AMRAPRepsAtStep8 / 30) ) | 8 | Implements the user-provided 8-week table. New 1RM based on Epley from Step 8 AMRAP. | 2025-05-10 16:35:20 |
| PM_8StepRPE_002 | 8-Step High Rep RPE Cycle | An 8-step cycle focused on higher repetitions, progressing sets, reps, and 1RM%. RPE dictates advancement. AMRAP test on Step 8 at 80% 1RM. | LoggedRPE <= 8 | LoggedRPE > 8 | CurrentStepNumber = 8 AND LoggedRPE <= 8 AND AMRAPReps > 0 | Reset to Step 1 | ( (CurrentCycle1RMEstimate * 0.80) * (1 + AMRAPRepsAtStep8 / 30) ) | 8 | Implements the user-provided 8-week table. New 1RM based on Epley from Step 8 AMRAP. | 2025-05-10 16:35:20 |


---
### ProgressionModelSteps

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `ProgressionModelStepID` | TEXT |
| `ProgressionModelID` | TEXT |
| `StepNumber` | INTEGER |
| `TargetSetsFormula` | TEXT |
| `TargetRepsFormula` | TEXT |
| `TargetWeightFormula` | TEXT |
| `StepNotes` | TEXT |
| `LastModified` | TEXT |
| `SuccessCriteriaRPE` | REAL |
| `FailureCriteriaType` | TEXT |
| `FailureCriteriaValue` | TEXT |
| `TargetWeightPercentage` | REAL |
| `RepsType` | TEXT |
| `RepsValue` | REAL |

**Data Samples (First 3 Rows)**

| ProgressionModelStepID | ProgressionModelID | StepNumber | TargetSetsFormula | TargetRepsFormula | TargetWeightFormula | StepNotes | LastModified | SuccessCriteriaRPE | FailureCriteriaType | FailureCriteriaValue | TargetWeightPercentage | RepsType | RepsValue |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| PMS_8S_High_Rep_001 | PM_8StepRPE_002 | 1 | 3 | 10 | CurrentCycle1RMEstimate * 0.75 | Week 1: 70-75% 1RM target (using 75% as base) | 2025-05-10 16:38:15 | NULL | NULL | NULL | 0.75 | FIXED | 10.0 |
| PMS_8S_High_Rep_002 | PM_8StepRPE_002 | 2 | 4 | 10 | CurrentCycle1RMEstimate * 0.75 | Week 2: 70-75% 1RM target | 2025-05-10 16:38:15 | NULL | NULL | NULL | 0.75 | FIXED | 10.0 |
| PMS_8S_High_Rep_003 | PM_8StepRPE_002 | 3 | 3 | 12 | CurrentCycle1RMEstimate * 0.75 | Week 3. 70-75% 1RM target | 2025-05-10 16:38:15 | NULL | NULL | NULL | 0.75 | FIXED | 12.0 |


---
### WorkoutTemplates

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `TemplateID` | TEXT |
| `TemplateName` | TEXT |
| `ProgressionModelID` | TEXT |
| `Description` | TEXT |
| `Focus` | TEXT |
| `Frequency` | TEXT |
| `CreatedByUserID` | TEXT |
| `LastModified` | TEXT |

**Data Samples (First 3 Rows)**

| TemplateID | TemplateName | ProgressionModelID | Description | Focus | Frequency | CreatedByUserID | LastModified |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| WT_UUID001 | Full Body A | PM_8StepRPE_002 | 3-day routine focusing on compound movements. | Strength | 3 times a week | davidrusho | 2025-05-10 |
| WT_UUID002 | Full Body B | PM_8StepRPE_002 | 3-day routine focusing on compound movements. | Strength | 3 times a week | davidrusho | 2025-05-10 |
| WT_UUID003 | Full Body C | PM_8StepRPE_002 | 3-day routine focusing on compound movements. | Strength | 3 times a week | davidrusho | 2025-05-10 |


---
### TemplateExerciseList

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `TemplateExerciseListID` | TEXT |
| `TemplateID` | TEXT |
| `ExerciseID` | TEXT |
| `ExerciseAlias` | TEXT |
| `ProgressionModelID` | TEXT |
| `OrderInWorkout` | INTEGER |
| `LastModified` | TEXT |

**Data Samples (First 3 Rows)**

| TemplateExerciseListID | TemplateID | ExerciseID | ExerciseAlias | ProgressionModelID | OrderInWorkout | LastModified |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| ET_UUID001 | WT_UUID001 | UUID001 | DB Incline | PM_8StepRPE_002 | 1 | NULL |
| ET_UUID002 | WT_UUID001 | UUID002 | SL Leg Press | PM_8StepRPE_002 | 2 | NULL |
| ET_UUID003 | WT_UUID001 | UUID003 | Lat Pulldowns | PM_8StepRPE_002 | 3 | NULL |


---
### UserExerciseProgression

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `UserExerciseProgressionID` | TEXT |
| `UserID` | TEXT |
| `TemplateID` | TEXT |
| `ExerciseID` | TEXT |
| `ProgressionModelID` | TEXT |
| `CurrentStepNumber` | INTEGER |
| `CurrentCycle1RMEstimate` | REAL |
| `LastWorkoutRPE` | REAL |
| `AMRAPRepsAtStep8` | REAL |
| `DateOfLastAttempt` | TEXT |
| `CycleStartDate` | TEXT |
| `MaxReps` | INTEGER |

**Data Samples (First 3 Rows)**

| UserExerciseProgressionID | UserID | TemplateID | ExerciseID | ProgressionModelID | CurrentStepNumber | CurrentCycle1RMEstimate | LastWorkoutRPE | AMRAPRepsAtStep8 | DateOfLastAttempt | CycleStartDate | MaxReps |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| UEP_1df55c38-38d5-4f5a-b28b-a42b0daa7f41 | davidrusho | WT_UUID001 | UUID001 | PM_8StepRPE_002 | 3 | 84.0 | 8.0 | NULL | 2025-05-28 22:54:12 | 2025-05-28 22:54:12 | NULL |
| 8919bd4d2ee66690b8bc9ae35195afa9 | davidrusho | WT_UUID001 | UUID002 | PM_8StepRPE_002 | 3 | 126.0 | 8.0 | NULL | 2025-05-28 23:08:10 | 2025-05-28 23:08:10 | NULL |
| 9741549c9c95e296f2837275f2dc3ce5 | davidrusho | WT_UUID001 | UUID003 | PM_8StepRPE_002 | 3 | 182.0 | 8.0 | NULL | 2025-05-28 23:20:49 | 2025-05-28 23:20:49 | NULL |


---
### users

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `username` | TEXT |
| `password_hash` | TEXT |
| `display_name` | TEXT |
| `profile_picture_url` | TEXT |
| `bio` | TEXT |
| `created_at` | DATETIME |

**Data Samples (First 3 Rows)**

| username | password_hash | display_name | profile_picture_url | bio | created_at |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Salaried8674 | $argon2id$v=19$m=19456,t=2,p=1$qIhw6C/lUDsx+QvHhw1mPQ$7xdYsVGfwmNYbB1FqBoiL69LcP5ZoaNWxSwc6Dnp2bA | David | NULL | NULL | 2025-06-14 02:22:12 |
| test_user_1 | $argon2id$v=19$m=19456,t=2,p=1$8Hgg07NKTWutAMKh50laWQ$ByWauqecbd7qDoZqKUopg1sNkrxoHfS9KB11sSvjF7o | test_user_1 | NULL | NULL | 2025-06-14 02:45:47 |
| davidrusho | $argon2id$v=19$m=19456,t=2,p=1$x7pdgcw6RPgR9/tlPUA4oA$dzGPIyUQ2iEyLrZHEEpzQwne97dJ9NKlWRzIseOwQeo | David | NULL | NULL | 2025-06-15 01:47:41 |


---
### sessions

**Schema**

| Column Name | Data Type |
| :---------- | :-------- |
| `session_token` | TEXT |
| `username` | TEXT |
| `expires_at` | DATETIME |

**Data Samples (First 3 Rows)**

| session_token | username | expires_at |
| :--- | :--- | :--- |
| nuvEHVKY0ErE0RRsSLmw7kpIallW4uJe | Salaried8674 | 2025-06-15 02:22:21 |
| lyb27vQ4pAxrmdkBqhthZtZPZaz6wFu1 | Salaried8674 | 2025-06-15 02:25:29 |
| HvsMdmbHxJHrGJl7DyNs8bvXKGpRswks | Salaried8674 | 2025-06-15 02:26:11 |

