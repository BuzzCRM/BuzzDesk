#!/bin/bash
# start-with-daemon.sh
#
# Single-container startup for EasyPanel: installs BuzzDesk on first boot
# (against either MySQL/MariaDB or PostgreSQL, set via DB_ENGINE), then runs
# the scheduler daemon in the background and Apache in the foreground.

set -e

ZNUNY_HOME=/opt/znuny
PERSISTENT_CFG=/persistent/Config.pm
ZNUNY_CFG="$ZNUNY_HOME/Kernel/Config.pm"
VERSION_FILE=/persistent/version

DB_ENGINE="${DB_ENGINE:-postgresql}"   # postgresql | mysql
DB_HOST="${DB_HOST:?DB_HOST must be set}"
DB_NAME="${DB_NAME:-buzzdesk}"
DB_USER="${DB_USER:-buzzdesk}"
DB_USER_PASS="${DB_USER_PASS:?DB_USER_PASS must be set}"
ZNUNY_ADMIN_PASS="${ZNUNY_ADMIN_PASS:?ZNUNY_ADMIN_PASS must be set}"
DEFAULT_INTERFACE="${DEFAULT_INTERFACE:-agent}"

echo "Listening on port 80"

# Seed persistent Config.pm
if [ -f "$PERSISTENT_CFG" ]; then
    echo "Using persistent Config.pm"
else
    echo "Persistent Config.pm not found, seeding it"
    cp "$ZNUNY_CFG" "$PERSISTENT_CFG"
fi
ln -sf "$PERSISTENT_CFG" "$ZNUNY_CFG"

# Configure database connection on fresh install (no version file yet)
if [ ! -f "$VERSION_FILE" ]; then
    echo "Configuring database connection ($DB_ENGINE) in Config.pm"
    grep -qF "\$Self->{DatabaseHost} = '127.0.0.1';" "$PERSISTENT_CFG" \
        || { echo "ERROR: DatabaseHost placeholder not found in Config.pm — template may have changed" >&2; exit 1; }
    sed -i "s/\$Self->{DatabaseHost} = '127\.0\.0\.1';/\$Self->{DatabaseHost} = '$DB_HOST';/" "$PERSISTENT_CFG"
    sed -i "s/\$Self->{DatabaseUser} = 'buzzdesk';/\$Self->{DatabaseUser} = '$DB_USER';/" "$PERSISTENT_CFG"
    sed -i "s/\$Self->{Database} = 'buzzdesk';/\$Self->{Database} = '$DB_NAME';/" "$PERSISTENT_CFG"
    sed -i "s/\$Self->{DatabasePw} = 'some-pass';/\$Self->{DatabasePw} = '$DB_USER_PASS';/" "$PERSISTENT_CFG"

    if [ "$DB_ENGINE" = "postgresql" ]; then
        # Comment out the default MySQL DSN line, uncomment the TCP/IP Postgres DSN line
        sed -i 's|^    \$Self->{DatabaseDSN} = "DBI:mysql:database=\$Self->{Database};host=\$Self->{DatabaseHost};";|    #$Self->{DatabaseDSN} = "DBI:mysql:database=$Self->{Database};host=$Self->{DatabaseHost};";|' "$PERSISTENT_CFG"
        sed -i 's|^#    \$Self->{DatabaseDSN} = "DBI:Pg:dbname=\$Self->{Database};host=\$Self->{DatabaseHost};";|    $Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};host=$Self->{DatabaseHost};";|' "$PERSISTENT_CFG"
    fi

    chown znuny:www-data "$PERSISTENT_CFG"
    chmod 660 "$PERSISTENT_CFG"
fi

cd "$ZNUNY_HOME"
"$ZNUNY_HOME/bin/buzzdesk.SetPermissions.pl" --buzzdesk-user znuny

# Install on first boot
if [ ! -f "$VERSION_FILE" ]; then
    echo "No installation detected, running install..."

    SQL_SUFFIX="mysql"
    [ "$DB_ENGINE" = "postgresql" ] && SQL_SUFFIX="postgresql"

    for SQL in schema initial_insert schema-post; do
        echo "Loading $SQL.$SQL_SUFFIX.sql"
        if [ "$DB_ENGINE" = "postgresql" ]; then
            PGPASSWORD="$DB_USER_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$ZNUNY_HOME/scripts/database/${SQL}.${SQL_SUFFIX}.sql"
        else
            mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_USER_PASS" "$DB_NAME" < "$ZNUNY_HOME/scripts/database/${SQL}.${SQL_SUFFIX}.sql"
        fi
    done

    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Console.pl" Maint::Config::Rebuild
    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Console.pl" Maint::Loader::CacheGenerate
    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Console.pl" Maint::Log::Clear
    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Console.pl" Admin::Config::Update --setting-name SecureMode --value 1
    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Console.pl" Admin::Config::Update --setting-name SystemID --value "$(printf "%02d\n" $((RANDOM % 99 + 1)))"
    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Console.pl" Admin::Package::Install 'Znuny Open Source Add-ons:Znuny-ContainerHelper' || echo "WARNING: optional add-on install failed, continuing"
    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Console.pl" Maint::Cache::Delete
    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Console.pl" Admin::User::SetPassword root@localhost "$ZNUNY_ADMIN_PASS"

    RELEASE_VERSION=$(grep 'VERSION' "$ZNUNY_HOME/RELEASE" | head -1 | awk '{print $NF}')
    echo "$RELEASE_VERSION" > "$VERSION_FILE"
    chown znuny:www-data "$VERSION_FILE"
    echo "Installation complete."
else
    echo "BuzzDesk already installed ($(cat "$VERSION_FILE")), skipping install."
fi

mkdir -p "$ZNUNY_HOME/var/tmp"
chown znuny:www-data "$ZNUNY_HOME/var/tmp"

DEFAULT_PAGE="index.pl"
[ "$DEFAULT_INTERFACE" = "customer" ] && DEFAULT_PAGE="customer.pl"
sed -i "s|URL=/buzzdesk/[a-z_]*\.pl|URL=/buzzdesk/${DEFAULT_PAGE}|" "$ZNUNY_HOME/var/httpd/htdocs/index.html"

# Start the scheduler daemon in the background
gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Daemon.pl" start || echo "WARNING: could not start daemon"

term_handler() {
    echo "Received termination signal, stopping BuzzDesk"
    gosu znuny "$ZNUNY_HOME/bin/buzzdesk.Daemon.pl" stop || true
    apachectl stop || true
    exit 0
}
trap term_handler INT TERM

echo "Starting Apache..."
apache2 -DFOREGROUND
