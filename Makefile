LEVEL ?= dev # one of: dev, staging, prod
COMPOSE ?= podman-compose
COMPOSE-ARGS := --env-file env.$(LEVEL)

.PHONY: up down setup clean

build: setup
	$(COMPOSE) $(COMPOSE-ARGS) build

up: build
	$(COMPOSE) $(COMPOSE-ARGS) up

down:
	$(COMPOSE) $(COMPOSE-ARGS) down --timeout 10 --remove-orphans

clean: down
	# purposefully keep volumes/ssl
	rm -rf volumes/email
	make -C tcp_server clean

setup:
	# Setup volumes/ and its content
	mkdir -p volumes/email/{logs,mail}
	cd volumes && ../extenginx/create_dev_keys.sh

	# Compile tcp_server
	make -C tcp_server tcp_server
