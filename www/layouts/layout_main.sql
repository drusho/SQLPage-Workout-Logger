/**
 * @filename      layout_main.sql
 * @description   The main application shell. Shows a full navigation menu to all users
 * to allow for guest exploration.
 * @last-updated  2025-06-18
 * @note          Guest access is enabled for all users. Database write actions are handled
 * by individual action scripts.
 */
------------------------------------------------------
-- STEP 1: Identify the current user
------------------------------------------------------
SET current_user_name = (
        SELECT username
        FROM sessions
        WHERE session_token = sqlpage.cookie('session_token')
            AND expires_at > CURRENT_TIMESTAMP
    );
SET current_display_name = (
        SELECT display_name
        FROM users
        WHERE username = $current_user_name
    );
------------------------------------------------------
-- STEP 2: DEFINE THE MAIN PAGE LAYOUT
------------------------------------------------------
SELECT 'shell' as component,
    $current_display_name as title,
    -- 'description' as description,
    'Workout Logger' as navbar_title,
    -- '/assets/form_actions.css' as css,
    'barbell' as icon,
    '/' as link,
    TRUE as sidebar,
    'dark' as sidebar_theme,
    'fluid' as layout,
    'en-US' as language,
    '[Built with SQLPage](https://github.com/sqlpage/SQLPage/tree/main/examples/official-site)' as footer,
    ------------------------------------------------------    
    -- STEP 3: UNIFIED NAVIGATION MENU
    -- The menu is now the same for guests and logged-in users.
    ------------------------------------------------------    
    json_array(
        json_object(
            'title',
            'Log',
            'link',
            '/index.sql',
            'icon',
            'clipboard-text'
        ),
        json_object(
            'title',
            'Exercises',
            'link',
            '/views/view_exercises.sql',
            'icon',
            'book'
        ),
        json_object(
            'title',
            ' Workouts',
            'link',
            '/views/view_workouts.sql',
            'icon',
            'weight'
        ),
        json_object(
            'title',
            'History',
            'link',
            '/views/view_history.sql',
            'icon',
            'history'
        ),
        json_object(
            'title',
            'Progression',
            'link',
            '/views/view_progression_models.sql ',
            'icon',
            'trending-up'
        ),
        json_object(
            'title',
            'Profile',
            'link',
            '/views/view_profile.sql',
            'icon',
            'user-circle'
        ),
        json_object(
            'title',
            'Logout',
            'link',
            '/auth/auth_logout.sql',
            'icon',
            'logout'
        )
    ) as menu_item,
    ------------------------------------------------------
    -- STEP 4: USER WELCOME MESSAGE
    ------------------------------------------------------
    json_object(
        'title',
        'Welcome: ' || COALESCE($current_display_name, 'Guest'),
        'link',
        '/profile.sql'
    ) as user;
