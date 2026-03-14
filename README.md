*This project has been created as part of the 42 curriculum by iel-kher.*

# Inception

## Description

**Inception** is a system administration project whose goal is to build a small, secure, and modular web infrastructure inside a **virtual machine** using **Docker Compose**.

The stack is composed of three isolated services, each running in its own dedicated container:

* **NGINX** as the only public entrypoint, serving HTTPS traffic on port **443**
* **WordPress + PHP-FPM** to provide the web application
* **MariaDB** to store the WordPress database

The services communicate through a dedicated **Docker bridge network**, and persistent data is stored outside the containers in Docker volumes mapped to the host storage under `/home/iel-kher/data`.

This project demonstrates how to separate concerns in a web infrastructure:

* the **web server** handles TLS and reverse proxying
* the **application server** runs PHP-FPM and WordPress
* the **database server** stores structured data permanently

---

## Project Overview

The infrastructure follows this flow:

`User → HTTPS (443) → NGINX → WordPress (PHP-FPM) → MariaDB`

### Services included

* **NGINX**

  * Handles HTTPS connections
  * Uses a self-signed SSL certificate
  * Only accepts **TLSv1.2** and **TLSv1.3**
  * Forwards PHP requests to the WordPress container

* **WordPress**

  * Runs with **PHP-FPM**
  * Automatically downloads and configures WordPress using **WP-CLI**
  * Creates both the administrator account and a second WordPress user

* **MariaDB**

  * Initializes the database on first launch
  * Creates the WordPress database and database user
  * Stores persistent database data in a volume

---

## Project Structure

```text
.
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── Makefile
├── srcs
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements
│       ├── mariadb
│       │   ├── Dockerfile
│       │   ├── conf
│       │   │   └── my.cnf
│       │   └── tools
│       │       └── mariadb-entrypoint.sh
│       ├── nginx
│       │   ├── Dockerfile
│       │   └── conf
│       │       └── nginx.conf
│       └── wordpress
│           ├── Dockerfile
│           ├── conf
│           │   └── www.conf
│           └── tools
│               └── wordpress-entrypoint.sh
```

---

## Technical Choices

### Base image choice

All services are built from **Alpine 3.19**.

This choice was made because Alpine is:

* lightweight
* fast to download and build
* well suited for containerized services
* commonly used for minimal production-like images

### Service separation

Each service runs in its own container:

* `nginx`
* `wordpress`
* `mariadb`

This separation improves:

* maintainability
* modularity
* debugging
* security
* service isolation

### Persistent storage

Two persistent data locations are used:

* `/home/iel-kher/data/wordpress`
* `/home/iel-kher/data/mariadb`

These directories are created by the `Makefile` before the containers start, ensuring that data survives container recreation.

### Domain configuration

The local domain used by the project is:

```text
iel-kher.42.fr
```

The `Makefile` automatically adds the following entry to `/etc/hosts` if it is missing:

```text
127.0.0.1 iel-kher.42.fr
```

This allows local access to the website through HTTPS.

---

## How Docker is used in this project

Docker is used to package each service with its own runtime environment and dependencies.

Instead of installing NGINX, PHP, WordPress, and MariaDB directly on the virtual machine, each service is built from its own **Dockerfile** and launched with **Docker Compose**.

This provides:

* isolated execution environments
* reproducible setup
* easier service orchestration
* cleaner project structure
* simple startup and teardown

### Sources included in the project

This project includes:

* a custom **Makefile**
* a custom `docker-compose.yml`
* one **Dockerfile per service**
* custom configuration files for:

  * NGINX
  * PHP-FPM
  * MariaDB
* custom entrypoint scripts for:

  * WordPress
  * MariaDB
* one `.env` file for environment variables

---

## Comparison Sections

## Virtual Machines vs Docker

### Virtual Machine

A virtual machine emulates an entire operating system, including its own kernel abstraction and full system environment.

**Advantages:**

* strong isolation
* complete OS-level environment
* close to a real standalone machine

**Disadvantages:**

* heavier resource usage
* slower boot time
* more storage consumption

### Docker

Docker uses containers that share the host kernel while isolating processes and filesystems.

**Advantages:**

* lightweight
* faster startup
* easier deployment
* simpler service orchestration

**Why Docker is appropriate here:**

This project requires several services to run together while staying isolated from one another. Docker is ideal for this because it allows a modular architecture without the overhead of multiple full virtual machines.

---

## Secrets vs Environment Variables

### Environment Variables

Environment variables are used to pass configuration values into containers.

In this project, the `.env` file contains values such as:

* domain name
* database name
* database user
* WordPress configuration
* WordPress user credentials

**Advantages:**

* simple to configure
* easy to integrate with Docker Compose
* convenient for project setup

### Secrets

Docker secrets are intended for sensitive data such as passwords or confidential tokens.

**Advantages:**

* better confidentiality
* not baked into images
* more secure handling in production environments

### Design choice in this project

This project currently relies on a `.env` file for configuration. This keeps setup simple and matches the expected development workflow. In a more production-oriented environment, passwords and confidential values should preferably be moved to Docker secrets.

---

## Docker Network vs Host Network

### Docker Network

The containers communicate through a dedicated **bridge network**:

* `inception_network`

This allows containers to reach each other using their service names such as:

* `mariadb`
* `wordpress`

**Advantages:**

* service isolation
* internal communication only
* cleaner architecture
* better security than exposing every service directly

### Host Network

With host networking, containers share the host machine’s network stack directly.

**Why it is not used:**

* weaker isolation
* harder to control exposed services
* forbidden by the subject

### Design choice in this project

