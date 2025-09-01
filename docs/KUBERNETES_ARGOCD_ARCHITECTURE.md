# ☸️ VIRIDA Kubernetes + ArgoCD Architecture

## 📋 Vue d'Ensemble

Cette documentation détaille l'architecture **Kubernetes + ArgoCD** pour VIRIDA, implémentant une approche **GitOps** complète avec déploiement continu, monitoring avancé et gestion déclarative de l'infrastructure.

## 🎯 Objectifs de l'Architecture

### **✅ Avantages de Kubernetes + ArgoCD**
- **Orchestration avancée** : Gestion automatique des conteneurs
- **Haute disponibilité** : Auto-réparation et scaling automatique
- **GitOps** : Déploiement basé sur Git avec synchronisation automatique
- **Sécurité renforcée** : RBAC, Network Policies, Pod Security Policies
- **Monitoring intégré** : Métriques, logs et alertes centralisés
- **Scalabilité** : Adaptation automatique à la charge

### **🔧 Composants Principaux**
- **Kubernetes Cluster** : Orchestration des conteneurs
- **ArgoCD** : Contrôleur GitOps pour la synchronisation
- **Helm Charts** : Templates de déploiement standardisés
- **Prometheus + Grafana** : Monitoring et observabilité
- **NGINX Ingress** : Routage et load balancing
- **HashiCorp Vault** : Gestion des secrets

## 🏗️ Architecture du Cluster

### **1. Topologie des Namespaces**

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   kube-     │  │   virida-   │  │   virida-   │        │
│  │   system    │  │   system    │  │    apps     │        │
│  │             │  │             │  │             │        │
│  │ • k3s       │  │ • ingress   │  │ • frontend  │        │
│  │ • metrics   │  │ • vault     │  │ • backend   │        │
│  │ • coredns   │  │ • cert-     │  │ • ai-ml     │        │
│  │             │  │   manager   │  │ • iot       │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                           │
│  ┌─────────────┐  ┌─────────────┐                        │
│  │   virida-   │  │   argocd    │                        │
│  │ monitoring  │  │             │                        │
│  │             │  │ • server    │                        │
│  │ • prometheus│  │ • controller│                        │
│  │ • grafana   │  │ • repo      │                        │
│  │ • jaeger    │  │ • cli       │                        │
│  │ • elastic   │  └─────────────┘                        │
│  └─────────────┘                                          │
└─────────────────────────────────────────────────────────────┘
```

### **2. Configuration Réseau**

#### **Pods Network**
- **CIDR** : `10.42.0.0/16`
- **Service CIDR** : `10.43.0.0/16`
- **Cluster Domain** : `virida.local`

#### **Network Policies**
```yaml
# Politique par défaut : Deny All
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: virida-apps
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress

# Autorisation du monitoring
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: virida-apps
spec:
  podSelector: {}
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: virida-monitoring
      ports:
        - protocol: TCP
          port: 8080
        - protocol: TCP
          port: 9090
```

### **3. Configuration RBAC**

#### **ClusterRole VIRIDA Admin**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: virida-admin
rules:
  - apiGroups: [""]
    resources: ["*"]
    verbs: ["*"]
  - apiGroups: ["apps"]
    resources: ["*"]
    verbs: ["*"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["*"]
    verbs: ["*"]
```

#### **ServiceAccount et Binding**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: virida-admin
  namespace: virida-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: virida-admin-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: virida-admin
subjects:
  - kind: ServiceAccount
    name: virida-admin
    namespace: virida-system
```

## 🚀 ArgoCD GitOps

### **1. Architecture ArgoCD**

```
┌─────────────────────────────────────────────────────────────┐
│                    Gitea Repository                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              VIRIDA Applications                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │  Frontend   │  │   Backend   │  │   AI/ML     │ │   │
│  │  │  3D Viz     │  │ API Gateway │  │ Prediction  │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    ArgoCD Server                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Application Controller                  │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Repo      │  │   Sync      │  │   Health    │ │   │
│  │  │  Server     │  │  Engine     │  │   Check     │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                Kubernetes Cluster                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              VIRIDA Services                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │  Frontend   │  │   Backend   │  │   AI/ML     │ │   │
│  │  │  3D Viz     │  │ API Gateway │  │ Prediction  │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### **2. Configuration des Applications**

#### **Application Frontend 3D Visualizer**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: frontend-3d-visualizer
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://gitea.virida.local/frontend/3d-visualizer.git
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: virida-apps
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
  revisionHistoryLimit: 10
```

#### **Politique de Synchronisation**
```yaml
# Configuration dans argocd-cm ConfigMap
sync.policy: |
  automated:
    prune: true
    selfHeal: true
  retry:
    limit: 5
    backoff:
      duration: 5s
      factor: 2
      maxDuration: 3m
