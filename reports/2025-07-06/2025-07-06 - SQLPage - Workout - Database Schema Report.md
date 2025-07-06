# 2025-07-06 - Database Schema Report\n\n**summary:**\n"Schema and data samples for the database powering the SQLPage - Workout application."\n\n>[!tip]+ Tip
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.
\n\n---\n
## Table of Contents

**Tables**
- [_migrations](#-migrations)
- [dimDate](#dimdate)
- [dimExercise](#dimexercise)
- [dimExercisePlan](#dimexerciseplan)
- [dimProgressionModel](#dimprogressionmodel)
- [dimProgressionModelStep](#dimprogressionmodelstep)
- [dimUser](#dimuser)
- [dimUserExercisePreferences](#dimuserexercisepreferences)
- [factWorkoutHistory](#factworkouthistory)
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
### dimDate

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `dateId` | INTEGER |  |  | ✅ |  |
| `fullDate` | TEXT | ✅ |  |  |  |
| `dayOfWeek` | TEXT | ✅ |  |  |  |
| `monthName` | TEXT | ✅ |  |  |  |
| `year` | INTEGER | ✅ |  |  |  |

**Creation SQL**

```sql
CREATE TABLE dimDate (
    dateId INTEGER PRIMARY KEY, -- TRX_YYYYMMDD format
    fullDate TEXT NOT NULL, -- YYYY-MM-DD format
    dayOfWeek TEXT NOT NULL,
    monthName TEXT NOT NULL,
    year INTEGER NOT NULL
)
```

**Data Samples (First 3 Rows)**

| dateId | fullDate | dayOfWeek | monthName | year |
| :--- | :--- | :--- | :--- | :--- |
| 20200101 | 2020-01-01 | Wednesday | January | 2020 |
| 20200102 | 2020-01-02 | Thursday | January | 2020 |
| 20200103 | 2020-01-03 | Friday | January | 2020 |


---
### dimExercise

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `exerciseId` | TEXT |  |  | ✅ |  |
| `exerciseName` | TEXT | ✅ |  |  |  |
| `bodyGroup` | TEXT |  |  |  |  |
| `equipmentNeeded` | TEXT |  |  |  |  |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_dimExercise_2` | `exerciseName` | ✅ |
| `sqlite_autoindex_dimExercise_1` | `exerciseId` | ✅ |

**Creation SQL**

```sql
CREATE TABLE dimExercise (
    exerciseId TEXT PRIMARY KEY,
    exerciseName TEXT NOT NULL UNIQUE,
    bodyGroup TEXT,
    equipmentNeeded TEXT
)
```

**Data Samples (First 3 Rows)**

| exerciseId | exerciseName | bodyGroup | equipmentNeeded |
| :--- | :--- | :--- | :--- |
| UUID001 | Dumbbell Incline Chest Press | Chest | Dumbbells, Adjustable Bench |
| UUID002 | Single Leg Press | Legs | Leg Press Machine |
| UUID003 | Lat Pulldown | Back | Lat Pulldown Machine, Attachment (e.g., Wide Bar) |


---
### dimExercisePlan

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `exercisePlanId` | TEXT |  |  | ✅ |  |
| `userId` | TEXT | ✅ |  |  |  |
| `exerciseId` | TEXT | ✅ |  |  |  |
| `templateName` | TEXT |  |  |  |  |
| `userTemplateAlias` | TEXT |  |  |  |  |
| `isActive` | INTEGER | ✅ | `1` |  |  |
| `currentStepNumber` | INTEGER |  |  |  |  |
| `current1rmEstimate` | REAL |  |  |  |  |
| `targetSets` | INTEGER |  |  |  |  |
| `targetReps` | INTEGER |  |  |  |  |
| `progressionModelId` | TEXT |  |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `exerciseId` | `dimExercise` | `exerciseId` |
| `userId` | `dimUser` | `userId` |
| `progressionModelId` | `dimProgressionModel` | `progressionModelId` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idxDimExercisePlanUserActive` | `userId`, `isActive` |  |
| `sqlite_autoindex_dimExercisePlan_1` | `exercisePlanId` | ✅ |

**Creation SQL**

```sql
CREATE TABLE dimExercisePlan (
    exercisePlanId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    templateName TEXT,
    userTemplateAlias TEXT,
    isActive INTEGER NOT NULL DEFAULT 1,
    currentStepNumber INTEGER,
    current1rmEstimate REAL,
    targetSets INTEGER,
    targetReps INTEGER, progressionModelId TEXT REFERENCES dimProgressionModel (progressionModelId),
    FOREIGN KEY (userId) REFERENCES dimUser (userId),
    FOREIGN KEY (exerciseId) REFERENCES dimExercise (exerciseId)
)
```

**Data Samples (First 3 Rows)**

| exercisePlanId | userId | exerciseId | templateName | userTemplateAlias | isActive | currentStepNumber | current1rmEstimate | targetSets | targetReps | progressionModelId |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 22728D9CD54A818FE058F182DB2332E4 | davidrusho | UUID001 | Full Body A | NULL | 1 | 1 | NULL | NULL | NULL | NULL |
| F0E7729612C022D5189CE92079958EB8 | davidrusho | UUID002 | Full Body A | NULL | 1 | 1 | NULL | NULL | NULL | NULL |
| 74B726DF640C14E4478E38B957B261CC | davidrusho | UUID003 | Full Body A | NULL | 1 | 1 | NULL | NULL | NULL | NULL |


---
### dimProgressionModel

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `progressionModelId` | TEXT |  |  | ✅ |  |
| `userId` | TEXT | ✅ |  |  |  |
| `modelName` | TEXT | ✅ |  |  |  |
| `modelType` | TEXT | ✅ |  |  |  |
| `description` | TEXT |  |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `userId` | `dimUser` | `userId` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_dimProgressionModel_1` | `progressionModelId` | ✅ |

**Creation SQL**

```sql
CREATE TABLE dimProgressionModel (
    progressionModelId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    modelName TEXT NOT NULL,
    modelType TEXT NOT NULL, -- 'weight' or 'reps'
    description TEXT,
    FOREIGN KEY (userId) REFERENCES dimUser (userId)
)
```

**Data Samples (First 3 Rows)**

| progressionModelId | userId | modelName | modelType | description |
| :--- | :--- | :--- | :--- | :--- |
| D5BF3317765B062340A347FDF8CB0764 | davidrusho | Testing Model | weight | Testing Description |


---
### dimProgressionModelStep

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `progressionModelStepId` | TEXT |  |  | ✅ |  |
| `progressionModelId` | TEXT | ✅ |  |  |  |
| `stepNumber` | INTEGER | ✅ |  |  |  |
| `description` | TEXT |  |  |  |  |
| `percentOfMax` | REAL |  |  |  |  |
| `targetSets` | INTEGER |  |  |  |  |
| `targetReps` | INTEGER |  |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `progressionModelId` | `dimProgressionModel` | `progressionModelId` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_dimProgressionModelStep_1` | `progressionModelStepId` | ✅ |

**Creation SQL**

```sql
CREATE TABLE dimProgressionModelStep (
    progressionModelStepId TEXT PRIMARY KEY,
    progressionModelId TEXT NOT NULL,
    stepNumber INTEGER NOT NULL,
    description TEXT, -- e.g., "75% of 1RM" or "75% of Max Reps"
    percentOfMax REAL, -- The percentage of 1RM or Max Reps to use
    targetSets INTEGER,
    targetReps INTEGER,
    FOREIGN KEY (progressionModelId) REFERENCES dimProgressionModel (progressionModelId) ON DELETE CASCADE
)
```

**Data Samples (First 3 Rows)**

| progressionModelStepId | progressionModelId | stepNumber | description | percentOfMax | targetSets | targetReps |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 261EC8B5CDBBC47B0040C3828E740137 | D5BF3317765B062340A347FDF8CB0764 | 1 | Testing 12 | 75.0 | 3 | 5 |
| 51ABAF9D36F40AD82BAB0AF33660DC47 | D5BF3317765B062340A347FDF8CB0764 | 2 | Testing 22 | 75.0 | 3 | 5 |


---
### dimUser

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `userId` | TEXT |  |  | ✅ |  |
| `displayName` | TEXT | ✅ |  |  |  |
| `timezone` | TEXT |  | `'America/Denver'` |  |  |
| `passwordHash` | TEXT |  |  |  |  |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_dimUser_1` | `userId` | ✅ |

**Creation SQL**

```sql
CREATE TABLE dimUser (
    userId TEXT PRIMARY KEY,
    displayName TEXT NOT NULL,
    timezone TEXT DEFAULT 'America/Denver'
, passwordHash TEXT)
```

**Data Samples (First 3 Rows)**

| userId | displayName | timezone | passwordHash |
| :--- | :--- | :--- | :--- |
| Salaried8674 | David | America/Denver | NULL |
| test_user_1 | test_user_1 | America/Denver | NULL |
| davidrusho | David | America/Denver | $argon2id$v=19$m=19456,t=2,p=1$5UIxNP9Nu9jmzmNUQ3QIxA$04wdGe0MDA1Vdrdu1ex2tGLHOfYOx5tS4Mj4wOS3fcA |


---
### dimUserExercisePreferences

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `userId` | TEXT | ✅ |  | ✅ |  |
| `exerciseId` | TEXT | ✅ |  |  |  |
| `userExerciseAlias` | TEXT | ✅ |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `exerciseId` | `dimExercise` | `exerciseId` |
| `userId` | `dimUser` | `userId` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_dimUserExercisePreferences_1` | `userId`, `exerciseId` | ✅ |

**Creation SQL**

```sql
CREATE TABLE dimUserExercisePreferences (
    userId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    userExerciseAlias TEXT NOT NULL,
    PRIMARY KEY (userId, exerciseId),
    FOREIGN KEY (userId) REFERENCES dimUser (userId),
    FOREIGN KEY (exerciseId) REFERENCES dimExercise (exerciseId)
)
```

**Data Samples (First 3 Rows)**

| userId | exerciseId | userExerciseAlias |
| :--- | :--- | :--- |
| davidrusho | UUID001 | DB Incline Press |
| davidrusho | UUID005 | DB OHP |
| davidrusho | UUID006 | RDL |


---
### factWorkoutHistory

**Columns**

| Name | Type | Not Null | Default | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `workoutHistoryId` | TEXT |  |  | ✅ |  |
| `userId` | TEXT | ✅ |  |  |  |
| `exerciseId` | TEXT | ✅ |  |  |  |
| `dateId` | INTEGER | ✅ |  |  |  |
| `exercisePlanId` | TEXT |  |  |  |  |
| `setNumber` | INTEGER | ✅ |  |  |  |
| `repsPerformed` | INTEGER | ✅ |  |  |  |
| `weightUsed` | REAL | ✅ |  |  |  |
| `rpeRecorded` | REAL |  |  |  |  |
| `createdAt` | INTEGER | ✅ |  |  |  |
| `updatedAt` | INTEGER | ✅ |  |  |  |
| `notes` | TEXT |  |  |  |  |

**Foreign Keys**

| Column | References Table | Foreign Column |
| :----- | :--------------- | :------------- |
| `exercisePlanId` | `dimExercisePlan` | `exercisePlanId` |
| `dateId` | `dimDate` | `dateId` |
| `exerciseId` | `dimExercise` | `exerciseId` |
| `userId` | `dimUser` | `userId` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `idxFactWorkoutHistoryPlanId` | `exercisePlanId` |  |
| `idxFactWorkoutHistoryDateId` | `dateId` |  |
| `idxFactWorkoutHistoryExerciseId` | `exerciseId` |  |
| `idxFactWorkoutHistoryUserId` | `userId` |  |
| `sqlite_autoindex_factWorkoutHistory_1` | `workoutHistoryId` | ✅ |

**Creation SQL**

```sql
CREATE TABLE factWorkoutHistory (
    workoutHistoryId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    dateId INTEGER NOT NULL,
    exercisePlanId TEXT, -- Can be NULL if no active plan exists
    setNumber INTEGER NOT NULL,
    repsPerformed INTEGER NOT NULL,
    weightUsed REAL NOT NULL,
    rpeRecorded REAL,
    createdAt INTEGER NOT NULL,
    updatedAt INTEGER NOT NULL, notes TEXT,
    FOREIGN KEY (userId) REFERENCES dimUser (userId),
    FOREIGN KEY (exerciseId) REFERENCES dimExercise (exerciseId),
    FOREIGN KEY (dateId) REFERENCES dimDate (dateId),
    FOREIGN KEY (exercisePlanId) REFERENCES dimExercisePlan (exercisePlanId)
)
```

**Data Samples (First 3 Rows)**

| workoutHistoryId | userId | exerciseId | dateId | exercisePlanId | setNumber | repsPerformed | weightUsed | rpeRecorded | createdAt | updatedAt | notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 9aa54afe80e4786f58f71727f73fa7c0 | davidrusho | UUID004 | 20250528 | AEED351BE5452133F9F51F1DCC68C53F | 1 | 12 | 40.0 | 8.0 | 1748475461 | 1748475461 | NULL |
| 96029ed67c9413ebae0d6389c94cd6b4 | davidrusho | UUID004 | 20250528 | AEED351BE5452133F9F51F1DCC68C53F | 2 | 12 | 40.0 | 8.0 | 1748475461 | 1748475461 | NULL |
| a9ee5163304a3cee181bff8a78f674cc | davidrusho | UUID004 | 20250528 | AEED351BE5452133F9F51F1DCC68C53F | 3 | 12 | 40.0 | 8.0 | 1748475461 | 1748475461 | NULL |


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
| `username` | `dimUser` | `userId` |

**Indexes**

| Index Name | Columns | Unique |
| :--- | :--- | :--- |
| `sqlite_autoindex_sessions_1` | `session_token` | ✅ |

**Creation SQL**

```sql
CREATE TABLE "sessions" (
    session_token TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (username) REFERENCES dimUser (userId) ON DELETE CASCADE
)
```

**Data Samples (First 3 Rows)**

| session_token | username | expires_at |
| :--- | :--- | :--- |
| nuvEHVKY0ErE0RRsSLmw7kpIallW4uJe | Salaried8674 | 2025-06-15 02:22:21 |
| lyb27vQ4pAxrmdkBqhthZtZPZaz6wFu1 | Salaried8674 | 2025-06-15 02:25:29 |
| HvsMdmbHxJHrGJl7DyNs8bvXKGpRswks | Salaried8674 | 2025-06-15 02:26:11 |

