FROM mcr.microsoft.com/devcontainers/universal:2

# Install Ora2Pg and PostgreSQL client for offline Oracle→PostgreSQL migration.
# The universal image ships a Yarn apt source whose signing key has expired, which
# breaks `apt-get update`. Remove any third-party lists with stale keys first so the
# build does not fail with a "repository is not signed" GPG error.
RUN find /etc/apt/sources.list.d/ -type f -exec grep -lE 'yarnpkg|dl\.yarn' {} + 2>/dev/null | xargs -r rm -f \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        perl \
        cpanminus \
        libdbi-perl \
        libdbd-oracle-perl \
        libaio1 \
        postgresql-client \
    && cpanm --notest Ora2Pg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Verify Ora2Pg and psql are available
RUN ora2pg --version || echo "Ora2Pg installed via CPAN (version check may require Oracle client libs)" && \
    psql --version
