# SonarQube - Guide des Métriques VIRIDA

## 📊 Vue d'ensemble

SonarQube analyse la qualité du code selon 3 axes principaux :
1. **Fiabilité** (Reliability) : Bugs qui affectent le comportement
2. **Sécurité** (Security) : Vulnérabilités et Security Hotspots
3. **Maintenabilité** (Maintainability) : Code Smells, dette technique, duplication

---

## 🎯 Métriques Principales

### 1. Coverage (Couverture de Tests)

**Définition** : Pourcentage du code exécuté par les tests automatisés.

**Calcul** :
```
Coverage = (Lignes testées / Total lignes exécutables) × 100
```

**Types de coverage** :
- **Lines Coverage** : % de lignes exécutées
- **Branch Coverage** : % de branches conditionnelles testées (if/else, switch)
- **Function Coverage** : % de fonctions appelées

**Seuils VIRIDA** :
- Backend APIs : **≥ 90%** (virida_api, Virida_marketplace_api)
- Nouveau code : **≥ 80%** (pour éviter régression)

**Interprétation** :
- ✅ **90-100%** : Excellente couverture
- ⚠️ **70-89%** : Correcte mais amélioration souhaitable
- ❌ **<70%** : Insuffisant, risque de bugs non détectés

**Comment l'améliorer** :
```bash
# Identifier les fichiers non couverts
npm run test:coverage
# Consulter coverage/index.html pour les détails
# Écrire des tests pour les lignes/branches non couvertes
```

---

### 2. Bugs (Fiabilité)

**Définition** : Code qui peut causer un comportement incorrect à l'exécution.

**Exemples** :
- Null pointer dereference
- Division par zéro
- Utilisation de variables non initialisées
- Conditions toujours vraies/fausses
- Boucles infinies potentielles

**Sévérités** :
- 🔴 **Blocker** : Bug critique, arrête le déploiement
- 🔴 **Critical** : Bug majeur, perte de données ou crash
- 🟠 **Major** : Bug important, impact fonctionnel
- 🟡 **Minor** : Bug mineur, impact limité
- ⚪ **Info** : Suggestion, pas un vrai bug

**Seuil VIRIDA** :
- **0 bug** dans le nouveau code (quality gate)
- Objectif : **0 bug** global

**Exemple de bug détecté** :
```javascript
// ❌ Bug : property access sans null check
function getUser(id) {
  const user = findUser(id);
  return user.name; // Crash si user est null
}

// ✅ Corrigé
function getUser(id) {
  const user = findUser(id);
  return user?.name ?? 'Unknown';
}
```

---

### 3. Vulnerabilities (Sécurité)

**Définition** : Failles de sécurité exploitables.

**Catégories OWASP** :
- Injection SQL/NoSQL
- Cross-Site Scripting (XSS)
- Authentification cassée
- Exposition de données sensibles
- XML External Entities (XXE)
- Contrôle d'accès manquant
- Configuration de sécurité incorrecte
- Dépendances vulnérables

**Sévérités** :
- 🔴 **Critical** : Exploitation facile, impact majeur
- 🔴 **High** : Exploitation possible, risque élevé
- 🟠 **Medium** : Exploitation complexe ou impact limité
- 🟡 **Low** : Faible risque

**Seuil VIRIDA** :
- **0 vulnérabilité** Critical/High
- Security Hotspots : révision obligatoire

**Exemple de vulnérabilité** :
```javascript
// ❌ Vulnérabilité : Injection SQL
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ Corrigé : Prepared statement
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
```

---

### 4. Security Hotspots

**Définition** : Code sensible nécessitant une révision manuelle de sécurité.

**Exemples** :
- Utilisation de `eval()` ou `Function()`
- Génération de nombres aléatoires (crypto vs Math.random)
- Gestion de mots de passe
- Validation d'entrées utilisateur
- Permissions et contrôles d'accès

**Statuts** :
- 🔍 **To Review** : Non encore audité
- ✅ **Reviewed - Safe** : Audité et considéré sûr
- ⚠️ **Reviewed - Unsafe** : Vulnérabilité confirmée

**Action VIRIDA** :
- Réviser tous les hotspots dans les 48h
- Documenter la décision (safe/unsafe)

---

### 5. Code Smells (Dette Technique)

**Définition** : Code qui fonctionne mais est difficile à maintenir.

