# Developer Documentation

This document explains how to set up, build, and manage the Inception project as a developer.

## Setting up the environment from scratch

### Prerequisites

- A Linux host or virtual machine
- Docker and Docker Compose installed
- `make` installed
- Git

### Configuration files

The project expects an environment file at `srcs/.env`. This file is **not** tracked by Git (it is excluded via `.gitignore`) and must be created manually before the first build.

It must contain the following variables:

```
# Database
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=<your_db_user_password>
MYSQL_ROOT_PASSWORD=<your_db_root_password>

# Domain
DOMAIN_NAME=wding.42.fr

# WordPress administrator
WP_ADMIN_USER=<admin_username_without_"admin">
WP_ADMIN_PASSWORD=<admin_password>
WP_ADMIN_EMAIL=<admin_email>

# WordPress second user (non-admin)
WP_USER=<username>
WP_USER_EMAIL=<email>
WP_USER_PASSWORD=<password>
```

Note: the administrator username must not contain "admin" or "administrator", as required by the project subject.

## Building and launching the project

From the project root (where the `Makefile` is located):

- **Build and start:** `make`

  This target creates the host data directories (`/home/wding/data/mariadb` and `/home/wding/data/wordpress`), builds the three images from their Dockerfiles, and starts the containers in detached mode using Docker Compose.

After the first start, allow up to a minute for WordPress to finish downloading and installing before the site responds.

## Managing containers and volumes

- **Stop containers (keep data):** `make down`
- **Stop and remove containers, images, volumes, and host data:** `make clean`
- **Full rebuild:** `make re`

Useful Docker commands for development:

```
docker ps                                                  # list running containers
docker compose -f srcs/docker-compose.yml logs <service>   # view logs of a service
docker exec -it <container> sh                             # open a shell inside a container
docker volume ls                                           # list named volumes
docker exec mariadb mariadb -u root -p<root_pw> -e "SHOW DATABASES;"   # inspect the database
```

## Project structure

```
inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env                      (not committed)
    └── requirements/
        ├── mariadb/  (Dockerfile, conf/, tools/init.sh)
        ├── nginx/    (Dockerfile, conf/, tools/init.sh)
        └── wordpress/(Dockerfile, conf/, tools/init.sh)
```

Each service has its own Dockerfile, built from the penultimate stable version of Debian. Configuration files are copied in at build time; runtime setup (database creation, WordPress installation, certificate generation) happens in each service's `init.sh` entrypoint, which uses the variables from `.env`.

## Where project data is stored and how it persists

The project uses two **named volumes**, configured with `driver_opts` so their data is stored on the host machine under `/home/wding/data`:

- `mariadb_data` -> `/home/wding/data/mariadb` (the WordPress database)
- `wordpress_data` -> `/home/wding/data/wordpress` (the WordPress website files)

Because the data lives in these host directories, it **persists** across container restarts and rebuilds (`make down`, then `make` again). It is only removed when you explicitly run `make clean`, which deletes both the volumes and the host data directories.

The `wordpress_data` volume is shared between the WordPress and NGINX containers: WordPress writes the site files there, and NGINX reads them to serve the website.

## How the services connect

- All three containers share a dedicated Docker bridge network (`inception`) and find each other by container name.
- NGINX is the only container that publishes a port to the host (443).
- WordPress (php-fpm) listens on port 9000; NGINX forwards `.php` requests to `wordpress:9000`.
- MariaDB listens on port 3306; WordPress connects to it at `mariadb:3306`.