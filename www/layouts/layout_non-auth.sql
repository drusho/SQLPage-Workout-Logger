/**
 * @filename      layout_non-auth.sql
 * @description   A simplified layout shell for development and testing purposes. It provides
 * the standard application `shell` and a full, authenticated-user navigation
 * menu, but *without* any of the authentication checks or dynamic logic
 * found in `layout_main.sql`. This is useful for testing individual
 * pages without being redirected to a login screen.
 * @created       2025-06-15
 * @last-updated  2025-06-15
 * @returns       A `shell` component containing a hardcoded title and the static navigation
 * menu for an authenticated user.
 * @see           - `layout_main.sql` - The production layout this script is a simplified
 * version of.
 * @note          This layout is intended ONLY for development and is not for production use.
 * It does not perform any authentication checks.
 */
------------------------------------------------------
-- STEP 1: DEFINE THE SHELL LAYOUT This only runs if 
-- the authentication check above passes.
------------------------------------------------------    
SELECT
    'shell' as component,
    'Workout Logger' as title,
    'barbell' as icon,
    '/' as link,
    true as sidebar,
    JSON_ARRAY(
        JSON_OBJECT(
            'title',
            'Log',
            'link',
            '/index.sql',
            'icon',
            'home'
        ),
        JSON_OBJECT(
            'title',
            'Exercises',
            'link',
            '/view_exercises.sql',
            'icon',
            'weight'
        ),
        JSON_OBJECT(
            'title',
            'History',
            'link',
            '/view_workout_logs.sql',
            'icon',
            'edit'
        ),
        JSON_OBJECT(
            'title',
            'Progression',
            'link',
            '/view_progression_models.sql',
            'icon',
            'trending-up'
        ),
        JSON_OBJECT(
            'title',
            'Profile',
            'link',
            '/profile.sql',
            'icon',
            'person'
        ),
        JSON_OBJECT(
            'title',
            'Logout',
            'link',
            '/auth_logout.sql',
            'icon',
            'log-out'
        )
    ) as menu_item;