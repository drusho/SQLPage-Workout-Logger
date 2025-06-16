---
date: 2025-06-15
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
├── backups
│   ├── README.md
│   └── workouts-2025-06-14.db
├── migrations
│   └── README.md
├── notebooks
│   └── SQLPage_Workout_Documentation_Generator.ipynb
├── reports
│   ├── 2025-06-15 - SQLPage - Workout - Database Schema Report.md
│   ├── 2025-06-15 - SQLPage - Workout - Folder Tree Report.md
│   └── 2025-06-15 - SQLPage - Workout - SQL Comment Documentation.md
└── www
    ├── actions
    │   ├── action_add_exercise.sql
    │   ├── action_delete_exercise.sql
    │   ├── action_edit_exercise.sql
    │   ├── action_save_workout.sql
    │   └── action_update_profile.sql
    ├── auth
    │   ├── README.md
    │   ├── auth_login_action.sql
    │   ├── auth_login_form.sql
    │   ├── auth_logout.sql
    │   ├── auth_signup_action.sql
    │   └── auth_signup_form.sql
    ├── dev
    │   ├── dev_multi-step_form.sql
    │   ├── dev_update.sql
    │   └── dev_workouts_print_log.sql
    ├── index.sql
    ├── layouts
    │   ├── layout_main.sql
    │   └── layout_non-auth.sql
    ├── profile.sql
    ├── sqlpage
    │   ├── sqlpage.json
    │   └── templates
    │       ├── form.handlebars
    │       ├── form_select.handlebars
    │       └── split_name.handlebars
    ├── views
    │   ├── view_exercises.sql
    │   ├── view_history.sql
    │   ├── view_progression_models.sql
    │   └── view_workout_logs.sql
    └── workouts.db
```