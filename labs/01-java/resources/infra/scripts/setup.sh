#!/usr/bin/env bash
# setup.sh — PhotoAlbum Java legacy app setup
# Runs at first boot via cloud-init (user_data).
#
# What this script does:
#   1. Updates the OS and installs Docker Engine + Docker Compose plugin + git
#   2. Clones the PhotoAlbum-Java repository
#   3. Creates protected credentials and starts Docker Compose (Oracle + Spring Boot)
#   4. Installs a systemd service so the stack restarts on VM reboot
#
# Total first-boot time: ~10 minutes (Oracle initialisation takes 3–5 minutes)
# Application URL: http://<vm-ip>:8080

set -euo pipefail

LOG=/var/log/photoalbum-setup.log
exec > >(tee -a "$LOG") 2>&1

echo "=== PhotoAlbum setup started at $(date) ==="

# ── 1. Update OS ──────────────────────────────────────────────────────────────
echo "--- Updating OS packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# ── 2. Install Docker Engine ──────────────────────────────────────────────────
echo "--- Installing Docker Engine..."
apt-get install -y ca-certificates curl gnupg lsb-release git openssl

# Docker official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Docker apt repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add azureuser to docker group so they can run docker without sudo
usermod -aG docker azureuser || true

echo "--- Docker $(docker --version) installed."

# ── 2.5 Install Ora2Pg + PostgreSQL client for Oracle→PostgreSQL migration ────
# This whole script runs as root (cloud-init), so no `sudo` is used here.
# Notes on the previous failures this section avoids:
#   * `DBI` was being COMPILED from CPAN and failed on a bare VM with no toolchain;
#     we install Perl DBI from apt (libdbi-perl) instead, and add build-essential
#     so DBD::Oracle can compile against the Oracle Instant Client.
#   * DBD::Oracle needs the proprietary Oracle client, which is not in apt; we
#     download the Oracle Instant Client (Basic + SDK) from Oracle's public CDN.
echo "--- Installing Ora2Pg, PostgreSQL client, and dependencies..."
apt-get install -y --no-install-recommends \
    perl \
    cpanminus \
    libdbi-perl \
    libdbd-pg-perl \
    postgresql-client \
    build-essential \
    wget \
    unzip \
    libaio1

