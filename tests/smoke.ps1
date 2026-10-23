# Tests de fumée du site LLDG (Windows PowerShell 5.1 ou PowerShell 7).
# Usage : powershell -ExecutionPolicy Bypass -File tests/smoke.ps1 -BaseUrl http://localhost:8095
param(
    [string]$BaseUrl = "http://localhost:8080",
    [int]$Tentatives = 10
)
$ErrorActionPreference = "Stop"
$pages = "index.html", "programme.html", "inscription.html", "contact.html"

# 0. Attendre que le serveur réponde (n'importe quel code HTTP)
for ($i = 1; $i -le $Tentatives; $i++) {
    try { Invoke-WebRequest $BaseUrl -UseBasicParsing -TimeoutSec 3 | Out-Null; break }
    catch {
        if ($_.Exception.Response) { break }   # le serveur a répondu, même avec une erreur HTTP
        if ($i -eq $Tentatives) { throw "Le site ne répond pas sur $BaseUrl" }
        Start-Sleep -Seconds 1
    }
}

# 1. Chaque page répond 200 (Invoke-WebRequest échoue sur 4xx/5xx)
foreach ($p in $pages) {
    $code = (Invoke-WebRequest "$BaseUrl/$p" -UseBasicParsing).StatusCode
    Write-Output "OK  $p  HTTP $code"
}

# 2. La page d'accueil contient le nom de l'association
$r = Invoke-WebRequest $BaseUrl -UseBasicParsing
if ($r.Content -notmatch "Loups du Game") { throw "Nom de l'association absent de la page d'accueil" }
Write-Output "OK  contenu de la page d'accueil"

# 3. La feuille de style est servie
$css = Invoke-WebRequest "$BaseUrl/css/style.css" -UseBasicParsing
Write-Output "OK  css/style.css  HTTP $($css.StatusCode)"

# 4. L'en-tête d'environnement est présent
$envHeader = $r.Headers["X-Environment"]
if (-not $envHeader) { throw "En-tête X-Environment absent" }
Write-Output "OK  X-Environment: $envHeader  X-App-Version: $($r.Headers['X-App-Version'])"

# 5. Une page inexistante renvoie 404
$ok = $false
try { Invoke-WebRequest "$BaseUrl/page-absente.html" -UseBasicParsing | Out-Null }
catch { $ok = ($_.Exception.Response.StatusCode.value__ -eq 404) }
if (-not $ok) { throw "Une page absente devrait renvoyer 404" }
Write-Output "OK  page absente  HTTP 404"

Write-Output "Tous les tests sont passés."
