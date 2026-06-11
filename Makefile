COMPOSE_FILE=srcs/docker-compose.yml
COMPOSE=docker compose -f $(COMPOSE_FILE)

all:
	mkdir -p /home/wding/data/mariadb
	mkdir -p /home/wding/data/wordpress
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v --rmi all --remove-orphans
	sudo rm -rf /home/wding/data/mariadb
	sudo rm -rf /home/wding/data/wordpress

re: clean all

.PHONY: all down clean re
