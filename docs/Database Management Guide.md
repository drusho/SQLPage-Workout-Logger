# Database Management Guide
updated: 2025-06-19


> [!NOTE] A Living Document for a Healthy Database
> 
> This guide outlines the official procedures for managing the application's database. Its purpose is to ensure data integrity, prevent data loss, and allow the schema to evolve safely over time. Following these procedures is crucial for the long-term stability of the project.

</br>

## At a Glance: Key Directories

A healthy database relies on an organized structure. Here are the key directories you need to know:


</br>

| **Directory**         | **Purpose**                                               | **Managed By**            |
| --------------------- | --------------------------------------------------------- | ------------------------- |
| 📂 `backups/`         | Stores timestamped, safe copies of the database.          | Python Script             |
| 📂 `maintenance/`     | Contains scripts for performance tuning and optimization. | Developer (Manual)        |
| 📂 `migrations/`      | Contains scripts for changing the database structure.     | Developer & Python Script |
| 🗃️ `www/workouts.db` | **The live, production database file.**                   | **The Application**       |

</br>

## 1. Schema Migrations: Changing the Structure

This is the process for making structural changes to the database, like adding a table or a column.

</br>

> [!TIP] The Migration Workflow
> 
> 1. **Create a new `.sql` script** in the `/migrations` folder (use `000_migration_template.sql` as a starting point).
>     
> 2. **Run the `migration_runner_notebook.ipynb`**.
>     
> 
> For detailed instructions, see the **[migrations/README.md](https://github.com/drusho/SQLPage-Workout-Logger/blob/master/migrations/README.md)**.



</br>

> [!TIP] 
> The Python runner script automatically handles backups and ensures migrations only run once. This prevents most common database errors.

</br>


## 2. Database Maintenance: Keeping it Fast

Maintenance focuses on the _health and performance_ of the existing database structure. It does not change the schema.

</br>

> [!NOTE] When and Why?
> 
> The maintenance.sql script cleans up the database file, rebuilds indexes, and optimizes the query planner. It's best to run it after deleting a lot of data or if the app feels sluggish.
> 
> For more details, see the **[[maintenance/README.md]]**.

</br>

## 3. Backup & Restore: The Safety Net

This strategy ensures we can always recover from a disaster.

### Backup Strategy

|   |   |   |
|---|---|---|
|**Backup Type**|**Trigger**|**Location**|
|**Automated**|Running the `migration_runner_notebook.ipynb`|`/backups`|
|**Manual**|Before any major, non-standard operation|`/backups` or off-site|

</br>

### Disaster Recovery

> [!WARNING] How to Restore From a Backup
> 
> Use this procedure only if the main database is corrupt or has suffered catastrophic data loss.
> 
> 1. **Stop the Application:** Ensure nothing is trying to access the database.
> 2. **Rename the Bad File:** Rename the broken `www/workouts.db` to `workouts.db.BROKEN`. **Do not delete it immediately.**
> 3. **Copy the Backup:** Find the desired backup file from the `/backups` folder and copy it into the `www/` directory.
> 4. **Rename the Copy:** Rename the copied backup file to `workouts.db`.
> 5. **Restart and Verify:** Start the application and thoroughly check that the data and functionality have been restored as expected.
> 6. **Clean Up:** Once you are 100% certain the restore was successful, you can delete the `workouts.db.BROKEN` file.
>