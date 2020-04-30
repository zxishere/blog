FROM 3guang/php-apache2:v0.0.2

ADD public/info.php /var/www/html/info.php

CMD sed -i -e "s/Listen 80/Listen $PORT/g" /usr/local/apache2/conf/httpd.conf && httpd-foreground