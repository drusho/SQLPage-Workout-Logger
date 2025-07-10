---
date: 2025-07-09
title: "SQLPage - Workout - SQL Comment Documentation"
summary: "A guide to docstring conventions and a summary of all documented SQL files in the project."
series: sqlpage.workout-logger
github: https://github.com/drusho/SQLPage-Workout-Logger
source: "/Volumes/Public/Container_Settings/sqlpage"
categories: Homelab
tags:
  - sqlpage
  - documentation
  - style-guide
cssclasses:
  - academia
  - academia-rounded  
---
>[!tip]+ Tip
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.

## Table of Contents

- [`001_recreate_views.sql`](#001_recreate_views.sql)
- [`action_add_exercise.sql`](#action_add_exercise.sql)
- [`action_add_workout.sql`](#action_add_workout.sql)
- [`action_change_password.sql`](#action_change_password.sql)
- [`action_delete_exercise.sql`](#action_delete_exercise.sql)
- [`action_delete_history.sql`](#action_delete_history.sql)
- [`action_edit_exercise.sql`](#action_edit_exercise.sql)
- [`action_edit_history.sql`](#action_edit_history.sql)
- [`action_edit_progression_model.sql`](#action_edit_progression_model.sql)
- [`action_edit_progression_step.sql`](#action_edit_progression_step.sql)
- [`action_edit_workout.sql`](#action_edit_workout.sql)
- [`action_get_workout_template.sql`](#action_get_workout_template.sql)
- [`action_save_workout.sql`](#action_save_workout.sql)
- [`action_update_profile.sql`](#action_update_profile.sql)
- [`auth_guest_prompt.sql`](#auth_guest_prompt.sql)
- [`auth_login_action.sql`](#auth_login_action.sql)
- [`auth_login_form.sql`](#auth_login_form.sql)
- [`auth_logout.sql`](#auth_logout.sql)
- [`auth_signup_action.sql`](#auth_signup_action.sql)
- [`auth_signup_form.sql`](#auth_signup_form.sql)
- [`dev_action_save_workout.sql`](#dev_action_save_workout.sql)
- [`dev_debug_info.sql`](#dev_debug_info.sql)
- [`dev_multi-step_form.sql`](#dev_multi-step_form.sql)
- [`dev_view_workouts.sql`](#dev_view_workouts.sql)
- [`dev_workouts_print_log.sql`](#dev_workouts_print_log.sql)
- [`index.sql`](#index.sql)
- [`layout_main.sql`](#layout_main.sql)
- [`layout_non-auth.sql`](#layout_non-auth.sql)
- [`view_exercises.sql`](#view_exercises.sql)
- [`view_history.sql`](#view_history.sql)
- [`view_library.sql`](#view_library.sql)
- [`view_profile.sql`](#view_profile.sql)
- [`view_progression_models.sql`](#view_progression_models.sql)
- [`view_workout_logs.sql`](#view_workout_logs.sql)
- [`view_workouts.sql`](#view_workouts.sql)
## SQL File Documentation

---
### `001_recreate_views.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/migrations/001_recreate_views.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-19` ⚠️

**Description:** _No description provided._

---
### `action_add_exercise.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_add_exercise.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** A self-submitting page that displays a form to create a new exercise and processes the INSERT submission.

**Requires:**
- layouts/layout_main.sql: Provides the main UI shell and handles user authentication.
- ExerciseLibrary (table): The target table for the INSERT and the source for the 'Body Group' dropdown.
- sessions (table): Used to identify the current user and protect the page from guest access.

**Parameters:**
- action [form] A hidden field with the value 'add_exercise' that triggers the INSERT logic on POST.
- name [form] The required name of the new exercise.
- alias [form, optional] An optional, shorter name for the exercise.
- equipment [form, optional] The equipment needed for the exercise.
- body_group [form, optional] The body group for the exercise, chosen from a dynamically populated dropdown.

**Returns:**
- On a GET request, returns a UI page with a data entry form. On a POST request, it processes the data and returns a redirect component on success.

**See Also:**
- /views/view_exercises.sql: The page that links to this form and the page the user is returned to after a successful submission.

**Notes:**
- This script follows the Post-Redirect-Get (PRG) pattern to prevent duplicate form submissions on browser refresh.
- An authentication check is performed at the start of the script. Unauthenticated users are redirected.

**TODO:**
- Add server-side validation to prevent creating exercises with duplicate names.

---
### `action_add_workout.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_add_workout.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** A pure action script with no visible UI. It creates a new, empty, and disabled Workout Template record and then immediately redirects the user to the edit page for that new template.

**Requires:**
- WorkoutTemplates (table): The target table for the new workout template record.
- sessions (table): Used to identify the current user for the 'CreatedByUserID' field and to protect the page from guest access.

**Parameters:**
- sqlpage.cookie('session_token') [cookie]: Implicitly used to identify the logged-in user. This script takes no other parameters.

**Returns:**
- A `redirect` component that sends the user to the edit page for the newly created workout.

**See Also:**
- /views/view_workouts.sql: The page that should contain the link that triggers this action.
- /actions/action_edit_workout.sql: The destination page where the user is redirected to complete the workout setup.

**Notes:**
- The new workout template is created with a default name and is disabled (`IsEnabled = 0`) by default.

---
### `action_change_password.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_change_password.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** Securely handles a user's request to change their password from the profile page.

**Requires:**
- The `dimUser` and `sessions` tables.

**Parameters:**
- currentPassword [form] The user's existing password for verification.
- newPassword [form] The desired new password.
- confirmPassword [form] Confirmation of the new password.

---
### `action_delete_exercise.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_delete_exercise.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** A self-submitting page that displays a confirmation form to prevent accidental deletion and processes a "soft delete" (by setting IsEnabled = 0) upon user confirmation.

**Requires:**
- layouts/layout_main.sql: Provides the main UI shell and handles user authentication.
- ExerciseLibrary (table): The source for the exercise name and the target for the UPDATE statement.
- sessions (table): Used to identify the current user and protect the page from guest access.

**Parameters:**
- $id [url] The ExerciseID of the record to be deleted, passed in the URL on the initial GET request.
- action [form] A hidden field with the value 'delete_exercise' that triggers the UPDATE logic on POST.
- id [form] A hidden field containing the ExerciseID to delete, passed during the POST request.
- confirmation [form] The user-typed exercise name, which must match the actual name to confirm the deletion.

**Returns:**
- On a GET request, returns a UI page with the confirmation form. On a successful POST, returns a redirect component.

**See Also:**
- /views/view_exercises.sql: The page that links to this confirmation page and is the destination after a successful deletion.

**Notes:**
- This script performs a "soft delete" by setting the `IsEnabled` flag to 0, not by permanently removing the record.
- It includes a safety mechanism requiring the user to type the full exercise name to confirm the action.

---
### `action_delete_history.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_delete_history.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-02` ⚠️

**Description:** A self-submitting page that displays a confirmation form to prevent accidental deletion of a workout log. It also handles reverting any progression changes that were triggered by the deleted log.

**Requires:**
- layouts/layout_main.sql: Provides the main UI shell and authentication.
- WorkoutLog, WorkoutSetLog, UserExerciseProgression, UserExerciseProgressionHistory, sessions (tables).

**Parameters:**
- $id [url] The LogID of the record to be deleted, passed in the URL.
- action [form] A hidden field with the value 'delete_log' that triggers the DELETE logic on POST.
- id [form] A hidden field containing the LogID to delete, passed during the POST request.
- confirmation [form] The user-typed exercise name, which must match the actual name to confirm the deletion.

**Returns:**
- On a GET request, returns a UI page with the confirmation form. On a successful POST, returns a redirect component.

**See Also:**
- /views/view_history.sql: The page the user is returned to after a successful deletion.
- /actions/action_edit_history.sql: The page that links to this confirmation page.

**Notes:**
- This script performs a "hard delete" by permanently removing the record from WorkoutLog. Associated sets in WorkoutSetLog are removed automatically via a cascading delete trigger in the database.
- Before deleting the log, the script checks the UserExerciseProgressionHistory table. If the log being deleted had previously triggered a progression, the script reverts the changes in the UserExerciseProgression table to restore the user's progression to its prior state.

---
### `action_edit_exercise.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_edit_exercise.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-05` ⚠️

**Description:** A self-submitting page for creating, editing, and deleting an exercise in the catalog.

**Requires:**
- `layouts/layout_main.sql` for the page shell.
- `dimExercise`, `dimUserExercisePreferences`, `sessions` tables.

**Parameters:**
- id [url, optional] The exerciseId to edit. If absent, the page is in "create" mode.
- action [form] The action to perform ('create', 'update').
- action2 [form] The action to perform for deletion ('delete').

---
### `action_edit_history.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_edit_history.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-09` ⚠️

**Description:** A self-submitting page for creating a new workout log or editing an existing one.

**Requires:**
- `layouts/layout_main.sql` for the page shell.
- All `dim` and `fact` tables.

**Parameters:**
- user_id, exercise_id, date_id [url, optional] A composite key to identify the workout session to edit. If absent, the page is in "create" mode.
- action [form] The action to perform (e.g., 'save_log').

---
### `action_edit_progression_model.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_edit_progression_model.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-05` ⚠️

**Description:** A page for creating a new progression model or editing an existing one's high-level details.

**Requires:**
- `layouts/layout_main.sql` for the page shell.
- `dimProgressionModel`, `dimProgressionModelStep`, `sessions` tables.

**Parameters:**
- id [url, optional] The ID of the progression model to edit. If absent, the page enters "create" mode.
- action [form] The action to perform (e.g., 'create_model', 'update_details').

---
### `action_edit_progression_step.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_edit_progression_step.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-06` ⚠️

**Description:** A self-submitting page for bulk editing all steps of a single progression model.

**Requires:**
- `layouts/layout_main.sql` for the page shell.
- `dimProgressionModel`, `dimProgressionModelStep`, `sessions` tables.

**Parameters:**
- model_id [url] The ID of the progression model whose steps are being edited.
- num_steps [url, optional] The number of step rows to display in the editor.
- action [form] The action to perform (e.g., 'save_steps').

---
### `action_edit_workout.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_edit_workout.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-07` ⚠️

**Description:** Manages a workout routine. A single form is used to edit all exercises in the plan at once, with separate forms for updating the plan's name and adding new exercises.

**Requires:**
- layouts/layout_main.sql, All dim tables.

**Parameters:**
- template_id [url] The unique ID of the workout routine to edit.
- action [form] The server-side action to perform, e.g., 'update_all_exercises', 'update_details', 'add_exercise'.

---
### `action_get_workout_template.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_get_workout_template.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** A reusable helper script that retrieves the details of a specific workout template given its ID.

**Requires:**
- WorkoutTemplates (table): The source of the workout template data.

**Parameters:**
- $1 {string} - The TemplateID of the workout template to retrieve.

**Returns:**
- A single row containing the template name, description, and enabled status, which is consumed as a JSON object by the calling script.

**See Also:**
- /actions/action_edit_workout.sql: The script that calls this file to populate its edit form.

**Notes:**
- This script is executed by `action_edit_workout.sql` via the `sqlpage.read_file_as_json()` function.

---
### `action_save_workout.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_save_workout.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-19` ⚠️

**Description:** A pure action script that processes a multi-set workout form submission from index.sql. It creates a parent log entry, saves each individual set, and updates the user's progression to the next step in their plan.

**Requires:**
- sessions (table): To identify the current user.
- WorkoutLog (table): The parent table for a workout session.
- WorkoutSetLog (table): The child table for individual sets within a session.
- UserExerciseProgression (table): The table that tracks a user's progress on an exercise, which is updated by this script.

**Parameters:**
- template_id [form] The ID of the workout template being followed.
- exercise_id [form] The ID of the exercise being logged.
- num_sets [form] The total number of sets submitted from the form.
- reps_1, weight_1, ... [form] Dynamically named fields for each set's reps and weight (up to a max of 10).
- rpe_recorded [form] The user's Rate of Perceived Exertion for the session.
- notes_recorded [form, optional] Any user-provided notes for the workout.

**Returns:**
- A `redirect` component that sends the user back to the index page with a success flag.

**See Also:**
- /index.sql: The page containing the form that submits to this action.

**Notes:**
- This script uses a series of conditional INSERTs to handle a variable number of sets.
- It uses an "upsert" (INSERT ON CONFLICT) pattern to robustly create or update the user's progression record.

---
### `action_update_profile.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_update_profile.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** Handles the form submission from the profile page to update a user's display name and timezone.

**Requires:**
- The `dimUser` and `sessions` tables.

**Parameters:**
- displayName [form] The user's new desired display name.
- timezone [form] The user's new desired timezone.

---
### `auth_guest_prompt.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_guest_prompt.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** An interstitial page shown to guests who try to perform an action that requires an account. It explains why they should log in or sign up.

---
### `auth_login_action.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_login_action.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** Handles the user login form submission. It manually verifies the password against the stored hash, creates a session record on success, sets a session cookie, and redirects the user.

**Requires:**
- The `dimUser` table to retrieve the stored password hash.
- The `sessions` table to insert a new session record.

**Parameters:**
- username [form] The userId submitted by the user.
- password [form] The raw password submitted for verification.

---
### `auth_login_form.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_login_form.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** Renders the user login page. It displays a form for the user to enter their User ID and password, and includes a component to display any error messages passed in the URL.

**Parameters:**
- error [url, optional] A message to display in an error alert, passed from the login action upon a failed attempt.

**Returns:**
- A UI page composed of a form component for user login.

**See Also:**
- /auth/auth_login_action.sql - The action script this form POSTs to.
- /auth/auth_signup_form.sql - The signup page this page links to.

---
### `auth_logout.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_logout.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** Logs a user out by terminating their current session. It deletes the session record from the `sessions` table and clears the session cookie.

**Requires:**
- The `sessions` table, from which the user's session is deleted.

**Parameters:**
- sqlpage.cookie('session_token') [cookie] The token used to identify which session record to delete from the database.

---
### `auth_signup_action.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_signup_action.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** Handles the new user registration form submission. It securely hashes the password and inserts the new user record into the 'dimUser' table.

**Requires:**
- The `dimUser` table.

**Parameters:**
- :username The desired user ID for the new account.
- :displayName The public-facing name for the new user.
- :password The user's chosen password (in plain text).

---
### `auth_signup_form.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_signup_form.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** Renders a page with a form for new users to create an account. It collects a user ID, a public display name, and a password.

**Returns:**
- A UI page containing a form component for user registration.

**See Also:**
- auth_signup_action.sql - The action script this form submits to for processing.
- auth_login_form.sql - The login page that typically links to this form.

---
### `dev_action_save_workout.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/dev/dev_action_save_workout.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-19` ⚠️

**Description:** A debugging page to receive and display form submissions from 'index.sql'. It renders a simple table showing the variable names and submitted values. This is useful for ensuring that the dynamic form in index.sql is passing the correct data.

**Requires:**
- index.sql: The page that contains the workout logging form that submits to this page.

**Parameters:**
- template_id [form] The ID of the workout template being followed.
- exercise_id [form] The ID of the exercise being logged.
- num_sets [form] The total number of sets submitted.
- notes_recorded [form, optional] User-provided notes for the workout.
- rpe_recorded [form] The user's Rate of Perceived Exertion.
- reps_1, weight_1, ... [form] Dynamically named fields for each set's reps and weight.

**Returns:**
- A UI page containing a table that lists all received form parameters and their values.

**See Also:**
- /index.sql: The page that submits data to this debug script.
- /actions/action_save_workout.sql: The production script this debug page mimics.

**Notes:**
- This is a developer tool and is not part of the main application flow. Its purpose is solely for testing form submissions. It does not write any data to the database.

---
### `dev_debug_info.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/dev/dev_debug_info.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** A reusable debugging partial that displays all available SQLPage variables and the current user's session information.

---
### `dev_multi-step_form.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/dev/dev_multi-step_form.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** A development and testing script that demonstrates how to build a complex, multi-step form in SQLPage. This code is based on an official SQLPage example for booking a flight and is not integrated with the main workout logger application.

**Requires:**
- The 'example' table (for the dynamic shell component).

**Returns:**
- A complex, multi-step `form` component that conditionally displays fields for booking a flight based on user input from previous steps.

**See Also:**
- Official Example: https://sql-page.com/examples/multistep-form/
- GitHub Source: https://github.com/sqlpage/SQLPage/blob/main/examples/official-site/examples/multistep-form/result.sql

**Notes:**
- This is a developer tool for testing and is not part of the main application. It creates its own temporary `cities` table. The initial `dynamic` component may fail if the `example` table does not exist.

---
### `dev_view_workouts.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/dev/dev_view_workouts.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** Displays a filterable list of all configured workouts. Allows enabling/disabling of workouts directly from the list.

**Requires:**
- The TemplateExerciseList table, which must have an `IsEnabled` column.

**Parameters:**
- action [url, optional] The action to perform ('enable' or 'disable').
- id [url, optional] The ID of the workout to act upon.
- template_filter [url, optional] The TemplateID to filter the list by.
- status_filter [url, optional] The status (1 for Enabled, 0 for Disabled) to filter by.
- prog_model_filter [url, optional] The ProgressionModelID to filter by.

**TODO:**
- Preserve filter settings in the URL after enabling/disabling a workout.

---
### `dev_workouts_print_log.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/dev/dev_workouts_print_log.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** A development script used for debugging. It displays the single most recent entry from the `WorkoutLog` table that was added on the current day.

**Requires:**
- The `WorkoutLog` table.

**Returns:**
- A `table` component containing the most recent workout log entry from the current day.

**Notes:**
- This is a developer tool and is not part of the main application flow.

**TODO:**
- Allow passing a date or `UserID` as a URL parameter to view other logs.

---
### `index.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/index.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-08` ⚠️

**Description:** The main dashboard for logging workouts. Guides the user through selecting a routine and exercise, then displays their targets and a form to log their performance.

**Requires:**
- layouts/layout_main.sql, All dim tables, action_edit_history.sql

---
### `layout_main.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/layouts/layout_main.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-07` ⚠️

**Description:** The main application shell. It handles session validation and dynamically builds the navigation menu from an external JSON file.

**Requires:**
- `assets/navigation.json` to define the menu structure.
- `sessions` and `dimUser` tables for authentication.

---
### `layout_non-auth.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/layouts/layout_non-auth.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** A simplified layout shell for development and testing purposes. It provides the standard application `shell` and a full, authenticated-user navigation menu, but without any of the authentication checks or dynamic logic found in `layout_main.sql`. This is useful for testing individual pages without being redirected to a login screen.

**Returns:**
- A `shell` component containing a hardcoded title and the static navigation menu for an authenticated user.

**See Also:**
- `layout_main.sql` - The production layout this script is a simplified version of.

**Notes:**
- This layout is intended ONLY for development and is not for production use. It does not perform any authentication checks.

---
### `view_exercises.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_exercises.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-05` ⚠️

**Description:** Displays a list of all exercises from the dimExercise table. This is the main page for exercise management.

**Requires:**
- `layouts/layout_main.sql` for the page shell and authentication.
- The `dimExercise`, `dimUserExercisePreferences`, and `sessions` tables.

**Returns:**
- A UI page containing a button to add new exercises and a table listing all existing exercises.

**See Also:**
- /actions/action_add_exercise.sql - Page for creating new exercises.
- /actions/action_edit_exercise.sql - Page for editing an existing exercise.
- /actions/action_delete_exercise.sql - Page for confirming the deletion of an exercise.

---
### `view_history.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_history.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-08` ⚠️

**Description:** Displays a personal, aggregated summary of the logged-in user's past workouts.

**Requires:**
- `layouts/layout_main.sql` for the page shell and session variables.
- `factWorkoutHistory`, `dimDate`, `dimExercise` tables.

**Returns:**
- A UI page containing a searchable table of the user's workout history.

**See Also:**
- /actions/action_edit_history.sql: The page for editing a workout log.

---
### `view_library.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_library.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** A central landing page for managing application resources like exercises and workout plans.

---
### `view_profile.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_profile.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-03` ⚠️

**Description:** Displays forms for the logged-in user to update their profile information (display name, timezone) and change their password.

**Requires:**
- `layouts/layout_main.sql` for the page shell.
- The `dimUser` and `sessions` tables to fetch the current user's data.
- `assets/timezones.json` to populate the timezone dropdown.

**Returns:**
- A UI page with pre-filled forms for profile management.

---
### `view_progression_models.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_progression_models.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-05` ⚠️

**Description:** Displays a list of all user-created progression models and provides a link to create new ones.

**Requires:**
- `layouts/layout_main.sql` for the page shell.
- `dimProgressionModel` and `sessions` tables.

**Returns:**
- A UI page for viewing and managing progression models.

---
### `view_workout_logs.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_workout_logs.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** Provides a full CRUD (Create, Read, Update, Delete) interface for the `WorkoutLog` table. Users can view all past workouts, select an entry to edit its details in a form, or delete it entirely.

**Requires:**
- `layouts/layout_main.sql` for the page shell and authentication.
- The `WorkoutLog` and `ExerciseLibrary` tables.

**Parameters:**
- action [url, optional] Controls the page mode. Can be `edit` (show form), `save_edit` (process update), or `delete` (process delete).
- log_id [url, optional] The ID of the `WorkoutLog` entry to act upon.
- ... [form, optional] Various form fields are submitted when saving an edit.

**Returns:**
- A full UI page containing a table of all workout logs. If `action=edit`, it also displays a pre-filled form. If a `delete` or `save_edit` action is processed, it returns a `redirect` to reload the page.

**See Also:**
- `action_save_workout.sql` - The primary action that creates the data managed here.

**Notes:**
- This page uses the Post-Redirect-Get (PRG) pattern for all data modifications.
- The edit form is rendered conditionally based on the `action=edit` URL parameter.
- A single JSON object (`$log_data`) is used to cleanly pre-fill the edit form.

**TODO:**
- The "Delete" button is instant, should be handled by dedicated scripts in the actions/ folder
- Add a "Create New Log" button to allow for manual entry of historical data.
- Implement pagination for the main table to handle a large workout history.

---
### `view_workouts.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_workouts.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-07-06` ⚠️

**Description:** Displays a list of all workout plans for the current user.

**Requires:**
- `layouts/layout_main.sql` for the page shell and session variables.
- `dimExercisePlan` table.

**Returns:**
- A UI page with a list of the user's workout plans.
