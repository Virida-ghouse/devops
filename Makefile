# 🚀 VIRIDA Makefile
# Commandes simplifiées pour le développement et le déploiement

.PHONY: help build dev staging prod clean logs status

# Variables
DOCKER_COMPOSE_DEV = docker-compose -f infrastructure/docker/docker-compose.dev.yml
DOCKER_COMPOSE_STAGING = docker-compose -f infrastructure/docker/docker-compose.staging.yml
DOCKER_COMPOSE_PROD = docker-compose -f infrastructure/docker/docker-compose.prod.yml

# Couleurs
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Aide
help: ## Afficher l'aide
	@echo "$(BLUE)🚀 VIRIDA - Commandes disponibles$(NC)"
	@echo ""
	@echo "$(GREEN)Environnements:$(NC)"
	@echo "  dev       - Environnement de développement"
	@echo "  staging   - Environnement de staging"
	@echo "  prod      - Environnement de production"
	@echo ""
	@echo "$(GREEN)Clever Cloud:$(NC)"
	@echo "  clever-deploy         - Déploie sur Clever Cloud"
	@echo "  clever-deploy-complete - Déploiement complet avec tests"
	@echo "  clever-status         - Statut Clever Cloud"
	@echo "  clever-logs           - Logs Clever Cloud"
	@echo "  clever-health         - Test de santé"
	@echo ""
	@echo "$(GREEN)Gitea Actions:$(NC)"
	@echo "  gitea-setup   - Configure les secrets Gitea"
	@echo "  gitea-update  - Met à jour les workflows"
	@echo "  gitea-test    - Test des workflows"
	@echo ""
	@echo "$(GREEN)Kubernetes & ArgoCD:$(NC)"
	@echo "  k8s-deploy    - Déploie sur Kubernetes avec ArgoCD"
	@echo "  k8s-gitops    - Configure GitOps avec ArgoCD"
	@echo "  k8s-status    - Statut Kubernetes"
	@echo "  k8s-logs      - Logs Kubernetes"
	@echo ""
	@echo "$(GREEN)Optimisation:$(NC)"
	@echo "  optimize      - Optimise les Dockerfiles"
	@echo "  cache-clean   - Nettoie le cache Docker"
	@echo "  cache-stats   - Statistiques du cache"
	@echo ""
	@echo "$(GREEN)Commandes:$(NC)"
	@echo "  build     - Construire toutes les images Docker"
	@echo "  clean     - Nettoyer les ressources Docker"
	@echo "  logs      - Afficher les logs des services"
	@echo "  status    - Afficher le statut des services"
	@echo ""
	@echo "$(GREEN)Exemples:$(NC)"
	@echo "  make clever-deploy-complete  - Déploiement complet Clever Cloud"
	@echo "  make k8s-deploy             - Déploiement Kubernetes"
	@echo "  make k8s-gitops             - Configuration GitOps"
	@echo "  make gitea-setup            - Configurer Gitea"
	@echo ""

# ========================================
# CONSTRUCTION DES IMAGES
# ========================================
build: ## Construire toutes les images Docker
	@echo "$(BLUE)🔨 Construction des images Docker...$(NC)"
	@./infrastructure/scripts/deploy.sh dev build
	@./infrastructure/scripts/deploy.sh staging build
	@./infrastructure/scripts/deploy.sh prod build
	@echo "$(GREEN)✅ Toutes les images ont été construites$(NC)"

# ========================================
# DÉPLOIEMENT CLEVER CLOUD
# ========================================
clever-deploy: ## Déploie sur Clever Cloud
	@echo "🚀 Déploiement sur Clever Cloud..."
	clever deploy --same-commit-policy rebuild
	@echo "✅ Déploiement terminé!"

clever-deploy-complete: ## Déploiement complet avec tests
	@echo "🚀 Déploiement complet VIRIDA..."
	./infrastructure/scripts/deploy-complete.sh
	@echo "✅ Déploiement complet terminé!"

clever-status: ## Affiche le statut sur Clever Cloud
	@echo "📊 Statut Clever Cloud..."
	clever status

clever-logs: ## Affiche les logs Clever Cloud
	@echo "📝 Logs Clever Cloud..."
	clever logs

clever-health: ## Test de santé de l'application
	@echo "🏥 Test de santé..."
	@curl -s https://app-e10f4ca6-35ab-49e6-967f-cf1ebc40bc37.cleverapps.io/health | jq .

# ========================================
# GITEA ACTIONS & CI/CD
# ========================================
gitea-setup: ## Configure les secrets Gitea Actions
	@echo "🔐 Configuration des secrets Gitea..."
	./infrastructure/scripts/setup-gitea-secrets.sh