```

### **3. Intégration avec Gitea**

#### **Repository Configuration**
```yaml
repositories: |
  - type: git
    url: https://gitea.virida.local
    name: virida-gitea
    insecure: true
    usernameSecret:
      name: gitea-credentials
      key: username
    passwordSecret:
      name: gitea-credentials
      key: password
```

#### **Webhooks et Notifications**
```yaml
notifications: |
  triggers:
    - name: on-sync-succeeded
      condition: app.status.operationState.phase in ['Succeeded']
      template: app-sync-succeeded
      enabled: true
    - name: on-sync-failed
      condition: app.status.operationState.phase in ['Error', 'Failed']
      template: app-sync-failed
      enabled: true
    - name: on-health-degraded
      condition: app.status.health.status == 'Degraded'
      template: app-health-degraded
      enabled: true
```

## 🎨 Helm Charts

### **1. Structure des Charts**

```
helm-charts/
├── frontend-3d-visualizer/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── configmap.yaml
│       └── _helpers.tpl
├── backend-api-gateway/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── ai-ml-prediction-engine/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── shared/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
```

### **2. Chart Frontend 3D Visualizer**

#### **Chart.yaml**
```yaml
apiVersion: v2
name: frontend-3d-visualizer
description: VIRIDA 3D Visualization Frontend Service
type: application
version: 1.0.0
appVersion: "1.0.0"
keywords:
  - virida
  - frontend
  - 3d
  - visualization
  - react
  - threejs
annotations:
  argocd.argoproj.io/sync-wave: "1"
  argocd.argoproj.io/sync-options: Prune=true
  argocd.argoproj.io/auto-prune: "true"
  argocd.argoproj.io/self-heal: "true"
```

#### **values.yaml**
```yaml
# Configuration par défaut
replicaCount: 2

image:
  repository: virida/frontend-3d-visualizer
  tag: "latest"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 3000

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: 3d.virida.local
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

config:
  nodeEnv: production
  apiUrl: http://backend-api-gateway:3000
  additionalEnvVars:
    NEXT_TELEMETRY_DISABLED: "1"
    NEXT_PUBLIC_API_URL: "https://api.virida.local"

persistence:
  enabled: false

securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5

startupProbe:
  httpGet:
    path: /health
    port: 3000
  failureThreshold: 30
  periodSeconds: 10

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - frontend-3d-visualizer
          topologyKey: kubernetes.io/hostname

topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: frontend-3d-visualizer
```

### **3. Templates Kubernetes**

#### **Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "frontend-3d-visualizer.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "frontend-3d-visualizer.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
  selector:
    matchLabels:
      {{- include "frontend-3d-visualizer.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "frontend-3d-visualizer.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
          env:
            - name: NODE_ENV
              value: {{ .Values.config.nodeEnv | quote }}
            - name: PORT
              value: {{ .Values.service.port | quote }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          livenessProbe:
            {{- toYaml .Values.livenessProbe | nindent 12 }}
          readinessProbe:
            {{- toYaml .Values.readinessProbe | nindent 12 }}
```

## 📊 Monitoring et Observabilité

### **1. Stack Prometheus + Grafana**

#### **Prometheus Configuration**
```yaml
# Prometheus Operator
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  namespace: virida-monitoring
spec:
  replicas: 1
  retention: 7d
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi
  storage:
    volumeClaimTemplate:
      spec:
        resources:
          requests:
            storage: 10Gi
```

#### **Grafana Dashboards**
```yaml
# Dashboard VIRIDA Frontend
apiVersion: v1
kind: ConfigMap
metadata:
  name: virida-frontend-dashboard
  namespace: virida-monitoring
  labels:
    grafana_dashboard: "1"
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "VIRIDA Frontend Metrics",
        "panels": [
          {
            "title": "Response Time",
            "type": "graph",
            "targets": [
              {
                "expr": "http_request_duration_seconds",
                "legendFormat": "{{pod}}"
              }
            ]
          }
        ]
      }
    }
```

### **2. Métriques VIRIDA**

#### **Métriques Frontend**
- **Response Time** : Temps de réponse des composants React
- **Bundle Size** : Taille des bundles JavaScript
- **Error Rate** : Taux d'erreurs côté client
- **User Interactions** : Interactions utilisateur (clics, navigation)

#### **Métriques Backend**
- **API Response Time** : Temps de réponse des API
- **Database Queries** : Performance des requêtes
- **Memory Usage** : Utilisation mémoire des services
- **Error Rate** : Taux d'erreurs des services

#### **Métriques Infrastructure**
- **Pod Health** : État des pods Kubernetes
- **Resource Usage** : CPU, mémoire, disque
- **Network Traffic** : Trafic réseau inter-services
- **Storage Performance** : Performance des volumes