A dedicated Docker bridge network is used so that:

* only NGINX is exposed publicly
* WordPress and MariaDB remain internal
* the architecture stays modular and secure

---

## Docker Volumes vs Bind Mounts

### Docker Volumes

Docker volumes are designed for persistent data managed through Docker.

**Advantages:**

* persistent storage across container restarts
* clean separation between container lifecycle and data lifecycle
* easier backup and reuse

### Bind Mounts

Bind mounts directly map a host directory into a container.

**Advantages:**

* explicit control over host-side storage path
* easy inspection of files from the host

**Disadvantages:**

* tighter coupling to the host filesystem
* less portability

### Design choice in this project

This project persists data under:

* `/home/iel-kher/data/wordpress`
* `/home/iel-kher/data/mariadb`

This ensures that WordPress files and database data remain available even after containers are stopped, rebuilt, or removed.

---

## Instructions

### Clone the repository

```bash
git clone <repository_url>
cd inception
```

### Build and start the infrastructure

```bash
make
```

This will:

* create the host data directories
* add the domain to `/etc/hosts` if needed
* build all Docker images
* start the containers in detached mode

### Start only the services

```bash
make up
```

### Rebuild all images without cache

```bash
make build
```

### Stop the infrastructure

```bash
make down
```

### Restart the infrastructure

```bash
make restart
```

### Full cleanup

```bash
make fclean
```

This removes:

* containers
* Docker resources
* host data directories under `/home/iel-kher/data`
* the domain entry from `/etc/hosts`

---

## Usage

### Access the website

Open:

```text
https://iel-kher.42.fr
```

### Access the WordPress administration panel

Open:

```text
https://iel-kher.42.fr/wp-admin
```

Use the administrator credentials defined in `srcs/.env`.

---

## Environment Variables

The project uses a `.env` file located in:

```text
srcs/.env
```

Main variables include:

```text
VOLUME_PATH=/home/iel-kher/data
DOMAIN_NAME=iel-kher.42.fr

MYSQL_ROOT_PASSWORD=...
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=...

WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=...

WORDPRESS_URL=https://iel-kher.42.fr
WORDPRESS_TITLE=Inception by iel-kher
WORDPRESS_ADMIN_USER=iel-kher
WORDPRESS_ADMIN_EMAIL=admin@iel-kher.42.fr
WORDPRESS_ADMIN_PASSWORD=...
WORDPRESS_USER=random
WORDPRESS_USER_EMAIL=author@iel-kher.42.fr
WORDPRESS_USER_PASSWORD=...
```

---

## Main Design Details

### NGINX

* listens only on port **443**
* uses SSL certificates generated with OpenSSL
* forwards PHP requests to `wordpress:9000`
* allows only **TLSv1.2** and **TLSv1.3**

### WordPress

* installs PHP 8.1 and PHP-FPM
* installs WP-CLI
* waits for MariaDB before starting
* downloads and configures WordPress automatically if needed
* creates:

  * one administrator
  * one additional WordPress user

### MariaDB

* initializes the database only if it has not already been created
* creates:

  * the database
  * the SQL user
  * root password
* stores persistent data in `/var/lib/mysql`

---

## Useful Commands

### Show service status

```bash
make status
```

### Follow logs

```bash
make logs
```

### List running containers

```bash
docker ps
```

### List images

```bash
docker images
```

### List volumes

```bash
docker volume ls
```

### List networks

```bash
docker network ls
```

---

## Resources

### Official documentation

- Docker Documentation  
  https://docs.docker.com/

- Docker Compose Documentation  
  https://docs.docker.com/compose/

- NGINX Documentation  
  https://nginx.org/en/docs/

- MariaDB Documentation  
  https://mariadb.org/documentation/

- WordPress Documentation  
  https://developer.wordpress.org/

- WP-CLI Documentation  
  https://developer.wordpress.org/cli/commands/

- OpenSSL Documentation  
  https://www.openssl.org/docs/

- Alpine Linux Documentation  
  https://wiki.alpinelinux.org/

### Helpful topics studied for this project

- Container lifecycle in Docker  
  https://docs.docker.com/engine/reference/run/

- PID 1 behavior inside containers  
  https://docs.docker.com/engine/reference/run/#foreground

- Entrypoint vs Command in Docker  
  https://docs.docker.com/engine/reference/builder/#entrypoint

- Reverse proxying with NGINX  
  https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/

- PHP-FPM and FastCGI  
  https://www.php.net/manual/en/install.fpm.php

- Database initialization in containers  
  https://mariadb.com/kb/en/docker-official-image/

- Persistent storage in Docker (Volumes)  
  https://docs.docker.com/storage/volumes/

- Local HTTPS configuration with OpenSSL  
  https://www.openssl.org/docs/manmaster/man1/openssl-req.html

---

## AI Usage

AI was used as a support tool during the project for:

* understanding Docker and Docker Compose concepts
* clarifying the role of each service
* improving documentation structure and explanations
* reviewing infrastructure descriptions
* helping explain technical comparisons such as:

  * Virtual Machines vs Docker
  * Secrets vs Environment Variables
  * Docker Network vs Host Network
  * Docker Volumes vs Bind Mounts

AI was **not** used as a replacement for implementation or testing. The architecture, configuration, debugging, and validation of the project were completed manually.

---

## Conclusion

This project introduces the fundamentals of containerized infrastructure by building a complete web stack from separate services. It highlights the importance of isolation, persistence, networking, automation, and secure access through HTTPS.

The final result is a modular WordPress infrastructure running entirely inside Docker containers, orchestrated with Docker Compose, and deployed within a virtual machine as required by the subject.
