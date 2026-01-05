#cloud-config
package_update: true
package_upgrade: true
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - lsb-release
runcmd:
  - |
    # Use a POSIX-compatible set; /bin/sh in cloud-init does not support -o pipefail
    set -eu

    # Install Docker and Docker Compose from Ubuntu repos (version compatible with Traefik's Docker client)
    if ! command -v docker >/dev/null 2>&1; then
      apt-get update -y
      apt-get install -y docker.io docker-compose
      systemctl enable --now docker
      usermod -aG docker ubuntu || true
    fi

    # Install and start SSM Agent for Session Manager (safer than SSH)
    if ! snap list | grep -q amazon-ssm-agent; then
      snap install amazon-ssm-agent --classic || true
    fi
    systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true

    mkdir -p /opt/traefik/data
    mkdir -p /opt/app
    mkdir -p /opt/portainer/data

    cat >/opt/app/docker-compose.yml <<'COMPOSE'
    version: "3.8"
    services:
      traefik:
        image: traefik:v3.1
        container_name: traefik
        restart: unless-stopped
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock:ro
          - /opt/traefik/data:/letsencrypt
        command:
          - "--providers.docker=true"
          - "--providers.docker.exposedbydefault=false"
          - "--entrypoints.web.address=:80"
          - "--entrypoints.websecure.address=:443"
          - "--certificatesresolvers.letsencrypt.acme.email=${acme_email}"
          - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
          - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
          - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.http-catchall.rule=HostRegexp(`{any:.+}`)"
          - "traefik.http.routers.http-catchall.entrypoints=web"
          - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
          - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"

      backend:
        image: ${backend_image}
        container_name: backend
        restart: unless-stopped
        environment:
          DB_HOST: "${db_host}"
          DB_NAME: "${db_name}"
          DB_USER: "${db_user}"
          DB_PASSWORD: "${db_password}"
          DB_PORT: "${db_port}"
          MEDIA_BUCKET: "${media_bucket}"
          ALLOWED_HOSTS: "salao.andrepombo.info,localhost,127.0.0.1"
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.backend.rule=Host(`${app_domain}`) && PathPrefix(`/api`)"
          - "traefik.http.routers.backend.entrypoints=websecure"
          - "traefik.http.routers.backend.tls.certresolver=letsencrypt"
          - "traefik.http.services.backend.loadbalancer.server.port=8000"

      frontend:
        image: ${frontend_image}
        container_name: frontend
        restart: unless-stopped
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.frontend.rule=Host(`${app_domain}`) && PathPrefix(`/`)"
          - "traefik.http.routers.frontend.entrypoints=websecure"
          - "traefik.http.routers.frontend.tls.certresolver=letsencrypt"
          - "traefik.http.services.frontend.loadbalancer.server.port=80"

      portainer:
        image: portainer/portainer-ce:latest
        container_name: portainer
        restart: unless-stopped
        ports:
          - "9000:9000"
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - /opt/portainer/data:/data

    COMPOSE

    docker-compose -f /opt/app/docker-compose.yml up -d
