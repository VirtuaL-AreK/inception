## Overview

This project provides a small containerized web infrastructure running inside Docker.
It hosts a **WordPress website** using three services:

* **NGINX** – handles HTTPS connections and serves as the public entrypoint
* **WordPress + PHP-FPM** – runs the website application
* **MariaDB** – stores the WordPress database

All services run inside separate Docker containers and communicate through a dedicated Docker network.

Persistent data such as the WordPress files and database are stored on the host machine inside:

```
/home/iel-kher/data
```

This ensures that the data remains available even if the containers are stopped or recreated.

---

## Starting the Project

To start the infrastructure, run:

```
make
```

This command will:

* create the required data directories
* configure the domain in `/etc/hosts`
* build the Docker images
* start all containers

The containers will run in the background.

---

## Stopping the Project

To stop all running services:

```
make down
```

This stops the containers but keeps the data and images.

---

## Restarting the Project

To restart the infrastructure:

```
make restart
```

This will stop and start the containers again.

---

## Removing the Infrastructure

To remove containers, images, and data:

```
make fclean
```

This command removes:

* containers
* Docker images
* volumes
* data stored in `/home/iel-kher/data`
* the domain entry in `/etc/hosts`

---

## Accessing the Website

Open a web browser and go to:

```
https://iel-kher.42.fr
```

The connection uses HTTPS through the NGINX container.

---

## Accessing the WordPress Administration Panel

To manage the website, open:

```
https://iel-kher.42.fr/wp-admin
```

Log in using the administrator credentials defined in the `.env` file.

Example administrator credentials:

```
Username: iel-kher
Password: defined in srcs/.env
```

---

## Locating Credentials

All configuration variables and credentials are stored in:

```
srcs/.env
```

This file contains:

* database credentials
* WordPress administrator credentials
* WordPress user credentials
* domain configuration

Example variables:

```
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD
WORDPRESS_ADMIN_USER
WORDPRESS_ADMIN_PASSWORD
```

---

## Checking if Services Are Running

To verify that the containers are running:

```
docker ps
```

You should see the following containers:

```
nginx
wordpress
mariadb
```

---

## Checking the Infrastructure Status

You can also use the Makefile command:

```
make status
```

This displays:

* container status
* Docker images
* Docker volumes
* Docker networks

---

## Viewing Logs

To see logs from all services:

```
make logs
```

To inspect logs of a specific container:

```
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Logs can help diagnose issues with the services.

---

## Persistent Data Location

The project stores persistent data in the following directories:

```
/home/iel-kher/data/wordpress
/home/iel-kher/data/mariadb
```

These directories contain:

* WordPress files
* the MariaDB database

Even if containers are removed or rebuilt, the data remains stored in these folders.
