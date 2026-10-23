#!/usr/bin/env bash
# Tests de fumée du site LLDG (Git Bash, WSL ou Linux).
# Usage : ./tests/smoke.sh http://localhost:8095
set -euo pipefail
base="${1:-http://localhost:8080}"
pages="index.html programme.html inscription.html contact.html"

code_http() { curl -s -o /dev/null -w "%{http_code}" "$1" || true; }

# 0. Attendre que le serveur réponde (n'importe quel code HTTP)
for i in $(seq 1 10); do
  [ "$(code_http "$base")" != "000" ] && break
  [ "$i" -eq 10 ] && { echo "Le site ne répond pas sur $base"; exit 1; }
  sleep 1
done

# 1. Chaque page répond 200
for p in $pages; do
  code=$(code_http "$base/$p")
  [ "$code" = "200" ] || { echo "ECHEC $p : HTTP $code"; exit 1; }
  echo "OK  $p  HTTP $code"
done

# 2. La page d'accueil contient le nom de l'association
curl -s "$base" | grep -q "Loups du Game" || { echo "ECHEC nom de l'association absent"; exit 1; }
echo "OK  contenu de la page d'accueil"

# 3. La feuille de style est servie
code=$(code_http "$base/css/style.css")
[ "$code" = "200" ] || { echo "ECHEC css/style.css : HTTP $code"; exit 1; }
echo "OK  css/style.css  HTTP $code"

# 4. L'en-tête d'environnement est présent
entetes=$(curl -sI "$base")
echo "$entetes" | grep -qi '^x-environment:' || { echo "ECHEC en-tête X-Environment absent"; exit 1; }
echo "OK  $(echo "$entetes" | grep -i '^x-environment:' | tr -d '\r')"

# 5. Une page inexistante renvoie 404
code=$(code_http "$base/page-absente.html")
[ "$code" = "404" ] || { echo "ECHEC page absente : HTTP $code au lieu de 404"; exit 1; }
echo "OK  page absente  HTTP 404"

echo "Tous les tests sont passés."
