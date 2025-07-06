-- Migration: 014_add_notes_to_history
-- Description: Adds a 'notes' column to the factWorkoutHistory table to allow
-- users to save notes with their workout logs.
ALTER TABLE factWorkoutHistory
ADD COLUMN notes TEXT;