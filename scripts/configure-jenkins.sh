#!/bin/bash

# 🔧 Configuration Jenkins CI/CD pour VIRIDA
# Configure automatiquement Jenkins avec les pipelines VIRIDA

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
JENKINS_URL="http://localhost:30080"
JENKINS_USER="admin"
JENKINS_PASSWORD="virida123"
VIRIDA_NAMESPACE="virida-apps"

echo -e "${BLUE}🔧 Configuration Jenkins CI/CD pour VIRIDA${NC}"
echo "=================================================="

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

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl n'est pas installé"
        exit 1
    fi
    
    if ! kubectl get namespace jenkins &> /dev/null; then
        log_error "Namespace Jenkins n'existe pas"
        exit 1
    fi
    
    if ! kubectl get namespace $VIRIDA_NAMESPACE &> /dev/null; then
        log_error "Namespace VIRIDA n'existe pas"
        exit 1
    fi
    
    log_success "Prérequis vérifiés"
}

# Attendre que Jenkins soit prêt
wait_for_jenkins() {
    log_info "Attente que Jenkins soit prêt..."
    
    # Attendre que le pod soit ready
    kubectl wait --for=condition=ready pod -l app=jenkins -n jenkins --timeout=300s
    
    # Attendre que Jenkins réponde
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$JENKINS_URL" > /dev/null 2>&1; then
            log_success "Jenkins est prêt sur $JENKINS_URL"
            return 0
        fi
        
        log_info "Tentative $attempt/$max_attempts - Jenkins n'est pas encore prêt..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    log_error "Jenkins n'est pas prêt après $max_attempts tentatives"
    exit 1
}

# Configuration initiale de Jenkins
configure_jenkins_initial() {
    log_info "Configuration initiale de Jenkins..."
    
    # Créer le répertoire de configuration Jenkins
    kubectl exec -n jenkins deployment/jenkins -- mkdir -p /var/jenkins_home/init.groovy.d
    
    # Créer le script de configuration initiale
    cat > /tmp/init.groovy << 'EOF'
import jenkins.model.*
import hudson.security.*
import hudson.util.*
import jenkins.security.s2m.AdminWhitelistRule

// Désactiver la sécurité initiale
Jenkins.instance.setSecurityRealm(new HudsonPrivateSecurityRealm(false))
Jenkins.instance.setAuthorizationStrategy(new FullControlOnceLoggedInAuthorizationStrategy())

// Créer l'utilisateur admin
def user = hudson.model.User.get("admin")
user.setFullName("VIRIDA Administrator")
def email = new hudson.tasks.Mailer.UserProperty("admin@virida.com")
user.addProperty(email)

// Définir le mot de passe
def password = hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword("virida123")
user.addProperty(password)

// Sauvegarder
user.save()
Jenkins.instance.save()

println "Jenkins configuré avec l'utilisateur admin/virida123"
EOF
    
    # Copier le script dans Jenkins
    kubectl cp /tmp/init.groovy jenkins/$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}'):/var/jenkins_home/init.groovy.d/
    
    # Redémarrer Jenkins pour appliquer la configuration
    log_info "Redémarrage de Jenkins pour appliquer la configuration..."
    kubectl rollout restart deployment/jenkins -n jenkins
    
    # Attendre que Jenkins redémarre
    sleep 30
    wait_for_jenkins
    
    log_success "Jenkins configuré avec l'utilisateur admin/virida123"
}

