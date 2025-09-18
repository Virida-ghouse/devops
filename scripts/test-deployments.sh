#!/bin/bash

# Script de test pour les déploiements VIRIDA
# Usage: ./scripts/test-deployments.sh

set -e

echo "🚀 Test des déploiements VIRIDA"
echo "================================"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour tester une URL
test_url() {
    local url=$1
    local service_name=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $service_name ($url)... "
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_status"; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Fonction pour tester un service local
test_local_service() {
    local port=$1
    local service_name=$2
    local path=${3:-/health}
    
    echo -n "Testing $service_name (localhost:$port$path)... "
    
    if curl -s -f "http://localhost:$port$path" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

echo ""
echo "🔍 Test des services locaux (si démarrés)"
echo "----------------------------------------"

# Test des services locaux
test_local_service 3000 "Frontend 3D" "/health" || echo -e "${YELLOW}⚠️  Frontend 3D non démarré${NC}"
test_local_service 8080 "Backend API" "/health" || echo -e "${YELLOW}⚠️  Backend API non démarré${NC}"
test_local_service 8000 "AI/ML Engine" "/health" || echo -e "${YELLOW}⚠️  AI/ML Engine non démarré${NC}"

echo ""
echo "🌐 Test des services de production"
echo "----------------------------------"

# Test des services de production
test_url "https://virida-frontend-3d.cleverapps.io/health" "Frontend 3D Production"
test_url "https://virida-backend-api.cleverapps.io/health" "Backend API Production"
test_url "https://virida-ai-ml.cleverapps.io/health" "AI/ML Engine Production"

echo ""
echo "📊 Résumé des tests"
echo "==================="

# Compter les tests réussis
local_tests=0
production_tests=0

# Test local
if curl -s -f "http://localhost:3000/health" > /dev/null 2>&1; then
    ((local_tests++))
fi
if curl -s -f "http://localhost:8080/health" > /dev/null 2>&1; then
    ((local_tests++))
fi
if curl -s -f "http://localhost:8000/health" > /dev/null 2>&1; then
    ((local_tests++))
fi

# Test production
if curl -s -f "https://virida-frontend-3d.cleverapps.io/health" > /dev/null 2>&1; then
    ((production_tests++))
fi
if curl -s -f "https://virida-backend-api.cleverapps.io/health" > /dev/null 2>&1; then
    ((production_tests++))
fi
if curl -s -f "https://virida-ai-ml.cleverapps.io/health" > /dev/null 2>&1; then
    ((production_tests++))
fi

echo "Services locaux: $local_tests/3"
echo "Services production: $production_tests/3"

if [ $production_tests -eq 3 ]; then
    echo -e "${GREEN}🎉 Tous les services de production fonctionnent !${NC}"
    exit 0
elif [ $local_tests -eq 3 ]; then
    echo -e "${YELLOW}⚠️  Services locaux OK, mais production en panne${NC}"
    exit 1
else
    echo -e "${RED}❌ Problèmes détectés dans les déploiements${NC}"
    exit 1
fi


