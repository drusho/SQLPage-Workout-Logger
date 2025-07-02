# Schema Documentation YAML Files

## 1. Overview

This directory contains the human-written documentation for the application's database schema. Since SQLite does not support native comments on tables or columns, we use a series of YAML files to define these descriptions in a structured way.

These files serve as the "single source of truth" for what each table and column represents. They are consumed by the `SQLPage_Workout_Documentation_Generator.ipynb` notebook, which combines this information with the technical schema details from the database to produce a complete, human-readable **Database Schema Report**.

This approach is inspired by the `schema.yml` files used in tools like dbt.

---

## 2. How It Works

1.  **Define:** For each table in the database, a corresponding `.yml` file is created in this directory (e.g., `DimUser.yml` for the `DimUser` table).
2.  **Describe:** Inside each file, you provide a high-level description for the table and a specific description for each of its columns.
3.  **Generate:** When the `SQLPage_Workout_Documentation_Generator.ipynb` notebook is run, it reads all the `.yml` files from this directory.
4.  **Combine:** The notebook then generates the final `Database Schema Report.md`, injecting the descriptions from these YAML files directly into the report, enriching the technical details with clear, contextual information.

---

## 3. File Structure and Syntax

Each YAML file must follow a specific structure. There should be one file per table.

### 3.1. Top-Level Keys

| Key          | Required | Type   | Description                                           |
| :----------- | :------- | :----- | :---------------------------------------------------- |
| `table_name` | Yes      | String | The exact name of the database table being described. |
| `description`| Yes      | String | A high-level description of the table's purpose.      |
| `columns`    | Yes      | List   | A list of objects, where each object describes a column. |

### 3.2. Column Keys

Each item in the `columns` list is an object with the following keys:

| Key         | Required | Type   | Description                                             |
| :---------- | :------- | :----- | :------------------------------------------------------ |
| `name`      | Yes      | String | The exact name of the column in the database table.     |
| `description` | Yes      | String | A clear, concise description of what the column stores. |

---

## 4. Examples

### Example 1: `DimUser.yml` (Dimension Table)

```yaml
table_name: DimUser
description: "Stores user profile information. Replaces the old 'users' table."
columns:
  - name: UserKey
    description: "Primary Key for the user (e.g., UUID or username)."
  - name: DisplayName
    description: "The user's public-facing display name."
  - name: Timezone
    description: "The user's local timezone to adjust workout timestamps (e.g., 'America/Denver')."
```

### Example 2: `FactWorkoutHistory.yml` (Fact Table)
```yaml
table_name: FactWorkoutHistory
description: "Central fact table recording every individual set performed in a workout. Replaces 'WorkoutLog' and 'WorkoutSetLog'."
columns:
  - name: WorkoutHistoryKey
    description: "Primary Key for the workout set entry (e.g., UUID)."
  - name: UserKey
    description: "Foreign Key referencing DimUser."
  - name: ExerciseKey
    description: "Foreign Key referencing DimExercise."
  - name: DateKey
    description: "Foreign Key referencing DimDate (in YYYYMMDD format)."
  - name: ExercisePlanKey
    description: "Foreign Key referencing DimExercisePlan (captures the state of the plan at the time of workout)."
  - name: SetNumber
    description: "The number of the set (e.g., 1, 2, 3)."
  - name: RepsPerformed
    description: "The number of repetitions performed."
  - name: WeightUsed
    description: "The weight used for the set."
  - name: RPE_Recorded
    description: "The Rate of Perceived Exertion for this specific set."
```