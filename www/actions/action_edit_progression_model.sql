/**
 * @filename      action_edit_progression_model.sql
 * @description   A page for creating a new progression model or editing an existing one's high-level details.
 * @created       2025-07-04
 * @requires      - `layouts/layout_main.sql` for the page shell.
 * @requires      - `dimProgressionModel`, `dimProgressionModelStep`, `sessions` tables.
 * @param         id [url, optional] The ID of the progression model to edit. If absent, the page enters "create" mode.
 * @param         action [form] The action to perform (e.g., 'create_model', 'update_details').
 */
-- Step 1: Get current user ID.
SET
    current_user_id=(
        SELECT
            username
        FROM
            sessions
        WHERE
            session_token=sqlpage.cookie ('session_token')
    );

-- Step 2: Handle all incoming POST actions before rendering any page content.
-- Action to CREATE a new progression model.
SET
    new_model_id=HEX(RANDOMBLOB(16));

INSERT INTO
    dimProgressionModel (
        progressionModelId,
        userId,
        modelName,
        modelType,
        description
    )
SELECT
    $new_model_id,
    $current_user_id,
    :model_name,
    :model_type,
    :description
WHERE
    :action='create_model';

-- After creating, redirect to the edit page for the new model.
SELECT
    'redirect' as component,
    FORMAT(
        '/actions/action_edit_progression_model.sql?id=%s',
        $new_model_id
    ) as link
WHERE
    :action='create_model';

-- Action to UPDATE the main model details.
UPDATE dimProgressionModel
SET
    modelName=:model_name,
    modelType=:model_type,
    description=:description
WHERE
    progressionModelId=:id
    AND userId=$current_user_id
    AND :action='update_details';

-- After updating, redirect back to the same edit page to show the changes.
SELECT
    'redirect' as component,
    FORMAT(
        '/actions/action_edit_progression_model.sql?id=%s&message=Model+details+updated.',
        :id
    ) as link
WHERE
    :action='update_details';

-- =============================================================================
-- Page Rendering Logic (only runs on GET requests)
-- =============================================================================
-- Step 3: Load the main layout.
SELECT
    'dynamic' AS component,
    sqlpage.run_sql ('layouts/layout_main.sql') AS properties;

--------------------------------------------------------------------------------
-- "CREATE" MODE RENDER
-- This section renders a simple form if no ID is present in the URL.
--------------------------------------------------------------------------------
SELECT
    'title' as component,
    'Create New Progression Model' as contents,
    3 as level
WHERE
    $id IS NULL;

SELECT
    'form' as component,
    'post' as method
WHERE
    $id IS NULL;

SELECT
    'hidden' as type,
    'action' as name,
    'create_model' as value
WHERE
    $id IS NULL;

SELECT
    'text' as type,
    'model_name' as name,
    'Model Name' as label,
    'E.g., 5x5 Linear Progression' as placeholder,
    TRUE as required,
    6 as width
WHERE
    $id IS NULL;

SELECT
    'select' as type,
    'model_type' as name,
    'Model Type' as label,
    TRUE as required,
    6 as width,
    JSON_ARRAY(
        JSON_OBJECT(
            'label',
            'Weight-Based (uses % of 1RM)',
            'value',
            'weight'
        ),
        JSON_OBJECT(
            'label',
            'Reps-Based (uses % of Max Reps)',
            'value',
            'reps'
        )
    ) as options
WHERE
    $id IS NULL;

SELECT
    'textarea' as type,
    'description' as name,
    'Description' as label,
    'Describe the purpose or methodology of this model.' as placeholder
WHERE
    $id IS NULL;

SELECT
    'button' as component,
    'submit' as type,
    'Create and Edit Model' as title
WHERE
    $id IS NULL;

--------------------------------------------------------------------------------
-- "EDIT" MODE RENDER
-- This section renders the full editor if an ID is present in the URL.
--------------------------------------------------------------------------------
-- Step 5: Fetch all data for the model.
SET
    model=(
        SELECT
            JSON_OBJECT(
                'modelName',
                modelName,
                'modelType',
                modelType,
                'description',
                description
            )
        FROM
            dimProgressionModel
        WHERE
            progressionModelId=$id
            AND userId=$current_user_id
    );

-- Step 6: Display the page header.
SELECT
    'title' as component,
    'Edit Progression Model: '||JSON_EXTRACT($model, '$.modelName') as contents,
    3 as level
WHERE
    $id IS NOT NULL;

-- Step 7: Display the form to edit the main model details.
SELECT
    'form' as component,
    'post' as method,
    'green' as validate_color,
    'Update Model Details' as validate
WHERE
    $id IS NOT NULL;

SELECT
    'hidden' as type,
    'id' as name,
    $id as value
WHERE
    $id IS NOT NULL;

SELECT
    'hidden' as type,
    'action' as name,
    'update_details' as value
WHERE
    $id IS NOT NULL;

SELECT
    'text' as type,
    'model_name' as name,
    'Model Name' as label,
    JSON_EXTRACT($model, '$.modelName') as value,
    6 as width
WHERE
    $id IS NOT NULL;

SELECT
    'select' as type,
    'model_type' as name,
    'Model Type' as label,
    JSON_EXTRACT($model, '$.modelType') as value,
    6 as width,
    JSON_ARRAY(
        JSON_OBJECT('label', 'Weight-Based', 'value', 'weight'),
        JSON_OBJECT('label', 'Reps-Based', 'value', 'reps')
    ) as options
WHERE
    $id IS NOT NULL;

SELECT
    'textarea' as type,
    'description' as name,
    'Description' as label,
    JSON_EXTRACT($model, '$.description') as value
WHERE
    $id IS NOT NULL;

SELECT
    'button' as component,
    'submit' as type,
    'Update Model Details' as title
WHERE
    $id IS NOT NULL;

-- Step 8: Display the table of progression steps.
SELECT
    'divider' as component
WHERE
    $id IS NOT NULL;

SELECT
    'title' as component,
    'Progression Steps' as contents,
    3 as level
WHERE
    $id IS NOT NULL;

SELECT
    'table' as component
WHERE
    $id IS NOT NULL;

SELECT
    stepNumber as "Step",
    description as "Description",
    targetSets as "Sets",
    targetReps as "Reps",
    percentOfMax as "% of Max"
FROM
    dimProgressionModelStep
WHERE
    progressionModelId=$id
    and $id IS NOT NULL
ORDER BY
    stepNumber;

-- Step 9: Display a button to edit the steps in the bulk editor.
SELECT
    'button' as component,
    'md' as size
WHERE
    $id IS NOT NULL;

SELECT
    FORMAT(
        '/actions/action_edit_progression_step.sql?model_id=%s',
        $id
    ) as link,
    'green' as color,
    'Edit Steps in Bulk Editor' as title,
    'edit' as icon
WHERE
    $id IS NOT NULL;
