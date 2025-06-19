/**
 * @filename      view_progression_models.sql
 * @description   A comprehensive management page for `ProgressionModels` and their associated
 * `ProgressionModelSteps`. It functions as a single-file CRUD interface,
 * allowing users to create, view, and delete both models and their steps.
 * @created       2025-06-14
 * @last-updated  2025-06-15
 * @requires      - `layouts/layout_main.sql` for the page shell and authentication.
 * @requires      - The `ProgressionModels` and `ProgressionModelSteps` tables.
 * @param         model_id [url, optional] The ID of a model to view its steps. This controls
 * the conditional display of the steps management section.
 * @param         delete_model_id [url, optional] The ID of a model to delete.
 * @param         delete_step_id [url, optional] The ID of a model step to delete.
 * @param         new_model_name [form, optional] The name for a new model to be created.
 * @param         new_step_number [form, optional] The step number for a new step to be created.
 * @returns       A full UI page for managing progression models. The page content changes based
 * on the presence of a `model_id` in the URL. If an action parameter is
 * provided, it returns a `redirect` component to reload the page.
 * @see           - `action_save_workout.sql` - This action consumes the models created here.
 * @note          - This page uses declarative `action` components and the Post-Redirect-Get
 * (PRG) pattern to handle all data modifications.
 * @note          - The section for managing model steps is rendered conditionally, only
 * appearing when a `model_id` is present in the URL.
 * @note          - It uses a raw HTML `<form>` inside a Markdown block for the "Add New Step"
 * form to achieve a custom layout.
 * @todo          - Add "Edit" functionality for both progression models and their steps.
 * @todo          - Refactor the raw HTML form to use standard SQLPage `form` components
 * @todo          - "delete" button in view_progression_models.sql should link to a new file like www/actions/action_delete_model.sql instead of handling the deletion itself.
 * for better consistency and maintainability.
 * @todo          - Implement more robust validation and user-friendly error handling for
 * all form submissions.
 */
-- Add this block at the top of any page that saves data.
-- It will check if a user is logged in. If not, it redirects them.
SET current_user = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
    );
SELECT 'redirect' AS component,
    '/auth/auth_guest_prompt.sql' AS link
WHERE $current_user IS NULL;
------------------------------------------------------
-- STEP 1: INCLUDE MAIN LAYOUT & AUTHENTICATION
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 2: HANDLE PAGE ACTIONS (DELETES & INSERTS)
-- This section processes any actions submitted to the page, like deleting or adding data.
-- It runs before the page content is rendered.
------------------------------------------------------
-- Handle Deletion of a Progression Model
SELECT 'action' AS component,
    'DELETE FROM ProgressionModels WHERE ProgressionModelID = :delete_model_id;' AS sql
WHERE :delete_model_id IS NOT NULL;
-- Handle Deletion of a Progression Model Step
SELECT 'action' AS component,
    'DELETE FROM ProgressionModelSteps WHERE ProgressionModelStepID = :delete_step_id AND ProgressionModelID = :model_id;' AS sql
WHERE :delete_step_id IS NOT NULL
    AND :model_id IS NOT NULL;
-- Handle Adding a New Progression Model
SELECT 'action' AS component,
    'INSERT INTO ProgressionModels (ProgressionModelID, ProgressionModelName, Description, DefaultTotalSteps)
     VALUES (''PM_'' || sqlpage.random_string(16), :new_model_name, :new_model_description, :new_model_total_steps);' AS sql
WHERE :new_model_name IS NOT NULL
    AND :new_model_name != '';
-- Handle Adding a New Progression Model Step
SELECT 'action' AS component,
    'INSERT INTO ProgressionModelSteps (ProgressionModelStepID, ProgressionModelID, StepNumber, TargetWeightFormula, TargetSetsFormula, TargetRepsFormula, StepNotes, SuccessCriteriaRPE, FailureCriteriaType, FailureCriteriaValue)
     VALUES (''PMS_'' || sqlpage.random_string(16), :model_id, :new_step_number, :new_step_target_weight_formula, :new_step_target_sets_formula, :new_step_target_reps_formula, :new_step_notes, :new_step_success_rpe, :new_step_failure_type, :new_step_failure_value);' AS sql
WHERE :model_id IS NOT NULL
    AND :new_step_number IS NOT NULL;
SELECT 'redirect' as component,
    'view_progression_models.sql' || COALESCE('?model_id=' || :model_id, '') AS link
WHERE :delete_model_id IS NOT NULL
    OR :delete_step_id IS NOT NULL
    OR (
        :new_model_name IS NOT NULL
        AND :new_model_name != ''
    )
    OR (
        :model_id IS NOT NULL
        AND :new_step_number IS NOT NULL
    );
------------------------------------------------------
-- STEP 3: RENDER THE MAIN PAGE CONTENT
------------------------------------------------------
SELECT 'text' as component,
    '## Progression Model Manager' as contents_md;
-- SUB-SECTION: Form and Table for Managing Models
SELECT 'text' as component,
    '### Manage Progression Models' as contents_md;
-- Form to add a new Progression Model
SELECT 'form' as component,
    'Add New Progression Model' as title,
    'view_progression_models.sql' as action,
    'POST' as method;
SELECT 'text' as type,
    'new_model_name' as name,
    'Model Name' as label,
    TRUE as required;
