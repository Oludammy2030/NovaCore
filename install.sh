#!/bin/bash
# ============================================================
# AfriNova Nexus — One-Command Installer for Hostinger VPS
# Run as root on a fresh Ubuntu 22.04 VPS:
#   curl -fsSL https://raw.githubusercontent.com/Oludammy2030/afrinova-app/main/install.sh | bash
# ============================================================

set -e

# One-liner: curl -fsSL https://raw.githubusercontent.com/Oludammy2030/afrinova-app/main/install.sh | bash

echo "============================================"
echo "  AfriNova Nexus — VPS Installer"
echo "  Powered by n8n + Docker"
echo "============================================"

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Please run as root: sudo bash install.sh"
  exit 1
fi

SERVER_IP=$(curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')
echo "Your server IP: $SERVER_IP"

echo ""
echo "How would you like to set up your domain?"
echo "  1) I have my own domain - recommended"
echo "  2) Use a free DuckDNS subdomain - free"
read -p "Enter 1 or 2: " DOMAIN_CHOICE

if [ "$DOMAIN_CHOICE" = "1" ]; then
  read -p "Enter your full domain (e.g. nexus.mycompany.com): " DOMAIN
  DUCKDNS_MODE=false
elif [ "$DOMAIN_CHOICE" = "2" ]; then
  echo "Go to https://www.duckdns.org - sign in - create a subdomain - set IP to $SERVER_IP"
  read -p "Enter your DuckDNS subdomain (just the name): " DUCKDNS_SUBDOMAIN
  read -p "Enter your DuckDNS Token: " DUCKDNS_TOKEN
  DOMAIN="${DUCKDNS_SUBDOMAIN}.duckdns.org"
  curl -s "https://www.duckdns.org/update?domains=${DUCKDNS_SUBDOMAIN}&token=${DUCKDNS_TOKEN}&ip=${SERVER_IP}"
  DUCKDNS_MODE=true
else
  echo "Invalid choice. Run again."; exit 1
fi

read -p "Set an n8n admin email: " N8N_EMAIL
read -s -p "Set an n8n admin password: " N8N_PASSWORD
echo ""
N8N_ENCRYPTION_KEY=$(openssl rand -hex 24)
INSTALL_DIR="/opt/nexus"

echo "Updating system..."
apt-get update -qq && apt-get upgrade -y -qq

echo "Installing Docker..."
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sh
fi

echo "Installing nginx and certbot..."
apt-get install -y nginx certbot python3-certbot-nginx docker-compose -qq

mkdir -p "${INSTALL_DIR}/n8n_data"
chown -R 1000:1000 "${INSTALL_DIR}/n8n_data"

cat > "${INSTALL_DIR}/docker-compose.yml" << EOF
version: "3.8"
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: nexus_n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=${DOMAIN}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://${DOMAIN}/
      - N8N_ENCRYPTION_KEY="${N8N_ENCRYPTION_KEY}"
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER="${N8N_EMAIL}"
      - N8N_BASIC_AUTH_PASSWORD="${N8N_PASSWORD}"
      - EXECUTIONS_MODE=regular
      - N8N_DIAGNOSTICS_ENABLED=false
      - GENERIC_TIMEZONE=UTC
    volumes:
      - ${INSTALL_DIR}/n8n_data:/home/node/.n8n
EOF

cat > /etc/nginx/sites-available/nexus << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_read_timeout 3600;
        client_max_body_size 16M;
    }
}
EOF

ln -sf /etc/nginx/sites-available/nexus /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "$N8N_EMAIL" --redirect || echo "SSL failed - run: certbot --nginx -d $DOMAIN manually"

cd "${INSTALL_DIR}" && docker-compose up -d

cat > "${INSTALL_DIR}/credentials.txt" << EOF
n8n URL: https://${DOMAIN}
Email: ${N8N_EMAIL}
Password: ${N8N_PASSWORD}
Encryption key: ${N8N_ENCRYPTION_KEY}
Setup Wizard: https://${DOMAIN}/form/ai-suite-setup
EOF
chmod 600 "${INSTALL_DIR}/credentials.txt"

echo "============================================"
echo "  Installation Complete!"
echo "============================================"
echo "  n8n URL: https://${DOMAIN}"
echo "  Setup Wizard: https://${DOMAIN}/form/ai-suite-setup"
echo ""
echo "NEXT: open the n8n URL, create an API key, import workflows, then run the Setup Wizard"
