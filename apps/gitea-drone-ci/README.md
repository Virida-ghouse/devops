# 🚀 VIRIDA Gitea + Drone CI Manager

Application Go qui déploie et configure automatiquement Gitea avec Drone CI sur Clever Cloud.

## 🏗️ Architecture

```
┌─────────────────────────────────┐
│     Clever Cloud VM            │
│  ┌─────────────────────────────┐│
│  │     Go Application          ││
│  │  (Gitea + Drone Manager)    ││
│  └─────────────────────────────┘│
│  ┌─────────────────────────────┐│
│  │     Gitea Server            ││
│  │     (Port 3000)             ││
│  └─────────────────────────────┘│
│  ┌─────────────────────────────┐│
│  │     Drone CI Server         ││
│  │     (Port 3001)             ││
│  └─────────────────────────────┘│
│  ┌─────────────────────────────┐│
│  │     Drone Runner            ││
│  │     (Docker)                ││
│  └─────────────────────────────┘│
└─────────────────────────────────┘
```

## 🚀 Déploiement

### 1. Prérequis

- Compte Clever Cloud
- CLI Clever Cloud installé

### 2. Configuration

1. **Créer l'application sur Clever Cloud :**
```bash
cd apps/gitea-drone-ci
clever create --type go gitea-drone-ci
```

2. **Configurer les variables d'environnement :**
```bash
# Configuration Gitea
clever env set GITEA_DOMAIN "votre-domaine.cleverapps.io" --app gitea-drone-ci
clever env set GITEA_CLIENT_ID "votre-client-id" --app gitea-drone-ci
clever env set GITEA_CLIENT_SECRET "votre-client-secret" --app gitea-drone-ci

# Configuration Drone
clever env set DRONE_HOST "votre-domaine.cleverapps.io" --app gitea-drone-ci
clever env set DRONE_SECRET "votre-secret-super-securise" --app gitea-drone-ci

# Configuration des ports
clever env set GITEA_PORT "3000" --app gitea-drone-ci
clever env set DRONE_PORT "3001" --app gitea-drone-ci
```

3. **Déployer :**
```bash
clever deploy
```

### 3. Configuration OAuth Gitea

Une fois déployé, vous devez configurer l'OAuth dans Gitea :

1. Accédez à votre Gitea : `https://votre-app.cleverapps.io:3000`
2. Allez dans **Settings** > **Applications**
3. Créez une nouvelle application OAuth :
   - **Application Name** : Drone CI
   - **Redirect URI** : `https://votre-app.cleverapps.io:3001/login`
4. Copiez le **Client ID** et **Client Secret**
5. Mettez à jour les variables d'environnement dans Clever Cloud

## 🔧 Fonctionnalités

### API Endpoints

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/` | GET | Status général de l'application |
| `/health` | GET | Health check |
| `/status` | GET | Status des services Gitea/Drone |
| `/restart` | POST | Redémarrer les services |

### Services Gérés

- **Gitea** : Serveur Git avec interface web
- **Drone CI** : Pipeline CI/CD
- **Drone Runner** : Exécuteur des pipelines Docker

## 📊 Monitoring

### Logs
```bash
clever logs --app gitea-drone-ci
```

### Status des services
```bash
curl https://votre-app.cleverapps.io/status
```

### Health check
```bash
curl https://votre-app.cleverapps.io/health
```

## 🔐 Sécurité

- Configuration OAuth sécurisée
- Secrets générés automatiquement
- Isolation des services
- Gestion des permissions

## 🛠️ Configuration Avancée

### Variables d'environnement

| Variable | Description | Défaut |
|----------|-------------|---------|
| `GITEA_PORT` | Port Gitea | 3000 |
| `DRONE_PORT` | Port Drone CI | 3001 |
| `DATA_DIR` | Répertoire de données | /tmp/gitea-drone |
| `DRONE_SECRET` | Secret partagé Drone | généré |
| `GITEA_DOMAIN` | Domaine Gitea | localhost |
| `DRONE_HOST` | Domaine Drone | localhost |

### Personnalisation

Vous pouvez modifier la configuration dans `main.go` :
- Configuration Gitea (app.ini)
- Configuration Drone
- Ports et domaines
- Secrets et clés

## 🚨 Dépannage

### Problèmes courants

1. **Services ne démarrent pas :**
   - Vérifiez les logs : `clever logs --app gitea-drone-ci`
   - Vérifiez les permissions sur `/tmp/gitea-drone`

2. **OAuth ne fonctionne pas :**
   - Vérifiez la configuration OAuth dans Gitea
   - Vérifiez les variables `GITEA_CLIENT_ID` et `GITEA_CLIENT_SECRET`

3. **Drone ne se connecte pas à Gitea :**
   - Vérifiez `GITEA_DOMAIN` et `DRONE_HOST`
   - Vérifiez que Gitea est accessible

### Logs utiles

```bash
# Logs de l'application
clever logs --app gitea-drone-ci

# Logs Gitea
clever logs --app gitea-drone-ci | grep gitea

# Logs Drone
clever logs --app gitea-drone-ci | grep drone
```

## 🎯 Prochaines étapes

- [ ] Configuration automatique des webhooks
- [ ] Interface d'administration web
- [ ] Monitoring avec Prometheus
- [ ] Backup automatique des données
- [ ] Scaling horizontal des runners

## 📞 Support

En cas de problème :
1. Vérifiez les logs
2. Testez les endpoints de status
3. Vérifiez la configuration OAuth
4. Consultez la documentation Gitea et Drone

---

**🎉 Votre Gitea + Drone CI est maintenant opérationnel sur Clever Cloud !**
