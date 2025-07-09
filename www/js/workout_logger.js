// www/js/workout_logger.js

document.addEventListener("DOMContentLoaded", function () {
  // Find the main workout logging form by its new ID
  const logForm = document.getElementById("log-performance-form");
  if (!logForm) return;

  logForm.addEventListener("submit", function (event) {
    // Prevent the default form submission which causes a page reload
    event.preventDefault();

    const formData = new FormData(logForm);
    const actionUrl = logForm.getAttribute("action");

    // 1. Save the new workout data in the background
    fetch(actionUrl, {
      method: "POST",
      body: formData,
    })
      .then((response) => {
        if (!response.ok) throw new Error("Failed to save workout.");

        // 2. After a successful save, fetch the updated list of recent workouts
        return fetch("/api/api_recent_workouts.sql");
      })
      .then((response) => response.json())
      .then((data) => {
        // 3. Update the "Recent Workouts" section on the page with the new data
        updateRecentWorkouts(data);
        logForm.reset(); // Optional: clear the form fields after successful submission
      })
      .catch((error) => console.error("Error logging workout:", error));
  });

  // Also fetch workouts on initial page load
  fetch("/api/api_recent_workouts.sql")
    .then((response) => response.json())
    .then((data) => updateRecentWorkouts(data));
});

function updateRecentWorkouts(data) {
  const container = document.getElementById("recent-workouts-container");
  if (!container) return;

  let tableHtml = "<h3>Recent Activity</h3>";
  if (data.length === 0) {
    tableHtml += "<p>No workouts logged yet.</p>";
    container.innerHTML = tableHtml;
    return;
  }

  tableHtml +=
    '<table class="table table-striped table-sm"><thead><tr><th>Date</th><th>Exercise</th><th>Sets</th></tr></thead><tbody>';
  data.forEach((item) => {
    tableHtml += `<tr><td>${item.Date}</td><td>${item.Exercise}</td><td>${item.Sets}</td></tr>`;
  });
  tableHtml += "</tbody></table>";

  container.innerHTML = tableHtml;
}

// This new function will handle the real-time 1RM calculation
function initialize1RMCalculator() {
  const repsInput = document.querySelector('input[name="reps_1"]');
  const weightInput = document.querySelector('input[name="weight_1"]');
  const est1rmInput = document.getElementById("est_1rm_input");

  // If any of the required fields don't exist on the page, do nothing.
  if (!repsInput || !weightInput || !est1rmInput) {
    return;
  }

  const calculate1RM = () => {
    const reps = parseFloat(repsInput.value);
    const weight = parseFloat(weightInput.value);

    // Only calculate if we have valid numbers for both reps and weight
    if (reps > 0 && weight > 0) {
      // Epley formula: 1RM = Weight * (1 + (Reps / 30))
      const estimated1RM = weight * (1 + reps / 30);
      // Update the Est. 1RM field, rounded to one decimal place
      est1rmInput.value = estimated1RM.toFixed(1);
    }
  };

  // Add event listeners to re-calculate whenever the user types in the fields
  repsInput.addEventListener("input", calculate1RM);
  weightInput.addEventListener("input", calculate1RM);
}

// Ensure the calculator is initialized after the main page content is loaded
// and also after our AJAX calls update the page.
document.addEventListener("DOMContentLoaded", initialize1RMCalculator);

// We can also call this function inside the success promise of your
// existing AJAX form submission if needed, to re-bind events.
// For now, DOMContentLoaded is sufficient.