### **3. Alertes et Notifications**

#### **Règles d'Alerte Prometheus**
```yaml
groups:
  - name: virida-alerts
    rules:
      - alert: HighResponseTime
        expr: http_request_duration_seconds > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "Service {{ $labels.service }} has high response time"
      
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Service {{ $labels.service }} has high error rate"
      
      - alert: PodDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Pod is down"
          description: "Pod {{ $labels.pod }} is down"
```

## 🔒 Sécurité

### **1. Pod Security Policies**

#### **Policy Restrictive**
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: virida-restrictive
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
  readOnlyRootFilesystem: true
```

### **2. Network Policies**

#### **Policy Frontend**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-network-policy
  namespace: virida-apps
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: frontend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: virida-system
      ports:
        - protocol: TCP
          port: 3000
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: virida-apps
      ports:
        - protocol: TCP
          port: 3000
    - to: []
      ports:
        - protocol: TCP
          port: 53
        - protocol: UDP
          port: 53
```

### **3. Secrets Management**

#### **HashiCorp Vault Integration**
```yaml
# Vault Agent Injector
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-agent-injector
  namespace: virida-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vault-agent-injector
  template:
    metadata:
      labels:
        app: vault-agent-injector
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-secret-database: "secret/data/virida/database"
        vault.hashicorp.com/role: "virida-app"
    spec:
      serviceAccountName: vault-auth
      containers:
        - name: vault-agent-injector
          image: hashicorp/vault-k8s:latest
          env:
            - name: VAULT_ADDR
              value: "http://vault:8200"
```

## 📈 Scaling et Performance

### **1. Horizontal Pod Autoscaler**

#### **HPA Frontend**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-3d-visualizer-hpa
  namespace: virida-apps
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend-3d-visualizer
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
```

### **2. Vertical Pod Autoscaler**

#### **VPA Frontend**
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: frontend-3d-visualizer-vpa
  namespace: virida-apps
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend-3d-visualizer
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
      - containerName: '*'
        minAllowed:
          cpu: 100m
          memory: 128Mi
        maxAllowed:
          cpu: 1000m
          memory: 1Gi
        controlledValues: RequestsAndLimits
```

### **3. Cluster Autoscaler**

#### **Configuration Cluster Autoscaler**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      containers:
        - name: cluster-autoscaler
          image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
          command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --expander=least-waste
            - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/virida-cluster
            - --balance-similar-node-groups
            - --skip-nodes-with-system-pods=false
```

## 🔄 CI/CD et GitOps

### **1. Workflow GitOps**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer    │    │   Gitea        │    │   ArgoCD        │
│                │    │   Repository   │    │   Controller    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │ 1. Push Code         │                       │
         │─────────────────────▶│                       │
         │                       │                       │
         │                       │ 2. Webhook Trigger    │
         │                       │─────────────────────▶│
         │                       │                       │
         │                       │                       │ 3. Sync
         │                       │                       │ Kubernetes
         │                       │                       │◀────────────
         │                       │                       │
         │                       │                       │ 4. Deploy
         │                       │                       │ Services
         │                       │                       │◀────────────
         │                       │                       │
         │                       │                       │ 5. Health
         │                       │                       │ Check
         │                       │                       │◀────────────
         │                       │                       │
         │                       │                       │ 6. Rollback
         │                       │                       │ if needed
         │                       │                       │◀────────────
```

### **2. Gitea Actions Workflow**

#### **.gitea/workflows/deploy.yml**
```yaml
name: Deploy to Kubernetes
run-name: Deploy ${{ gitea.ref_name }} to ${{ vars.ENVIRONMENT }}

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    types: [closed]
    branches:
      - main

env:
  ENVIRONMENT: ${{ vars.ENVIRONMENT || 'development' }}
  KUBECONFIG: ${{ secrets.KUBECONFIG }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Kubernetes
        uses: azure/setup-kubectl@v3
        with:
          version: 'latest'
          
      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f k8s/
          
      - name: Wait for deployment
        run: |
          kubectl wait --for=condition=available --timeout=300s deployment/frontend-3d-visualizer -n virida-apps
          
      - name: Run tests
        run: |
          kubectl run test --image=curlimages/curl --rm -i --restart=Never -- curl -f http://frontend-3d-visualizer:3000/health
```

### **3. ArgoCD ApplicationSet**

