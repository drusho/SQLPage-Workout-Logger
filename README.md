# SQLPage Workout Logger
A self-hosted, multi-user workout logging application built with SQLPage. This application allows users to track their workouts against predefined templates and progression models, log their performance, and view their history.

Last Updated: __June 14, 2025__

## Key Technologies
- Backend & Frontend: SQLPage (v0.20.1 or later)
- Database: SQLite
- Containerization: Docker & Docker Compose
- Reverse Proxy: Cloudflare Tunnel (cloudflare/cloudflared)
- Container Management: Portainer
- Database Administration: DB Browser for SQLite

## Project Structure
The project is organized into the following key directories:

- `/www`: The web root for the SQLPage application. Contains all `.sql` page files, layouts, and the live workouts.db database.
- `/migrations`: Contains a chronological history of all database schema changes. Each .sql file represents a single, atomic change to the database structure.
- `/backups`: The designated destination for automated daily backups of the `workouts.db` file.
- `docker-compose.yml`: Defines the services, networks, and volumes for the application stack.

## Setup & Running
1. Ensure Docker and Docker Compose are installed on the host system.
2. Create a `proxy-network` Docker network if it doesn't already exist: `docker network create proxy-network`.
3. Obtain a `TUNNEL_TOKEN` from your Cloudflare Zero Trust dashboard and add it to your environment variables or a .env file.
4. Deploy the application stack from the root directory using Portainer or the command line:
Bash

```bash
docker compose up -d
```

## Future Goals & Potential Improvements
- Dynamic User ID: Implement dynamic user ID fetching in all relevant scripts to replace the remaining hardcoded 'davidrusho' instances.
- UI/UX Enhancements: Improve the user interface for a more polished mobile and desktop experience.
- Advanced Charting: Integrate a charting library to visualize user progression over time.
- Robust Backup Strategy: Implement a more robust backup strategy, such as automatically pushing encrypted backups to a cloud storage provider.
- Admin Dashboard: Create a dedicated dashboard for administrative tasks, such as managing users and viewing site-wide statistics.
