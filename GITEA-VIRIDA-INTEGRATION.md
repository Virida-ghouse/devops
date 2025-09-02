# 🔗 Intégration Gitea ↔ virida_ihm

## 📋 Vue d'ensemble

Cette intégration permet de connecter votre application **virida_ihm** (interface de gestion environnementale) avec votre instance **Gitea** pour :

- 📊 Afficher les données de développement en temps réel
- 🔄 Synchroniser les données environnementales avec Git
- 📈 Visualiser les statistiques de contribution
- 🎫 Suivre les issues et pull requests

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   virida_ihm    │◄──►│ Gitea-Virida     │◄──►│     Gitea       │
│  (Interface)    │    │     Bridge       │    │   (Git Repo)    │
│                 │    │   (API Server)   │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 Déploiement

### 1. Déployer le Bridge API

```bash
# Exécuter le script de déploiement
./scripts/deploy-gitea-bridge.sh
```

### 2. Configurer le token Gitea

1. Allez sur votre Gitea : https://gitea.cleverapps.io
2. Créez un token d'accès personnel
3. Configurez-le dans Clever Cloud :

```bash
clever env set GITEA_TOKEN "votre-token-gitea" --app gitea-virida-bridge
```

## 🔧 Intégration dans virida_ihm

### 1. Ajouter le composant React

Copiez les fichiers suivants dans votre application virida_ihm :

- `gitea-virida-bridge/frontend/GiteaIntegration.jsx`
- `gitea-virida-bridge/frontend/GiteaIntegration.css`

### 2. Configurer les variables d'environnement

Dans votre application virida_ihm, ajoutez :

```bash
REACT_APP_GITEA_BRIDGE_URL=https://app-[ID].cleverapps.io
```

### 3. Utiliser le composant

```jsx
import GiteaIntegration from './components/GiteaIntegration';

function App() {
  return (
    <div>
      {/* Votre contenu existant */}
      <GiteaIntegration />
    </div>
  );
}
```

## 📊 Fonctionnalités disponibles

### 🔍 Informations du dépôt
- Nom, description, étoiles, forks
- Dernière mise à jour
- Taille du dépôt

### 📈 Statistiques de développement
- Nombre de commits (30 derniers jours)
- Contributions par auteur
- Lignes de code ajoutées/supprimées

### 🕒 Commits récents
- Liste des 10 derniers commits
- Auteur, message, date
- Statistiques de changement

### 🌿 Branches
- Liste des branches disponibles
- Statut de protection
- Dernier commit

### 🎫 Issues et Pull Requests
- Issues ouvertes
- Pull requests en cours
- Métadonnées (auteur, date, labels)

### 🔄 Synchronisation des données
- Envoi des données environnementales vers Git
- Création automatique de commits
- Historique des synchronisations

## 🛠️ API Endpoints

Le Bridge API expose les endpoints suivants :

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/gitea/repo-info` | GET | Informations du dépôt |
| `/api/gitea/commits` | GET | Commits récents |
| `/api/gitea/branches` | GET | Branches disponibles |
| `/api/gitea/issues` | GET | Issues et PRs |
| `/api/gitea/stats` | GET | Statistiques de développement |
| `/api/gitea/sync-environmental-data` | POST | Synchroniser les données |
| `/health` | GET | Health check |

### Exemple d'utilisation

```javascript
// Récupérer les commits récents
const response = await fetch('https://app-[ID].cleverapps.io/api/gitea/commits?limit=5');
const data = await response.json();

// Synchroniser des données environnementales
const syncResponse = await fetch('https://app-[ID].cleverapps.io/api/gitea/sync-environmental-data', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    data: {
      co2: 45.2,
      temperature: 22.5,
      humidity: 65
    },
    commitMessage: 'Mise à jour des données environnementales'
  })
});
```

## 🔐 Sécurité

- ✅ Token Gitea sécurisé
- ✅ CORS configuré
- ✅ Validation des données
- ✅ Rate limiting (à implémenter)

## 📱 Interface utilisateur

L'interface inclut :

- 🎨 Design moderne avec gradients
- 📱 Responsive design
- 🔄 Indicateurs de chargement
- ❌ Gestion d'erreurs
- 🎯 Animations fluides

## 🧪 Tests

### Test de l'API

```bash
# Health check
curl https://app-[ID].cleverapps.io/health

# Informations du dépôt
curl https://app-[ID].cleverapps.io/api/gitea/repo-info

# Commits récents
curl https://app-[ID].cleverapps.io/api/gitea/commits?limit=5
```

### Test de l'intégration

1. Ouvrez virida_ihm
2. Vérifiez que le composant GiteaIntegration s'affiche
3. Testez la synchronisation des données
4. Vérifiez les données dans Gitea

## 🔧 Maintenance

### Mise à jour du token Gitea

```bash
clever env set GITEA_TOKEN "nouveau-token" --app gitea-virida-bridge
clever restart --app gitea-virida-bridge
```

### Logs

```bash
clever logs --app gitea-virida-bridge
```

### Monitoring

- Health check : `/health`
- Métriques : `/api/gitea/stats`
- Logs Clever Cloud

## 🎯 Prochaines étapes

- [ ] Ajouter l'authentification OAuth
- [ ] Implémenter le cache Redis
- [ ] Ajouter les webhooks Gitea
- [ ] Créer des dashboards avancés
- [ ] Intégrer avec Prometheus/Grafana

## 🆘 Support

En cas de problème :

1. Vérifiez les logs : `clever logs --app gitea-virida-bridge`
2. Testez l'API : `curl https://app-[ID].cleverapps.io/health`
3. Vérifiez le token Gitea
4. Consultez la documentation Gitea API

---

**🎉 Votre intégration Gitea ↔ virida_ihm est maintenant opérationnelle !**