gitea-update: ## Met à jour les workflows Gitea Actions
	@echo "🔄 Mise à jour des workflows Gitea..."
	./infrastructure/scripts/update-gitea-workflows.sh

gitea-test: ## Test des workflows Gitea Actions
	@echo "🧪 Test des workflows Gitea..."
	./infrastructure/scripts/test-workflows.sh

# ========================================
# KUBERNETES & ARGOCD
# ========================================
k8s-deploy: ## Déploie sur Kubernetes avec ArgoCD
	@echo "🚀 Déploiement Kubernetes et ArgoCD..."
	./infrastructure/scripts/deploy-kubernetes.sh
	@echo "✅ Déploiement Kubernetes terminé!"

k8s-gitops: ## Configure GitOps avec ArgoCD
	@echo "🔧 Configuration GitOps..."
	./infrastructure/scripts/setup-gitops.sh
	@echo "✅ Configuration GitOps terminée!"

k8s-status: ## Affiche le statut Kubernetes
	@echo "📊 Statut Kubernetes..."
	@kubectl get pods -n virida
	@kubectl get pods -n argocd
	@kubectl get pods -n monitoring

k8s-logs: ## Affiche les logs Kubernetes
	@echo "📝 Logs Kubernetes..."
	@kubectl logs -f deployment/backend-api-gateway -n virida

# ========================================
# OPTIMISATION & CACHE
# ========================================
optimize: ## Optimise les Dockerfiles pour Clever Cloud
	@echo "⚡ Optimisation des Dockerfiles..."
	./infrastructure/scripts/optimize-for-clever.sh

cache-clean: ## Nettoie le cache Docker
	@echo "🧹 Nettoyage du cache Docker..."
	./infrastructure/scripts/docker-cache.sh

cache-stats: ## Affiche les statistiques du cache
	@echo "📊 Statistiques du cache..."
	./infrastructure/scripts/cache-stats.sh

# ========================================
# ENVIRONNEMENT DE DÉVELOPPEMENT
# ========================================
dev: ## Déployer l'environnement de développement
	@echo "$(BLUE)🚀 Déploiement de l'environnement de développement...$(NC)"
	@./infrastructure/scripts/deploy.sh dev deploy

dev-build: ## Construire pour l'environnement de développement
	@echo "$(BLUE)🔨 Construction pour le développement...$(NC)"
	@./infrastructure/scripts/deploy.sh dev build

dev-stop: ## Arrêter l'environnement de développement
	@echo "$(YELLOW)⏹️  Arrêt de l'environnement de développement...$(NC)"
	@./infrastructure/scripts/deploy.sh dev stop

dev-restart: ## Redémarrer l'environnement de développement
	@echo "$(BLUE)🔄 Redémarrage de l'environnement de développement...$(NC)"
	@./infrastructure/scripts/deploy.sh dev restart

dev-logs: ## Afficher les logs de développement
	@echo "$(BLUE)📋 Logs de l'environnement de développement...$(NC)"
	@./infrastructure/scripts/deploy.sh dev logs

dev-status: ## Afficher le statut de développement
	@echo "$(BLUE)📊 Statut de l'environnement de développement...$(NC)"
	@./infrastructure/scripts/deploy.sh dev status

dev-clean: ## Nettoyer l'environnement de développement
	@echo "$(RED)🧹 Nettoyage de l'environnement de développement...$(NC)"
	@./infrastructure/scripts/deploy.sh dev clean

# ========================================
# ENVIRONNEMENT DE STAGING
# ========================================
staging: ## Déployer l'environnement de staging
	@echo "$(BLUE)🚀 Déploiement de l'environnement de staging...$(NC)"
	@./infrastructure/scripts/deploy.sh staging deploy

staging-build: ## Construire pour l'environnement de staging
	@echo "$(BLUE)🔨 Construction pour le staging...$(NC)"
	@./infrastructure/scripts/deploy.sh staging build

staging-stop: ## Arrêter l'environnement de staging
	@echo "$(YELLOW)⏹️  Arrêt de l'environnement de staging...$(NC)"
	@./infrastructure/scripts/deploy.sh staging stop

staging-restart: ## Redémarrer l'environnement de staging
	@echo "$(BLUE)🔄 Redémarrage de l'environnement de staging...$(NC)"
	@./infrastructure/scripts/deploy.sh staging restart

staging-logs: ## Afficher les logs de staging
	@echo "$(BLUE)📋 Logs de l'environnement de staging...$(NC)"
	@./infrastructure/scripts/deploy.sh staging logs

staging-status: ## Afficher le statut de staging
	@echo "$(BLUE)📊 Statut de l'environnement de staging...$(NC)"
	@./infrastructure/scripts/deploy.sh staging status

