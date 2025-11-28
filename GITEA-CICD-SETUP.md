# 🚀 Guide de Configuration CI/CD Gitea Actions pour VIRIDA

## 📋 Vue d'ensemble

Ce guide explique comment configurer Gitea Actions pour activer la CI/CD sur votre dépôt VIRIDA.

## ✅ Prérequis

1. **Gitea** version 1.19+ avec Actions activées
2. **Docker** installé sur le serveur qui hébergera le runner
3. **Accès administrateur** à Gitea ou permissions pour créer des runners

## 🔧 Étapes de Configuration

### 1. Activer Gitea Actions dans le dépôt

1. Aller sur https://gitea.virida.org/Virida/devops
2. Cliquer sur **Settings** (Paramètres)
3. Aller dans **Actions** → **General**
4. Vérifier que **Enable Actions** est activé
5. Sauvegarder

### 2. Créer un Runner Gitea

#### Option A : Runner local (sur votre machine)

```bash
# 1. Télécharger act_runner
cd /tmp
wget https://gitea.com/gitea/act_runner/releases/download/v0.3.0/act_runner-0.3.0-linux-amd64.tar.gz
tar -xzf act_runner-0.3.0-linux-amd64.tar.gz
sudo mv act_runner /usr/local/bin/
chmod +x /usr/local/bin/act_runner

# 2. Obtenir le token d'enregistrement
# Aller sur: https://gitea.virida.org/Virida/devops/settings/actions/runners
# Cliquer sur "Create new Runner"
# Copier le REGISTRATION TOKEN affiché

# 3. Enregistrer le runner
act_runner register \
  --instance https://gitea.virida.org \
  --token VOTRE_REGISTRATION_TOKEN \
  --name virida-runner-local \
  --labels ubuntu-latest:docker://node:18,ubuntu-latest:docker://python:3.11 \
  --no-interactive

# 4. Démarrer le runner
act_runner daemon
```

#### Option B : Runner sur Clever Cloud (recommandé)

1. **Déployer le runner sur Clever Cloud** :
   ```bash
   # Utiliser le fichier clevercloud-gitea-runner.json
   clever create --type docker virida-gitea-runner
   clever link virida-gitea-runner
   clever deploy
   ```

2. **Configurer les variables d'environnement** dans Clever Cloud :
   - `GITEA_INSTANCE_URL`: `https://gitea.virida.org`
   - `GITEA_TOKEN`: Le registration token (obtenu à l'étape 2)
   - `RUNNER_NAME`: `virida-runner-cloud`
   - `RUNNER_LABELS`: `ubuntu-latest:docker://node:18,ubuntu-latest:docker://python:3.11`

### 3. Obtenir le Registration Token

1. Aller sur https://gitea.virida.org/Virida/devops/settings/actions/runners
2. Cliquer sur **"Créer un nouvel exécuteur"** (Create new runner)
3. Copier le **REGISTRATION TOKEN** affiché
4. ⚠️ **Important** : Ce token est différent du Personal Access Token utilisé pour Git

### 4. Vérifier les Workflows

Les workflows sont déjà configurés dans `.gitea/workflows/` :

- **pr-validation.yml** : Validation des Pull Requests
- **ci-cd.yml** : Pipeline CI/CD complet
- **test.yml** : Tests automatisés
- **security-scan.yml** : Scan de sécurité
- **deploy-clever-cloud.yml** : Déploiement sur Clever Cloud

### 5. Tester la CI/CD

1. **Créer une Pull Request** ou **push sur une branche** (main, staging, develop)
2. Aller dans **Actions** dans le dépôt Gitea
3. Vérifier que les workflows s'exécutent
4. Vérifier que le runner est actif et prend les jobs en charge

## 📝 Configuration des Workflows

### Structure des workflows

Les workflows Gitea Actions utilisent la syntaxe YAML similaire à GitHub Actions :

```yaml
name: Mon Workflow

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  mon-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Hello World"
```

### Labels des Runners

Les labels définissent les environnements disponibles :
- `ubuntu-latest` : Ubuntu avec Docker
- `ubuntu-latest:docker://node:18` : Ubuntu avec Node.js 18
- `ubuntu-latest:docker://python:3.11` : Ubuntu avec Python 3.11

## 🔍 Dépannage

### Le runner ne prend pas les jobs

1. Vérifier que le runner est enregistré :
   ```bash
   act_runner list
   ```

2. Vérifier les logs du runner :
   ```bash
   journalctl -u act_runner -f
   ```

3. Vérifier que Docker fonctionne :
   ```bash
   docker ps
   ```

### Les workflows ne se déclenchent pas

1. Vérifier que Gitea Actions est activé dans les paramètres du dépôt
2. Vérifier que les fichiers `.gitea/workflows/*.yml` sont présents
3. Vérifier la syntaxe YAML des workflows

### Erreur "No runner available"

1. Vérifier qu'au moins un runner est enregistré et actif
2. Vérifier que les labels du workflow correspondent aux labels du runner
3. Vérifier que le runner a les permissions nécessaires

## 📚 Ressources

- [Documentation Gitea Actions](https://docs.gitea.com/usage/actions/overview)
- [Documentation act_runner](https://gitea.com/gitea/act_runner)
- [Workflows VIRIDA](.gitea/workflows/)

## 🎯 Prochaines Étapes

1. ✅ Activer Gitea Actions dans le dépôt
2. ✅ Créer et enregistrer un runner
3. ✅ Tester avec un push ou une PR
4. ✅ Configurer les secrets pour les déploiements
5. ✅ Optimiser les workflows selon vos besoins