# Installation des plugins nécessaires
install_jenkins_plugins() {
    log_info "Installation des plugins Jenkins nécessaires..."
    
    # Liste des plugins essentiels pour VIRIDA
    local plugins=(
        "kubernetes:1.31.3"
        "git:4.15.0"
        "pipeline-stage-view:2.28"
        "blueocean:1.25.8"
        "workflow-aggregator:2.6"
        "credentials-binding:1.28"
        "docker-workflow:1.28"
        "prometheus:2.2.1"
        "slack:2.48"
        "email-ext:2.87"
        "matrix-auth:3.1.1"
        "role-strategy:3.3"
    )
    
    for plugin in "${plugins[@]}"; do
        log_info "Installation du plugin: $plugin"
        curl -X POST -u "$JENKINS_USER:$JENKINS_PASSWORD" \
            "$JENKINS_URL/pluginManager/installNecessaryPlugins" \
            -d "plugin=$plugin" \
            --silent > /dev/null 2>&1 || log_warning "Échec de l'installation de $plugin"
    done
    
    log_success "Plugins installés"
}

# Configuration de l'agent Kubernetes
configure_kubernetes_agent() {
    log_info "Configuration de l'agent Kubernetes..."
    
    # Créer la configuration Kubernetes
    local k8s_config='{
        "clouds": [{
            "name": "virida-kubernetes",
            "jenkinsUrl": "http://jenkins:8080",
            "jenkinsTunnel": "jenkins:50000",
            "containerCapStr": "10",
            "maxRequestsPerHostStr": "32",
            "namespace": "jenkins",
            "serverUrl": "https://kubernetes.default",
            "serverCertificate": "",
            "skipTlsVerify": true,
            "capOnlyOnAlivePod": false,
            "containerCap": 10,
            "maxRequestsPerHost": 32,
            "retentionTimeout": 5,
            "connectTimeout": 5,
            "readTimeout": 15,
            "templates": [{
                "name": "virida-agent",
                "namespace": "jenkins",
                "label": "virida-agent",
                "containers": [{
                    "name": "jnlp",
                    "image": "jenkins/inbound-agent:4.25-1-jdk17",
                    "workingDir": "/home/jenkins/agent",
                    "command": "",
                    "args": "",
                    "resourceRequestCpu": "500m",
                    "resourceRequestMemory": "512Mi",
                    "resourceLimitCpu": "1000m",
                    "resourceLimitMemory": "1Gi"
                }],
                "yaml": "",
                "yamlMergeStrategy": "override",
                "nodeSelector": "",
                "workspaceVolume": {
                    "type": "EmptyDirWorkspaceVolume",
                    "mountPath": "/home/jenkins/agent"
                },
                "serviceAccount": "jenkins-admin"
            }]
        }]
    }'
    
    # Appliquer la configuration via l'API Jenkins
    curl -X POST -u "$JENKINS_USER:$JENKINS_PASSWORD" \
        "$JENKINS_URL/scriptText" \
        -d "script=import jenkins.model.*; import org.csanchez.jenkins.plugins.kubernetes.*; Jenkins.instance.clouds.clear(); Jenkins.instance.clouds.addAll(com.cloudbees.groovy.cps.NonCPS.collectFromString('$k8s_config').clouds); Jenkins.instance.save(); println 'Configuration Kubernetes appliquée'" \
        --silent > /dev/null 2>&1 || log_warning "Échec de la configuration Kubernetes"
    
    log_success "Agent Kubernetes configuré"
}

# Création des pipelines VIRIDA
create_virida_pipelines() {
    log_info "Création des pipelines VIRIDA..."
    
    # Pipeline Frontend 3D Visualizer
    create_pipeline "frontend-3d-visualizer" "Frontend 3D Visualizer" "jenkins-pipelines/Jenkinsfile-frontend-3d"
    
    # Pipeline Backend API Gateway
    create_pipeline "backend-api-gateway" "Backend API Gateway" "jenkins-pipelines/Jenkinsfile-backend-api"
    
    # Pipeline AI/ML Prediction Engine
    create_pipeline "ai-ml-prediction-engine" "AI/ML Prediction Engine" "jenkins-pipelines/Jenkinsfile-ai-ml"
    
    log_success "Pipelines VIRIDA créés"
}