staging-clean: ## Nettoyer l'environnement de staging
	@echo "$(RED)🧹 Nettoyage de l'environnement de staging...$(NC)"
	@./infrastructure/scripts/deploy.sh staging clean

# ========================================
# ENVIRONNEMENT DE PRODUCTION
# ========================================
prod: ## Déployer l'environnement de production
	@echo "$(BLUE)🚀 Déploiement de l'environnement de production...$(NC)"
	@./infrastructure/scripts/deploy.sh prod deploy

prod-build: ## Construire pour l'environnement de production
	@echo "$(BLUE)🔨 Construction pour la production...$(NC)"
	@./infrastructure/scripts/deploy.sh prod build

prod-stop: ## Arrêter l'environnement de production
	@echo "$(YELLOW)⏹️  Arrêt de l'environnement de production...$(NC)"
	@./infrastructure/scripts/deploy.sh prod stop

prod-restart: ## Redémarrer l'environnement de production
	@echo "$(BLUE)🔄 Redémarrage de l'environnement de production...$(NC)"
	@./infrastructure/scripts/deploy.sh prod restart

prod-logs: ## Afficher les logs de production
	@echo "$(BLUE)📋 Logs de l'environnement de production...$(NC)"
	@./infrastructure/scripts/deploy.sh prod logs

prod-status: ## Afficher le statut de production
	@echo "$(BLUE)📊 Statut de l'environnement de production...$(NC)"
	@./infrastructure/scripts/deploy.sh prod status

prod-clean: ## Nettoyer l'environnement de production
	@echo "$(RED)🧹 Nettoyage de l'environnement de production...$(NC)"
	@./infrastructure/scripts/deploy.sh prod clean

# ========================================
# COMMANDES GLOBALES
# ========================================
logs: ## Afficher les logs de tous les environnements
	@echo "$(BLUE)📋 Logs de tous les environnements...$(NC)"
	@echo "$(YELLOW)=== DÉVELOPPEMENT ===$(NC)"
	@$(DOCKER_COMPOSE_DEV) logs --tail=50
	@echo "$(YELLOW)=== STAGING ===$(NC)"
	@$(DOCKER_COMPOSE_STAGING) logs --tail=50
	@echo "$(YELLOW)=== PRODUCTION ===$(NC)"
	@$(DOCKER_COMPOSE_PROD) logs --tail=50

status: ## Afficher le statut de tous les environnements
	@echo "$(BLUE)📊 Statut de tous les environnements...$(NC)"
	@echo "$(YELLOW)=== DÉVELOPPEMENT ===$(NC)"
	@$(DOCKER_COMPOSE_DEV) ps
	@echo "$(YELLOW)=== STAGING ===$(NC)"
	@$(DOCKER_COMPOSE_STAGING) ps
	@echo "$(YELLOW)=== PRODUCTION ===$(NC)"
	@$(DOCKER_COMPOSE_PROD) ps

clean: ## Nettoyer toutes les ressources Docker
	@echo "$(RED)🧹 Nettoyage de toutes les ressources...$(NC)"
	@./infrastructure/scripts/deploy.sh dev clean
	@./infrastructure/scripts/deploy.sh staging clean
	@./infrastructure/scripts/deploy.sh prod clean
	@echo "$(GREEN)✅ Toutes les ressources ont été nettoyées$(NC)"

# ========================================
# COMMANDES DE DÉVELOPPEMENT
# ========================================
install: ## Installer les dépendances pour tous les services
	@echo "$(BLUE)📦 Installation des dépendances...$(NC)"
	@cd frontend/3d-visualizer && npm install
	@cd frontend/dashboard && npm install
	@cd backend/api-gateway && npm install
	@cd backend/auth-service && npm install
	@cd ai-ml/prediction-engine && pip install -r requirements.txt
	@cd ai-ml/eve-assistant && pip install -r requirements.txt
	@cd iot/sensor-collector && pip install -r requirements.txt
	@echo "$(GREEN)✅ Toutes les dépendances ont été installées$(NC)"

test: ## Exécuter les tests pour tous les services
	@echo "$(BLUE)🧪 Exécution des tests...$(NC)"
	@cd frontend/3d-visualizer && npm test
	@cd frontend/dashboard && npm test
	@cd backend/api-gateway && npm test
	@cd backend/auth-service && npm test
	@cd ai-ml/prediction-engine && python -m pytest
	@cd ai-ml/eve-assistant && python -m pytest
	@cd iot/sensor-collector && python -m pytest
	@echo "$(GREEN)✅ Tous les tests ont été exécutés$(NC)"

