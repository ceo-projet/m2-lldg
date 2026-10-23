#!/usr/bin/env bash
# Déploie un environnement LLDG. À lancer depuis la racine du dépôt.
# Usage : ./scripts/deploy.sh preprod
set -euo pipefail
cible="${1:-}"
case "$cible" in
  dev|preprod|prod) ;;
  *) echo "Usage : $0 dev|preprod|prod" >&2; exit 1 ;;
esac
options=(-p "lldg-$cible" -f docker-compose.yml -f "docker-compose.$cible.yml")
if [ "$cible" = "dev" ]; then
  docker compose "${options[@]}" up -d --build
else
  docker compose "${options[@]}" up -d
fi
docker compose "${options[@]}" ps
