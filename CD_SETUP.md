## CD Clever Cloud (optionnel)

Le workflow `/.gitea/workflows/ci-main.yml` contient un job `deploy-clevercloud` **désactivé par défaut**.

### Activation

- **Secret `CD_ENABLED`**: mettre la valeur `true`
- **Secret `CLEVER_GIT_URL`**: URL git de l’app Clever Cloud (remote de déploiement)
  - Exemple SSH: `ssh://git@push-...clever-cloud.com:22/app_xxx.git`
  - Exemple HTTPS: `https://push-...clever-cloud.com/app_xxx.git`
- **Secret `CLEVER_DEPLOY_REF`**: branche cible sur Clever Cloud (`master` ou `main`)

### Notes importantes

- Si vous utilisez une URL SSH, le runner doit avoir accès à une **clé SSH** permettant le push vers Clever Cloud.
- Le job ne tourne que sur `push` vers `master`.

