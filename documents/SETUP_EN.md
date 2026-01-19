# Fincode Project Setup Guide

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Clone Repository](#1-clone-repository)
3. [Environment Configuration](#2-environment-configuration)
4. [Docker Build & Up](#3-docker-build--up)
5. [Database Seeding](#4-database-seeding)
6. [Run Application](#5-run-application)
7. [Frontend Application](#6-frontend-application)
8. [Email Login](#7-email-login)
9. [Check Email](#8-check-email)
10. [Troubleshooting](#troubleshooting)

---

## System Requirements

Before starting, ensure your machine has the following installed:

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- **Git**

Check versions:
```bash
docker --version
docker-compose --version
git --version
```

---

## 1. Environment Configuration

### 1.1. Create `.env` File

Copy the `.env.example` file to `.env`:

```bash
cp .env.example .env
```

### 1.2. Configure Environment Variables

Open the `.env` file and update the necessary information:

```bash
# Rails Environment
RAILS_ENV=development

# Database Configuration
DATABASE_HOST=mysql
DATABASE_PORT=3306
DATABASE_USERNAME=fincode_user
DATABASE_PASSWORD=fincode_password
DATABASE_NAME=fincode_development

# Mailer Configuration
MAILER_HOST=localhost
MAILER_PORT=3000

# Fincode API Configuration
FINCODE_API_URL=https://api.test.fincode.jp
FINCODE_PUBLIC_KEY=p_test_xxxxx
FINCODE_SECRET_KEY=m_test_xxxxx
```

> **Important**: Update `FINCODE_PUBLIC_KEY` and `FINCODE_SECRET_KEY` with actual API keys from Fincode.

---

## 2. Docker Build & Up

### 2.1. Build Docker Images

Build all necessary Docker images:

```bash
docker-compose build
```

This process will:
- Build the Rails application image
- Pull MySQL 8.0 image
- Pull Redis 7 Alpine image
- Pull Mailcatcher image

### 2.2. Start Containers

Start all services:

```bash
docker-compose up -d
```

The `-d` flag runs containers in detached mode (background).

### 2.3. Check Container Status

Verify that all containers are running successfully:

```bash
docker-compose ps
```

Expected output:
```
NAME                   STATUS              PORTS
fincode_mysql          Up (healthy)        0.0.0.0:33060->3306/tcp
fincode_redis          Up (healthy)        0.0.0.0:63790->6379/tcp
fincode_rails          Up                  0.0.0.0:3005->3000/tcp
fincode_mailcatcher    Up                  0.0.0.0:10800->1080/tcp, 0.0.0.0:10250->1025/tcp
```

> **Note**: Wait until MySQL and Redis show `healthy` status before proceeding.

---

## 3. Database Seeding

The database will be automatically created and migrated when the Rails container starts for the first time (as configured in `docker-compose.yml`).

### 3.1. Check Logs

View the Rails container logs to ensure seeding completed successfully:

```bash
docker-compose logs rails
```

You should see output similar to:
```
Cleaning up database...
Seeding Users...
Seeding Categories...
Seeding Products...
Seeding done.
```

### 3.2. Re-run Seeding (If Needed)

If you need to re-run seeding:

```bash
docker-compose exec rails bundle exec rails db:seed
```

Or reset the entire database:

```bash
docker-compose exec rails bundle exec rails db:reset
```

---

## 4. Run Application

### 4.1. Access Application

After all containers are running successfully, open your browser and navigate to:

```
http://localhost:3005
```

### 4.2. Health Check

Check the API health endpoint:

```bash
curl http://localhost:3005/api/v1/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-01-19T10:01:59Z"
}
```

---

## 5. Frontend Application

### 5.1. Access Frontend

The frontend application runs separately from the backend API. After setting up the frontend project, access it at:

```
http://localhost:3006
```

> **Note**: The frontend source code is in a separate repository. Make sure to clone and set up the frontend project as well.

### 5.2. Frontend Configuration

The frontend is configured to communicate with the backend API at `http://localhost:3005`. Ensure both services are running:

- **Backend API**: `http://localhost:3005`
- **Frontend**: `http://localhost:3006`

### 5.3. Development Workflow

1. Start the backend (this project) using Docker Compose
2. Start the frontend development server (refer to frontend repository documentation)
3. Access the frontend at `http://localhost:3006`
4. The frontend will make API calls to `http://localhost:3005`

---

## 6. Email Login

The application uses **Magic Link Authentication** (passwordless login via email).

### 6.1. Available Test Accounts

After seeding, the following accounts are available:

| Email                    | Display Name    |
|--------------------------|-----------------|
| test@example.com         | Test Customer   |
| john@example.com         | johndoe         |
| johnwick@example.com     | johndoe         |
| janewick@example.com     | janesmith       |

### 6.2. Login Process

1. Navigate to the login page
2. Enter an email address (e.g., `test@example.com`)
3. Click the "Send Magic Link" button
4. The system will send an email containing a magic link
5. Check the email in Mailcatcher (see next section)
6. Click the magic link in the email to log in

---

## 7. Check Email

### 7.1. Access Mailcatcher

Mailcatcher is a mock SMTP server that captures all emails in the development environment.

Open your browser and navigate to:

```
http://0.0.0.0:10800/
```

Or:

```
http://localhost:10800/
```

### 7.2. View Magic Link Email

1. In the Mailcatcher interface, you'll see a list of sent emails
2. Click on the latest email (Magic Link Email)
3. The email content will contain the login link
4. Click the link or copy it to log in

### 7.3. SMTP Configuration

Mailcatcher is running with the following configuration:
- **Web Interface**: `http://0.0.0.0:10800/` (port 1080 → 10800)
- **SMTP Server**: `localhost:10250` (port 1025 → 10250)

---

## Troubleshooting

### Issue 1: Container Fails to Start

**Symptoms**: One or more containers fail during startup.

**Solution**:
```bash
# View detailed logs
docker-compose logs [service-name]

# Example: view Rails logs
docker-compose logs rails

# Restart containers
docker-compose restart

# Or stop and start again
docker-compose down
docker-compose up -d
```

### Issue 2: Database Connection Error

**Symptoms**: Rails cannot connect to MySQL.

**Solution**:
```bash
# Check if MySQL is healthy
docker-compose ps

# Wait a few more seconds for MySQL to fully start
# Then restart the Rails container
docker-compose restart rails
```

### Issue 3: Port Already in Use

**Symptoms**: Error "port is already allocated".

**Solution**:
```bash
# Check which ports are in use
sudo lsof -i :3005
sudo lsof -i :33060
sudo lsof -i :63790
sudo lsof -i :10800

# Kill the process using the port (if needed)
sudo kill -9 <PID>

# Or change ports in docker-compose.yml
```

### Issue 4: Mailcatcher Not Receiving Emails

**Symptoms**: Emails don't appear in Mailcatcher.

**Solution**:
```bash
# Check Mailcatcher container
docker-compose ps mailcatcher

# Check logs
docker-compose logs mailcatcher

# Restart Mailcatcher
docker-compose restart mailcatcher

# Check Rails mailer configuration
docker-compose exec rails bundle exec rails console
# In console:
ActionMailer::Base.delivery_method
ActionMailer::Base.smtp_settings
```

### Issue 5: Seeding Failed

**Symptoms**: Errors when running seeds.

**Solution**:
```bash
# Drop and recreate database
docker-compose exec rails bundle exec rails db:drop db:create db:migrate db:seed

# Or reset database
docker-compose exec rails bundle exec rails db:reset
```

### Issue 6: Bundle Install Errors

**Symptoms**: Errors when installing gems.

**Solution**:
```bash
# Rebuild Rails container
docker-compose build --no-cache rails

# Or exec into container and install manually
docker-compose exec rails bundle install
```

---

## Useful Commands

### Docker Commands

```bash
# View logs in realtime
docker-compose logs -f

# View logs for a specific service
docker-compose logs -f rails

# Exec into Rails container
docker-compose exec rails bash

# Run Rails console
docker-compose exec rails bundle exec rails console

# Run tests
docker-compose exec rails bundle exec rspec

# Stop all containers
docker-compose down

# Stop and remove volumes (caution: will lose data!)
docker-compose down -v

# Rebuild and restart
docker-compose up -d --build
```

### Database Commands

```bash
# Create database
docker-compose exec rails bundle exec rails db:create

# Run migrations
docker-compose exec rails bundle exec rails db:migrate

# Rollback migration
docker-compose exec rails bundle exec rails db:rollback

# Reset database
docker-compose exec rails bundle exec rails db:reset

# Seed database
docker-compose exec rails bundle exec rails db:seed
```

### MySQL Direct Access

```bash
# Connect to MySQL container
docker-compose exec mysql mysql -u fincode_user -pfincode_password fincode_development

# Or from host machine
mysql -h 127.0.0.1 -P 33060 -u fincode_user -pfincode_password fincode_development
```

### Redis Commands

```bash
# Connect to Redis
docker-compose exec redis redis-cli -a redis_password

# Check Redis
docker-compose exec redis redis-cli -a redis_password ping
```

---

## Project Structure

```
fincode/
├── app/                    # Rails application code
│   ├── controllers/        # Controllers
│   ├── models/            # Models
│   ├── mailers/           # Mailers (Magic Link)
│   └── views/             # Views
├── config/                # Configuration files
├── db/                    # Database files
│   ├── migrate/           # Migrations
│   └── seeds.rb           # Seed data
├── docker/                # Docker configuration
├── documents/             # Documentation
├── spec/                  # RSpec tests
├── docker-compose.yml     # Docker Compose configuration
├── Dockerfile             # Rails Docker image
├── .env.example           # Environment variables template
└── README.md              # Project README
```

---

## Services & Ports

| Service      | Container Name       | Internal Port | External Port | URL                          |
|--------------|---------------------|---------------|---------------|------------------------------|
| Rails (API)  | fincode_rails       | 3000          | 3005          | http://localhost:3005        |
| Frontend     | -                   | -             | 3006          | http://localhost:3006        |
| MySQL        | fincode_mysql       | 3306          | 33060         | localhost:33060              |
| Redis        | fincode_redis       | 6379          | 63790         | localhost:63790              |
| Mailcatcher  | fincode_mailcatcher | 1080, 1025    | 10800, 10250  | http://localhost:10800       |

---

## Contact & Support

If you encounter issues during setup, please:
1. Check the [Troubleshooting](#troubleshooting) section
2. View detailed logs: `docker-compose logs`
3. Contact the team for support

---

**Happy coding! 🚀**
