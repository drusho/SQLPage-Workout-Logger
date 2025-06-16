# Database Backups

This folder is the destination for automated database backups.

## Process

A scheduled task (`cron` job) on the host system runs nightly to copy the live `workouts.db` file into this directory, appending the current date to the filename.

**Example Command:**
`cp /path/to/project/www/workouts.db /path/to/project/backups/workouts-YYYY-MM-DD.db`

## How to Restore

1.  Stop the SQLPage Docker container.
2.  Copy the desired backup file from this folder.
3.  Paste it into the `www/` directory and rename it to `workouts.db`, replacing the corrupted file.
4.  Restart the SQLPage container.