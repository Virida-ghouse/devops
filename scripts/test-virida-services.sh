#!/bin/bash

# 🧪 VIRIDA Services Test Script
# Teste tous les services déployés

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Test des Services VIRIDA${NC}"
echo "=================================="

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des services Kubernetes
check_kubernetes_services() {
    log_info "Vérification des services Kubernetes..."
    
    # Vérifier les pods
    echo -e "\n${BLUE}📊 État des Pods:${NC}"
    kubectl get pods -n virida-apps
    
    # Vérifier les services
    echo -e "\n${BLUE}🌐 Services exposés:${NC}"
    kubectl get svc -n virida-apps
    
    # Vérifier les endpoints
    echo -e "\n${BLUE}🔗 Endpoints:${NC}"
    kubectl get endpoints -n virida-apps
}

# Test des endpoints de santé
test_health_endpoints() {
    log_info "Test des endpoints de santé..."
    
    # Récupérer les URLs des services
    FRONTEND_URL=$(minikube service frontend-3d-visualizer -n virida-apps --url 2>/dev/null | head -1)
    BACKEND_URL=$(minikube service backend-api-gateway -n virida-apps --url 2>/dev/null | head -1)
    AI_ML_URL=$(minikube service ai-ml-prediction-engine -n virida-apps --url 2>/dev/null | head -1)
    
    echo -e "\n${BLUE}🔍 URLs des Services:${NC}"
    echo "Frontend 3D: $FRONTEND_URL"
    echo "Backend API: $BACKEND_URL"
    echo "AI/ML Engine: $AI_ML_URL"
    
    # Test Frontend
    if [ ! -z "$FRONTEND_URL" ]; then
        log_info "Test du Frontend 3D Visualizer..."
        if curl -s "$FRONTEND_URL/health" > /dev/null; then
            log_success "Frontend /health ✅"
        else
            log_error "Frontend /health ❌"
        fi
        
        if curl -s "$FRONTEND_URL/ready" > /dev/null; then
            log_success "Frontend /ready ✅"
        else
            log_error "Frontend /ready ❌"
        fi
    fi
    
    # Test Backend
    if [ ! -z "$BACKEND_URL" ]; then
        log_info "Test du Backend API Gateway..."
        if curl -s "$BACKEND_URL/health" > /dev/null; then
            log_success "Backend /health ✅"
        else
            log_error "Backend /health ❌"
        fi
        
        if curl -s "$BACKEND_URL/api/info" > /dev/null; then
            log_success "Backend /api/info ✅"
        else
            log_error "Backend /api/info ❌"
        fi
    fi
    
    # Test AI/ML
    if [ ! -z "$AI_ML_URL" ]; then
        log_info "Test de l'AI/ML Prediction Engine..."
        if curl -s "$AI_ML_URL/health" > /dev/null; then
            log_success "AI/ML /health ✅"
        else
            log_error "AI/ML /health ❌"
        fi
        
        if curl -s "$AI_ML_URL/api/info" > /dev/null; then
            log_success "AI/ML /api/info ✅"
        else
            log_error "AI/ML /api/info ❌"
        fi
    fi
}

# Test des fonctionnalités API
test_api_functionality() {
    log_info "Test des fonctionnalités API..."
    
    BACKEND_URL=$(minikube service backend-api-gateway -n virida-apps --url 2>/dev/null | head -1)
    AI_ML_URL=$(minikube service ai-ml-prediction-engine -n virida-apps --url 2>/dev/null | head -1)
    
    if [ ! -z "$BACKEND_URL" ]; then
        echo -e "\n${BLUE}🔧 Test Backend API:${NC}"
        
        # Test Users API
        echo "Test /api/users:"
        curl -s "$BACKEND_URL/api/users" | jq . 2>/dev/null || echo "❌ Erreur"
        
        # Test Data API
        echo "Test /api/data:"
        curl -s "$BACKEND_URL/api/data" | jq . 2>/dev/null || echo "❌ Erreur"
        
        # Test AI API
        echo "Test /api/ai:"
        curl -s "$BACKEND_URL/api/ai" | jq . 2>/dev/null || echo "❌ Erreur"
    fi
    
    if [ ! -z "$AI_ML_URL" ]; then
        echo -e "\n${BLUE}🤖 Test AI/ML API:${NC}"
        
        # Test Prediction API
        echo "Test /api/predict:"
        curl -s "$AI_ML_URL/api/predict" | jq . 2>/dev/null || echo "❌ Erreur"
        
        # Test Classification API
        echo "Test /api/classify:"
        curl -s "$AI_ML_URL/api/classify" | jq . 2>/dev/null || echo "❌ Erreur"
        
        # Test NLP API
        echo "Test /api/nlp:"
        curl -s "$AI_ML_URL/api/nlp" | jq . 2>/dev/null || echo "❌ Erreur"
    fi
}

# Test de la connectivité inter-services
test_service_connectivity() {
    log_info "Test de la connectivité inter-services..."
    
    # Vérifier que les services peuvent communiquer entre eux
    echo -e "\n${BLUE}🔗 Test de connectivité:${NC}"
    
    # Test depuis le frontend vers le backend
    FRONTEND_POD=$(kubectl get pods -n virida-apps -l app=frontend-3d-visualizer -o jsonpath='{.items[0].metadata.name}')
    if [ ! -z "$FRONTEND_POD" ]; then
        log_info "Test de connectivité depuis Frontend vers Backend..."
        if kubectl exec -n virida-apps $FRONTEND_POD -- curl -s http://backend-api-gateway:8080/health > /dev/null 2>&1; then
            log_success "Frontend → Backend ✅"
        else
            log_warning "Frontend → Backend ⚠️"
        fi
    fi
    
    # Test depuis le backend vers l'AI/ML
    BACKEND_POD=$(kubectl get pods -n virida-apps -l app=backend-api-gateway -o jsonpath='{.items[0].metadata.name}')
    if [ ! -z "$BACKEND_POD" ]; then
        log_info "Test de connectivité depuis Backend vers AI/ML..."
        if kubectl exec -n virida-apps $BACKEND_POD -- curl -s http://ai-ml-prediction-engine:8000/health > /dev/null 2>&1; then
            log_success "Backend → AI/ML ✅"
        else
            log_warning "Backend → AI/ML ⚠️"
        fi
    fi
}

# Affichage des informations d'accès
show_access_info() {
    echo -e "\n${GREEN}🎉 Tests terminés !${NC}"
    echo "=================================="
    
    echo -e "\n${BLUE}🔗 Accès aux Services:${NC}"
    
    FRONTEND_URL=$(minikube service frontend-3d-visualizer -n virida-apps --url 2>/dev/null | head -1)
    BACKEND_URL=$(minikube service backend-api-gateway -n virida-apps --url 2>/dev/null | head -1)
    AI_ML_URL=$(minikube service ai-ml-prediction-engine -n virida-apps --url 2>/dev/null | head -1)
    
    echo "• Frontend 3D: $FRONTEND_URL"
    echo "• Backend API: $BACKEND_URL"
    echo "• AI/ML Engine: $AI_ML_URL"
    
    echo -e "\n${YELLOW}📝 Prochaines étapes:${NC}"
    echo "1. Ouvrir les URLs dans votre navigateur"
    echo "2. Tester les fonctionnalités interactives"
    echo "3. Configurer Jenkins CI/CD"
    echo "4. Déployer sur Clever Cloud"
}

# Fonction principale
main() {
    check_kubernetes_services
    test_health_endpoints
    test_api_functionality
    test_service_connectivity
    show_access_info
}

# Exécution
main "$@"