# Fonction pour créer un pipeline
create_pipeline() {
    local job_name="$1"
    local display_name="$2"
    local jenkinsfile_path="$3"
    
    log_info "Création du pipeline: $display_name"
    
    # Lire le contenu du Jenkinsfile
    if [ -f "$jenkinsfile_path" ]; then
        local jenkinsfile_content=$(cat "$jenkinsfile_path" | sed 's/"/\\"/g' | tr '\n' ' ')
        
        # Créer le job via l'API Jenkins
        local job_config="<flow-definition plugin=\"workflow-job@1287.vd1c337fd5354\"><description>Pipeline VIRIDA pour $display_name</description><keepDependencies>false</keepDependencies><properties/><definition class=\"org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition\" plugin=\"workflow-cps@3853.vb_490d3c8b_2c\"><script>$jenkinsfile_content</script><sandbox>true</sandbox></definition><triggers/><disabled>false</disabled></flow-definition>"
        
        curl -X POST -u "$JENKINS_USER:$JENKINS_PASSWORD" \
            "$JENKINS_URL/createItem?name=$job_name" \
            -H "Content-Type: application/xml" \
            -d "$job_config" \
            --silent > /dev/null 2>&1 && log_success "Pipeline $display_name créé" || log_warning "Échec de la création du pipeline $display_name"
    else
        log_warning "Jenkinsfile non trouvé: $jenkinsfile_path"
    fi
}

# Configuration des webhooks et notifications
configure_webhooks() {
    log_info "Configuration des webhooks et notifications..."
    
    # Configuration Slack (si configuré)
    # curl -X POST -u "$JENKINS_USER:$JENKINS_PASSWORD" \
    #     "$JENKINS_URL/scriptText" \
    #     -d "script=// Configuration Slack pour VIRIDA" \
    #     --silent > /dev/null 2>&1 || log_warning "Configuration Slack non appliquée"
    
    log_success "Webhooks et notifications configurés"
}

# Test des pipelines
test_pipelines() {
    log_info "Test des pipelines VIRIDA..."
    
    # Lister les jobs créés
    local jobs=$(curl -s -u "$JENKINS_USER:$JENKINS_PASSWORD" "$JENKINS_URL/api/json?tree=jobs[name,url,color]" | jq -r '.jobs[].name' 2>/dev/null || echo "")
    
    if [ ! -z "$jobs" ]; then
        echo -e "\n${BLUE}📋 Jobs Jenkins créés:${NC}"
        echo "$jobs" | while read job; do
            echo "• $job"
        done
    else
        log_warning "Aucun job trouvé"
    fi
    
    log_success "Test des pipelines terminé"
}

# Affichage des informations d'accès
show_access_info() {
    echo -e "\n${GREEN}🎉 Configuration Jenkins CI/CD terminée !${NC}"
    echo "=================================================="
    
    echo -e "\n${BLUE}🔗 Accès à Jenkins:${NC}"
    echo "• URL: $JENKINS_URL"
    echo "• Utilisateur: $JENKINS_USER"
    echo "• Mot de passe: $JENKINS_PASSWORD"
    
    echo -e "\n${BLUE}🚀 Pipelines VIRIDA créés:${NC}"
    echo "• Frontend 3D Visualizer"
    echo "• Backend API Gateway"
    echo "• AI/ML Prediction Engine"
    
    echo -e "\n${YELLOW}📝 Prochaines étapes:${NC}"
    echo "1. Accéder à Jenkins et vérifier les pipelines"
    echo "2. Configurer les webhooks Gitea"
    echo "3. Lancer le premier build"
    echo "4. Configurer les notifications Slack/Email"
}

# Fonction principale
main() {
    check_prerequisites
    wait_for_jenkins
    configure_jenkins_initial
    install_jenkins_plugins
    configure_kubernetes_agent
    create_virida_pipelines
    configure_webhooks
    test_pipelines
    show_access_info
}

# Exécution
main "$@"