SELECT 'textarea' as type,
    'new_model_description' as name,
    'Description' as label;
SELECT 'number' as type,
    'new_model_total_steps' as name,
    'Default Total Steps' as label,
    1 as min,
    1 as value,
    TRUE as required;
-- Table displaying all existing models
SELECT 'table' as component,
    'Existing Progression Models' as title,
    -- Tells SQLPage to render the 'Actions' column as Markdown to make links clickable.
    JSON_ARRAY('Actions') AS markdown;
SELECT ProgressionModelName AS "Model Name",
    Description AS "Description",
    DefaultTotalSteps AS "Total Steps",
    '[View/Edit Steps](?model_id=' || ProgressionModelID || ') | [Delete](?delete_model_id=' || ProgressionModelID || ')' AS "Actions"
FROM ProgressionModels
ORDER BY ProgressionModelName;
---------------------------------------------------------------------------------------------
-- STEP 4: CONDITIONALLY RENDER THE "STEPS" MANAGEMENT SECTION
-- This entire section only appears if a user has clicked on "View/Edit Steps" for a specific model,
-- which adds a 'model_id' parameter to the URL.
---------------------------------------------------------------------------------------------
-- The 'dynamic' component with a WHERE clause ensures all content inside only renders
-- when a model_id is present.
SELECT 'dynamic' AS component,
    -- Build a single large block of Markdown content using JSON and SQL concatenation.
    JSON_OBJECT(
        'component',
        'markdown',
        'contents',
        -- Title for the steps section
        '### Steps for Model: ' || (
            SELECT ProgressionModelName
            FROM ProgressionModels
            WHERE ProgressionModelID = :model_id
        ) || '

' || -- Start of the Markdown table for displaying steps
        '| Step | Weight Formula | Sets | Reps | Notes | Success RPE | Failure Type | Failure Value | Actions |
|---|---|---|---|---|---|---|---|---|' || -- This query fetches all steps for the selected model and builds the table rows
        (
            SELECT COALESCE(
                    GROUP_CONCAT(
                        '| ' || StepNumber || ' | ' || TargetWeightFormula || ' | ' || TargetSetsFormula || ' | ' || TargetRepsFormula || ' | ' || COALESCE(StepNotes, '') || ' | ' || SuccessCriteriaRPE || ' | ' || COALESCE(FailureCriteriaType, '') || ' | ' || COALESCE(FailureCriteriaValue, '') || ' | [Delete](?model_id=' || ProgressionModelID || '&delete_step_id=' || ProgressionModelStepID || ') |',
                        ''
                    ),
                    '| *No steps defined for this model yet.* |'
                )
            FROM ProgressionModelSteps
            WHERE ProgressionModelID = :model_id
            ORDER BY StepNumber
        ) || '

' || -- Start of the raw HTML form for adding a new step
        '### Add New Step to Model

<form action="view_progression_models.sql?model_id=' || :model_id || '" method="POST">
    <input type="hidden" name="model_id" value="' || :model_id || '">
    <div class="mb-3">
        <label for="new_step_number" class="form-label">Step Number <span class="text-danger">*</span></label>
        <input type="number" class="form-control" id="new_step_number" name="new_step_number" min="1" required>
    </div>
    <div class="mb-3">
        <label for="new_step_target_weight_formula" class="form-label">Target Weight Formula <span class="text-danger">*</span></label>
        <input type="text" class="form-control" id="new_step_target_weight_formula" name="new_step_target_weight_formula" required placeholder="CurrentCycle1RMEstimate * 0.8">
    </div>
    <div class="mb-3">
        <label for="new_step_target_sets_formula" class="form-label">Target Sets Formula <span class="text-danger">*</span></label>
        <input type="text" class="form-control" id="new_step_target_sets_formula" name="new_step_target_sets_formula" required placeholder="3">
    </div>
    <div class="mb-3">
        <label for="new_step_target_reps_formula" class="form-label">Target Reps Formula <span class="text-danger">*</span></label>
        <input type="text" class="form-control" id="new_step_target_reps_formula" name="new_step_target_reps_formula" required placeholder="5">
    </div>
    <div class="mb-3">
        <label for="new_step_notes" class="form-label">Step Notes</label>
        <textarea class="form-control" id="new_step_notes" name="new_step_notes"></textarea>
    </div>
    <div class="mb-3">
        <label for="new_step_success_rpe" class="form-label">Success RPE (e.g., 8) <span class="text-danger">*</span></label>
        <input type="number" class="form-control" id="new_step_success_rpe" name="new_step_success_rpe" min="1" max="10" step="0.5" value="8" required>
    </div>
    <div class="mb-3">
        <label for="new_step_failure_type" class="form-label">Failure Criteria Type (e.g., reverse)</label>
        <input type="text" class="form-control" id="new_step_failure_type" name="new_step_failure_type">
    </div>
    <div class="mb-3">
        <label for="new_step_failure_value" class="form-label">Failure Criteria Value (e.g., 1)</label>
        <input type="text" class="form-control" id="new_step_failure_value" name="new_step_failure_value">
    </div>
    <button type="submit" class="btn btn-primary">Add Step</button>
</form>'
    ) AS properties
WHERE :model_id IS NOT NULL;