lint: ## Exécuter le linting pour tous les services
	@echo "$(BLUE)🔍 Exécution du linting...$(NC)"
	@cd frontend/3d-visualizer && npm run lint
	@cd frontend/dashboard && npm run lint
	@cd backend/api-gateway && npm run lint
	@cd backend/auth-service && npm run lint
	@cd ai-ml/prediction-engine && flake8 .
	@cd ai-ml/eve-assistant && flake8 .
	@cd iot/sensor-collector && flake8 .
	@echo "$(GREEN)✅ Le linting a été exécuté$(NC)"

# ========================================
# COMMANDES DE MAINTENANCE
# ========================================
backup: ## Sauvegarder les données
	@echo "$(BLUE)💾 Sauvegarde des données...$(NC)"
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@echo "$(GREEN)✅ Sauvegarde terminée$(NC)"

update: ## Mettre à jour les dépendances
	@echo "$(BLUE)🔄 Mise à jour des dépendances...$(NC)"
	@cd frontend/3d-visualizer && npm update
	@cd frontend/dashboard && npm update
	@cd backend/api-gateway && npm update
	@cd backend/auth-service && npm update
	@cd ai-ml/prediction-engine && pip install --upgrade -r requirements.txt
	@cd ai-ml/eve-assistant && pip install --upgrade -r requirements.txt
	@cd iot/sensor-collector && pip install --upgrade -r requirements.txt
	@echo "$(GREEN)✅ Toutes les dépendances ont été mises à jour$(NC)"

# ========================================
# COMMANDES DE SÉCURITÉ
# ========================================
security-scan: ## Exécuter les scans de sécurité
	@echo "$(BLUE)🔒 Exécution des scans de sécurité...$(NC)"
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image virida/3d-visualizer:latest
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image virida/api-gateway:latest
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image virida/prediction-engine:latest
	@echo "$(GREEN)✅ Scans de sécurité terminés$(NC)"

# ========================================
# COMMANDES DE MONITORING
# ========================================
monitor: ## Afficher les métriques de monitoring
	@echo "$(BLUE)📊 Métriques de monitoring...$(NC)"
	@echo "$(YELLOW)Prometheus: http://localhost:9090$(NC)"
	@echo "$(YELLOW)Grafana: http://localhost:3002$(NC)"
	@echo "$(YELLOW)Logs: make logs$(NC)"

# ========================================
# COMMANDES DE DÉVELOPPEMENT RAPIDE
# ========================================
setup-env: ## Configurer les variables d'environnement
	@echo "$(BLUE)⚙️  Configuration des variables d'environnement...$(NC)"
	@cd infrastructure/docker && ./../scripts/setup-env.sh
	@echo "$(GREEN)✅ Variables d'environnement configurées$(NC)"

quick-dev: ## Démarrage rapide pour le développement
	@echo "$(BLUE)⚡ Démarrage rapide pour le développement...$(NC)"
	@make setup-env
	@make dev-build
	@make dev
	@echo "$(GREEN)✅ Environnement de développement prêt$(NC)"

quick-test: ## Test rapide de tous les services
	@echo "$(BLUE)⚡ Test rapide de tous les services...$(NC)"
	@make dev-build
	@make dev
	@sleep 10
	@make test
	@echo "$(GREEN)✅ Tests rapides terminés$(NC)"

# ========================================
# COMMANDES DE DÉPLOIEMENT
# ========================================
deploy-all: ## Déployer tous les environnements
	@echo "$(BLUE)🚀 Déploiement de tous les environnements...$(NC)"
	@make dev
	@make staging
	@make prod
	@echo "$(GREEN)✅ Tous les environnements ont été déployés$(NC)"

# ========================================
# COMMANDES DE NETTOYAGE
# ========================================
clean-all: ## Nettoyer tous les environnements
	@echo "$(RED)🧹 Nettoyage de tous les environnements...$(NC)"
	@make dev-clean
	@make staging-clean
	@make prod-clean
	@echo "$(GREEN)✅ Tous les environnements ont été nettoyés$(NC)"

# ========================================
# COMMANDES D'INFORMATION
# ========================================
info: ## Afficher les informations du projet
	@echo "$(BLUE)ℹ️  Informations du projet VIRIDA$(NC)"
	@echo ""
	@echo "$(GREEN)Version:$(NC) 1.0.0"
	@echo "$(GREEN)Environnements:$(NC) dev, staging, prod"
	@echo "$(GREEN)Services:$(NC) frontend, backend, ai-ml, iot"
	@echo "$(GREEN)Technologies:$(NC) Docker, Node.js, Python, PostgreSQL, Redis"
	@echo ""
	@echo "$(GREEN)Commandes utiles:$(NC)"
	@echo "  make help        - Afficher l'aide"
	@echo "  make quick-dev   - Démarrage rapide"
	@echo "  make status      - Statut des services"
	@echo "  make logs        - Voir les logs"
	@echo "  make clean       - Nettoyer les ressources"
