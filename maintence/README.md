# Database Maintenance

This folder contains scripts for routine database maintenance and optimization. These scripts are not for changing the database schema (like adding tables or columns) but for keeping the existing database healthy and performant.

## `maintenance.sql`

This is the primary script for database upkeep. It should be run periodically to ensure the database remains efficient.

### What This Script Does

The script performs several key operations:
1. **`VACUUM`**: Rebuilds the entire database file to clean up unused space from deleted data. This reduces the file size and can improve data access speed.
2. **`REINDEX`**: Deletes and rebuilds all indexes. This is useful for optimizing indexes that have become fragmented over time.
3. **`ANALYZE`**: Gathers up-to-date statistics about the tables and indexes. The query planner uses these statistics to execute queries more efficiently.
4. **Rebuilds Views**: The script drops and recreates all application views (`FullWorkoutHistory`, `UserExerciseProgressionTargets`, `WorkoutTemplateDetails`). This ensures they are always in a correct and optimal state.
    

### When to Run This Script

This script does not need to be run frequently. Good times to run it are:
- After deleting a large amount of data.
- If you notice the application becoming generally sluggish over time.
- As part of a scheduled routine (e.g., once a month or every few months).
    
### How to Run This Script

You can execute this script directly against your `workouts.db` database using a SQLite command-line tool or a GUI like DB Browser for SQLite.

### Important Distinction: Maintenance vs. Migrations
- **Maintenance (This Folder):** Focuses on the _health and performance_ of the existing database structure. It is safe to run `maintenance.sql` at any time.
- **Migrations (`/migrations` folder):** Focuses on _changing the structure_ of the database itself. Migrations are run once, in a specific order, using the `migration_runner_notebook.ipynb` to apply schema changes.
    

> [!WARNING]
> **Do not** treat the maintenance script as a migration.