**Catégories** :
- **Complexité** : Fonctions trop longues, trop de paramètres, complexité cyclomatique élevée
- **Duplication** : Code copié-collé (DRY violation)
- **Conventions** : Noms peu clairs, code mort, commentaires obsolètes
- **Design** : Couplage fort, responsabilités mélangées

**Sévérités** :
- 🔴 **Critical** : Refactoring urgent
- 🔴 **Major** : Impact important sur maintenabilité
- 🟠 **Minor** : Amélioration souhaitable
- 🟡 **Info** : Suggestion

**Seuil VIRIDA** :
- **0 code smell** Critical/Major dans nouveau code
- Réduction progressive de la dette existante

**Exemples** :
```javascript
// ❌ Code Smell : Fonction trop complexe
function processOrder(order, user, inventory, payment) {
  if (order) {
    if (user && user.active) {
      if (inventory.check(order.items)) {
        if (payment.validate(order.total)) {
          // 50 lignes de logique imbriquée...
        }
      }
    }
  }
}

// ✅ Corrigé : Découpage en fonctions plus petites
function processOrder(order, user, inventory, payment) {
  validateOrder(order);
  validateUser(user);
  checkInventory(inventory, order.items);
  processPayment(payment, order.total);
}
```

---

### 6. Duplication

**Définition** : Lignes de code identiques ou très similaires dans plusieurs endroits.

**Métriques** :
- **Duplicated Lines** : Nombre de lignes dupliquées
- **Duplicated Blocks** : Nombre de blocs de code dupliqués
- **Duplicated Files** : Nombre de fichiers contenant de la duplication
- **Duplicated Lines Density** : % de lignes dupliquées

**Seuil VIRIDA** :
- Nouveau code : **≤ 3%** de duplication
- Code existant : **≤ 5%** acceptable

**Impact** :
- Bugs répétés dans chaque copie
- Maintenance difficile (modifier N endroits)
- Coût de maintenance élevé

**Solution** :
```javascript
// ❌ Duplication
function createUserEmail(user) {
  return `<h1>Welcome ${user.name}</h1><p>Email: ${user.email}</p>`;
}
function createAdminEmail(admin) {
  return `<h1>Welcome ${admin.name}</h1><p>Email: ${admin.email}</p>`;
}

// ✅ Factorisation
function createWelcomeEmail(user) {
  return `<h1>Welcome ${user.name}</h1><p>Email: ${user.email}</p>`;
}
```

---

### 7. Complexité Cyclomatique

**Définition** : Nombre de chemins d'exécution indépendants dans le code.

**Calcul** :
- Commence à 1
- +1 pour chaque `if`, `else if`, `for`, `while`, `case`, `&&`, `||`, `?:`

**Exemple** :
```javascript
function calculateDiscount(user, amount) {  // Complexité = 1
  if (user.isPremium) {                     // +1 = 2
    if (amount > 100) {                     // +1 = 3
      return amount * 0.2;
    } else {                                // +1 = 4
      return amount * 0.1;
    }
  } else if (amount > 200) {                // +1 = 5
    return amount * 0.05;
  }
  return 0;
}
// Complexité cyclomatique = 5
```

**Seuils** :
- ✅ **1-10** : Simple, facile à tester
- ⚠️ **11-20** : Complexe, décomposition recommandée
- ❌ **>20** : Très complexe, refactoring urgent

**SonarQube alerte** quand une fonction dépasse **10** (configurable).

---

### 8. Technical Debt (Dette Technique)

**Définition** : Temps estimé pour corriger tous les code smells.

**Calcul SonarQube** :
- Code Smell **Minor** : 5 min
- Code Smell **Major** : 20 min
- Code Smell **Critical** : 1 heure

**Exemple** :
```
Projet avec :
- 10 Minor code smells : 10 × 5min = 50min
- 5 Major code smells  : 5 × 20min = 1h40
- 1 Critical code smell : 1h
Total : 3h30 de dette technique
```

**Métrique dérivée** :
```
SQALE Rating (Maintainability Rating) :
A : ≤ 5% du temps de développement
B : 6-10%
C : 11-20%
D : 21-50%
E : > 50%
```

**Objectif VIRIDA** :
- Rating **A** ou **B** sur tous les projets
- Réduction progressive de la dette

---

### 9. Lines of Code (NCLOC)

**Définition** : Nombre de lignes de code (Non-Comment Lines of Code).

**Exclus du comptage** :
- Lignes vides
- Commentaires
- Lignes ne contenant que des accolades `{` ou `}`

