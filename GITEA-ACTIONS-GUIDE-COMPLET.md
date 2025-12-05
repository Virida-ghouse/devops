# 🚀 Guide Complet : Mise en Place Gitea Actions & Runners

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Activation de Gitea Actions](#activation-de-gitea-actions)
4. [Installation et Configuration des Runners](#installation-et-configuration-des-runners)
5. [Création des Workflows](#création-des-workflows)
6. [Test et Vérification](#test-et-vérification)
7. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

Gitea Actions permet d'automatiser les tâches CI/CD directement dans Gitea, similaire à GitHub Actions. Le système nécessite :

- **Gitea** version 1.19+ avec Actions activées
- **Runners** (act_runner) pour exécuter les workflows
- **Workflows** définis dans `.gitea/workflows/`

---

## ✅ Prérequis

### 1. Vérifier la version de Gitea

Assure-toi que ton instance Gitea est en version 1.19.0 ou supérieure :

- Va sur `https://gitea.virida.org`
- Vérifie la version en bas de page (ex: "Propulsé par Gitea Version: 1.22.4")

### 2. Activer Gitea Actions au niveau de l'instance

Si tu es administrateur de l'instance Gitea, vérifie que Actions est activé dans la configuration :

```ini
[actions]
ENABLED=true
```

---

## 🔧 Activation de Gitea Actions

### Étape 1 : Activer Actions pour le dépôt

1. Va sur ton dépôt : `https://gitea.virida.org/Virida/devops`
2. Clique sur **Settings** (Paramètres)
3. Va dans **Actions** → **General**
4. Active **Enable Actions** (Activer les Actions)
5. Sauvegarde

### Étape 2 : Vérifier que les workflows sont présents

Les workflows doivent être dans le dossier `.gitea/workflows/` :

```bash
ls -la .gitea/workflows/
```

Tu devrais voir des fichiers comme :
- `ci-cd.yml`
- `pr-validation.yml`
- `test.yml`
- etc.

---

## 🤖 Installation et Configuration des Runners

### Option A : Runner Local (macOS/Linux)

#### 1. Télécharger act_runner

**Pour macOS ARM64 (Apple Silicon) :**
```bash
cd /tmp
wget https://gitea.com/gitea/act_runner/releases/download/v0.2.13/act_runner-0.2.13-darwin-arm64
chmod +x act_runner-0.2.13-darwin-arm64
sudo mv act_runner-0.2.13-darwin-arm64 /usr/local/bin/act_runner
```

**Pour macOS Intel (amd64) :**
```bash
cd /tmp
wget https://gitea.com/gitea/act_runner/releases/download/v0.2.13/act_runner-0.2.13-darwin-amd64
chmod +x act_runner-0.2.13-darwin-amd64
sudo mv act_runner-0.2.13-darwin-amd64 /usr/local/bin/act_runner
```

**Pour Linux amd64 :**
```bash
cd /tmp
wget https://gitea.com/gitea/act_runner/releases/download/v0.2.13/act_runner-0.2.13-linux-amd64
chmod +x act_runner-0.2.13-linux-amd64
sudo mv act_runner-0.2.13-linux-amd64 /usr/local/bin/act_runner
```

#### 2. Obtenir le Registration Token

1. Va sur `https://gitea.virida.org/Virida/devops/settings/actions/runners`
2. Clique sur **"Créer un nouvel exécuteur"** (Create new runner)
3. Copie le **REGISTRATION TOKEN** affiché
4. ⚠️ **Important** : Ce token est différent du Personal Access Token

#### 3. Enregistrer le runner

```bash
act_runner register \
  --instance https://gitea.virida.org \
  --token VOTRE_REGISTRATION_TOKEN \
  --name virida-runner-local \
  --labels ubuntu-latest:docker://node:18,ubuntu-latest:docker://python:3.11 \
  --no-interactive
```

**Explication des paramètres :**
- `--instance` : URL de ton instance Gitea
- `--token` : Le registration token copié à l'étape précédente
- `--name` : Nom du runner (peut être personnalisé)
- `--labels` : Labels définissant les environnements disponibles
  - `ubuntu-latest` : Environnement de base
  - `docker://node:18` : Docker avec Node.js 18
  - `docker://python:3.11` : Docker avec Python 3.11

#### 4. Démarrer le runner

```bash
act_runner daemon
```

Le runner va maintenant écouter les jobs et les exécuter automatiquement.

**Pour le démarrer en arrière-plan :**
```bash
nohup act_runner daemon > /tmp/act_runner.log 2>&1 &
```

**Pour vérifier qu'il fonctionne :**
```bash
ps aux | grep act_runner
```

### Option B : Runner sur Clever Cloud (Production)

#### 1. Préparer la configuration

Le fichier `clevercloud-gitea-runner.json` est déjà configuré. Assure-toi que les variables d'environnement sont définies :

```json
{
  "environment": {
    "GITEA_INSTANCE_URL": "https://gitea.virida.org",
    "GITEA_TOKEN": "VOTRE_REGISTRATION_TOKEN",
    "RUNNER_NAME": "virida-runner-cloud",
    "RUNNER_LABELS": "ubuntu-latest:docker://node:18"
  }
}
```

#### 2. Déployer sur Clever Cloud

```bash
clever create --type docker virida-gitea-runner
clever link virida-gitea-runner
clever env set GITEA_INSTANCE_URL https://gitea.virida.org
clever env set GITEA_TOKEN VOTRE_REGISTRATION_TOKEN
clever env set RUNNER_NAME virida-runner-cloud
clever deploy
```

---

## 📝 Création des Workflows

### Structure des Workflows

Les workflows sont des fichiers YAML dans `.gitea/workflows/` avec la syntaxe suivante :

```yaml
name: Nom du Workflow

on:
  push:
    branches: [ main, staging ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  mon-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Exécuter une commande
        run: echo "Hello World"
```

### Workflows Disponibles dans VIRIDA

#### 1. PR Validation (`pr-validation.yml`)

Valide les Pull Requests :
- Vérifie la taille de la PR
- Analyse le code
- Valide les builds

#### 2. CI/CD Pipeline (`ci-cd.yml`)

Pipeline complet :
- Validation
- Tests
- Build
- Security scan

#### 3. Tests (`test.yml`)

Exécute les tests automatisés

#### 4. Security Scan (`security-scan.yml`)

Scan de sécurité du code

#### 5. Déploiement (`deploy-clever-cloud.yml`)

Déploiement automatique sur Clever Cloud

### Créer un Nouveau Workflow

1. Crée un fichier `.gitea/workflows/mon-workflow.yml`
2. Ajoute la structure YAML
3. Commit et push :

```bash
git add .gitea/workflows/mon-workflow.yml
git commit -m "feat: add new workflow"
git push origin devops_crk
```

---

## 🧪 Test et Vérification

### 1. Vérifier que le Runner est Actif

**Sur Gitea :**
1. Va sur `https://gitea.virida.org/Virida/devops/settings/actions/runners`
2. Tu devrais voir ton runner avec le statut "Online" (En ligne)

**En ligne de commande :**
```bash
ps aux | grep act_runner
```

### 2. Déclencher un Workflow

**Option 1 : Push sur une branche**
```bash
echo "# Test" >> README.md
git add README.md
git commit -m "test: trigger workflow"
git push origin devops_crk
```

**Option 2 : Créer une Pull Request**
- Crée une PR depuis `devops_crk` vers `main`
- Le workflow `pr-validation.yml` se déclenchera automatiquement

**Option 3 : Déclencher manuellement**
- Va sur `https://gitea.virida.org/Virida/devops/actions`
- Clique sur un workflow
- Clique sur "Run workflow"

### 3. Vérifier l'Exécution

1. Va sur `https://gitea.virida.org/Virida/devops/actions`
2. Tu devrais voir les workflows en cours d'exécution
3. Clique sur un workflow pour voir les détails et les logs

### 4. Vérifier les Logs du Runner

**Si le runner est local :**
```bash
tail -f /tmp/act_runner.log
```

**Si le runner est sur Clever Cloud :**
```bash
clever logs --app virida-gitea-runner
```

---

## 🔍 Dépannage

### Le runner ne prend pas les jobs

**Vérifier que le runner est enregistré :**
```bash
act_runner list
```

**Vérifier les logs :**
```bash
# Local
tail -f /tmp/act_runner.log

# Clever Cloud
clever logs --app virida-gitea-runner
```

**Vérifier Docker (si utilisation de labels Docker) :**
```bash
docker ps
docker info
```

### Les workflows ne se déclenchent pas

1. **Vérifier que Gitea Actions est activé** dans les paramètres du dépôt
2. **Vérifier que les fichiers `.gitea/workflows/*.yml` sont présents** dans le dépôt
3. **Vérifier la syntaxe YAML** des workflows
4. **Vérifier que le runner a les bons labels** correspondant à `runs-on` dans les workflows

### Erreur "No runner available"

1. **Vérifier qu'au moins un runner est enregistré et actif**
2. **Vérifier que les labels du workflow correspondent aux labels du runner**
   - Si le workflow utilise `runs-on: ubuntu-latest`
   - Le runner doit avoir le label `ubuntu-latest`
3. **Vérifier que le runner a les permissions nécessaires**

### Erreur Docker

Si tu utilises des labels Docker (`docker://node:18`), assure-toi que :
- Docker est installé et démarré
- Le runner a accès à Docker (groupe `docker`)

```bash
# Vérifier Docker
docker ps

# Ajouter l'utilisateur au groupe docker (Linux)
sudo usermod -aG docker $USER
```

### Le runner se déconnecte

**Pour le maintenir actif en production, utilise un service systemd (Linux) :**

```bash
# Créer le service
sudo nano /etc/systemd/system/gitea-runner.service
```

Contenu :
```ini
[Unit]
Description=Gitea Runner for VIRIDA
After=network.target docker.service

[Service]
Type=simple
User=runner
WorkingDirectory=/opt/gitea-runner
ExecStart=/usr/local/bin/act_runner daemon
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Activer le service :
```bash
sudo systemctl daemon-reload
sudo systemctl enable gitea-runner
sudo systemctl start gitea-runner
sudo systemctl status gitea-runner
```

---

## 📚 Ressources

- [Documentation Gitea Actions](https://docs.gitea.com/usage/actions/overview)
- [Documentation act_runner](https://gitea.com/gitea/act_runner)
- [Syntaxe des Workflows](https://docs.gitea.com/usage/actions/overview#workflow-syntax)
- [Workflows VIRIDA](.gitea/workflows/)

---

## ✅ Checklist de Mise en Place

- [ ] Gitea Actions activé au niveau de l'instance
- [ ] Gitea Actions activé pour le dépôt
- [ ] Workflows présents dans `.gitea/workflows/`
- [ ] Runner installé et enregistré
- [ ] Runner actif et en ligne
- [ ] Workflow testé avec succès
- [ ] Logs vérifiés

---

## 🎯 Prochaines Étapes

1. ✅ Configurer plusieurs runners pour la scalabilité
2. ✅ Ajouter des secrets pour les déploiements
3. ✅ Configurer des notifications (email, Slack, etc.)
4. ✅ Optimiser les workflows selon tes besoins
5. ✅ Configurer des environnements (staging, production)

---

**🎉 Félicitations ! Tu as maintenant une CI/CD complète avec Gitea Actions !**