#### **ApplicationSet pour tous les services**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: virida-services
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - name: frontend-3d-visualizer
            repo: frontend/3d-visualizer
            path: k8s
            namespace: virida-apps
          - name: frontend-dashboard
            repo: frontend/dashboard
            path: k8s
            namespace: virida-apps
          - name: backend-api-gateway
            repo: backend/api-gateway
            path: k8s
            namespace: virida-apps
          - name: ai-ml-prediction-engine
            repo: ai-ml/prediction-engine
            path: k8s
            namespace: virida-apps
  template:
    metadata:
      name: '{{name}}'
      namespace: argocd
      labels:
        app.kubernetes.io/name: '{{name}}'
        app.kubernetes.io/part-of: virida
    spec:
      project: default
      source:
        repoURL: https://gitea.virida.local/{{repo}}.git
        targetRevision: HEAD
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
          - PrunePropagationPolicy=foreground
          - PruneLast=true
      revisionHistoryLimit: 10
```

## 🚨 Troubleshooting

### **1. Problèmes Courants**

#### **Pod en CrashLoopBackOff**
```bash
# Vérifier les logs du pod
kubectl logs -n virida-apps deployment/frontend-3d-visualizer

# Vérifier les événements
kubectl get events -n virida-apps --sort-by='.lastTimestamp'

# Vérifier la configuration
kubectl describe pod -n virida-apps -l app.kubernetes.io/name=frontend-3d-visualizer
```

#### **Service non accessible**
```bash
# Vérifier les endpoints
kubectl get endpoints -n virida-apps

# Vérifier la configuration du service
kubectl describe service -n virida-apps frontend-3d-visualizer

# Tester la connectivité interne
kubectl run test --image=curlimages/curl --rm -i --restart=Never -- curl -f http://frontend-3d-visualizer:3000
```

#### **ArgoCD ne synchronise pas**
```bash
# Vérifier le statut d'ArgoCD
kubectl get applications -n argocd

# Vérifier les logs d'ArgoCD
kubectl logs -n argocd deployment/argocd-application-controller

# Vérifier la configuration du repository
kubectl get configmap -n argocd argocd-cm -o yaml
```

### **2. Commandes de Debug**

#### **Vérification du cluster**
```bash
# Statut des nodes
kubectl get nodes -o wide

# Statut des pods système
kubectl get pods -n kube-system

# Utilisation des ressources
kubectl top nodes
kubectl top pods --all-namespaces
```

#### **Vérification des services**
```bash
# Services dans tous les namespaces
kubectl get services --all-namespaces

# Endpoints
kubectl get endpoints --all-namespaces

# Ingress
kubectl get ingress --all-namespaces
```

#### **Vérification du monitoring**
```bash
# Statut de Prometheus
kubectl get pods -n virida-monitoring

# Métriques Prometheus
kubectl port-forward -n virida-monitoring service/prometheus-kube-prometheus-prometheus 9090:9090

# Dashboards Grafana
kubectl port-forward -n virida-monitoring service/prometheus-grafana 3000:80
```

## 📚 Ressources et Support

### **1. Documentation Officielle**

- **Kubernetes** : [https://kubernetes.io/docs/](https://kubernetes.io/docs/)
- **ArgoCD** : [https://argo-cd.readthedocs.io/](https://argo-cd.readthedocs.io/)
- **Helm** : [https://helm.sh/docs/](https://helm.sh/docs/)
- **Prometheus** : [https://prometheus.io/docs/](https://prometheus.io/docs/)

### **2. Outils Recommandés**

- **k9s** : Interface TUI pour Kubernetes
- **Lens** : IDE pour Kubernetes
- **kubectx** : Gestion des contextes Kubernetes
- **kubens** : Gestion des namespaces
- **stern** : Logs multi-pods

### **3. Formation et Communauté**

- **Kubernetes Slack** : [slack.k8s.io](https://slack.k8s.io/)
- **ArgoCD Slack** : [argoproj.slack.com](https://argoproj.slack.com/)
- **CNCF Training** : [training.cncf.io](https://training.cncf.io/)

---

## 🎯 Prochaines Étapes

### **Phase 1 - Infrastructure de Base**
- [x] Configuration du cluster Kubernetes
- [x] Installation d'ArgoCD
- [x] Configuration des applications de base

### **Phase 2 - Monitoring et Observabilité**
- [ ] Déploiement de Prometheus + Grafana
- [ ] Configuration des dashboards VIRIDA
- [ ] Mise en place des alertes

### **Phase 3 - Sécurité et Performance**
- [ ] Configuration des Pod Security Policies
- [ ] Mise en place des Network Policies
- [ ] Configuration du Cluster Autoscaler

### **Phase 4 - Production et Maintenance**
- [ ] Tests de charge et performance
- [ ] Configuration du backup et disaster recovery
- [ ] Formation de l'équipe

---

*Dernière mise à jour : $(date)*
*Version : 1.0.0*
*Environnement : Kubernetes + ArgoCD*

