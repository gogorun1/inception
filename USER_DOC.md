# User Documentation

This document explains how to use the Inception stack as an end user.

## Services provided

The stack runs three services inside Docker containers:

- **NGINX** — the web server and single entry point, serving the site over HTTPS (port 443).
- **WordPress (php-fpm)** — the content management system where the website and its content live.
- **MariaDB** — the database that stores all WordPress data (users, posts, settings).

## Start and stop the project

All commands are run from the project root, where the `Makefile` is located.

- **Start the project:** `make`
  Creates the data directories, builds the images, and starts all containers in the background.
- **Stop the project (keep data):** `make down`
- **Stop and remove everything (containers, images, volumes, data):** `make clean`
- **Rebuild from scratch:** `make re`

(After starting, allow up to a minute for WordPress to finish its first-time installation before accessing the site.)

## Accessing the website

1. Make sure the domain points to your machine. Add this line to `/etc/hosts`:
   `127.0.0.1 wding.42.fr`
2. Open the website: `https://wding.42.fr`
   The site uses a self-signed certificate, so your browser will show a security warning. This is expected — accept it to continue.

## Accessing the administration panel

The WordPress admin dashboard is available at `https://wding.42.fr/wp-admin`.
Log in with the administrator credentials defined in the `.env` file (`WP_ADMIN_USER` and `WP_ADMIN_PASSWORD`).

## Credentials

All credentials are stored in the `srcs/.env` file, which is **not** committed to Git. This file contains:

- Database name, user, and passwords (`MYSQL_*`)
- WordPress administrator account (`WP_ADMIN_*`)
- A second, non-administrator WordPress user (`WP_USER*`)

To view or change credentials, edit `srcs/.env` and restart the project with `make re`.

## Checking that the services are running

- **List running containers:** `docker ps`
  You should see three containers (`nginx`, `wordpress`, `mariadb`), all with status `Up`.
- **Check the website responds:** `curl -k https://wding.42.fr`
  This should return the WordPress homepage HTML.
- **Check WordPress users:** `docker exec wordpress wp user list --path=/var/www/wordpress --allow-root`
  This lists the two WordPress users (one administrator, one author).
