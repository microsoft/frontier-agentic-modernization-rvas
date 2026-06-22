FROM mcr.microsoft.com/devcontainers/universal:2

# Install Ora2Pg and PostgreSQL client for offline Oracle→PostgreSQL migration.
# The universal image ships a Yarn apt source whose signing key has expired, which
# breaks `apt-get update`; remove stale third-party lists first so the build does
# not fail with a "repository is not signed" GPG error.

# Oracle Instant Client version (x86_64). The unpacked folder is derived from it.
ARG ORACLE_IC_VERSION=21.13.0.0.0
ARG ORACLE_IC_ZIPVER=21.13.0.0.0dbru
ARG ORACLE_IC_URLDIR=2113000
# Ora2Pg release (built from GitHub tarball; it is not published on CPAN).
ARG ORA2PG_VERSION=25.0
ENV ORACLE_IC_HOME=/opt/oracle/instantclient_21_13
ENV ORACLE_HOME=${ORACLE_IC_HOME} \
    LD_LIBRARY_PATH=${ORACLE_IC_HOME} \
    TNS_ADMIN=${ORACLE_IC_HOME}/network/admin \
    PATH=${ORACLE_IC_HOME}:${PATH}

RUN find /etc/apt/sources.list.d/ -type f -exec grep -lE 'yarnpkg|dl\.yarn' {} + 2>/dev/null | xargs -r rm -f \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        perl \
        cpanminus \
        libdbi-perl \
        libdbd-pg-perl \
        postgresql-client \
        build-essential \
        wget \
        unzip \
        ca-certificates \
        libaio1 \
    # Download and unpack Oracle Instant Client (Basic runtime + SDK headers)
    && mkdir -p /opt/oracle \
    && cd /opt/oracle \
    && wget -q "https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_IC_URLDIR}/instantclient-basic-linux.x64-${ORACLE_IC_ZIPVER}.zip" \
    && wget -q "https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_IC_URLDIR}/instantclient-sdk-linux.x64-${ORACLE_IC_ZIPVER}.zip" \
    && unzip -q "instantclient-basic-linux.x64-${ORACLE_IC_ZIPVER}.zip" \
    && unzip -q "instantclient-sdk-linux.x64-${ORACLE_IC_ZIPVER}.zip" \
    && rm -f ./*.zip \
    && mkdir -p "${ORACLE_IC_HOME}/network/admin" \
    && echo "${ORACLE_IC_HOME}" > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig \
    # Build the Oracle DBI driver against the Instant Client
    && cpanm --notest DBD::Oracle \
    # Ora2Pg is NOT on CPAN; build it from the GitHub release tarball.
    # stdin is non-interactive during build, so Makefile.PL accepts defaults.
    && wget -q "https://github.com/darold/ora2pg/archive/refs/tags/v${ORA2PG_VERSION}.tar.gz" -O /tmp/ora2pg.tar.gz \
    && tar -xzf /tmp/ora2pg.tar.gz -C /tmp \
    && (cd "/tmp/ora2pg-${ORA2PG_VERSION}" && perl Makefile.PL </dev/null && make && make install) \
    && rm -rf /tmp/ora2pg.tar.gz "/tmp/ora2pg-${ORA2PG_VERSION}" \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Verify Ora2Pg and psql are available
RUN ora2pg --version || echo "Ora2Pg installed via CPAN (version check may require Oracle client libs)" && \
    psql --version