-- /**
--  * @filename      layout_main.sql
--  * @description   The main application shell, included on most pages to provide a consistent
--  * layout, navigation menu, and site-wide authentication. It dynamically
--  * adjusts the navigation menu and welcome message based on the user' s login status.--  * @created       2025-06-14
--  * @last-updated  2025-06-15
--  * @requires      - The `sessions` table to identify the logged-in user.
--  * @requires      - The `users` table to fetch the user's display name.
--  * @param         sqlpage.cookie('session_token') [cookie, optional] The session token used
--  * to identify the user. If absent or invalid, the user is treated as a guest.
--  * @returns       A `shell` component that wraps the content of the calling page, providing
--  * the overall page structure, header, and a dynamic sidebar menu. May also
--  * return an `authentication` component to force login.
--  * @see           - `index.sql` - An example of a page that uses this layout.
--  * @note          Features conditional authentication: users on the local network (192.168.x.x)
--  * can browse as guests, while external users are required to log in.
--  * @todo          - Consider moving the navigation menu structure into a database table to allow
--  * for dynamic menu management without editing this SQL file.
--  */
-- ------------------------------------------------------
-- -- STEP 1: Identify the current user and their display name, if they are logged in.
-- -- We store these in variables to safely reuse them throughout the script.
-- ------------------------------------------------------
-- SET current_user_name = (
--         SELECT username
--         FROM sessions
--         WHERE session_token = sqlpage.cookie('session_token')
--             AND expires_at > CURRENT_TIMESTAMP
--     );
-- SET current_display_name = (
--         SELECT display_name
--         FROM users
--         WHERE username = $current_user_name
--     );
-- ------------------------------------------------------
-- -- STEP 2:CONDITIONAL AUTHENTICATION
-- -- This check now simply uses the variable we defined above.
-- ------------------------------------------------------
-- SELECT 'authentication' as component,
--     'auth/auth_login_form.sql' as link
-- WHERE sqlpage.client_ip() NOT LIKE '192.168.%' -- User is external
--     AND $current_user_name IS NULL;
-- ------------------------------------------------------
-- -- STEP 3: DEFINE THE MAIN PAGE LAYOUT
-- ------------------------------------------------------
-- SELECT 'shell' as component,
--     'Workout Logger' as title,
--     'barbell' as icon,
--     '/' as link,
--     true as sidebar,
--     'boxed' as layout,
--     'en-US' as language,
--     '[Built with SQLPage](https://github.com/sqlpage/SQLPage/tree/main/examples/official-site)' as footer,
--     ------------------------------------------------------    
--     -- STEP 4: DYNAMIC NAVIGATION MENU
--     ------------------------------------------------------    
--     CASE
--         -- If a user is logged in ($current_user_name is not empty), show the full menu.
--         WHEN $current_user_name IS NOT NULL THEN json_array(
--             json_object(
--                 'title',
--                 'Log',
--                 'link',
--                 '/index.sql',
--                 'icon',
--                 'clipboard-text' 
--             ),
--             json_object(
--                 'title',
--                 'Exercises',
--                 'link',
--                 '/views/view_exercises.sql',
--                 'icon',
--                 'book' 
--             ),
--             json_object(
--                 'title',
--                 'Workouts',
--                 'link',
--                 '/views/view_workouts.sql',
--                 'icon',
--                 'weight' 
--             ),            
--             json_object(
--                 'title',
--                 'History',
--                 'link',
--                 '/views/view_history.sql',
--                 'icon',
--                 'history' 
--             ),
--             json_object(
--                 'title',
--                 'Progression',
--                 'link',
--                 '/views/view_progression_models.sql',
--                 'icon',
--                 'trending-up'
--             ),
--             json_object(
--                 'title',
--                 'Profile',
--                 'link',
--                 '/profile.sql',
--                 'icon',
--                 'user-circle' 
--             ),
--             json_object(
--                 'title',
--                 'Logout',
--                 'link',
--                 '/auth/auth_logout.sql',
--                 'icon',
--                 'logout'
--             )
--         ) -- Otherwise, show the guest menu.
--         ELSE json_array(
--             json_object(
--                 'title',
--                 'Login',
--                 'link',
--                 '/auth/auth_login_form.sql',
--                 'icon',
--                 'login'
--             ),
--             json_object(
--                 'title',
--                 'Signup',
--                 'link',
--                 '/auth/auth_signup_form.sql',
--                 'icon',
--                 'user-plus'
--             )
--         )
--     END as menu_item,
--     ------------------------------------------------------
--     -- STEP 5: USER WELCOME MESSAGE
--     -- This now safely uses the variable we defined at the top.
--     ------------------------------------------------------
--     json_object(
--         'title',
--         'Welcome, ' || COALESCE($current_display_name, 'Guest'),
--         'link',
--         '/profile.sql'
--     ) as user;
-- --------------------
-- -- Page examples
-- --------------------
-- -- JSON(
-- --     '{
-- --         "title":"Documentation",
-- --         "submenu":
-- --             [
-- --                 {
-- --                 "link":"/your-first-sql-website",
-- --                 "title":"Getting started",
-- --                 "icon":"book"
-- --                 },
-- --                 {
-- --                 "link":"/components.sql",
-- --                 "title":"All Components",
-- --                 "icon":"list-details"},
-- --                 {
-- --                 "link":"/functions.sql",
-- --                 "title":"SQLPage Functions",
-- --                 "icon":"math-function"
-- --                 },
-- --                 {
-- --                 "link":"/extensions-to-sql",
-- --                 "title":"Extensions to SQL",
-- --                 "icon":"cube-plus"
-- --                 },
-- --                 {
-- --                 "link":"/custom_components.sql",
-- --                 "title":"Custom Components",
-- --                 "icon":"puzzle"
-- --                 },
-- --                 {
-- --                 "link":"//github.com/sqlpage/SQLPage/blob/main/configuration.md#configuring-sqlpage",
-- --                 "title":"Configuration",
-- --                 "icon":"settings"
-- --                 }   
-- --             ]
-- --     }'
-- -- ) as menu_item,