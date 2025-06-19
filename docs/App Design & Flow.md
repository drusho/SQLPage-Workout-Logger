
# App Design & Flow

Updated: 2025-06-16

### 1. Dashboard (Log Workout)

- **File:** `index.sql`
- **Purpose:** This is the main page of your app. Its only job is to allow the user to log a workout for the current day.
- **Features:**
    - It should display a list of **enabled Workouts** for the user to choose from.
    - Once a workout is selected, the page should show the user their target sets, reps, and weight for that day, based on their current progress in that workout's progression model.
    - A simple form to enter the actual results (reps, weight, RPE, etc.) and save the log entry.

### 2. My Workouts

- **File:** `/views/view_workouts.sql`
- **Purpose:** This is the central hub for managing the list of workouts the user wants to track. This is where they build their routine.
- **Features:**
    - Lists all of the user's created workouts.
    - Each item in the list shows the exercise, the progression model, and the custom alias (e.g., "Main Squat Day").
    - Has a toggle or button to **enable/disable** a workout, which controls whether it appears on the Dashboard for logging.
- **Actions:** This page will have buttons that link to:
    - `add_workout.sql`: To create a new workout.
    - `edit_workout.sql`: To change a workout's alias or progression model.
    - `delete_workout.sql`: To remove a workout from the list.

### 3. Exercise Library

- **File:** `/views/view_exercises.sql`
- **Purpose:** This is a pure library management tool. It is not for workout customization, but for managing the master list of all possible exercises.
- **Features:** We have already built this page. It correctly lists all exercises and links to the pages for adding, editing, and deleting them.

### 4. Progression Models

- **File:** `/views/view_progression_models.sql`
- **Purpose:** A library management tool for creating and fine-tuning the logic for your progression models and their steps.
- **Features:** This page should allow a user to see all their progression models and provide actions to add, edit, or delete them.

### 5. Profile

- **File:** `/profile.sql`
- **Purpose:** Allows the user to view and update their personal information, like display name and bio.

---

## Visual Page Flow

Here is how a user would navigate through the app with this design:

```
Workout Logger
├── Log Workout 
├── Exercises
│   └── Add/Edit/Delete Exercise
├── Workouts
│   └── Add/Edit/Delete Workout
├── Progression Models
│   └── Add/Edit/Delete Models
└── Profile
    └── View/Edit Profile
```
