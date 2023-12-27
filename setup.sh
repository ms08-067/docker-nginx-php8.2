apk add nano
apk add bash
apk add sudo


#The ultra fast download utility
apk add aria2

apk add tzdata
cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
date

apk add --upgrade glances

sudo -i

apk update
apk upgrade

#install aws
#https://github.com/aws/aws-cli/issues/4685#issuecomment-615872019
apk --no-cache add \
    binutils \
    curl \
&& curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
&& curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.31-r0/glibc-2.31-r0.apk \
&& curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.31-r0/glibc-bin-2.31-r0.apk \
&& apk add --no-cache \
    glibc-2.31-r0.apk \
    glibc-bin-2.31-r0.apk \
&& rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples \
&& apk --no-cache del \
    binutils \
    curl \
&& rm glibc-2.31-r0.apk \
&& rm glibc-bin-2.31-r0.apk \
&& rm -rf /var/cache/apk/*

apk add groff less
aws configure

#install php from repo
cat > /etc/apk/repositories << EOF
http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main
http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community
EOF
apk add php7 php7-bcmath php7-fileinfo php7-ssh2 php7-ftp php7-bz2 php7-ctype php7-curl php7-dom php7-enchant php7-exif php7-fpm php7-gd php7-gettext php7-gmp php7-iconv php7-imap php7-intl php7-json php7-mbstring php7-opcache php7-openssl php7-phar php7-posix php7-pspell php7-recode php7-session php7-simplexml php7-sockets php7-sysvmsg php7-sysvsem php7-sysvshm php7-tidy php7-xml php7-xmlreader php7-xmlrpc php7-xmlwriter php7-xsl php7-zip php7-sqlite3 php7-dba php7-sqlite3 php7-mysqli php7-mysqlnd php7-pgsql php7-pdo_dblib php7-pdo_odbc php7-pdo_pgsql php7-pdo_sqlite php7-snmp php7-soap php7-ldap php7-pcntl php7-pear php7-shmop php7-wddx php7-cgi php7-pdo php7-snmp php7-tokenizer

# LDAP configuration
echo TLS_REQCERT never >> /etc/openldap/ldap.conf

apk add curl
cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
composer -v
rm composer-setup.php

apk add nginx
rm -rf /etc/nginx/conf.d/default.conf
cd /etc/nginx/ 

cat >> /etc/nginx/conf.d/upload_download_tool.conf <<EOL
# This is a default site configuration which will simply return 404, preventing
# chance access to any other virtualhost.

server {
    listen 80;
    server_name alpine.lc;
    large_client_header_buffers 8 16k;
    client_header_buffer_size 2k;

    uwsgi_connect_timeout 600s;
    proxy_connect_timeout 600s;
    proxy_send_timeout 600s;
    proxy_read_timeout 600s;
    fastcgi_send_timeout 600s;
    fastcgi_read_timeout 600s;

    client_max_body_size 5000m;
    client_header_timeout 5m;
    client_body_timeout 5m;

    root /var/www/src/alpine/public;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    # location ~* \.php {
    #     include fastcgi_params;

    #     #fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    #     fastcgi_pass 127.0.0.1:9000;

    #     fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    #     fastcgi_cache off;
    #     fastcgi_index index.php;
    #     fastcgi_buffers 8 256k;
    #     fastcgi_buffer_size 256k;
    #     fastcgi_read_timeout 600;
    # }

    location ~ \.php$ {
        fastcgi_pass      127.0.0.1:9000;
        fastcgi_index     index.php;
        include           fastcgi.conf;
    }

    # log files
    access_log  /var/log/nginx/default_access.log;
    error_log   /var/log/nginx/default_error.log;

    #if ($host != "http://down-up-srv.br24.int/") {
    #    return 404;
    #}
}
EOL

#ln -s sites-available/default.conf sites-enabled/default.conf

#service nginx added to runlevel default
rc-update add nginx default
#service php-fpm7 added to runlevel default
rc-update add php-fpm7 default


rc-service nginx restart
rc-service php-fpm7 restart

rc-update add netmount default



mkdir /var/www/src/
mkdir /var/www/src/alpine/
mkdir /var/www/src/alpine/storage/logs/crontab_joblogs


apk add git

apk add zip
apk add upzip

apk add cifs-utils
apk add tree
apk add rsync
apk add nodejs
apk add npm
apk add pv
# apk add lsof

#generate rsa deploy key 
ssh-keygen -o -t rsa -b 4096 -C "email@example.com"
#add public key to repo deploy keys
cd /var/www/src/
#clone the repository to named folder 
git clone git@gitlab.br24.vn:br24-vietnam/download-upload-server.git alpine


sudo chown -R alpine:alpine alpine/


cd /var/www/src/alpine
echo "prod" > .env
chmod a+x logging.sh
#sudo chmod -R 777 ./storage ./bootstrap/cache
# sudo chgrp -R www-data storage bootstrap/cache
# sudo chmod -R ug+rwx storage bootstrap/cache
cd /var/www/src/alpine/storage
sudo chgrp -R www-data logs
sudo chmod -R ug+rwx logs

#only for fresh install use these commands
cd /var/www/src/alpine
#make sure database folder is writable 
#make sure the database file is writeable
touch /var/www/src/alpine/database/database.sqlite
php artisan migrate:fresh --seed
composer dumpautoload
#only for fresh isntall use these commands

#add the rocketchat not-bot account with view-room-administration permission among the default bot permissions on the rocketchat server (not here).


# fix php.ini to allow for bigger file sizes to be uploaded 
sudo sed -i 's/post_max_size.*/post_max_size = 20G/' /etc/php7/php.ini
sudo sed -i 's/upload_max_filesize.*/upload_max_filesize = 20G/' /etc/php7/php.ini
sudo sed -i 's/memory_limit.*/memory_limit = 1G/' /etc/php7/php.ini
sudo reboot
