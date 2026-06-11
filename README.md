*This project has been created as part of the 42 curriculum by wding.*

# Inception

## Description

Inception is a project that builds a small web infrastructure entirely inside a virtual machine, using Docker and Docker Compose. The stack runs three services, each in its own dedicated container built from a custom Dockerfile based on Debian:

- **NGINX** — the only entry point, serving HTTPS on port 443 with TLSv1.2/1.3
- **WordPress + php-fpm** — the application layer, without its own web server
- **MariaDB** — the database

The setup also includes two named volumes (one for the database, one for the WordPress website files) and a dedicated Docker network connecting the containers. No pre-built images are pulled; every image is built from source.

## Instructions

Prerequisites: a Linux host (or VM) with Docker and Docker Compose installed.

1. Clone the repository.
2. Create a `.env` file inside `srcs/` with the required variables (see `DEV_DOC.md`).
3. Point the domain to your local machine by adding this line to `/etc/hosts`: 127.0.0.1 wding.42.fr
4. From the project root, run: `make`. This creates the data directories, builds the images, and starts the containers.
5. Access the site at `https://wding.42.fr` (accept the self-signed certificate warning).
6. To stop the project: `make down`. To remove everything including volumes: `make clean`.

## Resources

### Docker
- [What is Docker (overview)](https://docs.docker.com/get-started/docker-overview/)
- [Develop with containers](https://docs.docker.com/get-started/introduction/develop-with-containers/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Volumes](https://docs.docker.com/storage/volumes/)
- [Networking](https://docs.docker.com/network/)
- [Docker secrets (Compose)](https://docs.docker.com/compose/how-tos/use-secrets/)
- [How to Dockerize WordPress](https://www.docker.com/blog/how-to-dockerize-wordpress/)

### NGINX
- [Configuring HTTPS servers (nginx.org)](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [ngx_http_fastcgi_module (fastcgi_pass)](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)
- [Debian NGINX directory structure](https://wiki.debian.org/Nginx/DirectoryStructure)

### PHP-FPM
- [PHP-FPM configuration (php.net)](https://www.php.net/manual/en/install.fpm.configuration.php)

### MariaDB
- [MariaDB server documentation](https://mariadb.com/kb/en/documentation/)
- [Configuring MariaDB with option files](https://mariadb.com/kb/en/configuring-mariadb-with-option-files/)

### WordPress / WP-CLI
- [WP-CLI commands](https://developer.wordpress.org/cli/commands/)
- [wp core install](https://developer.wordpress.org/cli/commands/core/install/)
- [wp user create](https://developer.wordpress.org/cli/commands/user/create/)

### TLS / Security
- [OpenSSL req command](https://www.openssl.org/docs/man3.0/man1/openssl-req.html)

### 42
- 42 community resources and peer discussions

**Use of AI:** AI was used to explain underlying concepts (TLS handshake, PID 1, named volumes vs bind mounts etc), to point toward the right documentation to consult, and to review configuration files and help debug. 

## Project description

### Why Docker is used here
Docker lets each service run in an isolated container with only its own dependencies, following the single-responsibility principle. Compose orchestrates the three containers, the network, and the volumes from a single declarative file.

### Virtual Machines vs Docker
A virtual machine emulates a full operating system on top of a hypervisor, with its own kernel — heavy but strongly isolated. A Docker container shares the host kernel and isolates only the process and its filesystem — much lighter and faster to start, but less isolated than a full VM. Here the whole project runs inside one VM, and the services are split into containers within it.

### Secrets vs Environment Variables
Environment variables (via the `.env` file) are convenient for configuration values, but they are visible to the running process and easy to leak if committed. Docker secrets are designed for sensitive data: they are mounted as files, kept out of the image and the environment, and not stored in the Git repository. In this project credentials are kept in `.env`, which is excluded from Git via `.gitignore`.

### Docker Network vs Host Network
A dedicated Docker (bridge) network gives the containers their own isolated subnet where they reach each other by container name, while exposing only what is explicitly published. Using the host network would make containers share the host's network stack directly, removing that isolation. This project uses a dedicated bridge network, and only NGINX publishes a port (443) to the host.

### Docker Volumes vs Bind Mounts
A bind mount maps an arbitrary host path directly into a container. A named volume is managed by Docker and referenced by name, which is cleaner and more portable. The subject requires named volumes (bind mounts are forbidden), while also requiring the data to live under `/home/wding/data`; this is achieved with named volumes configured with `driver_opts` to point their storage at that location.