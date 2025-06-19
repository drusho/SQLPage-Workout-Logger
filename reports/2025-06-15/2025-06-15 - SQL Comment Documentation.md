# 2025-06-15 - SQL Comment Documentation

**summary:**\
 "A guide to docstring conventions and a summary of all documented SQL files in the project."

>[!tip]
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.

---

## Table of Contents

- [`action_add_exercise.sql`](#action_add_exercisesql)
- [`action_delete_exercise.sql`](#action_delete_exercisesql)
- [`action_edit_exercise.sql`](#action_edit_exercisesql)
- [`action_save_workout.sql`](#action_save_workoutsql)
- [`action_update_profile.sql`](#action_update_profilesql)
- [`auth_login_action.sql`](#auth_login_actionsql)
- [`auth_login_form.sql`](#auth_login_formsql)
- [`auth_logout.sql`](#auth_logoutsql)
- [`auth_signup_action.sql`](#auth_signup_actionsql)
- [`auth_signup_form.sql`](#auth_signup_formsql)
- [`dev_multi-step_form.sql`](#dev_multi-step_formsql)
- [`dev_workouts_print_log.sql`](#dev_workouts_print_logsql)
- [`index.sql`](#indexsql)
- [`layout_main.sql`](#layout_mainsql)
- [`layout_non-auth.sql`](#layout_non-authsql)
- [`profile.sql`](#profilesql)
- [`view_exercises.sql`](#view_exercisessql)
- [`view_history.sql`](#view_historysql)
- [`view_progression_models.sql`](#view_progression_modelssql)
- [`view_workout_logs.sql`](#view_workout_logssql)
## SQL File Documentation

---
### `action_add_exercise.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_add_exercise.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Displays a form to create a new entry in the `ExerciseLibrary` table and processes the form submission.

**Requires:**
- `../layouts/layout_main.sql` for the page shell and authentication.
- The `ExerciseLibrary` table, which this script reads from (for dropdowns) and writes to.

**Parameters:**
- action [form] A hidden parameter with the value 'add_exercise' to trigger the INSERT statement.
- name [form] The name of the new exercise.
- alias [form, optional] An optional alias for the new exercise.
- body_group [form, optional] The body group for the new exercise, selected from a dropdown.
- equipment [form, optional] The equipment needed for the new exercise.

**Returns:**
- On successful submission, a `redirect` component that sends the user back to the main exercise list. Otherwise, returns a UI page with a `form`.

**See Also:**
- `view_exercises.sql` - The page that links to this one and to which this page redirects.

**Notes:**
- This page is self-submitting and uses the Post-Redirect-Get (PRG) pattern.

**TODO:**
- Add server-side validation to prevent creating exercises with duplicate names.

---
### `action_delete_exercise.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_delete_exercise.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Displays a confirmation form to prevent accidental deletion of an exercise. Processes the soft-delete action upon confirmation.

**Requires:**
- `../layouts/layout_main.sql` for the page shell.
- The `ExerciseLibrary` table, which this script reads from and updates.

**Parameters:**
- $id [url] The `ExerciseID` of the record to be deleted.
- action [form] A hidden parameter with the value 'delete_exercise' to trigger the UPDATE statement.
- id [form] A hidden parameter containing the ExerciseID to delete.
- confirmation [form] The user-typed exercise name, required to confirm the deletion.

**Returns:**
- On successful submission, a `redirect` component. Otherwise, returns a UI page with the confirmation form.

**See Also:**
- `view_exercises.sql` - The page that links to this delete page.

**Notes:**
- This performs a "soft delete" by setting `IsEnabled = 0`, not a hard `DELETE` from the database.

---
### `action_edit_exercise.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_edit_exercise.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Displays a form pre-filled with data for a specific exercise from the `ExerciseLibrary` table.

**Requires:**
- `layouts/layout_main.sql` for the page shell and authentication.
- The `ExerciseLibrary` table, which this script reads from to populate the form.

**Parameters:**
- $id [url] The `ExerciseID` of the record to be edited, passed in the URL.

**Returns:**
- A UI page containing a form pre-filled with the data for the specified exercise.

**See Also:**
- `view_exercises.sql` - The page that links to this edit page.
- `../actions/action_edit_exercise.sql` - The script that processes this form's submission.

**Notes:**
- The form fields are pre-populated using a separate, direct database query for each field.

---
### `action_save_workout.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_save_workout.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Processes and saves a completed workout set from a form submission. It first inserts a new record into the `WorkoutLog` table, then updates or creates a record in `UserExerciseProgression` to advance the user's progress for that exercise.

**Requires:**
- The `sessions` table to identify the current user.
- The `WorkoutLog` table for inserting new workout data.
- The `UserExerciseProgression` table to update the user's progress.
- The `ExerciseLibrary` table to check the exercise's log type.
- The `TemplateExerciseList` table to find the associated progression model.

**Parameters:**
- sqlpage.cookie('session_token') [cookie] The user's session identifier.
- exercise_id [form] The unique ID of the exercise being logged.
- template_id [form] The unique ID of the parent workout template.
- sets_recorded [form] The total number of sets performed.
- reps_recorded [form] Reps performed for a standard weighted exercise.
- weight_recorded [form] Weight used for a standard weighted exercise.
- reps_set_1 - reps_set_5 [form] Reps for 'RepsOnly' type exercises.
- rpe_recorded [form] The Rate of Perceived Exertion for the workout.
- notes_recorded [form, optional] User-provided notes for the log.

**Returns:**
- A `redirect` component that sends the user back to the main workout page for the current template.

**See Also:**
- `index.sql` - The page where the workout form is displayed.
- `views/view_workout_logs.sql` - A page that displays data saved by this script.

**TODO:**
- Implement more complex progression logic based on `ProgressionModels` table.
- Add validation for required form parameters to prevent SQL errors.
- The 1RM estimation formula is hardcoded; consider making it dynamic.

---
### `action_update_profile.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_update_profile.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Processes a form submission to update a user's profile information. It uses the session cookie to identify the logged-in user and updates their record in the `users` table with the new data.

**Requires:**
- The `sessions` table to identify the current user.
- The `users` table, which this script updates.

**Parameters:**
- sqlpage.cookie('session_token') [cookie] The user's session identifier.
- display_name [form] The new display name submitted by the user.
- profile_picture_url [form] The new URL for the user's profile picture.
- bio [form] The new biography text for the user's profile.

**Returns:**
- A `redirect` component that sends the user back to their profile page, displaying a success notification upon completion.

**See Also:**
- `profile.sql` - The page that contains the form that initiates this action.

**Notes:**
- This action requires an active user session to function correctly.

**TODO:**
- Add server-side validation for input lengths (e.g., bio character limit).
- Implement a check to ensure a user session is valid before the `UPDATE` and show an error message if the session is invalid or expired.

---
### `auth_login_action.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_login_action.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Handles the user login form submission. It validates credentials using SQLPage's built-in `authentication` component. On failure, it redirects to the login form with an error. On success, it creates a new record in the `sessions` table, sets a session cookie, and redirects to the main application.

**Requires:**
- The `users` table to retrieve the stored password hash for verification.
- The `sessions` table to insert a new session record on success.

**Parameters:**
- username [form] The username submitted by the user.
- password [form] The raw password submitted for verification.

**Returns:**
- A series of components with conditional logic: - On failure: An immediate `redirect` to the login form with an error message. - On success: A `cookie` component to set the session token, followed by a `redirect` component to the application's root page (`/`).

**See Also:**
- `auth_login_form.sql` - The form that `POST`s to this action.
- `index.sql` - The page the user is redirected to on success.

**TODO:**
- Implement logging for failed login attempts to monitor for security threats.
- Make the session duration (`+1 day`) a configurable application setting.

---
### `auth_login_form.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_login_form.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Renders the user login page. It displays a `form` with `username` and `password` fields that submits to the login action script, and provides a link for new users to navigate to the signup page.

**Parameters:**
- error [url, optional] A message to display in an error alert, passed from the login action upon a failed attempt.

**Returns:**
- A UI page composed of a `form` component for user login and a `text` component with a link to the signup form.

**See Also:**
- `auth_login_action.sql` - The action script this form `POST`s to.
- `auth_signup_form.sql` - The signup page this page links to.

**Notes:**
- This page is intended for public access by unauthenticated users.

**TODO:**
- Implement a conditional `alert` component to display the `error` parameter's contents when it exists in the URL.
- Add a "Forgot Password?" link to a future password recovery page.

---
### `auth_logout.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_logout.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Logs a user out by terminating their current session. It deletes the session record from the `sessions` table, sends a command to the browser to clear the `session_token` cookie, and then redirects to the login page.

**Requires:**
- The `sessions` table, from which the user's session is deleted.

**Parameters:**
- sqlpage.cookie('session_token') [cookie] The token used to identify which session record to delete from the database.

**Returns:**
- A `cookie` component to clear the session token from the browser, followed by a `redirect` component sending the user to the login page.

**See Also:**
- `auth_login_form.sql` - The page the user is redirected to after logout.
- `layouts/layout_main.sql` - The likely location of the "Logout" link.

**Notes:**
- This script requires a user to be logged in with a valid session cookie to have any effect.

**TODO:**
- Pass a success message to the login form (e.g., `?message=...`) and update the form to be able to display it.
- Consider adding a "log out from all devices" feature, which would require getting the username and deleting all of their associated sessions.

---
### `auth_signup_action.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_signup_action.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-14` ⚠️

**Description:** Handles the new user registration form submission from auth_signup_form.sql. It takes the submitted username, display name, and password, securely hashes the password using sqlpage.hash_password(), and inserts the new user record into the 'users' table.

**Parameters:**
- :username The desired username for the new account.
- :display_name The public-facing name for the new user.
- :password The user's chosen password (in plain text).

**Notes:**
- This is a server-side action script with no visible output. Its only function is to create a user and redirect.

---
### `auth_signup_form.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_signup_form.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Renders a page with a form for new users to create an account. It collects a `username`, a public `display_name`, and a `password`, then `POST`s the data to the signup action script.

**Returns:**
- A UI page containing a `form` component for user registration.

**See Also:**
- auth_signup_action.sql - The action script this form submits to for processing.
- auth_login_form.sql - The login page that typically links to this form.

**Notes:**
- This page is for public access and does not require a user to be logged in.

**TODO:**
- Add a `Confirm Password` field to the form to prevent user typos. The action script must then be updated to verify the passwords match.
- Implement a mechanism to display errors returned from `auth_signup_action.sql`, such as when a username is already taken.
- Add a text link for users who already have an account, pointing back to `auth_login_form.sql`.

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
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** The main application dashboard, functioning as a multi-step, self-reloading form to guide the user through logging a workout. It conditionally displays information based on user selections: first templates, then exercises with progression targets, and finally a detailed logging form for a specific exercise.

**Requires:**
- `layouts/layout_main.sql` for the page shell and authentication.
- The `sessions` table to identify the current user.
- All tables related to templates and progression: `WorkoutTemplates`, `TemplateExerciseList`, `ExerciseLibrary`, `UserExerciseProgression`, and `ProgressionModelSteps`.

**Parameters:**
- sqlpage.cookie('session_token') [cookie] Used to identify the current user.
- template_id [url, optional] The ID of the currently selected workout template. Controls the display of the exercise list and selector.
- selected_exercise_id [url, optional] The ID of the chosen exercise. Controls the display of the final workout logging form.

**Returns:**
- A full UI page that progressively reveals more components as the user makes selections. The final state includes selectors and the detailed logging form.

**See Also:**
- `action_save_workout.sql` - The script that the final logging form submits to.

**Notes:**
- This page heavily uses auto-submitting forms and conditional rendering to create a dynamic, single-page application experience.
- The progression targets shown in the exercise list and pre-filled into the final form are calculated with complex, multi-table joins.

**TODO:**
- Refactor the complex progression-target queries into a single database `VIEW` to simplify the SQL in this file and reduce redundancy.
- Add more graceful handling for cases where a user has no progression data for a selected exercise, preventing potential errors or empty fields.

---
### `layout_main.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/layouts/layout_main.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** The main application shell, included on most pages to provide a consistent layout, navigation menu, and site-wide authentication. It dynamically adjusts the navigation menu and welcome message based on the user's login status.

**Requires:**
- The `sessions` table to identify the logged-in user.
- The `users` table to fetch the user's display name.

**Parameters:**
- sqlpage.cookie('session_token') [cookie, optional] The session token used to identify the user. If absent or invalid, the user is treated as a guest.

**Returns:**
- A `shell` component that wraps the content of the calling page, providing the overall page structure, header, and a dynamic sidebar menu. May also return an `authentication` component to force login.

**See Also:**
- `index.sql` - An example of a page that uses this layout.

**Notes:**
- Features conditional authentication: users on the local network (192.168.x.x) can browse as guests, while external users are required to log in.

**TODO:**
- Consider moving the navigation menu structure into a database table to allow for dynamic menu management without editing this SQL file.

---
### `layout_non-auth.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/layouts/layout_non-auth.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** A simplified layout shell for development and testing purposes. It provides the standard application `shell` and a full, authenticated-user navigation menu, but without any of the authentication checks or dynamic logic found in `layout_main.sql`. This is useful for testing individual pages without being redirected to a login screen.

**Returns:**
- A `shell` component containing a hardcoded title and the static navigation menu for an authenticated user.

**See Also:**
- `layout_main.sql` - The production layout this script is a simplified version of.

**Notes:**
- This layout is intended ONLY for development and is not for production use. It does not perform any authentication checks.

---
### `profile.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/profile.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Displays the logged-in user's profile information within an editable form. It fetches the user's display name, profile picture URL, and bio, allowing the user to update them by submitting the form.

**Requires:**
- `layouts/layout_main.sql` for the page shell and authentication.
- The `sessions` and `users` tables to fetch the current user's data.

**Parameters:**
- sqlpage.cookie('session_token') [cookie] Used to identify the logged-in user.

**Returns:**
- A full UI page containing the user's profile picture (if available) and a form pre-filled with their current profile information.

**See Also:**
- `action_update_profile.sql` - The script that this page's form submits to.

**Notes:**
- This page requires a user to be logged in with a valid session cookie.
- It safely fetches all user data into a single JSON object (`$user_data`) to prevent errors if some profile fields are empty (`NULL`).

**TODO:**
- Consider adding an actual file upload component for the profile picture instead of requiring a URL from the user.

---
### `view_exercises.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_exercises.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Displays a list of all enabled exercises from the `ExerciseLibrary`. This is the main page for exercise management.

**Requires:**
- `layouts/layout_main.sql` for the page shell and authentication.
- The `ExerciseLibrary` table to populate the list.

**Returns:**
- A UI page containing a button to add new exercises and a table listing all existing exercises.

**See Also:**
- `/actions/action_add_exercise.sql` - Page for creating new exercises.
- `/actions/action_edit_exercise.sql` - Page for editing an existing exercise.
- `/actions/action_delete_exercise.sql` - Page for confirming the deletion of an exercise.

**Notes:**
- This page links to other pages for specific actions (add, edit, delete), following a multi-page application pattern.

---
### `view_history.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_history.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** Displays a comprehensive, searchable, and sortable table of all workout logs. It joins workout data with the exercise library to provide a user-friendly view of a user's complete training history.

**Requires:**
- `layouts/layout_main.sql` for the page shell and authentication.
- The `WorkoutLog` table to fetch workout data.
- The `ExerciseLibrary` table to display exercise names.

**Returns:**
- A full UI page containing a searchable and sortable `table` of the entire workout history.

**See Also:**
- `action_save_workout.sql` - The action that creates the data displayed here.

**Notes:**
- This page is read-only. The search and sort functionality is handled client-side by the SQLPage `table` component.

**TODO:**
- Add server-side pagination to improve performance when the log history grows large.
- Implement advanced filtering options, such as by date range or by exercise.

---
### `view_progression_models.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_progression_models.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

**Description:** A comprehensive management page for `ProgressionModels` and their associated `ProgressionModelSteps`. It functions as a single-file CRUD interface, allowing users to create, view, and delete both models and their steps.

**Requires:**
- `layouts/layout_main.sql` for the page shell and authentication.
- The `ProgressionModels` and `ProgressionModelSteps` tables.

**Parameters:**
- model_id [url, optional] The ID of a model to view its steps. This controls the conditional display of the steps management section.
- delete_model_id [url, optional] The ID of a model to delete.
- delete_step_id [url, optional] The ID of a model step to delete.
- new_model_name [form, optional] The name for a new model to be created.
- new_step_number [form, optional] The step number for a new step to be created.

**Returns:**
- A full UI page for managing progression models. The page content changes based on the presence of a `model_id` in the URL. If an action parameter is provided, it returns a `redirect` component to reload the page.

**See Also:**
- `action_save_workout.sql` - This action consumes the models created here.

**Notes:**
- This page uses declarative `action` components and the Post-Redirect-Get (PRG) pattern to handle all data modifications.
- The section for managing model steps is rendered conditionally, only appearing when a `model_id` is present in the URL.
- It uses a raw HTML `<form>` inside a Markdown block for the "Add New Step" form to achieve a custom layout.

**TODO:**
- Add "Edit" functionality for both progression models and their steps.
- Refactor the raw HTML form to use standard SQLPage `form` components for better consistency and maintainability.
- Implement more robust validation and user-friendly error handling for all form submissions.

---
### `view_workout_logs.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_workout_logs.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-15` ⚠️

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
- The "Delete" button is instant. Add a confirmation step (e.g., using JavaScript or a confirmation page) to prevent accidental deletions.
- Add a "Create New Log" button to allow for manual entry of historical data.
- Implement pagination for the main table to handle a large workout history.
