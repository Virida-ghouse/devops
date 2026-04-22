# Gitea Actions – Pipeline principale invisible

## Pourquoi « VIRIDA CI - Main Pipeline » n’apparaît pas dans la liste

Sur Gitea, **la liste déroulante des workflows dans l’onglet Actions n’affiche que les workflows qui ont déjà été exécutés au moins une fois**. Tant que la pipeline principale n’a jamais été lancée, elle ne figure pas dans le menu.

- **Security Scan** apparaît car elle a déjà été exécutée (planifiée ou manuelle).
- **VIRIDA CI - Main Pipeline** (`ci-main.yml`) n’apparaît pas tant qu’elle n’a pas été lancée une première fois.

## Faire apparaître la pipeline principale

Il faut **lancer une fois** le workflow `ci-main.yml` sur Gitea. Deux possibilités :

### 1. Via l’interface (si le workflow est déjà listé)

Si un jour la pipeline apparaît dans la liste (par exemple après une exécution déclenchée par l’API) :

- Onglet **Actions** du dépôt **devops** sur Gitea.
- Menu déroulant « Run workflow » → choisir **VIRIDA CI - Main Pipeline**.
- Branche : **main** (ou **master** en compatibilité) → **Run workflow**.

### 2. Via l’API Gitea (première fois)

Pour la **première** exécution, utilisez le script fourni (avec un token Gitea) :

```bash
# Depuis la racine du repo
export GITEA_URL="https://votre-gitea.example.com"   # URL de base (sans /api/v1)
export GITEA_TOKEN="votre_token_avec_droits_repo"
./scripts/trigger_gitea_main_workflow.sh Virida devops
```

Cela envoie un « workflow_dispatch » pour `ci-main.yml` sur la branche **main** (par défaut). Une fois cette exécution lancée (et visible dans l’onglet Actions), **VIRIDA CI - Main Pipeline** restera disponible dans la liste déroulante.

### Miroir (pull) et déclenchement des workflows

Sur un dépôt **miroir** (pull depuis GitHub), les mises à jour faites par la synchro du miroir ne déclenchent pas toujours un événement `push` côté Gitea. Dans ce cas, les workflows déclenchés par `push` (dont `ci-main.yml`) ne partent pas automatiquement à chaque sync. Le fait de lancer une fois le workflow via l’API (ou manuellement) permet au moins de le faire apparaître et de le relancer à la main quand besoin.
