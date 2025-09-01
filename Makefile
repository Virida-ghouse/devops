# 🚀 VIRIDA Docker Makefile
# Commandes standardisées pour le développement et le déploiement

.PHONY: help build build-all build-frontend build-backend build-ai-ml build-infrastructure \
        up up-frontend up-backend up-ai-ml up-infrastructure up-monitoring up-tools \
        down down-all logs logs-frontend logs-backend logs-ai-ml logs-infrastructure \
        clean clean-all clean-volumes clean-images test test-frontend test-backend test-ai-ml \
        lint lint-frontend lint-backend lint-ai-ml format format-frontend format-backend \
        shell shell-frontend shell-backend shell-ai-ml shell-infrastructure \
        restart restart-all scale scale-frontend scale-backend scale-ai-ml \
        health health-all logs-follow logs-follow-all

# Configuration
COMPOSE_FILE := docker-compose.dev.yml
COMPOSE_PROD_FILE := docker-compose.gitea.yml
PROJECT_NAME := virida

# Couleurs pour le terminal
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Aide
help: ## Afficher l'aide
	@echo "$(BLUE)🚀 VIRIDA Docker Makefile$(NC)"
	@echo "$(GREEN)Commandes disponibles:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

# ========================================
# BUILD COMMANDS
# ========================================

build: ## Construire tous les services
	@echo "$(BLUE)🔨 Construction de tous les services VIRIDA...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build

build-all: build ## Alias pour build

build-frontend: ## Construire les services frontend
	@echo "$(BLUE)🎨 Construction des services frontend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build frontend-3d-visualizer frontend-dashboard

build-backend: ## Construire les services backend
	@echo "$(BLUE)⚙️  Construction des services backend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build backend-api-gateway backend-user-service

build-ai-ml: ## Construire les services AI/ML
	@echo "$(BLUE)🤖 Construction des services AI/ML...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build ai-ml-prediction-engine

build-infrastructure: ## Construire les services d'infrastructure
	@echo "$(BLUE)🏗️  Construction des services d'infrastructure...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build postgres redis

# ========================================
# START COMMANDS
# ========================================

up: ## Démarrer tous les services
	@echo "$(BLUE)🚀 Démarrage de tous les services VIRIDA...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d

up-frontend: ## Démarrer les services frontend
	@echo "$(BLUE)🎨 Démarrage des services frontend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile frontend up -d

up-backend: ## Démarrer les services backend
	@echo "$(BLUE)⚙️  Démarrage des services backend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile backend up -d

up-ai-ml: ## Démarrer les services AI/ML
	@echo "$(BLUE)🤖 Démarrage des services AI/ML...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile ai-ml up -d

up-infrastructure: ## Démarrer les services d'infrastructure
	@echo "$(BLUE)🏗️  Démarrage des services d'infrastructure...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile infrastructure up -d

up-monitoring: ## Démarrer les services de monitoring
	@echo "$(BLUE)📊 Démarrage des services de monitoring...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile monitoring up -d

up-tools: ## Démarrer les outils de développement
	@echo "$(BLUE)🛠️  Démarrage des outils de développement...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile tools up -d

# ========================================
# STOP COMMANDS
# ========================================

down: ## Arrêter tous les services
	@echo "$(BLUE)🛑 Arrêt de tous les services VIRIDA...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

down-all: down ## Alias pour down

# ========================================
# LOGS COMMANDS
# ========================================

logs: ## Afficher les logs de tous les services
	docker-compose -f $(COMPOSE_FILE) logs -f

logs-frontend: ## Afficher les logs des services frontend
	docker-compose -f $(COMPOSE_FILE) logs -f frontend-3d-visualizer frontend-dashboard

logs-backend: ## Afficher les logs des services backend
	docker-compose -f $(COMPOSE_FILE) logs -f backend-api-gateway backend-user-service

