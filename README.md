# SQLPage Workout Logger
<p align="center">
  <a href="https://sql.ophir.dev/" target="_blank"><img src="https://img.shields.io/badge/SQLPage-v0.20.1+-orange?style=for-the-badge" alt="SQLPage"></a>
  <img src="https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54" alt="Python">
  <a href="https://jupyter.org/" target="_blank"><img src="https://img.shields.io/badge/Jupyter-F37626?style=for-the-badge&logo=jupyter&logoColor=white" alt="Jupyter Notebook"></a>
  <img src="https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite">
  <img src="https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
</p>
  
A self-hosted, multi-user workout logging application built entirely with SQLPage. This application allows users to track their workouts against predefined templates, follow progression models, log their performance, and view their history.

---

## Features

- **Workout Logging:** Record sets, reps, weight, and RPE for each exercise.
- **Exercise Management:** Maintain a personal, custom library of exercises.
- **Progression Tracking:** Utilize predefined progression models to guide workout intensity and volume.
- **Workout History:** View and search past workout performance.
- **Template-Based Workouts:** Create and reuse workout templates for structured and efficient sessions.

### Screenshots
<details open>
<summary>Home Page</summary>

![home-page](https://github.com/drusho/SQLPage-Workout-Logger/blob/master/assets/2025-06-18-home-page.png?raw=true)

</details>

<details open>
<summary>Exercise Library</summary>

![exercises-page](https://github.com/drusho/SQLPage-Workout-Logger/blob/master/assets/2025-06-18-exercise-library.png?raw=true)

</details>

<details open>
<summary>Workouts</summary>

![workouts](https://github.com/drusho/SQLPage-Workout-Logger/blob/master/assets/2025-06-18-workouts.png?raw=true)

</details>

---

## Technology Stack

- Backend & Frontend: SQLPage (v0.20.1 or later)
- Database: SQLite
- Containerization: Docker & Docker Compose
- Reverse Proxy: Cloudflare Tunnel (cloudflare/cloudflared)
- Container Management: Portainer
- Database Administration: DB Browser for SQLite

---

## Getting Started

Follow these instructions to get the application running on your own host.

### Prerequisites

- Docker and Docker Compose installed on your system.
- A Cloudflare account with a `TUNNEL_TOKEN` from your Zero Trust dashboard.

### Installation

**1. Clone the repository:**

```bash
git clone https://github.com/drusho/SQLPage-Workout-Logger.git
cd SQLPage-Workout-Logger
```

**2. Create Docker Network:**
Ensure the `proxy-network` Docker network exists. If not, create it:

```bash
docker network create proxy-network
```

**3. Configure Environment**
Create a .env file in the root directory and add your Cloudflare Tunnel token:

```bash
TUNNEL_TOKEN=your-token-goes-here
```

**4. Deply the Stack:**

Launch the application using Docker Compose. You can manage it via Portainer or the command line:

```bash
docker compose up -d
```

### Docker Compose Sample

```yaml
services:
  sqlpage:
    image: lovasoa/sqlpage
    container_name: sqlpage
    ports:
      - "8080:8080"
    volumes:
      -  #directory for your sqlpage setup
    # user: "0:0"
    user: "1000:100" # Run as your user
    restart: unless-stopped
    environment:
      - DATABASE_URL=sqlite:///var/www/${databasename} # ex. workouts.db
    networks:
      - proxy-network # use this if your using a reverse proxy, otherwise comment out

networks: # comment this out if your not using a reverse proxy
  proxy-network:
    external: true
```

## Project Structure

The project is organized into the following key directories:

- `www/`: The web root for the SQLPage application. Contains all `.sql` page files, layouts, and the live `workouts.db` database.
- `migrations/`: Contains a chronological history of all database schema changes. Migrations are managed via a Python notebook to ensure safety and integrity.
- `maintenance/`: Contains scripts for routine database optimization, such as vacuuming and reindexing.
- `backups/`: The designated destination for automated, timestamped backups of the database, created by the migration runner.
- `docker-compose.yml`: Defines the services, networks, and volumes for the application stack.

## Database Management
This project uses a robust, script-based approach to manage the database lifecycle. This ensures that schema changes are safe, repeatable, and version-controlled. For a complete overview of the procedures, please see the [DATABASE_MANAGEMENT_GUIDE.md](https://github.com/drusho/SQLPage-Workout-Logger/blob/master/docs/Database%20Management%20Guide.md).



---

## Roadmap

This project is under active development. Future goals and potential improvements include:
- [ ] UI/UX Enhancements: Improve the user interface for a more polished mobile and desktop experience.
- [ ] Advanced Charting: Integrate a charting library to visualize user progression over time.
- [ ] Admin Dashboard: Create a dedicated dashboard for administrative tasks, such as managing users and viewing site-wide statistics.
- [ ] Enhance Backup Strategy: Further improve the backup strategy, such as by automatically pushing encrypted backups to a cloud storage provider (e.g., S3).
