# Database Migrations

This folder contains a chronological history of all changes made to the database schema. Each file represents a single, atomic change.

## Naming Convention

Files should be named with a leading, zero-padded number to ensure they are always listed in the correct order of execution.

- `001_create_initial_tables.sql`
- `002_add_bio_to_users.sql`

## How to Use

When a change to the database structure is required (e.g., adding a column with `ALTER TABLE`), create a **new**, numbered SQL script in this directory. **Do not** modify old migration files.
