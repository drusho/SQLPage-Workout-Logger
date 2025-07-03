---
date: 2025-07-03
title: "SQLPage - Workout - Folder Tree Report"
summary: "An ASCII tree representation of the file and folder structure for the SQLPage - Workout project."
series: sqlpage.workout-logger
github: https://github.com/drusho/SQLPage-Workout-Logger
source: "/Volumes/Public/Container_Settings/sqlpage"
categories: Homelab
tags:
  - sqlpage
  - workout
cssclasses:
  - academia
  - academia-rounded

---
>[!tip]+ Tip
> - This report was auto-generated using the `SQLPage_Workout_Documentation_Generator.ipynb` notebook.
## Directory Tree

```tree
sqlpage/
├── .gitignore
├── README.md
├── assets
│   ├── 2025-06-18-exercise-library.png
│   ├── 2025-06-18-home-page.png
│   ├── 2025-06-18-workouts.png
│   └── custom_form_layout.css
├── backups
│   ├── README.md
│   ├── workouts-2025-06-14.db
│   ├── workouts-2025-06-17.db
│   ├── workouts-2025-06-18.db
│   ├── workouts-2025-06-19.db
│   ├── workouts-2025-06-30.db
│   ├── workouts-backup-2025-06-30_184258.db
│   ├── workouts-backup-2025-06-30_195301.db
│   ├── workouts-backup-2025-07-02_185257.db
│   ├── workouts-backup-2025-07-02_190008.db
│   ├── workouts-backup-2025-07-02_190141.db
│   ├── workouts-backup-2025-07-02_190308.db
│   ├── workouts-backup-2025-07-02_190454.db
│   ├── workouts-backup-2025-07-02_190638.db
│   ├── workouts-backup-2025-07-02_190727.db
│   ├── workouts-backup-2025-07-02_191946.db
│   ├── workouts-backup-2025-07-02_192157.db
│   ├── workouts-backup-2025-07-02_192646.db
│   ├── workouts-backup-2025-07-02_193023.db
│   ├── workouts-backup-2025-07-02_193429.db
│   ├── workouts-backup-2025-07-02_193726.db
│   ├── workouts-backup-2025-07-02_194605.db
│   ├── workouts-backup-2025-07-02_194941.db
│   ├── workouts-backup-2025-07-03_125150.db
│   ├── workouts-backup-2025-07-03_125555.db
│   ├── workouts-backup-2025-07-03_130437.db
│   ├── workouts-backup-2025-07-03_130826.db
│   ├── workouts-backup-2025-07-03_133213.db
│   ├── workouts-backup-2025-07-03_133418.db
│   ├── workouts-backup-2025-07-03_133535.db
│   └── workouts-backup-2025-07-03_133729.db
├── docs
│   ├── App Design & Flow.md
│   ├── Database Management Guide.md
│   ├── Style Guide.md
│   └── changelogs
│       └── 2025-06-17- SQLPage - Workout - Changelog.md
├── maintence
│   ├── README.md
│   ├── maintenance-2025-06-18.sql
│   └── maintenance-2025-06-30.sql
├── migrations
│   ├── 000_migration_template.sql
│   ├── 001_recreate_views.sql
│   ├── 002_add_progression_history.sql
│   ├── 003_add_timezone_to_users.sql
│   ├── 004_create_star_schema_tables.sql
│   ├── 005_populate_dimensions.sql
│   ├── 006_populate_plans_and_facts.sql
│   ├── 007_decommission_old_tables.sql
│   ├── 008_decommision_old_tables_again.sql
│   ├── 009_consolidate_star_schema_migration.sql
│   ├── 010_restore_from_backup.sql
│   ├── 011_add_password_hash_to_dimUser.sql
│   ├── 012_fix_sessions_foreign_key.sql
│   ├── README.md
│   └── migrations_runner_notebook.ipynb
├── notebooks
│   └── SQLPage_Workout_Documentation_Generator.ipynb
├── reports
│   ├── 2025-06-15
│   │   ├── 2025-06-15 - Database Schema Report.md
│   │   ├── 2025-06-15 - Folder Tree Report.md
│   │   └── 2025-06-15 - SQL Comment Documentation.md
│   ├── 2025-06-17
│   │   ├── 2025-06-17 - Database Schema Report.md
│   │   ├── 2025-06-17 - Folder Tree Report.md
│   │   └── 2025-06-17 - SQL Comment Documentation.md
│   ├── 2025-06-18
│   │   ├── 2025-06-18 - Database Schema Report.md
│   │   ├── 2025-06-18 - Folder Tree Report.md
│   │   └── 2025-06-18 - SQL Comment Documentation.md
│   ├── 2025-06-19
│   │   ├── 2025-06-19 - SQLPage - Workout - Database Schema Report.md
│   │   ├── 2025-06-19 - SQLPage - Workout - Folder Tree Report.md
│   │   └── 2025-06-19 - SQLPage - Workout - SQL Comment Documentation.md
│   ├── 2025-06-30
│   │   ├── 2025-06-30 - SQLPage - Workout - Database Schema Report.md
│   │   ├── 2025-06-30 - SQLPage - Workout - Folder Tree Report.md
│   │   └── 2025-06-30 - SQLPage - Workout - SQL Comment Documentation.md
│   ├── 2025-07-02
│   │   ├── 2025-07-02 - SQLPage - Workout - Database Schema Report.md
│   │   ├── 2025-07-02 - SQLPage - Workout - Folder Tree Report.md
│   │   └── 2025-07-02 - SQLPage - Workout - SQL Comment Documentation.md
│   └── 2025-07-03
│       └── 2025-07-03 - SQLPage - Workout - Database Schema Report.md
├── schema
│   ├── README.md
│   ├── _migrations.yml
│   ├── dimDate.yml
│   ├── dimExercise.yml
│   ├── dimExercisePlan.yml
│   ├── dimUser.yml
│   ├── dimUserExercisePreferences.yml
│   ├── factWorkoutHistory.yml
│   └── sessions.yml
└── www
    ├── actions
    │   ├── action_add_exercise.sql
    │   ├── action_add_workout.sql
    │   ├── action_delete_exercise.sql
    │   ├── action_delete_history.sql
    │   ├── action_edit_exercise.sql
    │   ├── action_edit_history.sql
    │   ├── action_edit_workout.sql
    │   ├── action_get_workout_template.sql
    │   ├── action_save_workout.sql
    │   └── action_update_profile.sql
    ├── admin
    │   ├── admin_debug_user.sql
    │   └── admin_reset_admin_password.sql
    ├── assets
    ├── auth
    │   ├── README.md
    │   ├── auth_guest_prompt.sql
    │   ├── auth_login_action.sql
    │   ├── auth_login_form.sql
    │   ├── auth_logout.sql
    │   ├── auth_signup_action.sql
    │   └── auth_signup_form.sql
    ├── dev
    │   ├── dev_action_save_workout.sql
    │   ├── dev_debug_template_id.sql
    │   ├── dev_multi-step_form.sql
    │   ├── dev_update.sql
    │   ├── dev_view_workouts.sql
    │   └── dev_workouts_print_log.sql
    ├── index.sql
    ├── layouts
    │   ├── layout_guest_menu.sql
    │   ├── layout_main.sql
    │   ├── layout_non-auth.sql
    │   └── layout_user_menu.sql
    ├── sqlpage
    │   ├── sqlpage.json
    │   └── templates
    │       ├── form.handlebars
    │       ├── form_select.handlebars
    │       └── split_name.handlebars
    ├── views
    │   ├── view_exercises.sql
    │   ├── view_history.sql
    │   ├── view_profile.sql
    │   ├── view_progression_models.sql
    │   ├── view_workout_logs.sql
    │   └── view_workouts.sql
    └── workouts.db
```