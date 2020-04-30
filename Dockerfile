FROM php:7.3-apache-stretch

RUN apt-get -y update && \
        apt-get -y upgrade

RUN apt-get install -y git gnupg2 apt-transport-https ca-certificates && \
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

#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

#set our application folder as an environment variable
ENV APP_HOME /var/www/html

#change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

#change the web_root to laravel /var/www/html/public folder
RUN sed -i -e "s/html/html\/public/g" /etc/apache2/sites-enabled/000-default.conf

# enable apache module rewrite
RUN a2enmod rewrite

#copy source files and run composer
COPY . $APP_HOME

# install all PHP dependencies
RUN composer install --no-interaction --no-dev

#change ownership of our applications
RUN chown -R www-data:www-data $APP_HOME

#update apache port at runtime for Heroku
ENTRYPOINT []
CMD sed -i "s/80/$PORT/g" /etc/apache2/sites-enabled/000-default.conf /etc/apache2/ports.conf && docker-php-entrypoint apache2-foreground