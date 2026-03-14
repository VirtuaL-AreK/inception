## Overview

This document explains how developers can set up, build, run, and manage the **Inception infrastructure**.

The project uses **Docker** and **Docker Compose** to run a WordPress stack composed of three containers:

* **NGINX** – reverse proxy handling HTTPS connections
* **WordPress + PHP-FPM** – application container running the WordPress website
* **MariaDB** – database container storing the WordPress data

Each service is built from a **custom Dockerfile** and connected through a **Docker bridge network**.

Persistent data is stored on the host machine in:

```
/home/iel-kher/data
```

---

## Prerequisites

Before running the project, ensure the following tools are installed:

* Docker
* Docker Compose
* Make
* Git

Check Docker installation:

```
docker --version
```

Check Docker Compose:

```
docker compose version
```

---

## Project Structure

```
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

Each service has:

* its own **Dockerfile**
* configuration files
* an entrypoint script (for MariaDB and WordPress)

---

## Environment Configuration

Configuration variables are stored in:

```
srcs/.env
```

This file defines:

* database configuration
* WordPress configuration
* domain name
* persistent storage location

Example variables:

```
VOLUME_PATH=/home/iel-kher/data
DOMAIN_NAME=iel-kher.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=...
MYSQL_ROOT_PASSWORD=...

WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=...

WORDPRESS_ADMIN_USER=iel-kher
WORDPRESS_ADMIN_PASSWORD=...
```

---

## Building the Project

The infrastructure is managed using the **Makefile**.

To build the Docker images:

```
make build
```

This command runs:

```
docker compose build --no-cache
```

The images are built from the Dockerfiles located in:

```
srcs/requirements/
```

---

## Starting the Infrastructure

To start the containers:

```
make
```

This command runs three steps:

1. **setup**

Creates the data directories:

```
/home/iel-kher/data/wordpress
/home/iel-kher/data/mariadb
```

It also adds the domain entry to `/etc/hosts`:

```
127.0.0.1 iel-kher.42.fr
```

2. **build**

Builds the Docker images.

3. **up**

Starts the containers using:

```
docker compose up -d
```

---

## Stopping the Infrastructure

To stop the running containers:

```
make down
```

This runs:

```
docker compose down
```

Containers stop but persistent data remains.

---

## Restarting the Infrastructure

To restart the stack:

```
make restart
```

This runs:

```
make down
make up
```

---

## Cleaning Docker Resources

To remove unused Docker resources:

```
make clean
```

This command:

* stops containers
* runs `docker system prune`
* removes Docker volumes

---

## Full Cleanup

To completely reset the project:

```
make fclean
```

This removes:

* containers
* images
* volumes
* host data directories
* domain entry in `/etc/hosts`

---

## Managing Containers

List running containers:

```
docker ps
```

List all containers:

```
docker ps -a
```

View logs of a container:

```
docker logs container_name
```

Examples:

```
docker logs nginx
docker logs wordpress
docker logs mariadb
```

---

## Docker Images

List images:

```
docker images
```

Remove an image:

```
docker rmi image_name
```

---

## Docker Volumes

List volumes:

```
docker volume ls
```

Inspect a volume:

```
docker volume inspect volume_name
```

Remove a volume:

```
docker volume rm volume_name
```

---

## Docker Networks

List networks:

```
docker network ls
```

Inspect the project network:

```
docker network inspect inception_network
```

This network allows the containers to communicate using their service names:

```
nginx
wordpress
mariadb
```

---

## Persistent Data

Two persistent storage locations are used:

```
/home/iel-kher/data/wordpress
/home/iel-kher/data/mariadb
```

These directories contain:

* WordPress application files
* MariaDB database files

Because they exist on the host system, data remains available even if containers are rebuilt or removed.

---

## Service Communication

The containers communicate through the Docker network:

```
inception_network
```

Service communication:

```
NGINX → wordpress:9000
WordPress → mariadb:3306
```

NGINX forwards PHP requests to the WordPress container using **FastCGI**.

---

## Debugging Tips

Check container status:

```
make status
```

Follow container logs:

```
make logs
```

Check container connectivity:

```
docker exec -it wordpress sh
```

Test database connection:

```
mysql -h mariadb -u wpuser -p
```

---

## Rebuilding a Single Service

To rebuild a specific container:

```
docker compose build service_name
```

Example:

```
docker compose build wordpress
```

Restart the service:

```
docker compose up -d wordpress
```

---

## Conclusion

This infrastructure demonstrates how to deploy a modular WordPress stack using Docker containers. Each service runs independently while communicating through a dedicated Docker network, and persistent data is stored on the host system to ensure durability across container lifecycles.
