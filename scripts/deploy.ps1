# Déploie un environnement LLDG. À lancer depuis la racine du dépôt.
# Usage : .\scripts\deploy.ps1 -Cible preprod
param(
    [Parameter(Mandatory)]
    [ValidateSet("dev", "preprod", "prod")]
    [string]$Cible
)
$ErrorActionPreference = "Stop"
$options = @("-p", "lldg-$Cible", "-f", "docker-compose.yml", "-f", "docker-compose.$Cible.yml")
if ($Cible -eq "dev") {
    docker compose @options up -d --build
} else {
    docker compose @options up -d
}
docker compose @options ps