logs-ai-ml: ## Afficher les logs des services AI/ML
	docker-compose -f $(COMPOSE_FILE) logs -f ai-ml-prediction-engine

logs-infrastructure: ## Afficher les logs des services d'infrastructure
	docker-compose -f $(COMPOSE_FILE) logs -f postgres redis

logs-follow: logs ## Alias pour logs

logs-follow-all: logs ## Alias pour logs

# ========================================
# CLEANUP COMMANDS
# ========================================

clean: ## Nettoyer les conteneurs et réseaux
	@echo "$(BLUE)🧹 Nettoyage des conteneurs et réseaux...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down --remove-orphans

clean-all: clean clean-volumes clean-images ## Nettoyer complètement

clean-volumes: ## Nettoyer les volumes
	@echo "$(BLUE)🗑️  Nettoyage des volumes...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down -v
	docker volume prune -f

clean-images: ## Nettoyer les images non utilisées
	@echo "$(BLUE)🖼️  Nettoyage des images...$(NC)"
	docker image prune -f

# ========================================
# TEST COMMANDS
# ========================================

test: ## Lancer tous les tests
	@echo "$(BLUE)🧪 Lancement de tous les tests...$(NC)"
	@$(MAKE) test-frontend
	@$(MAKE) test-backend
	@$(MAKE) test-ai-ml

test-frontend: ## Lancer les tests frontend
	@echo "$(BLUE)🎨 Tests frontend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec frontend-3d-visualizer npm test || true
	docker-compose -f $(COMPOSE_FILE) exec frontend-dashboard npm test || true

test-backend: ## Lancer les tests backend
	@echo "$(BLUE)⚙️  Tests backend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec backend-api-gateway npm test || true
	docker-compose -f $(COMPOSE_FILE) exec backend-user-service npm test || true

test-ai-ml: ## Lancer les tests AI/ML
	@echo "$(BLUE)🤖 Tests AI/ML...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec ai-ml-prediction-engine python -m pytest || true

# ========================================
# LINTING COMMANDS
# ========================================

lint: ## Lancer le linting sur tous les services
	@echo "$(BLUE)🔍 Linting de tous les services...$(NC)"
	@$(MAKE) lint-frontend
	@$(MAKE) lint-backend
	@$(MAKE) lint-ai-ml

lint-frontend: ## Linting des services frontend
	@echo "$(BLUE)🎨 Linting frontend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec frontend-3d-visualizer npm run lint || true
	docker-compose -f $(COMPOSE_FILE) exec frontend-dashboard npm run lint || true

lint-backend: ## Linting des services backend
	@echo "$(BLUE)⚙️  Linting backend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec backend-api-gateway npm run lint || true
	docker-compose -f $(COMPOSE_FILE) exec backend-user-service npm run lint || true

lint-ai-ml: ## Linting des services AI/ML
	@echo "$(BLUE)🤖 Linting AI/ML...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec ai-ml-prediction-engine python -m flake8 || true

# ========================================
# FORMATTING COMMANDS
# ========================================

format: ## Formater le code de tous les services
	@echo "$(BLUE)✨ Formatage de tous les services...$(NC)"
	@$(MAKE) format-frontend
	@$(MAKE) format-backend
	@$(MAKE) format-ai-ml

format-frontend: ## Formatage des services frontend
	@echo "$(BLUE)🎨 Formatage frontend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec frontend-3d-visualizer npm run format || true
	docker-compose -f $(COMPOSE_FILE) exec frontend-dashboard npm run format || true

format-backend: ## Formatage des services backend
	@echo "$(BLUE)⚙️  Formatage backend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec backend-api-gateway npm run format || true
	docker-compose -f $(COMPOSE_FILE) exec backend-user-service npm run format || true

format-ai-ml: ## Formatage des services AI/ML
	@echo "$(BLUE)🤖 Formatage AI/ML...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec ai-ml-prediction-engine python -m black . || true

