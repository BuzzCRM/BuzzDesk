#!/usr/bin/env bash

set -o errexit
set -o pipefail

a2dismod mpm_event mpm_worker
a2enmod perl deflate filter headers mpm_prefork
useradd -d /opt/buzzdesk -c 'BuzzDesk user' -g www-data -s /bin/bash -M buzzdesk

# link and create files
ln -sf "$PWD" /opt/buzzdesk
ln -s /opt/buzzdesk/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/zzz_buzzdesk.conf
cp Kernel/Config.pm.dist Kernel/Config.pm
mkdir -p /opt/buzzdesk/var/tmp

# start apache
apachectl start

# MySQL
if [ "$DB" == "mysql" ]; then
    .github/workflows/ci/config-mysql.sh
fi

# run needed scripts
/opt/buzzdesk/bin/buzzdesk.SetPermissions.pl
su -c "bin/buzzdesk.CheckSum.pl -a create" - buzzdesk
touch /opt/buzzdesk/installed

# prepare Selenium tests
if [[ "$GITHUB_JOB" =~ ^Selenium ]]; then
    .github/workflows/ci/config-selenium.sh
fi

if [ "$DB" ]; then
    su -c "bin/buzzdesk.Console.pl Maint::Config::Rebuild" - buzzdesk
    su -c "bin/buzzdesk.Console.pl Admin::Config::Update --setting-name CheckEmailAddresses --value 0" - buzzdesk
fi
