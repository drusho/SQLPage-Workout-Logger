-- Migration: 010_add_password_hash_to_dimUser
-- Description: Adds a passwordHash column to the dimUser table to store
-- securely hashed user passwords for authentication.
ALTER TABLE dimUser
ADD COLUMN passwordHash TEXT;
