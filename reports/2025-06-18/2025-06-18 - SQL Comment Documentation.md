# 2025-06-18 - SQL Comment Documentation

**summary:**\
 "A guide to docstring conventions and a summary of all documented SQL files in the project."

>[!tip]
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.

---

## SQL File Documentation

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
### `action_edit_exercise.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_edit_exercise.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** A self-submitting page that displays a form pre-filled with an exercise's current data and processes the UPDATE submission.

**Requires:**
- layouts/layout_main.sql: Provides the main UI shell and handles user authentication.
- ExerciseLibrary (table): The source for the exercise data and the target for the UPDATE statement.
- sessions (table): Used to identify the current user and protect the page from guest access.

**Parameters:**
- $id [url] The ExerciseID of the record to be edited, passed in the URL on the initial GET request.
- action [form] A hidden field with the value 'update_exercise' that triggers the UPDATE logic on POST.
- id [form] A hidden field containing the ExerciseID to update, passed during the POST request.
- name [form] The new name for the exercise.
- alias [form, optional] The new alias for the exercise.
- equipment [form, optional] The new equipment needed for the exercise.
- body_group [form, optional] The new body group for the exercise.

**Returns:**
- On a GET request, returns a UI page with the pre-filled form. On a successful POST, returns a redirect component.

**See Also:**
- /views/view_exercises.sql: The page that links to this edit page and is the destination after a successful update.

**Notes:**
- This script follows the Post-Redirect-Get (PRG) pattern. An authentication check is performed at the start.
- Each form field is pre-populated by running its own individual query against the database.

---
### `action_edit_workout.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/actions/action_edit_workout.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** A complex, self-submitting page for managing a single Workout Template. It handles updating the template's main details and allows for adding, removing, and updating exercises within the template.

**Requires:**
- layouts/layout_main.sql: For the main UI shell and authentication.
- actions/action_get_workout_template.sql: A helper script used to fetch template data as JSON.
- WorkoutTemplates, TemplateExerciseList, ExerciseLibrary, ProgressionModels, sessions (tables): Used for various read/write operations.

**Parameters:**
- $id [url] The TemplateID of the workout being edited.
- action [url/form] Determines which database operation to perform (e.g., 'update_details', 'remove_exercise').
- remove_id [url] The TemplateExerciseListID of the exercise link to delete.
- workout_name, workout_description, is_enabled [form] Parameters for updating the template details.
- tel_id, exercise_id, progression_model_id, order_in_workout [form] Parameters for updating an exercise in the list.

**Returns:**
- A UI page for editing the workout. All database actions result in a redirect back to this same page.

**Notes:**
- This script is a "single-page CRUD" interface that handles multiple distinct actions, all routing back to itself using the Post-Redirect-Get (PRG) pattern.

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
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

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
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

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
### `auth_guest_prompt.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/auth/auth_guest_prompt.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** An interstitial page shown to guests who try to perform an action that requires an account. It explains why they should log in or sign up.

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
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** The main application dashboard and a dynamic, multi-step, single-page interface for logging workouts. It uses a progressive disclosure UI where components appear as the user makes selections.

**Requires:**
- layouts/layout_main.sql: Provides the main UI shell and handles user authentication.
- UserExerciseProgressionTargets (view): Used to fetch the target sets, reps, and weight for a user's current progression.
- WorkoutTemplateDetails (view): Used to populate the list of exercises for a given workout template.
- WorkoutLog, WorkoutSetLog (tables): Queried to display the user's last performance for a selected exercise.

**Parameters:**
- template_id [url, optional] Controls which workout's exercises are displayed. Set by the form in Step 3.
- selected_exercise_id [url, optional] Controls which exercise's logging form is displayed. Set by the form in Step 5.
- success [url, optional] A flag that triggers the display of the "Workout Saved!" alert.

**Returns:**
- A full UI page that progressively reveals more components as the user makes selections.

**See Also:**
- /actions/action_save_workout.sql: The script that the main workout logging form submits to.

**Notes:**
- The page state is managed via URL parameters. Forms are set to 'auto_submit' to reload the page and reveal the next step in the workflow.
- The query for user targets is robust, using COALESCE to provide default values for exercises that have no prior user history.
- The set/rep/weight input form is generated dynamically using a recursive Common Table Expression (CTE).

---
### `layout_main.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/layouts/layout_main.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** The main application shell. Shows a full navigation menu to all users to allow for guest exploration.

**Notes:**
- Guest access is enabled for all users. Database write actions are handled by individual action scripts.

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
### `view_exercises.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_exercises.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-16` ⚠️

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
### `view_profile.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_profile.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

**Description:** Displays the user's profile information within an editable form. Gracefully handles guest users by displaying "Guest" as the name.

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
- It safely fetches all user data into a single JSON object (`$user_data`) to prevent errors if some profile fields are empty (`NULL`).

**TODO:**
- Consider adding an actual file upload component for the profile picture instead of requiring a URL from the user.

---
### `view_progression_models.sql`
**Path:** `/Volumes/Public/Container_Settings/sqlpage/www/views/view_progression_models.sql`
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-18` ⚠️

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
- Refactor the raw HTML form to use standard SQLPage `form` components
- "delete" button in view_progression_models.sql should link to a new file like www/actions/action_delete_model.sql instead of handling the deletion itself. for better consistency and maintainability.
- Implement more robust validation and user-friendly error handling for all form submissions.

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
**Last Updated (doc):** `N/A` | **File Modified:** `2025-06-17` ⚠️

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
