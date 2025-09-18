# 🚀 Guide Étape par Étape - Création et Déploiement

## Étape 1 : Créer l'application sur Clever Cloud

1. **Allez sur** [console.clever-cloud.com](https://console.clever-cloud.com)
2. **Cliquez sur** "Create an application" (bouton vert)
3. **Sélectionnez** "Go"
4. **Nom** : `gitea-drone-ci`
5. **Région** : `par` (Paris)
6. **Cliquez** "Create"

## Étape 2 : Récupérer l'URL de déploiement

Après création, Clever Cloud affiche une URL comme :
```
https://push-n3-par-clevercloud-customers.services.clever-cloud.com/app_XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX.git
```

**Copiez cette URL !**

## Étape 3 : Déployer automatiquement

```bash
# Exécuter le script de déploiement
./quick-deploy.sh
```

Le script vous demandera l'URL de déploiement et fera tout automatiquement.

## Étape 4 : Configurer les variables d'environnement

1. **Allez dans** Clever Cloud > votre application > Settings > Environment variables
2. **Exécutez** pour voir les variables à ajouter :
```bash
./setup-variables.sh
```
3. **Ajoutez** chaque variable une par une

## Étape 5 : Configurer OAuth dans Gitea

1. **Attendez** 2-3 minutes que l'application démarre
2. **Accédez à** `https://gitea-drone-ci.cleverapps.io:3000`
3. **Créez un compte admin** (première connexion)
4. **Allez dans** Settings > Applications
5. **Créez une application OAuth** :
   - **Nom** : Drone CI
   - **Redirect URI** : `https://gitea-drone-ci.cleverapps.io:3001/login`
6. **Copiez** le Client ID et Secret
7. **Mettez à jour** les variables dans Clever Cloud :
   - `GITEA_CLIENT_ID` = Client ID
   - `GITEA_CLIENT_SECRET` = Client Secret
8. **Redéployez** l'application

## Étape 6 : Vérifier le déploiement

```bash
# Health check
curl https://gitea-drone-ci.cleverapps.io/health

# Status des services
curl https://gitea-drone-ci.cleverapps.io/status
```

## URLs d'accès

- **Application** : `https://gitea-drone-ci.cleverapps.io`
- **Gitea** : `https://gitea-drone-ci.cleverapps.io:3000`
- **Drone CI** : `https://gitea-drone-ci.cleverapps.io:3001`

## 🆘 En cas de problème

```bash
# Voir les logs
clever logs --alias gitea-drone-ci

# Redéployer
git push gitea-drone-ci staging
```

