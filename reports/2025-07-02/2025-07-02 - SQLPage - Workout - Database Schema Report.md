# 2025-07-02 - Database Schema Report\n\n**summary:**\n"Schema and data samples for the database powering the SQLPage - Workout application."\n\n>[!tip]+ Tip
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.
\n\n---\n
## Table of Contents

**Tables**
- [DimDate](#dimdate)
- [DimExercise](#dimexercise)
- [DimExercisePlan](#dimexerciseplan)
- [DimUser](#dimuser)
- [DimUserExercisePreferences](#dimuserexercisepreferences)
- [FactWorkoutHistory](#factworkouthistory)
- [_migrations](#-migrations)
- [sessions](#sessions)

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
### DimDate

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `DateKey` | INTEGER |  |  | ✅ |  |
| `FullDate` | TEXT | ✅ |  |  |  |
| `DayOfWeekName` | TEXT | ✅ |  |  |  |
| `MonthName` | TEXT | ✅ |  |  |  |
| `Year` | INTEGER | ✅ |  |  |  |

**Creation SQL**

```sql
CREATE TABLE DimDate (
    DateKey INTEGER PRIMARY KEY, -- YYYYMMDD format
    FullDate TEXT NOT NULL, -- YYYY-MM-DD format
    DayOfWeekName TEXT NOT NULL,
    MonthName TEXT NOT NULL,
    Year INTEGER NOT NULL
)
```

**Data Samples (First 3 Rows)**

| DateKey | FullDate | DayOfWeekName | MonthName | Year |
| :--- | :--- | :--- | :--- | :--- |
| 20200101 | 2020-01-01 | Wednesday | January | 2020 |
| 20200102 | 2020-01-02 | Thursday | January | 2020 |
| 20200103 | 2020-01-03 | Friday | January | 2020 |


---
### DimExercise

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ExerciseKey` | TEXT |  |  | ✅ |  |
| `ExerciseName` | TEXT | ✅ |  |  |  |
| `BodyGroup` | TEXT |  |  |  |  |
| `EquipmentNeeded` | TEXT |  |  |  |  |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_DimExercise_2` | `ExerciseName` | ✅ |
| `sqlite_autoindex_DimExercise_1` | `ExerciseKey` | ✅ |

**Creation SQL**

```sql
CREATE TABLE DimExercise (
    ExerciseKey TEXT PRIMARY KEY,
    ExerciseName TEXT NOT NULL UNIQUE, -- The default, global name
    BodyGroup TEXT,
    EquipmentNeeded TEXT
)
```

**Data Samples (First 3 Rows)**

| ExerciseKey | ExerciseName | BodyGroup | EquipmentNeeded |
| :--- | :--- | :--- | :--- |
| UUID001 | Dumbbell Incline Chest Press | Chest | Dumbbells, Adjustable Bench |
| UUID002 | Single Leg Press | Legs | Leg Press Machine |
| UUID003 | Lat Pulldown | Back | Lat Pulldown Machine, Attachment (e.g., Wide Bar) |


---
### DimExercisePlan

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ExercisePlanKey` | TEXT |  |  | ✅ |  |
| `UserKey` | TEXT | ✅ |  |  |  |
| `ExerciseKey` | TEXT | ✅ |  |  |  |
| `TemplateName` | TEXT |  |  |  |  |
| `UserTemplateAlias` | TEXT |  |  |  |  |
| `IsActive` | INTEGER | ✅ | `1` |  |  |
| `CurrentStepNumber` | INTEGER |  |  |  |  |
| `Current1RMEstimate` | REAL |  |  |  |  |
| `TargetSets` | INTEGER |  |  |  |  |
| `TargetReps` | INTEGER |  |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `ExerciseKey` | `DimExercise` | `ExerciseKey` |
| `UserKey` | `DimUser` | `UserKey` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idx_dim_exercise_plan_user_active` | `UserKey`, `IsActive` |  |
| `sqlite_autoindex_DimExercisePlan_1` | `ExercisePlanKey` | ✅ |

**Creation SQL**

```sql
CREATE TABLE DimExercisePlan (
    ExercisePlanKey TEXT PRIMARY KEY,
    UserKey TEXT NOT NULL,
    ExerciseKey TEXT NOT NULL,
    TemplateName TEXT, -- The default, global template name
    UserTemplateAlias TEXT, -- The user's custom name for this template
    IsActive INTEGER NOT NULL DEFAULT 1, -- 1 for active, 0 for archived/restarted
    CurrentStepNumber INTEGER,
    Current1RMEstimate REAL,
    TargetSets INTEGER,
    TargetReps INTEGER,
    FOREIGN KEY (UserKey) REFERENCES DimUser (UserKey),
    FOREIGN KEY (ExerciseKey) REFERENCES DimExercise (ExerciseKey)
)
```

**Data Samples (First 3 Rows)**

| ExercisePlanKey | UserKey | ExerciseKey | TemplateName | UserTemplateAlias | IsActive | CurrentStepNumber | Current1RMEstimate | TargetSets | TargetReps |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| FFE77EC2A97A7EDAC82D56B959DD3335 | davidrusho | UUID001 | Full Body A | NULL | 1 | 1 | NULL | NULL | NULL |
| 07B56155D426BE11AD6E0AB4D942E1C9 | davidrusho | UUID002 | Full Body A | NULL | 1 | 1 | NULL | NULL | NULL |
| 5EF176BDF80A8C01D91600EDA87FE123 | davidrusho | UUID003 | Full Body A | NULL | 1 | 1 | NULL | NULL | NULL |


---
### DimUser

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `UserKey` | TEXT |  |  | ✅ |  |
| `DisplayName` | TEXT | ✅ |  |  |  |
| `Timezone` | TEXT |  | `'America/Denver'` |  |  |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_DimUser_1` | `UserKey` | ✅ |

**Creation SQL**

```sql
CREATE TABLE DimUser (
    UserKey TEXT PRIMARY KEY,
    DisplayName TEXT NOT NULL,
    Timezone TEXT DEFAULT 'America/Denver'
)
```

**Data Samples (First 3 Rows)**

| UserKey | DisplayName | Timezone |
| :--- | :--- | :--- |
| Salaried8674 | David | America/Denver |
| test_user_1 | test_user_1 | America/Denver |
| davidrusho | David | America/Denver |


---
### DimUserExercisePreferences

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `UserKey` | TEXT | ✅ |  | ✅ |  |
| `ExerciseKey` | TEXT | ✅ |  |  |  |
| `UserExerciseAlias` | TEXT | ✅ |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `ExerciseKey` | `DimExercise` | `ExerciseKey` |
| `UserKey` | `DimUser` | `UserKey` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_DimUserExercisePreferences_1` | `UserKey`, `ExerciseKey` | ✅ |

**Creation SQL**

```sql
CREATE TABLE DimUserExercisePreferences (
    UserKey TEXT NOT NULL,
    ExerciseKey TEXT NOT NULL,
    UserExerciseAlias TEXT NOT NULL,
    PRIMARY KEY (UserKey, ExerciseKey),
    FOREIGN KEY (UserKey) REFERENCES DimUser (UserKey),
    FOREIGN KEY (ExerciseKey) REFERENCES DimExercise (ExerciseKey)
)
```

**Data Samples (First 3 Rows)**

_Object is empty._


---
### FactWorkoutHistory

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `WorkoutHistoryKey` | TEXT |  |  | ✅ |  |
| `UserKey` | TEXT | ✅ |  |  |  |
| `ExerciseKey` | TEXT | ✅ |  |  |  |
| `DateKey` | INTEGER | ✅ |  |  |  |
| `ExercisePlanKey` | TEXT | ✅ |  |  |  |
| `SetNumber` | INTEGER | ✅ |  |  |  |
| `RepsPerformed` | INTEGER | ✅ |  |  |  |
| `WeightUsed` | REAL | ✅ |  |  |  |
| `RPE_Recorded` | REAL |  |  |  |  |
| `CreatedTimestamp` | INTEGER | ✅ |  |  |  |
| `LastModifiedTimestamp` | INTEGER | ✅ |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `ExercisePlanKey` | `DimExercisePlan` | `ExercisePlanKey` |
| `DateKey` | `DimDate` | `DateKey` |
| `ExerciseKey` | `DimExercise` | `ExerciseKey` |
| `UserKey` | `DimUser` | `UserKey` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idx_fact_workout_history_plan_key` | `ExercisePlanKey` |  |
| `idx_fact_workout_history_date_key` | `DateKey` |  |
| `idx_fact_workout_history_exercise_key` | `ExerciseKey` |  |
| `idx_fact_workout_history_user_key` | `UserKey` |  |
| `sqlite_autoindex_FactWorkoutHistory_1` | `WorkoutHistoryKey` | ✅ |

**Creation SQL**

```sql
CREATE TABLE FactWorkoutHistory (
    WorkoutHistoryKey TEXT PRIMARY KEY,
    UserKey TEXT NOT NULL,
    ExerciseKey TEXT NOT NULL,
    DateKey INTEGER NOT NULL,
    ExercisePlanKey TEXT NOT NULL,
    SetNumber INTEGER NOT NULL,
    RepsPerformed INTEGER NOT NULL,
    WeightUsed REAL NOT NULL,
    RPE_Recorded REAL,
    CreatedTimestamp INTEGER NOT NULL, -- Unix timestamp of when the set was first logged
    LastModifiedTimestamp INTEGER NOT NULL, -- Unix timestamp, updated anytime the record is edited
    FOREIGN KEY (UserKey) REFERENCES DimUser (UserKey),
    FOREIGN KEY (ExerciseKey) REFERENCES DimExercise (ExerciseKey),
    FOREIGN KEY (DateKey) REFERENCES DimDate (DateKey),
    FOREIGN KEY (ExercisePlanKey) REFERENCES DimExercisePlan (ExercisePlanKey)
)
```

**Data Samples (First 3 Rows)**

| WorkoutHistoryKey | UserKey | ExerciseKey | DateKey | ExercisePlanKey | SetNumber | RepsPerformed | WeightUsed | RPE_Recorded | CreatedTimestamp | LastModifiedTimestamp |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 9aa54afe80e4786f58f71727f73fa7c0 | davidrusho | UUID004 | 20250528 | 5E42768102434D44FF4A0764879B77F4 | 1 | 12 | 40.0 | 8.0 | 1748475461 | 1748475461 |
| 96029ed67c9413ebae0d6389c94cd6b4 | davidrusho | UUID004 | 20250528 | 5E42768102434D44FF4A0764879B77F4 | 2 | 12 | 40.0 | 8.0 | 1748475461 | 1748475461 |
| a9ee5163304a3cee181bff8a78f674cc | davidrusho | UUID004 | 20250528 | 5E42768102434D44FF4A0764879B77F4 | 3 | 12 | 40.0 | 8.0 | 1748475461 | 1748475461 |


---
### _migrations

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `filename` | TEXT |  |  | ✅ |  |
| `applied_at` | TIMESTAMP |  | `CURRENT_TIMESTAMP` |  |  |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex__migrations_1` | `filename` | ✅ |

**Creation SQL**

```sql
CREATE TABLE _migrations (
            filename TEXT PRIMARY KEY,
            applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
```

**Data Samples (First 3 Rows)**

| filename | applied_at |
| :--- | :--- |
| 001_recreate_views.sql | 2025-07-01 00:42:58 |
| 002_add_progression_history.sql | 2025-07-01 00:42:59 |
| 003_add_timezone_to_users.sql | 2025-07-01 01:53:04 |


---
### sessions

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `session_token` | TEXT |  |  | ✅ |  |
| `username` | TEXT | ✅ |  |  |  |
| `expires_at` | DATETIME | ✅ |  |  |  |

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

