FROM php:7.3-apache-stretch

RUN apt-get -y update && \
        apt-get -y upgrade

RUN apt-get install -y gnupg2 apt-transport-https ca-certificates && \
    #apt-get install -y libapache2-mod-evasive && \
    #a2dismod mpm_event && \
    #a2enmod evasive && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update -y && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools && \
    ACCEPT_EULA=Y apt-get install -y unixodbc-dev libgssapi-krb5-2 && \
    apt-get install -y libpq-dev libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libfreetype6-dev pkg-config libmagickwand-dev

RUN docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/include \
    --with-png-dir=/usr/include \
    --with-freetype-dir=/usr/include && \
    pecl install sqlsrv pdo_sqlsrv redis imagick && \
    docker-php-ext-install gd pcntl pdo pdo_pgsql && \
    docker-php-ext-enable sqlsrv pdo_sqlsrv redis imagick gd pcntl pdo pdo_pgsql

ADD public/index.html /var/www/html/index.html
ADD public/info.php /var/www/html/info.php

ENTRYPOINT []

CMD sed -i "s/Listen 80/Listen ${PORT}/g" /etc/apache2/ports.conf && apache2-foreground