**Utilité** :
- Dimensionner l'effort de revue
- Suivre la croissance du projet
- Calculer les ratios (dette/NCLOC, tests/NCLOC)

**VIRIDA actuel** :
- virida_api : 4,461 NCLOC
- Virida_marketplace_api : 1,211 NCLOC

---

## 🚦 Quality Gates VIRIDA

### Configuration Actuelle

**Pour les APIs backend (virida_api, Virida_marketplace_api)** :

| Condition | Opérateur | Seuil | Bloquant |
|-----------|-----------|-------|----------|
| **Coverage nouveau code** | < | 80% | ⚠️ Warning |
| **Duplication nouveau code** | > | 3% | ⚠️ Warning |
| **Nouveaux bugs** | > | 0 | ⚠️ Warning |
| **Nouvelles vulnérabilités** | > | 0 | ⚠️ Warning |
| **Code Smells nouveau code** | > | 0 | ⚠️ Warning |

**Mode actuel** : **Non-bloquant** (SONAR_GATE_ENFORCE=false)
- Les échecs émettent des `::warning::` dans les logs CI
- Les pipelines continuent même si le gate échoue
- Permet une amélioration progressive

**Pour activer le mode bloquant** :
```yaml
# Dans .gitea/workflows/sonar-nightly.yml ligne ~238
SONAR_GATE_ENFORCE: 'true'  # Au lieu de 'false'
```

---

## 📈 Interpréter les Résultats SonarQube

### Dashboard Principal

**URL** : https://app-d64afe8e-3d25-4e76-9180-a454874ff002.cleverapps.io

**Projets actifs** :
- `virida_api`
- `Virida_marketplace_api`

### Vue par Projet

**Navigation** : Dashboard → Sélectionner le projet

**Sections importantes** :

#### 1. Overview (Vue d'ensemble)
```
┌─────────────────────────────────────────┐
│ Quality Gate Status : PASSED/FAILED     │
│                                         │
│ Bugs              : 0    │ Rating : A   │
│ Vulnerabilities   : 0    │ Rating : A   │
│ Code Smells       : 12   │ Rating : A   │
│ Coverage          : 97.5%              │
│ Duplications      : 1.2%               │
│ Security Hotspots : 0                  │
└─────────────────────────────────────────┘
```

#### 2. Issues (Problèmes)
- Filtre par type : Bug / Vulnerability / Code Smell
- Filtre par sévérité : Blocker / Critical / Major / Minor / Info
- Vue par fichier
- Détails + suggestion de correction

#### 3. Measures (Mesures)
**Reliability** :
- Bugs par sévérité
- Reliability Rating (A-E)

**Security** :
- Vulnérabilités par sévérité
- Security Rating (A-E)
- Security Hotspots à réviser

**Maintainability** :
- Code Smells par sévérité
- Technical Debt
- Maintainability Rating (A-E)

**Coverage** :
- Line coverage
- Branch coverage
- Conditions coverage
- Uncovered lines

**Duplications** :
- Duplicated blocks
- Duplicated lines (%)
- Duplicated files

**Size** :
- Lines of code (NCLOC)
- Statements
- Functions
- Files

---

## 🎨 Ratings (Notes)

SonarQube attribue une note de **A** (meilleur) à **E** (pire) selon les seuils :

### Reliability Rating
```
A : 0 bugs
B : ≥ 1 bug Minor
C : ≥ 1 bug Major
D : ≥ 1 bug Critical
E : ≥ 1 bug Blocker
```

### Security Rating
```
A : 0 vulnérabilité
B : ≥ 1 vulnérabilité Minor
C : ≥ 1 vulnérabilité Major
D : ≥ 1 vulnérabilité Critical
E : ≥ 1 vulnérabilité Blocker
```

### Maintainability Rating (SQALE)
```
A : Dette technique ≤ 5% du temps de développement
B : 6-10%
C : 11-20%
D : 21-50%
E : > 50%
```

**Objectif VIRIDA** : Rating **A** sur les 3 axes (Reliability, Security, Maintainability)

---

## 🔍 Métriques Avancées

### 1. Overall Coverage vs New Code Coverage

**Overall Coverage** : Taux de couverture sur tout le code existant
**New Code Coverage** : Taux de couverture uniquement sur le code ajouté depuis la dernière version

**Pourquoi cette distinction ?**
- Permet d'améliorer progressivement sans bloquer les livraisons
- Focus sur la qualité du nouveau code
- Évite la régression

