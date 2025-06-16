# Authentication Flow

This directory contains all the SQL files required for user authentication.

## File Descriptions

-   **`auth_signup_form.sql`**: Displays the new user registration form.
-   **`auth_signup_action.sql`**: Processes the signup form, creates the user, and redirects.
-   **`auth_login_form.sql`**: Displays the login form for existing users.
-   **`auth_login_action.sql`**: Validates credentials, creates a session, sets a cookie, and redirects.
-   **`auth_logout.sql`**: Deletes the user's session and clears the cookie.