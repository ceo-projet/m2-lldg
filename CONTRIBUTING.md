# Contribuer au projet LLDG

## Flux de travail

1. Prendre un ticket dans Jira et le passer « En cours ».
2. Partir d'une branche `main` à jour :
   ```
   git switch main
   git pull
   git switch -c feature/LLDG-12-page-programme
   ```
3. Travailler, tester en local (`.\scripts\deploy.ps1 -Cible dev`, puis `tests/smoke.ps1`).
4. Commiter avec la clé du ticket : `git commit -m "LLDG-12 Ajoute les tarifs étudiants"`.
5. Pousser et ouvrir une pull request vers `main` :
   ```
   git push -u origin feature/LLDG-12-page-programme
   gh pr create --base main --fill
   ```
6. Une approbation est nécessaire avant la fusion. Après la fusion, Jenkins construit, teste et déploie.

## Nommage des branches

| Préfixe     | Usage                              | Exemple                          |
|-------------|------------------------------------|----------------------------------|
| `feature/`  | Nouvelle fonctionnalité            | `feature/LLDG-12-page-programme` |
| `fix/`      | Correction                         | `fix/LLDG-15-lien-contact`       |
| `docs/`     | Documentation                      | `docs/LLDG-18-readme`            |
| `ops/`      | Docker, Compose, Jenkins           | `ops/LLDG-20-healthcheck`        |

## Règles

- Jamais de push direct sur `main` : la branche est protégée.
- Jamais de secret (mot de passe, jeton) dans le dépôt, même dans une branche.
- Une pull request = un ticket = un sujet.
- Les fichiers d'infrastructure (Dockerfile, Compose, Jenkinsfile) sont relus par l'équipe Ops.
