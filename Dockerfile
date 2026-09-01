# Dockerfile
# Single-container build for EasyPanel: builds BuzzDesk directly from this
# repository (no external tarball download, no pre-built base image) and
# runs Apache + the scheduler daemon together in one process.

FROM debian:12.13-slim

ARG BUZZDESK_USER=znuny
ENV ZNUNY_HOME=/opt/znuny \
    PATH=$PATH:/opt/znuny/bin

# gosu (privilege drop helper)
ARG GOSU_VERSION=1.17
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget && \
    dpkgArch="$(dpkg --print-architecture)" && \
    wget -qO /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}" && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# System + Perl + Apache packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wget default-mysql-client postgresql-client vim curl unzip \
      apache2 libapache2-mod-perl2 rsync \
      libdbd-odbc-perl \
      libdbd-mysql-perl \
      libdbd-pg-perl \
      libdbi-perl \
      libtimedate-perl \
      libnet-dns-perl \
      libnet-ldap-perl \
      libio-socket-ssl-perl \
      libpdf-api2-perl \
      libsoap-lite-perl \
      libtext-csv-xs-perl \
      libjson-xs-perl \
      libapache-dbi-perl \
      libxml-libxml-perl \
      libxml-libxslt-perl \
      libyaml-perl \
      libarchive-zip-perl \
      libcrypt-eksblowfish-perl \
      libencode-hanextra-perl \
      libmail-imapclient-perl \
      libtemplate-perl \
      libdatetime-perl \
      libdatetime-timezone-perl \
      libdatetime-locale-perl \
      libmoo-perl \
      locales \
      bash-completion \
      libyaml-libyaml-perl \
      libjavascript-minifier-xs-perl \
      libcss-minifier-xs-perl \
      libauthen-sasl-perl \
      libauthen-ntlm-perl \
      libcrypt-jwt-perl \
      libcrypt-openssl-x509-perl \
      libhash-merge-perl \
      libical-parser-perl \
      libspreadsheet-xlsx-perl \
      libdata-uuid-perl \
      libmoose-perl \
      libmoosex-types-uri-perl \
      libmoosex-types-datetime-perl \
      libdatetime-format-xsd-perl \
      libdatetime-hires-perl \
      liblwp-protocol-https-perl \
      libssl-dev \
      libcrypt-openssl-random-perl \
      libfile-slurper-perl \
      build-essential cpanminus && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && \
    locale-gen

RUN cpanm --notest --force Jq Net::SAML2 && \
    apt remove --purge -y build-essential cpanminus gcc make libssl-dev && \
    apt autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/* /root/.cpanm

# App source: this Dockerfile builds directly from the repo (build context = repo root)
RUN mkdir -p ${ZNUNY_HOME}
COPY . ${ZNUNY_HOME}/

RUN sed -i 's/^#use DBD::mysql/use DBD::mysql/' ${ZNUNY_HOME}/scripts/apache2-perl-startup.pl && \
    sed -i 's/^#use Kernel::System::DB::mysql/use Kernel::System::DB::mysql/' ${ZNUNY_HOME}/scripts/apache2-perl-startup.pl

RUN useradd -d ${ZNUNY_HOME} -c "BuzzDesk user" -g www-data -s /bin/bash -M -N ${BUZZDESK_USER} && \
    mkdir /persistent && \
    cp ${ZNUNY_HOME}/Kernel/Config.pm.dist /persistent/Config.pm && \
    chown -R ${BUZZDESK_USER}:www-data /persistent && \
    chmod 2775 /persistent && \
    ${ZNUNY_HOME}/bin/buzzdesk.SetPermissions.pl --buzzdesk-user ${BUZZDESK_USER}

# Apache configuration
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork perl headers deflate filter cgi rewrite && \
    echo "RedirectMatch ^/\$ /buzzdesk/index.pl" >> /etc/apache2/apache2.conf && \
    ln -s ${ZNUNY_HOME}/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/zzz_buzzdesk.conf && \
    a2enconf zzz_buzzdesk

ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid

RUN mkdir -p /var/run/apache2 /var/lock/apache2 /var/log/apache2 && \
    chown -R www-data:www-data /var/run/apache2 /var/lock/apache2 /var/log/apache2 && \
    ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/2 /var/log/apache2/error.log && \
    ln -sf /proc/self/fd/2 /var/log/apache2/other_vhosts_access.log

EXPOSE 80

COPY start-with-daemon.sh /usr/local/bin/start-with-daemon.sh
RUN chmod +x /usr/local/bin/start-with-daemon.sh

USER root
ENTRYPOINT ["/usr/local/bin/start-with-daemon.sh"]
