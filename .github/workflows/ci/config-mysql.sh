#!/usr/bin/env bash

set -o errexit
set -o pipefail

echo "Change Config.pm"
sed -i 's/\(.*{DatabaseHost}.*\)127.0.0.1/\1'"mariadb"'/' /opt/buzzdesk/Kernel/Config.pm
sed -i 's/\(.*{Database}.*\)buzzdesk/\1'"${MYSQL_DATABASE}"'/' /opt/buzzdesk/Kernel/Config.pm
sed -i 's/\(.*{DatabaseUser}.*\)buzzdesk/\1'"${MYSQL_USER}"'/' /opt/buzzdesk/Kernel/Config.pm
sed -i 's/\(.*{DatabasePw}.*\)some-pass/\1'"${MYSQL_PASSWORD}"'/' /opt/buzzdesk/Kernel/Config.pm

SCHEMA_FILE=$(find /opt/buzzdesk/scripts/database -type f -name '*schema.mysql.sql')
INITIAL_INSERT_FILE=$(find /opt/buzzdesk/scripts/database -type f -name '*initial_insert.mysql.sql')
SCHEMA_POST_FILE=$(find /opt/buzzdesk/scripts/database -type f -name '*schema-post.mysql.sql')

echo "Use SCHEMA_FILE: $SCHEMA_FILE"
echo "Use INITIAL_INSERT_FILE: $INITIAL_INSERT_FILE"
echo "Use SCHEMA_POST_FILE: $SCHEMA_POST_FILE"

echo "Change character set"
mysql -h mariadb -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -e "ALTER DATABASE buzzdesk DEFAULT CHARACTER SET utf8mb4;ALTER DATABASE buzzdesk DEFAULT COLLATE utf8mb4_unicode_ci;" || exit 1

echo "Create schema"
mysql -h mariadb -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" buzzdesk < "$SCHEMA_FILE" || exit 1

echo "Initial data"
mysql -h mariadb -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" buzzdesk < "$INITIAL_INSERT_FILE" || exit 1

echo "Create post schema"
mysql -h mariadb -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" buzzdesk < "$SCHEMA_POST_FILE" || exit 1

