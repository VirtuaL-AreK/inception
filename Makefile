HOST_USER = $(if $(SUDO_USER),$(SUDO_USER),$(USER))
VOLUME_PATH = /home/$(HOST_USER)/data
DC = cd srcs && VOLUME_PATH=$(VOLUME_PATH) docker compose
WORDPRESS_VOLUME = $(VOLUME_PATH)/wordpress
MARIADB_VOLUME = $(VOLUME_PATH)/mariadb
DOMAIN = ielkher.42.fr

all: setup build up

setup:
	@echo "=== Creating data directories ==="
	@sudo mkdir -p $(WORDPRESS_VOLUME)
	@sudo mkdir -p $(MARIADB_VOLUME)
	@sudo chmod 777 $(WORDPRESS_VOLUME)
	@sudo chmod 777 $(MARIADB_VOLUME)
	@echo "=== Setting up hosts file ==="
	@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts; \
	fi

build:
	@echo "=== Building Docker images ==="
	@$(DC) build --no-cache

up:
	@echo "=== Starting services ==="
	@$(DC) up -d

down:
	@echo "=== Stopping services ==="
	@$(DC) down

clean: down
	@echo "=== Cleaning up Docker resources ==="
	@docker system prune -af
	@echo "=== Removing Docker volumes ==="
	@if [ "$$(docker volume ls -q)" ]; then \
		docker volume rm $$(docker volume ls -q); \
	fi

fclean: clean
	@echo "=== Removing all data directories ==="
	@sudo rm -rf $(VOLUME_PATH)
	@echo "=== Removing domain from hosts file ==="
	@sudo sed -i '/$(DOMAIN)/d' /etc/hosts

status:
	@echo "=== Container Status ==="
	@$(DC) ps
	@echo "\n=== Docker Images ==="
	@docker images
	@echo "\n=== Docker Volumes ==="
	@docker volume ls
	@echo "\n=== Docker Networks ==="
	@docker network ls

logs:
	@$(DC) logs -f

restart: down up

re: fclean all

.PHONY: all setup build up down clean fclean status logs restart re help