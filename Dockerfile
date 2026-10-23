# Image du site Les Loups du Game
# Construction : docker build --build-arg VERSION=2.0.0 -t lldg:2.0.0 .
FROM nginx:stable-alpine

# Arguments disponibles uniquement pendant la construction
ARG VERSION=dev
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="Les Loups du Game" \
      org.opencontainers.image.description="Site de l'escape game d'Halloween de l'île du Frioul" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.vendor="Beliink" \
      org.opencontainers.image.source="https://github.com/ceo-projet/m2-lldg" \
      maintainer="ceo@beliink.fr"

# Variables lues au démarrage du conteneur (surchargeables avec -e ou env_file)
ENV APP_ENV=prod \
    APP_VERSION=${VERSION} \
    APP_BANNER=""

# On retire la configuration et la page par défaut de Nginx
RUN rm -f /etc/nginx/conf.d/default.conf \
 && rm -rf /usr/share/nginx/html/*

# Configuration paramétrable, complétée au démarrage par les variables APP_*
COPY docker/nginx/default.conf.template /etc/nginx/templates/default.conf.template

# Les pages du site
COPY site/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q --spider http://127.0.0.1/ || exit 1
