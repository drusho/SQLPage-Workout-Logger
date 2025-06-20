---
date: 2025-06-19
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
│   └── 2025-06-18-workouts.png
├── backups
│   ├── README.md
│   ├── workouts-2025-06-14.db
│   ├── workouts-2025-06-17.db
│   └── workouts-2025-06-18.db
├── docs
│   ├── App Design & Flow.md
│   ├── Database Management Guide.md
│   ├── Style Guide.md
│   └── changelogs
│       └── 2025-06-17- SQLPage - Workout - Changelog.md
├── maintence
│   ├── README.md
│   └── maintenance.sql
├── migrations
│   ├── 000_migration_template.sql
│   ├── 001_recreate_views.sql
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
│   └── 2025-06-19
│       └── 2025-06-19 - SQLPage - Workout - Database Schema Report.md
└── www
    ├── actions
    │   ├── action_add_exercise.sql
    │   ├── action_add_workout.sql
    │   ├── action_delete_exercise.sql
    │   ├── action_edit_exercise.sql
    │   ├── action_edit_workout.sql
    │   ├── action_get_workout_template.sql
    │   ├── action_save_workout.sql
    │   └── action_update_profile.sql
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
    │   ├── dev_debug_template_id.sql
    │   ├── dev_multi-step_form.sql
    │   ├── dev_update.sql
    │   └── dev_workouts_print_log.sql
    ├── index.sql
    ├── layouts
    │   ├── layout_main.sql
    │   └── layout_non-auth.sql
    ├── sqlpage
    │   ├── sqlpage.json
    │   └── templates
    │       ├── form.handlebars
    │       ├── form_select.handlebars
    │       └── split_name.handlebars
    ├── views
    │   ├── dev_view_workouts.sql
    │   ├── view_exercises.sql
    │   ├── view_history.sql
    │   ├── view_profile.sql
    │   ├── view_progression_models.sql
    │   ├── view_workout_logs.sql
    │   └── view_workouts.sql
    └── workouts.db
```