# ========================================
# SHELL COMMANDS
# ========================================

shell: ## Ouvrir un shell dans le premier service disponible
	@echo "$(BLUE)🐚 Ouverture d'un shell...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec backend-api-gateway sh

shell-frontend: ## Shell dans un service frontend
	@echo "$(BLUE)🎨 Shell frontend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec frontend-3d-visualizer sh

shell-backend: ## Shell dans un service backend
	@echo "$(BLUE)⚙️  Shell backend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec backend-api-gateway sh

shell-ai-ml: ## Shell dans un service AI/ML
	@echo "$(BLUE)🤖 Shell AI/ML...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec ai-ml-prediction-engine bash

shell-infrastructure: ## Shell dans un service d'infrastructure
	@echo "$(BLUE)🏗️  Shell infrastructure...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec postgres psql -U virida_user -d virida_dev

# ========================================
# RESTART COMMANDS
# ========================================

restart: ## Redémarrer tous les services
	@echo "$(BLUE)🔄 Redémarrage de tous les services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart

restart-all: restart ## Alias pour restart

# ========================================
# SCALE COMMANDS
# ========================================

scale: ## Afficher l'état des services
	@echo "$(BLUE)📊 État des services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps

scale-frontend: ## Mettre à l'échelle les services frontend
	@echo "$(BLUE)🎨 Mise à l'échelle frontend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d --scale frontend-3d-visualizer=2 --scale frontend-dashboard=2

scale-backend: ## Mettre à l'échelle les services backend
	@echo "$(BLUE)⚙️  Mise à l'échelle backend...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d --scale backend-api-gateway=2 --scale backend-user-service=2

scale-ai-ml: ## Mettre à l'échelle les services AI/ML
	@echo "$(BLUE)🤖 Mise à l'échelle AI/ML...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d --scale ai-ml-prediction-engine=2

# ========================================
# HEALTH COMMANDS
# ========================================

health: ## Vérifier la santé de tous les services
	@echo "$(BLUE)🏥 Vérification de la santé des services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps

health-all: health ## Alias pour health

# ========================================
# PRODUCTION COMMANDS
# ========================================

prod-up: ## Démarrer l'infrastructure de production
	@echo "$(BLUE)🚀 Démarrage de l'infrastructure de production...$(NC)"
	docker-compose -f $(COMPOSE_PROD_FILE) up -d

prod-down: ## Arrêter l'infrastructure de production
	@echo "$(BLUE)🛑 Arrêt de l'infrastructure de production...$(NC)"
	docker-compose -f $(COMPOSE_PROD_FILE) down

prod-logs: ## Logs de l'infrastructure de production
	docker-compose -f $(COMPOSE_PROD_FILE) logs -f

# ========================================
# UTILITY COMMANDS
# ========================================

status: ## Afficher le statut de tous les services
	@echo "$(BLUE)📊 Statut des services VIRIDA...$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo "$(GREEN)Services disponibles:$(NC)"
	@echo "  🎨 Frontend: http://localhost:3001 (3D), http://localhost:3002 (Dashboard)"
	@echo "  ⚙️  Backend: http://localhost:3000 (API Gateway), http://localhost:3004 (User Service)"
	@echo "  🤖 AI/ML: http://localhost:8000 (Prediction Engine)"
	@echo "  📊 Monitoring: http://localhost:9090 (Prometheus), http://localhost:3003 (Grafana)"
	@echo "  🛠️  Tools: http://localhost:8025 (MailHog), http://localhost:4444 (Selenium)"

logs-tail: ## Logs avec tail (dernières lignes)
	docker-compose -f $(COMPOSE_FILE) logs --tail=100 -f

logs-error: ## Logs d'erreur uniquement
	docker-compose -f $(COMPOSE_FILE) logs --tail=100 | grep -i error

# ========================================
# DEFAULT TARGET
# ========================================

.DEFAULT_GOAL := help

