FROM php:8.2-fpm

ARG NODE_VERSION=16
ENV TZ=Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && mkdir -p /var/run/php/ \
    && mkdir -p /var/www/src/alpine \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install supervisor libicu-dev zlib1g-dev libpng-dev libzip-dev libxml2-dev libonig-dev libldap2-dev libgmp-dev cron sudo -y \
    && apt-get install libcurl4-openssl-dev \
    && docker-php-ext-install curl intl gd zip xml mbstring ldap gmp

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && curl -sLS https://deb.nodesource.com/setup_$NODE_VERSION.x | bash \
    && apt-get install -y nodejs

WORKDIR /var/www/src/alpine

ARG CONTAINER_ENV
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG LOCAL_UID
ARG LOCAL_GID

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY supervisord.conf /etc/supervisord.conf
COPY startup.sh /opt/startup.sh
COPY . /var/www/src/alpine

RUN whoami \
    && echo "change user to local UID $LOCAL_UID" \
    && usermod -u $LOCAL_UID www-data \
    && echo "change user group to local GID $LOCAL_GID" \
    && groupmod -g $LOCAL_GID www-data \
    && chown -R root:www-data /var/www/src/alpine \
    && chmod 777 -R /var/www/src/alpine \
    && mkdir -p /run/nginx \
    && mkdir -p /var/lib/nginx/ \
    && rm -f /etc/nginx/sites-enabled/default \
    && rm -f /etc/nginx/sites-available/default \
    && sed -i 's/listen = 127.0.0.1.*/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/www.conf \
    # php setup
    && sed -i 's/post_max_size.*/post_max_size = 20G/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/upload_max_filesize.*/upload_max_filesize = 20G/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/memory_limit.*/memory_limit = 1G/' "$PHP_INI_DIR/php.ini" \
    # zend opcache setup
    && sed -i 's~;zend_extension=opcache.*~zend_extension=opcache~' "$PHP_INI_DIR/php.ini" \
    && sed -i 's~;opcache.enable=.*~opcache.enable=0~' "$PHP_INI_DIR/php.ini" \
    && sed -i 's~;opcache.enable_cli=.*~opcache.enable_cli=1~' "$PHP_INI_DIR/php.ini" \
    && sed -i 's~;opcache.memory_consumption=.*~opcache.memory_consumption=128~' "$PHP_INI_DIR/php.ini" \
    && sed -i 's~;opcache.max_accelerated_files=.*~opcache.max_accelerated_files=10000~' "$PHP_INI_DIR/php.ini" \
    && sed -i 's~;opcache.revalidate_freq=.*~opcache.revalidate_freq=200~' "$PHP_INI_DIR/php.ini" \
    # cron job setup
    # MAKE SURE TO PUT INTO THE SAME USER AS THE SCHEDULER otherwise log files will not be created with the correct permissions to allow the function to perform correctly ## crontab -e -u www-data #
    && touch /var/spool/cron/crontabs/www-data \
    && echo "* * * * * /var/www/src/alpine/logging.sh >> /var/www/src/alpine/storage/logs/crontab_joblogs/cronjob-\`date +\%Y-\%m-\%d\`.log 2>&1" >> /var/spool/cron/crontabs/www-data \
    && { crontab -l -u www-data; echo '#ACTIVATE'; } | crontab -u www-data - \
    # nginx tmp directory correct permissions for uploading files
    && chown www-data:www-data -R /var/lib/nginx/
    

