# Database Migrations

This folder contains a chronological history of all changes made to the database schema. Each file represents a single, atomic change. The migration process is managed by a Python notebook (migration_runner_notebook.ipynb) to ensure changes are applied safely and reliably.

## Naming Convention

Files should be named with a leading, zero-padded number to ensure they are always listed in the correct order of execution.

- `001_create_initial_tables.sql`
- `002_add_bio_to_users.sql`

## Migration Workflow
When a change to the database structure is required (e.g., adding a column with `ALTER TABLE`), follow these steps:

**1. Create a New Migration Script**
- **Copy the Template:** Make a copy of the `000_migration_template.sql` file.
- **Rename the File:** Rename the copy with the next sequential number to maintain chronological order. The name should be descriptive.
    - Good: `006_add_theme_to_user_preferences.sql`
    - Bad: `update.sql`
- **Edit the SQL:** Open your new file and add your `ALTER TABLE`, `CREATE TABLE`, etc., statements in the "SCHEMA CHANGES" section. The template already includes the critical final step of rebuilding all application views.

**2. Run the Migration Notebook**
- **Open the Runner:** Open the `migration_runner_notebook.ipynb` file in a Jupyter environment.
- **Execute All Cells:** Run all cells in the notebook from top to bottom.
The Python script will automatically handle the rest of the process.

## Key Safety Features
The Python runner script provides several critical safety features that are not available with pure SQL:
- **Automated Backups:** Before running any migrations, the script automatically creates a timestamped backup of the workouts.db file in the `/backups` directory.
- **Idempotency:** The script creates and maintains a `_migrations` table in the database to track which scripts have already been applied. It will never run the same script twice.
- **Transactional Integrity:** Each `.sql` file is executed within a database transaction. If any command in the script fails, the entire set of changes is automatically rolled back, preventing a partially migrated, broken database.




  
