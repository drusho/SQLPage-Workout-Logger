// www/js/workout_logger.js

document.addEventListener('DOMContentLoaded', function () {
    const logForm = document.getElementById('modal-log-form');
    if (!logForm) return;

    // Listen for the form submission inside the modal
    logForm.addEventListener('submit', function (event) {
        // Prevent the default form submission which causes a page reload
        event.preventDefault();

        const formData = new FormData(logForm);
        const actionUrl = logForm.getAttribute('action');
        
        // 1. Save the new workout data in the background
        fetch(actionUrl, {
            method: 'POST',
            body: formData,
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            // After a successful save, close the modal
            // This depends on the modal's implementation; this line clicks the close button.
            document.querySelector('#log-workout-modal .btn-close').click();
            // 2. Fetch the updated list of recent workouts
            return fetch('/api/api_recent_workouts.sql');
        })
        .then(response => response.json())
        .then(data => {
            // 3. Update the "Recent Workouts" section on the page with the new data
            updateRecentWorkouts(data);
        })
        .catch(error => {
            console.error('There was a problem with your fetch operation:', error);
        });
    });
});

function updateRecentWorkouts(data) {
    const container = document.getElementById('recent-workouts-container');
    if (!container) return;

    // Clear the existing list
    container.innerHTML = '<h3>Recent Workouts</h3>';

    if (data.length === 0) {
        container.innerHTML += '<p>No workouts logged yet.</p>';
        return;
    }

    // Create a new table and populate it with the fresh data
    const table = document.createElement('table');
    table.className = 'table table-striped table-sm';
    
    const thead = `<thead><tr><th>Date</th><th>Exercise</th><th>Sets</th></tr></thead>`;
    table.innerHTML = thead;

    const tbody = document.createElement('tbody');
    data.forEach(item => {
        const row = document.createElement('tr');
        row.innerHTML = `<td>${item.Date}</td><td>${item.Exercise}</td><td>${item.Sets}</td>`;
        tbody.appendChild(row);
    });

    table.appendChild(tbody);
    container.appendChild(table);
}