**Exemple** :
```
Projet avec 10,000 lignes :
- Overall coverage : 70% (7,000 lignes testées)
- Ajout de 500 lignes avec 95% de coverage

Nouveau overall : (7,000 + 475) / 10,500 = 71.2%
New code coverage : 95%
→ Quality gate PASSED si seuil new code = 80%
```

### 2. Conditions to Cover

**Définition** : Nombre de branches conditionnelles à tester.

**Exemple** :
```javascript
function discount(isPremium, amount) {
  if (isPremium && amount > 100) {  // 4 conditions à couvrir
    return 0.2;                     // 1. isPremium=true, amount>100
  }                                 // 2. isPremium=true, amount≤100
  return 0;                         // 3. isPremium=false, amount>100
}                                   // 4. isPremium=false, amount≤100

// Pour 100% branch coverage : tester les 4 cas
```

### 3. Cognitive Complexity

**Définition** : Mesure la difficulté à comprendre le code (différent de la complexité cyclomatique).

**Facteurs** :
- Imbrication de conditions (+1 par niveau)
- Structures de contrôle (if, while, for, etc.)
- Ruptures de flux (break, continue, return)
- Récursion

**Exemple** :
```javascript
function processData(data) {
  if (data) {                        // +1
    for (item of data) {             // +1 (+1 pour imbrication = +2)
      if (item.valid) {              // +1 (+2 pour imbrication = +3)
        while (item.hasNext()) {     // +1 (+3 pour imbrication = +4)
          // ...
        }
      }
    }
  }
}
// Cognitive Complexity ≈ 11
```

**Seuil recommandé** : ≤ 15 par fonction

---

## 🛠️ Workflow SonarQube VIRIDA

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Gitea Actions (.gitea/workflows/sonar-nightly.yml)   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Checkout virida_api + Virida_marketplace_api       │
│  2. Install dependencies                                │
│  3. Run tests with coverage                             │
│     → npm run test:coverage                             │
│     → Génère coverage/lcov.info                         │
│  4. Install SonarScanner CLI                            │
│  5. Scan virida_api                                     │
│     → Upload code + coverage                            │
│  6. Scan Virida_marketplace_api                         │
│     → Upload code + coverage                            │
│  7. Verify quality gates                                │
│     → Check status via API                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────────┐
│  SonarQube Server (Clever Cloud)                       │
│  https://app-d64afe8e...cleverapps.io                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  • Analyse le code                                      │
│  • Calcule les métriques                                │
│  • Applique les quality gates                           │
│  • Génère le dashboard                                  │
│  • API accessible via SONAR_TOKEN                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Déclenchement

**Automatique** :
- Après chaque exécution de "VIRIDA CI - Main Pipeline" (workflow_run)
- Tous les jours à 03:00 UTC (schedule)

**Manuel** :
- Interface Gitea Actions → "SonarQube Analysis - Backend APIs Only" → "Run workflow"

### Secrets Requis

| Secret | Description | Exemple |
|--------|-------------|---------|
| `SONAR_HOST_URL` | URL de l'instance SonarQube | `https://app-xxx.cleverapps.io` |
| `SONAR_TOKEN` | Token d'authentification | `squ_...` |
| `GITEA` | Token pour cloner virida_api | `ghp_...` |
| `GH_TOKEN_MARKETPLACE` | Token pour cloner Virida_marketplace_api | `ghp_...` |

---

## 📋 Checklist Qualité par Projet

### virida_api

**État actuel** :
- ✅ Coverage : 97.5%
- ✅ Bugs : 0
- ✅ Vulnérabilités : 0
- ✅ Code Smells : 1
- ✅ Duplication : 1.2%
- ✅ Quality Gate : OK

**Actions** :
- ✅ Maintenir le coverage > 90%
- ✅ Continuer à écrire des tests pour nouveau code
- ℹ️ Corriger le dernier code smell (optionnel)

### Virida_marketplace_api

**État actuel** :
- ✅ Coverage : 90.93% (local, prochain scan Sonar)
- ✅ Bugs : 0
- ✅ Vulnérabilités : 0
- ✅ Code Smells : 0
- ⚠️ Duplication : À vérifier après scan
- 🔄 Quality Gate : OK après prochain scan

**Actions** :
- ✅ Coverage 90%+ atteint
- 📊 Lancer le scan Sonar pour confirmer
- 🎯 Surveiller les métriques après déploiement

---

## 🚀 Comment Améliorer les Métriques

