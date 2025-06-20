/**
 * @filename      dev_action_save_workout.sql
 * @description   A debugging page to receive and display form submissions from 'index.sql'.
 * It renders a simple table showing the variable names and submitted values. This is
 * useful for ensuring that the dynamic form in index.sql is passing the correct data.
 * @created       2025-06-19
 * @last-updated  2025-06-19
 * @requires      - index.sql: The page that contains the workout logging form that submits to this page.
 * @param         template_id [form] The ID of the workout template being followed.
 * @param         exercise_id [form] The ID of the exercise being logged.
 * @param         num_sets [form] The total number of sets submitted.
 * @param         notes_recorded [form, optional] User-provided notes for the workout.
 * @param         rpe_recorded [form] The user's Rate of Perceived Exertion.
 * @param         reps_1, weight_1, ... [form] Dynamically named fields for each set's reps and weight.
 * @returns       A UI page containing a table that lists all received form parameters and their values.
 * @see           - /index.sql: The page that submits data to this debug script.
 * @see           - /actions/action_save_workout.sql: The production script this debug page mimics.
 * @note          This is a developer tool and is not part of the main application flow. Its purpose is
 * solely for testing form submissions. It does not write any data to the database.
 */
------------------------------------------------------
-- STEP 1: Render Page Skeleton
-- Includes the main layout to provide a consistent look and feel with the rest of the application,
-- including the navigation menu and user authentication state.
------------------------------------------------------
SELECT 'dynamic' AS component,
    sqlpage.run_sql('layouts/layout_main.sql') AS properties;
------------------------------------------------------
-- STEP 2: Display Page Title & Description
-- Sets the main title for the page and creates a table component with a helpful
-- description of the page's purpose.
------------------------------------------------------
SELECT 'title' as component,
    'Form Submission Debug Page' as contents;
SELECT 'table' as component,
    'This page displays the values submitted in the form for debugging purposes.' as description;
------------------------------------------------------
-- STEP 3: Display Submitted Form Values
-- Each SELECT statement that follows reads a specific named parameter from the form
-- submission (`:parameter_name`) and displays it as a new row in the table defined above.
-- This creates a clear, two-column view of all received data.
------------------------------------------------------
-- Static and hidden values passed from the form
SELECT "template_id" as "variable",
    :template_id as 'value';
SELECT "exercise_id" as "variable",
    :exercise_id as 'value';
SELECT "notes_recorded" as "variable",
    :notes_recorded as 'value';
SELECT "num_sets" as "variable",
    :num_sets as 'value';
SELECT "rpe_recorded" as "variable",
    :rpe_recorded as 'value';
-- Dynamically generated values for each set
-- NOTE: You can copy and paste these blocks to debug more sets if needed.
SELECT "reps_1" as "variable",
    :reps_1 as 'value';
SELECT "weight_1" as "variable",
    :weight_1 as 'value';
SELECT "reps_2" as "variable",
    :reps_2 as 'value';
SELECT "weight_2" as "variable",
    :weight_2 as 'value';
SELECT "reps_3" as "variable",
    :reps_3 as 'value';
SELECT "weight_3" as "variable",
    :weight_3 as 'value';
SELECT "reps_4" as "variable",
    :reps_4 as 'value';
SELECT "weight_4" as "variable",
    :weight_4 as 'value';