# Oracle Instant Client (Basic runtime + SDK headers). Needed only for connecting
# to a live Oracle DB; offline file-based conversion works without it. Download
# failures are non-fatal so provisioning continues.
ORACLE_IC_DIR=/opt/oracle/instantclient_21_13
ORACLE_IC_ZIPVER=21.13.0.0.0dbru
ORACLE_IC_URLDIR=2113000
ORACLE_BASE_URL="https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_IC_URLDIR}"
if mkdir -p /opt/oracle && cd /opt/oracle \
    && wget -q "${ORACLE_BASE_URL}/instantclient-basic-linux.x64-${ORACLE_IC_ZIPVER}.zip" \
    && wget -q "${ORACLE_BASE_URL}/instantclient-sdk-linux.x64-${ORACLE_IC_ZIPVER}.zip" \
    && unzip -oq "instantclient-basic-linux.x64-${ORACLE_IC_ZIPVER}.zip" \
    && unzip -oq "instantclient-sdk-linux.x64-${ORACLE_IC_ZIPVER}.zip"; then
    rm -f /opt/oracle/*.zip
    echo "${ORACLE_IC_DIR}" > /etc/ld.so.conf.d/oracle-instantclient.conf
    ldconfig
    # Make the client discoverable for this script and for interactive shells.
    export ORACLE_HOME="${ORACLE_IC_DIR}"
    export LD_LIBRARY_PATH="${ORACLE_IC_DIR}:${LD_LIBRARY_PATH:-}"
    export PATH="${ORACLE_IC_DIR}:${PATH}"
    cat > /etc/profile.d/oracle-instantclient.sh <<EOF
export ORACLE_HOME=${ORACLE_IC_DIR}
export LD_LIBRARY_PATH=${ORACLE_IC_DIR}:\${LD_LIBRARY_PATH:-}
export PATH=${ORACLE_IC_DIR}:\${PATH}
EOF
    echo "--- Oracle Instant Client installed at ${ORACLE_IC_DIR}."
else
    echo "Warning: Oracle Instant Client download failed; Ora2Pg will only support offline file conversion."
fi

# Build DBD::Oracle only when the Oracle client is present (live Oracle connect).
if [ -n "${ORACLE_HOME:-}" ] && [ -d "${ORACLE_HOME:-/nonexistent}" ]; then
    cpanm --notest DBD::Oracle || echo "Warning: DBD::Oracle build failed; live Oracle connections unavailable."
fi

# Ora2Pg is NOT on CPAN — `cpanm Ora2Pg` fails with "Couldn't find module".
# It is released only as a GitHub tarball, built with Makefile.PL/make install.
# Makefile.PL prompts for the config dir; redirecting stdin from /dev/null makes
# it accept defaults non-interactively (required under cloud-init).
ORA2PG_VERSION=25.0
if wget -q "https://github.com/darold/ora2pg/archive/refs/tags/v${ORA2PG_VERSION}.tar.gz" -O /tmp/ora2pg.tar.gz \
    && tar -xzf /tmp/ora2pg.tar.gz -C /tmp; then
    if ( cd "/tmp/ora2pg-${ORA2PG_VERSION}" \
            && perl Makefile.PL </dev/null \
            && make \
            && make install ); then
        echo "--- Ora2Pg ${ORA2PG_VERSION} installed."
    else
        echo "Warning: Ora2Pg build failed (offline conversion may still be documented in Challenge 06)."
    fi
    rm -rf /tmp/ora2pg.tar.gz "/tmp/ora2pg-${ORA2PG_VERSION}"
else
    echo "Warning: Ora2Pg download failed; see Challenge 06 for manual install."
fi
echo "--- Ora2Pg $(ora2pg --version 2>/dev/null || echo 'installed (version check may require Oracle libs)') and psql $(psql --version) available."

# ── 3. Clone the PhotoAlbum-Java repository ───────────────────────────────────
REPO_URL="https://github.com/Azure-Samples/PhotoAlbum-Java.git"
APP_DIR="/opt/photoalbum"

if [ -d "$APP_DIR/.git" ]; then
    echo "--- Reusing existing PhotoAlbum checkout at $APP_DIR."
else
    echo "--- Cloning $REPO_URL → $APP_DIR..."
    git clone "$REPO_URL" "$APP_DIR"
    echo "--- Repository cloned."
fi

# ── 4. Start the application with Docker Compose ─────────────────────────────
echo "--- Starting PhotoAlbum stack with docker compose..."
cd "$APP_DIR"

# Fix missing Compose credentials: demo DB defaults and a random website admin password.
ENV_FILE="$APP_DIR/.env"
if [ ! -e "$ENV_FILE" ]; then
    (
        set +x
        umask 077
        APP_ADMIN_PASSWORD=$(openssl rand -hex 15)
        cat > "$ENV_FILE" <<EOF
ORACLE_PASSWORD=photoalbum
APP_USER=photoalbum
APP_USER_PASSWORD=photoalbum
APP_ADMIN_USERNAME=admin
APP_ADMIN_PASSWORD=${APP_ADMIN_PASSWORD}
EOF
    )
    echo "--- Created root-only application credentials in $ENV_FILE."
fi
chown root:root "$ENV_FILE"
chmod 600 "$ENV_FILE"

# Fix: gvenzl/oracle-free uses service FREEPDB1, not XE (which is Oracle XE).
# The upstream create-user.sh connects to XE, causing the container to exit(1).
cat > "$APP_DIR/oracle-init/create-user.sh" << 'CREATEUSER'
#!/bin/bash
set -euo pipefail
set +x
: "${APP_USER_PASSWORD:?APP_USER_PASSWORD must be set}"
APP_USER_UPPER=$(printf '%s' "${APP_USER:-photoalbum}" | tr '[:lower:]' '[:upper:]')

echo "Waiting for Oracle to be ready..."
sleep 30

# Local OS authentication keeps the administrator password out of process arguments.
sqlplus -s / as sysdba <<EOF
WHENEVER OSERROR EXIT FAILURE
WHENEVER SQLERROR EXIT SQL.SQLCODE
ALTER SESSION SET CONTAINER = FREEPDB1;
DECLARE
    user_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO user_exists FROM dba_users WHERE username = '${APP_USER_UPPER}';
    IF user_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER "${APP_USER_UPPER}" IDENTIFIED BY "${APP_USER_PASSWORD}"';
        EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO "${APP_USER_UPPER}"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO "${APP_USER_UPPER}"';
        EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO "${APP_USER_UPPER}"';
        EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO "${APP_USER_UPPER}"';
        EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO "${APP_USER_UPPER}"';
        EXECUTE IMMEDIATE 'ALTER USER "${APP_USER_UPPER}" DEFAULT TABLESPACE USERS';
        DBMS_OUTPUT.PUT_LINE('Application user created successfully');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Application user already exists');
    END IF;
END;
/
exit;
EOF

echo "User creation script completed."
CREATEUSER
chmod +x "$APP_DIR/oracle-init/create-user.sh"
echo "--- Patched oracle-init/create-user.sh to use FREEPDB1 service."

# Oracle Free requires at least 1 GB of shared memory to initialise correctly.
# Docker's default /dev/shm is only 64 MB, which causes Oracle to exit(1).
cat > "$APP_DIR/docker-compose.override.yml" << 'OVERRIDE'
services:
  oracle-db:
    shm_size: '1gb'
OVERRIDE

# Validate required credentials without printing the resolved configuration.
docker compose --env-file "$ENV_FILE" config --quiet

# Pull images first to give a cleaner startup
docker compose --env-file "$ENV_FILE" pull --quiet

# Build the Spring Boot image and start all services in the background
docker compose --env-file "$ENV_FILE" up --build -d

echo "--- Docker containers started:"
docker compose --env-file "$ENV_FILE" ps

# ── 5. Install systemd service for reboot persistence ────────────────────────
echo "--- Installing systemd service for auto-restart on reboot..."
cat > /etc/systemd/system/photoalbum.service << 'EOF'
[Unit]
Description=PhotoAlbum Java Application (Docker Compose)
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/photoalbum
ExecStart=/usr/bin/docker compose --env-file /opt/photoalbum/.env up -d
ExecStop=/usr/bin/docker compose --env-file /opt/photoalbum/.env down
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable photoalbum.service

echo "--- systemd service 'photoalbum' enabled."

# ── 6. Summary ────────────────────────────────────────────────────────────────
PUBLIC_IP=$(curl -s --max-time 5 http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2021-02-01&format=text 2>/dev/null || echo "<vm-public-ip>")

echo ""
echo "=== Setup complete at $(date) ==="
echo ""
echo "  Application URL : http://${PUBLIC_IP}:8080"
echo "  Log file        : $LOG"
echo ""
echo "  Oracle Database takes 3–5 minutes to fully initialise on first run."
echo "  The Spring Boot app will retry the connection automatically."
echo ""
echo "  Check container status:"
echo "    cd $APP_DIR && sudo docker compose --env-file $ENV_FILE ps"
echo ""
echo "  View application logs:"
echo "    cd $APP_DIR && sudo docker compose --env-file $ENV_FILE logs -f photoalbum-java-app"