### Augmenter le Coverage

**1. Identifier les fichiers non couverts** :
```bash
cd virida_api  # ou Virida_marketplace_api
npm run test:coverage
open coverage/index.html
```

**2. Prioriser** :
- Fichiers critiques (auth, paiement, data)
- Fonctions complexes
- Code récent

**3. Écrire les tests manquants** :
```javascript
// Pour chaque fonction non couverte
describe('MonModule', () => {
  it('should handle normal case', () => {
    // Test du cas nominal
  });
  
  it('should handle error case', () => {
    // Test des erreurs
  });
  
  it('should handle edge cases', () => {
    // Test des cas limites
  });
});
```

### Réduire les Bugs

**1. Consulter la liste** :
- SonarQube → Issues → Type: Bug
- Trier par sévérité (Critical → Minor)

**2. Corriger** :
- Suivre les suggestions SonarQube
- Ajouter des null checks
- Valider les entrées utilisateur
- Gérer les erreurs explicitement

**3. Prévenir** :
- Activer le linter ESLint/TSLint
- Configurer des pre-commit hooks
- Code review systématique

### Réduire la Duplication

**1. Identifier les duplications** :
- SonarQube → Measures → Duplications
- Cliquer sur "Duplicated Blocks"

**2. Refactorer** :
- Extraire le code dupliqué dans une fonction
- Créer des utilitaires réutilisables
- Utiliser l'héritage ou la composition

