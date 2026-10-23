# Les Loups du Game

Site de l'escape game d'Halloween organisé par l'association Les Loups du Game sur l'île du Frioul, à Marseille.
Projet support de la formation « Pipelines DevOps CI/CD » : le site est conteneurisé avec Docker et déployé par Jenkins
dans trois environnements (Dev, Pré-prod, Prod).

## Dépôt officiel

`https://github.com/ceo-projet/m2-lldg` – le projet GitLab `beliink/lldg` est archivé (lecture seule).

## Contenu du dépôt

```
m2-lldg/
├── site/                      les 4 pages du site, la feuille de style et le logo
├── docker/nginx/              configuration Nginx paramétrable (template)
├── env/                       variables de chaque environnement (dev, preprod, prod)
├── tests/                     tests de fumée (PowerShell et Bash)
├── scripts/                   scripts de déploiement (PowerShell et Bash)
├── .github/                   modèle de pull request, relecteurs désignés
├── Dockerfile                 recette de l'image lldg
├── docker-compose.yml         socle commun aux environnements
├── docker-compose.dev.yml     environnement Dev       → http://localhost:8081
├── docker-compose.preprod.yml environnement Pré-prod  → http://localhost:8082
├── docker-compose.prod.yml    environnement Prod      → http://localhost:8080
├── Jenkinsfile                pipeline CI/CD
└── .env                       version de l'image (LLDG_VERSION)
```

## Prérequis

- Docker Desktop (moteur WSL 2) et Git
- VS Code avec les extensions Docker et GitLens (conseillées)
- Pour le pipeline : Jenkins LTS sur le port 9090, Java 21, plugin Pipeline Graph View

## Démarrer en local

```powershell
git clone https://github.com/ceo-projet/m2-lldg.git
cd m2-lldg
.\scripts\deploy.ps1 -Cible dev        # Bash : ./scripts/deploy.sh dev
```

Ouvrir http://localhost:8081. En Dev, le dossier `site/` est monté dans le conteneur :
une modification d'une page est visible en rechargeant le navigateur.

## Construire et tester l'image

```powershell
docker build --build-arg VERSION=2.0.0 -t lldg:2.0.0 .
docker run -d --name lldg-test -p 8095:80 lldg:2.0.0
.\tests\smoke.ps1 -BaseUrl http://localhost:8095     # Bash : ./tests/smoke.sh http://localhost:8095
docker rm -f lldg-test
```

Les tests vérifient que les 4 pages et la feuille de style répondent, que la page d'accueil contient
le nom de l'association, que l'en-tête `X-Environment` est présent et qu'une page absente renvoie 404.

## Environnements

| Environnement | Commande                               | Adresse               | Particularités                          |
|---------------|----------------------------------------|-----------------------|-----------------------------------------|
| Dev           | `.\scripts\deploy.ps1 -Cible dev`      | http://localhost:8081 | Bandeau bleu, site monté en direct      |
| Pré-prod      | `.\scripts\deploy.ps1 -Cible preprod`  | http://localhost:8082 | Bandeau orange, image figée             |
| Prod          | `.\scripts\deploy.ps1 -Cible prod`     | http://localhost:8080 | Sans bandeau, ressources limitées       |

La version déployée en Pré-prod et en Prod est celle du fichier `.env` (`LLDG_VERSION`).
Pour vérifier ce qui tourne : `curl.exe -I http://localhost:8082` affiche `X-Environment` et `X-App-Version`.

## Pipeline Jenkins

Job `lldg-pipeline` de type Pipeline, « Pipeline script from SCM » :

- Repository URL : `https://github.com/ceo-projet/m2-lldg.git` (dépôt public, sans identifiant)
- Branch Specifier : `*/main` – Script Path : `Jenkinsfile`

Étapes : Checkout → Build image → Test HTTP → Deploy Dev → Deploy Pré-prod → Recette (validation manuelle) → Deploy Prod.
Chaque build produit l'image `lldg:2.0.<numéro de build>`. Jenkins vérifie GitHub toutes les 2 minutes
(un webhook GitHub ne peut pas joindre un Jenkins installé sur `localhost`).

## Contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md). En résumé : une branche par ticket Jira, la clé du ticket dans
chaque message de commit, et une pull request relue avant toute fusion sur `main`.

## Équipe

Chef de projet : ceo@beliink.fr – Chef de l'équipe Dev : samuel@beliink.fr
