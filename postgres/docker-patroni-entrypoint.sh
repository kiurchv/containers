#!/usr/bin/env bash
set -Eeuo pipefail

source /usr/local/bin/docker-entrypoint.sh

docker_create_patroni_directories() {
	local user; user="$(id -u)"

	mkdir -p "$PATRONI_RAFT_DATA_DIR"
	# ignore failure since there are cases where we can't chmod
	chmod 00700 "$PATRONI_RAFT_DATA_DIR" || :

	# allow the container to be started with `--user`
	if [ "$user" = '0' ]; then
		find "$PATRONI_RAFT_DATA_DIR" \! -user postgres -exec chown postgres '{}' +
	fi
}

PATRONI_POSTGRESQL_DATA_DIR=${PGDATA:=/var/lib/postgresql/data}

docker_setup_env
# setup data directories and permissions (when run as root)
docker_create_db_directories
docker_create_patroni_directories

if [ "$(id -u)" = '0' ]; then
	# then restart script as postgres user
	exec gosu postgres "$BASH_SOURCE" "$@"
fi

# # only run initialization on an empty data directory
# if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
# 	docker_verify_minimum_env

# 	# check dir permissions to reduce likelihood of half-initialized database
# 	ls /docker-entrypoint-initdb.d/ > /dev/null

# 	docker_init_database_dir
# 	pg_setup_hba_conf # "$@"

# 	# PGPASSWORD is required for psql when authentication is required for 'local' connections via pg_hba.conf and is otherwise harmless
# 	# e.g. when '--auth=md5' or '--auth-local=md5' is used in POSTGRES_INITDB_ARGS
# 	export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
# 	docker_temp_server_start # "$@"

# 	docker_setup_db
# 	docker_process_init_files /docker-entrypoint-initdb.d/*

# 	docker_temp_server_stop

# 	cat <<-'EOM'

# 		PostgreSQL init process complete; ready for start up.

# 	EOM
# else
#   cat <<-'EOM'

# 		PostgreSQL Database directory appears to contain a database; Skipping initialization

# 	EOM
# fi

exec "$@"