**3. Prévenir** :
- Principe DRY (Don't Repeat Yourself)
- Code review pour détecter les copier-coller

### Simplifier le Code

**1. Réduire la complexité cyclomatique** :
```javascript
// ❌ Complexe
function validate(user) {
  if (user && user.email && user.email.includes('@')) {
    if (user.age >= 18 && user.age < 100) {
      if (user.country === 'FR' || user.country === 'BE') {
        return true;
      }
    }
  }
  return false;
}

// ✅ Simplifié
function validate(user) {
  return isValidEmail(user?.email) &&
         isValidAge(user?.age) &&
         isValidCountry(user?.country);
}
```

**2. Découper les fonctions longues** :
- Règle : 1 fonction = 1 responsabilité
- Maximum 20-30 lignes par fonction
- Extraire les blocs logiques en sous-fonctions

**3. Éviter l'imbrication profonde** :
- Early return pour les cas d'erreur
- Guard clauses
- Extraction de fonctions

---

## 📖 Glossaire

| Terme | Signification |
|-------|---------------|
| **NCLOC** | Non-Comment Lines of Code (lignes de code sans commentaires) |
| **SQALE** | Software Quality Assessment based on Lifecycle Expectations (rating maintenabilité) |
| **Technical Debt** | Temps estimé pour corriger tous les code smells |
| **New Code** | Code ajouté/modifié depuis la dernière version/analyse |
| **Leak Period** | Période de référence pour calculer le "nouveau code" |
| **Quality Gate** | Ensemble de conditions à respecter pour valider la qualité |
| **Security Hotspot** | Code sensible nécessitant une révision manuelle |
| **OWASP** | Open Web Application Security Project (top 10 des vulnérabilités) |

---

## 🔗 Ressources Utiles

### Documentation Officielle
- **SonarQube Docs** : https://docs.sonarqube.org/latest/
- **Metric Definitions** : https://docs.sonarqube.org/latest/user-guide/metric-definitions/
- **Quality Gates** : https://docs.sonarqube.org/latest/user-guide/quality-gates/

### VIRIDA Specific
- **Workflow Sonar** : `.gitea/workflows/sonar-nightly.yml`
- **Infrastructure Setup** : `INFRA_SETUP.md`
- **SonarQube Instance** : https://app-d64afe8e-3d25-4e76-9180-a454874ff002.cleverapps.io

### Token SonarQube
- **Type** : User Token
- **Permissions** : Execute Analysis + Browse
- **Stocké dans** : Gitea Secrets → `SONAR_TOKEN`
- **Format** : `squ_...` (40 caractères hexadécimaux)

---

## 🎯 Objectifs Qualité VIRIDA 2026

### Court terme (Q2 2026)
- ✅ Coverage ≥ 90% sur virida_api
- ✅ Coverage ≥ 90% sur Virida_marketplace_api
- ✅ 0 bugs Critical/Blocker
- ✅ 0 vulnérabilités High/Critical

### Moyen terme (Q3 2026)
- 🎯 Coverage ≥ 95% sur toutes les APIs
- 🎯 Maintainability Rating A
- 🎯 Réduction dette technique < 2% du temps dev
- 🎯 Mode bloquant quality gate (SONAR_GATE_ENFORCE=true)

### Long terme (Q4 2026)
- 🎯 Zero Security Hotspots non révisés
- 🎯 Duplication < 2%
- 🎯 Complexité moyenne < 8
- 🎯 100% des fonctions < 50 lignes

---

## 🆘 Troubleshooting

### Le scan Sonar échoue

**Erreur : "Unable to read quality gate"**
```
Solution : Vérifier que SONAR_TOKEN a les permissions Browse
→ SonarQube → Administration → Security → Users → Edit Token
→ Ajouter permission "Browse" sur les projets
```

**Erreur : "Out of memory"**
```
Solution : Augmenter la mémoire Java dans le workflow
SONAR_SCANNER_OPTS: '-Xmx1024m -Xms256m'  # Au lieu de 512m
```

**Erreur : "Coverage report not found"**
```
Solution : Vérifier que les tests génèrent coverage/lcov.info
cd virida_api
npm run test:coverage
ls -lah coverage/lcov.info
```

### Le coverage affiché est incorrect

**Coverage trop bas alors que les tests passent** :
```
Cause probable : Fichiers exclus de l'analyse
Solution : Vérifier sonar.exclusions dans le workflow
→ Ne pas exclure trop de fichiers
→ Exclure uniquement : node_modules, dist, coverage, tests
```

**Coverage à 0%** :
```
Cause : lcov.info non uploadé ou invalide
Solution : 
1. Vérifier que le fichier existe : ls coverage/lcov.info
2. Vérifier le chemin dans Sonar : -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
3. Vérifier le format : head -20 coverage/lcov.info
```

### Quality Gate échoue mais le code est bon

**Nouveau code avec coverage faible** :
```
Explication : Fichiers ajoutés sans tests
Solution : 
1. Lister les fichiers récents : git diff --name-only HEAD~1
2. Écrire des tests pour chaque nouveau fichier
3. Relancer le scan
```

**Trop de duplication détectée** :
```
Explication : Code similaire dans plusieurs endroits
Solution :
1. Consulter Measures → Duplications
2. Identifier les blocs dupliqués
3. Extraire en fonction commune
4. Refactorer progressivement
```

---

## 📅 Calendrier de Scan VIRIDA

| Workflow | Déclenchement | Fréquence |
|----------|---------------|-----------|
| `sonar-nightly.yml` | Schedule | Tous les jours 03:00 UTC |
| `sonar-nightly.yml` | workflow_run | Après chaque CI main |
| `sonar-nightly.yml` | workflow_dispatch | Manuel (on-demand) |

**Durée estimée** : ~10-15 minutes (2 projets)

**Historique** : Consultable dans SonarQube → Activity

---

## ✅ Validation Finale

### Checklist avant déploiement en production

- [ ] Quality Gate PASSED sur les 2 APIs
- [ ] Coverage ≥ 90% sur nouveau code
- [ ] 0 bugs Critical/Blocker
- [ ] 0 vulnérabilités High/Critical
- [ ] Tous les Security Hotspots révisés
- [ ] Duplication < 3%
- [ ] Tests passent en local ET sur CI
- [ ] Coverage report uploadé sur Sonar

### Commande de vérification rapide

```bash
# Check status via API
SONAR_TOKEN="squ_..."
SONAR_URL="https://app-d64afe8e-3d25-4e76-9180-a454874ff002.cleverapps.io"

curl -sS -H "Authorization: Bearer ${SONAR_TOKEN}" \
  "${SONAR_URL}/api/qualitygates/project_status?projectKey=virida_api" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["projectStatus"]["status"])'

# Output attendu : OK
```

---

## 📞 Support

**Questions sur les métriques** : Consulter ce document + docs SonarQube officielle

**Issues techniques** :
- Logs CI : Gitea Actions → Workflow run → Job → Logs
- Logs SonarQube : Console Clever Cloud → app virida-sonarqube → Logs

**Configuration** :
- Quality Gates : SonarQube → Administration → Quality Gates
- Projets : SonarQube → Administration → Projects
- Permissions : SonarQube → Administration → Security

---

**Document maintenu par** : DevOps VIRIDA  
**Dernière mise à jour** : 23 avril 2026  
**Version SonarQube** : Scanner CLI 8.0.1.6346
