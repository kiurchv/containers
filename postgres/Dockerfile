FROM postgres:17.2-alpine3.21

ARG CITUS_VERSION=13.0.1

# Setup apk repositories
RUN echo 'https://dl-cdn.alpinelinux.org/alpine/v3.21/community' >> /etc/apk/repositories

# Build citus and delete all used libraries
RUN apk add --no-cache \
  --virtual builddeps \
  build-base \
  krb5-dev \
  curl \
  curl-dev \
  openssl-dev \
  ca-certificates \
  llvm \
  llvm19-dev \
  clang19 \
  lz4-dev \
  zstd-dev \
  libxslt-dev \
  libxml2-dev \
  icu-dev && \
  apk add --no-cache libcurl && \
  curl -sfLO "https://github.com/citusdata/citus/archive/v${CITUS_VERSION}.tar.gz" && \
  tar xzf "v${CITUS_VERSION}.tar.gz" && \
  cd "citus-${CITUS_VERSION}" && \
  ./configure --with-security-flags && \
  make install && \
  cd .. && \
  rm -rf "citus-${CITUS_VERSION}" "v${CITUS_VERSION}.tar.gz" && \
  apk del builddeps

# Install lz4 dependencies
RUN apk add --no-cache \
  zstd \
  zstd-dev \
  lz4 \
  lz4-dev

# # Add citus to default PostgreSQL config
# RUN echo "shared_preload_libraries='citus'" >> /usr/local/share/postgresql/postgresql.conf.sample

# Install Patroni dependencies
RUN apk add --no-cache \
  python3-dev \
  py3-pip \
  py3-psycopg \
  py3-virtualenv

# Create a virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install Patroni
RUN apk add --no-cache --virtual builddeps \
  build-base \
  linux-headers && \
  pip install patroni[psycopg3,raft] && \
  apk del builddeps

# Add Patroni config file
COPY patroni.yaml /etc/patroni.yaml

# Setup Patroni Raft directory
ENV PATRONI_RAFT_DATA_DIR /var/lib/raft
# this 1777 will be replaced by 0700 at runtime (allows semi-arbitrary "--user" values)
RUN install --verbose --directory --owner postgres --group postgres --mode 1777 "$PATRONI_RAFT_DATA_DIR"
VOLUME /var/lib/raft

# USER postgres

# Setup entrypoint script and default command
COPY docker-patroni-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-patroni-entrypoint.sh"]
CMD ["patroni", "/etc/patroni.yaml"]
