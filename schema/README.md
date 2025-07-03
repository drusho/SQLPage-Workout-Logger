# Schema Documentation YAML Files

## 1. Overview

This directory contains the human-written documentation for the application's database schema. Since SQLite does not support native comments on tables or columns, we use a series of YAML files to define these descriptions in a structured way.

These files serve as the "single source of truth" for what each table and column represents. They are consumed by the `SQLPage_Workout_Documentation_Generator.ipynb` notebook, which combines this information with the technical schema details from the database to produce a complete, human-readable **Database Schema Report**.

The notebook can also **automatically generate or update** these files. When run, it will:
1.  Create placeholder `.yml` files for any new tables it finds in the database.
2.  Add placeholder entries for any new columns it finds in existing tables.

This approach is inspired by the `schema.yml` files used in tools like dbt.

---

## 2. File Structure and Syntax

Each YAML file must follow a specific structure. There should be one file per table. The columns within the file will be automatically sorted alphabetically by the generator script to ensure consistency.

### 2.1. Top-Level Keys

| Key          | Required | Type   | Description                                                                 |
| :----------- | :------- | :----- | :-------------------------------------------------------------------------- |
| `table_name` | Yes      | String | The exact name of the database table being described.                       |
| `description`| Yes      | String | A high-level description of the table's purpose.                            |
| `owner`      | No       | String | The person or team responsible for the table (e.g., "David R.").             |
| `tags`       | No       | List   | A list of strings to categorize the table (e.g., `fact`, `dimension`, `core`). |
| `columns`    | Yes      | List   | A list of objects, where each object describes a column.                      |

### 2.2. Column Keys

Each item in the `columns` list is an object with the following keys:

| Key         | Required | Type   | Description                                                                |
| :---------- | :------- | :----- | :------------------------------------------------------------------------- |
| `name`      | Yes      | String | The exact name of the column in the database table.                        |
| `description` | Yes      | String | A clear, concise description of what the column stores.                    |
| `tests`     | No       | List   | A list of data quality tests to apply to the column (see section below). |

---

## 3. Data Quality Tests

The `tests` key allows you to define data quality rules for each column. This documents your assumptions about the data and can be used by a future script to validate the database's integrity.

A test can be a simple string or an object for more complex rules.

* **`unique`**: Every value in this column must be unique.
* **`not_null`**: This column cannot contain any `NULL` or empty values.
* **`relationships`**: Checks referential integrity. Ensures a value in a foreign key column exists in the primary key column of another table.
* **`accepted_values`**: Ensures a column only contains values from a specified list.

---

## 4. Tagging Strategy

Tags are used to categorize your tables, making it easier to understand the data model at a glance. You should apply tags that describe the table's role and the nature of its data.

Here is a recommended set of tags for this project:

* **`fact`**: Use for central fact tables that store observational events. In this project, this applies to `FactWorkoutHistory`.
* **`dimension`**: Use for dimension tables that provide descriptive context to the fact tables. This applies to `DimUser`, `DimDate`, `DimExercise`, and `DimExercisePlan`.
* **`core`**: Use for any table that is fundamental to the application's core functionality. This would likely apply to all fact and dimension tables.
* **`user_data`**: Use for tables that contain user-specific information that is not directly related to a workout event. This applies to `DimUser`.
* **`pii`**: (Personally Identifiable Information) Although not currently in use, this tag would be important if you were to store sensitive user information like emails or full names.

---

## 4. Examples

### Example 1: `DimUser.yml` (Dimension Table)

```yaml
table_name: DimUser
description: "Stores user profile information. Replaces the old 'users' table."
owner: "David R."
tags:
  - dimension
  - user_data
  - core
columns:
  - name: DisplayName
    description: "The user's public-facing display name."
    tests:
      - not_null
  - name: Timezone
    description: "The user's local timezone to adjust workout timestamps."
    tests:
      - not_null
      - accepted_values:
          values: ['America/Denver', 'America/New_York', 'America/Chicago', 'America/Los_Angeles']
  - name: UserKey
    description: "Primary Key for the user (e.g., UUID or username)."
    tests:
      - unique
      - not_null
```

### Example 2: `FactWorkoutHistory.yml` (Fact Table)
```yaml
table_name: FactWorkoutHistory
description: "Central fact table recording every individual set performed in a workout."
owner: "David R."
tags:
  - fact
  - core
columns:
  - name: DateKey
    description: "Foreign Key referencing DimDate (in YYYYMMDD format)."
    tests:
      - not_null
      - relationships:
          to: DimDate
          field: DateKey
  - name: ExerciseKey
    description: "Foreign Key referencing DimExercise."
    tests:
      - not_null
  - name: ExercisePlanKey
    description: "Foreign Key referencing DimExercisePlan."
    tests:
      - not_null
  - name: RPE_Recorded
    description: "The Rate of Perceived Exertion for this specific set."
    tests:
      - not_null
  - name: RepsPerformed
    description: "The number of repetitions performed."
    tests:
      - not_null
  - name: SetNumber
    description: "The number of the set (e.g., 1, 2, 3)."
    tests:
      - not_null
  - name: UserKey
    description: "Foreign Key referencing DimUser."
    tests:
      - not_null
      - relationships:
          to: DimUser
          field: UserKey
  - name: WeightUsed
    description: "The weight used for the set."
    tests:
      - not_null
  - name: WorkoutHistoryKey
    description: "Primary Key for the workout set entry (e.g., UUID)."
    tests:
      - unique
      - not_null
```