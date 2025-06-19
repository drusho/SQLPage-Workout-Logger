# Style Guide


</br>

> [!NOTE]
> **Guiding Principle**\ 
> Write code and documentation for humans first, computers second. Clarity, consistency, and maintainability are the primary goals.


## File Naming Conventions
- **Pages:** Use lowercase `snake_case`. Name files based on the primary noun and action they represent (e.g., `view_logs.sql`, `edit_exercise.sql`).
- **Layouts/Components:** Prefix with `layout_` or `component_` (e.g., `layout_main.sql`).
- **Actions:** Prefix with `action_` for scripts that handle form submissions (e.g., `action_update_profile.sql`).

## SQL Formatting Rules

#### Keyword Casing
All SQL keywords must be `UPPERCASE` to distinguish them from table and column names.
- **DO:** 
	- `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `ORDER BY`, `INSERT INTO`, `VALUES`
- **DON'T:** 
	- `select`, `from`, `where`

#### Indentation
Use four (4) spaces for indentation to show logical hierarchy in subqueries and joins.

```sql
SELECT
    u.display_name,
    (
        SELECT
            COUNT(*)
        FROM workouts w
        WHERE
            w.username = u.username
    ) AS workout_count
FROM
    users u
WHERE
    u.is_active = TRUE;
````

#### Line Formatting

- Place each major clause (`SELECT`, `FROM`, `WHERE`, etc.) on a new line.
- Place each selected column on its own line for readability and easier diffing in version control.
- Use trailing commas at the end of each column line, except for the last one.

```sql
-- GOOD
SELECT
    w.workout_id,
    w.workout_date,
    e.exercise_name
FROM workouts w
JOIN exercises e ON w.exercise_id = e.exercise_id;
```
```sql
-- BAD
SELECT w.workout_id, w.workout_date, e.exercise_name FROM workouts w JOIN exercises e ON w.exercise_id = e.exercise_id;
```

## Naming Conventions

- **Tables:** Use plural, lowercase `snake_case` (e.g., `workouts`, `exercise_logs`).
- **Columns:** Use singular, lowercase `snake_case` (e.g., `user_id`, `display_name`, `created_at`).
- **Aliases:** Use short, intuitive aliases for tables in joins (e.g., `users u`, `workouts w`).

## Documentation Comments (Docstrings)

This guide outlines the standard format for doc comments in this project. Following these rules ensures consistency, improves code readability, and allows for the automated documentation generation you are currently viewing.

### General Rules

- **Placement:** Every `.sql` file must begin with a doc comment block at the very top.
- **Format:** Use a Javadoc-style comment block starting with `/**` and ending with `*/`, each on its own line.
- **Structure**: Each block consists of two parts:
	- A brief **description** of the file's purpose.
	- A series of **block tags** that provide specific, structured details.
- **Markdown:** All descriptive text supports Markdown. Use backticks `` ` `` for `code`, `filenames`, and `table_names`.

### Standard Tags

The following tags should be used to document each file:

| Tag | Purpose |
| :--- | :--- |
| **`@filename`** | The full name of the current file (e.g., `index.sql`). |
| **`@description`** | A one or two-sentence summary of what the script does. |
| **`@created`** | The date the file was originally created, in `YYYY-MM-DD` format. |
| **`@last-updated`**| The date the file was last modified. |
| **`@requires`** | Lists critical dependencies like tables, views, or other `.sql` files. |
| **`@param`** | Describes a parameter from a form, URL, or cookie. |
| **`@returns`** | Explains what the script outputs to the user (e.g., a UI component). |
| **`@see`** | Links to another related file or document. |
| **`@note`** | Provides special context, implementation details, or known quirks. |
| **`@todo`** | A note for future work or planned improvements. |

### Formatting Conventions

#### List-Based Tags
For tags that can have multiple entries (`@requires`, `@see`, `@todo`), format each as a separate line.

**Example**
```js
/**
 * @requires      - The `sessions` table to identify the current user.
 * @requires      - The `users` table, which this script updates.
 * @todo          - Add server-side validation for input lengths.
 * @todo          - Implement a check to ensure a user session is valid.
 */
```


#### Parameter (`@param`) Format

The `@param` tag follows a specific pattern to capture its source and optionality: `@param name [source, optionality] description`
- **`source`**: Can be `url`, `form`, or `cookie`.
- **`optionality`**: Can be `optional` if the parameter is not required for the script to run.

**Example**
```js
/**
 * @param log_id [url, optional] The ID of the `WorkoutLog` entry to act upon.
 * @param username [form] The username submitted by the user.
 * @param sqlpage.cookie('session_token') [cookie] Used to identify the logged-in user.
 */
```


### Complete Example
Docstring from `profile.sql`

```js
/**
 * @filename profile.sql
 * @description Displays the logged-in user's profile information within an editable form.
 * It fetches the user's display name, profile picture URL, and bio,
 * allowing the user to update them by submitting the form.
 * @created  2025-06-14
 * @last-updated 2025-06-15 16:59:26 MDT
 * @requires - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires - The `sessions` and `users` tables to fetch the current user's data.
 * @param sqlpage.cookie('session_token') [cookie] Used to identify the logged-in user.
 * @returns A full UI page containing the user's profile picture (if available) and a
 * form pre-filled with their current profile information.
 * @see - `action_update_profile.sql` - The script that this page's form submits to.
 * @note - This page requires a user to be logged in with a valid session cookie.
 * @note - It safely fetches all user data into a single JSON object (`$user_data`)
 * to prevent errors if some profile fields are empty (`NULL`).
 * @todo - Consider adding an actual file upload component for the profile picture
 * instead of requiring a URL from the user.
 */
```