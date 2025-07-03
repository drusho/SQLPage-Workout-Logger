-- Migration: 011_fix_sessions_foreign_key
-- Description: Rebuilds the 'sessions' table to update its foreign key to
-- point to the new dimUser(userId) column, ensuring referential integrity
-- with the new schema.
PRAGMA foreign_keys = OFF;

-- Step 1: Create a new sessions table with the correct foreign key
CREATE TABLE IF NOT EXISTS sessions_new (
    session_token TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (username) REFERENCES dimUser (userId) ON DELETE CASCADE
);

-- Step 2: Copy all existing sessions from the old table to the new one
INSERT INTO
    sessions_new (session_token, username, expires_at)
SELECT
    session_token,
    username,
    expires_at
FROM
    sessions;

-- Step 3: Drop the old, outdated sessions table
DROP TABLE sessions;

-- Step 4: Rename the new table to take its place
ALTER TABLE sessions_new
RENAME TO sessions;

PRAGMA foreign_keys = ON;
