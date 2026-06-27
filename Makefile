.DEFAULT_GOAL := help

COMPOSE_BASE := docker compose
COMPOSE_TS    := docker compose -f docker-compose.yml -f docker-compose.tailscale.yml

.PHONY: help up up-ts down logs status update shell setup

help: ## Show this help message
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

up: ## Start all services (standard mode)
	$(COMPOSE_BASE) up -d

up-ts: ## Start all services with Tailscale sidecar
	$(COMPOSE_TS) up -d

down: ## Stop and remove all containers
	$(COMPOSE_BASE) down

logs: ## Follow logs for all services
	$(COMPOSE_BASE) logs -f

status: ## Show container status
	$(COMPOSE_BASE) ps

update: ## Pull latest images and restart services
	$(COMPOSE_BASE) pull && $(COMPOSE_BASE) up -d

shell: ## Open a shell in the hermes container
	$(COMPOSE_BASE) exec hermes sh

setup: ## Run the interactive setup wizard
	bash setup.sh
