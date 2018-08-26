FROM debian:stretch-slim

## Install s6

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

COPY services.d/ /etc/services.d/

## END

## Install nginx

RUN apt-get update && apt-get install -y nginx && \
        rm -rf /var/lib/apt/lists/*

ADD nginx.conf /etc/nginx/
ADD application.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/application.conf /etc/nginx/sites-enabled/application
RUN rm /etc/nginx/sites-enabled/default

RUN usermod -u 1000 www-data

## END

RUN apt-get update \
    && apt-get install -y apt-transport-https lsb-release ca-certificates wget curl \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --force-yes php7.2 php7.2-soap php7.2-fpm  \
        php7.2-mysql php7.2-apcu php7.2-gd php7.2-imagick php7.2-curl php7.2-common \
        php7.2-intl php7.2-memcached php7.2-dom php7.2-bcmath php7.2-zip \
        php7.2-mbstring php7.2-ldap php7.2-gmp php7.2-xdebug gnupg && \
        rm -rf /var/lib/apt/lists/* && \
        mkdir -p /run/php/ && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
RUN apt-get update && apt-get install -y openssl git && apt-get purge -y --auto-remove
RUN composer global require hirak/prestissimo; composer config --global sort-packages true

ENV PHP_VERSION '7.2'

RUN \
  sed -i "s/^memory_limit = .*/memory_limit = \"\${PHP_CLI_MEMORY_LIMIT}\"/g" "/etc/php/$PHP_VERSION/cli/php.ini"; \
  \
  sed -i "s/^;?access\.log = .*/access.log = \/proc\/self\/fd\/2/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^;?error\.log = .*/error.log = \/proc\/self\/fd\/2/g" "/etc/php/$PHP_VERSION/fpm/php-fpm.conf"; \
  \
  sed -i "s/^user = .*/user = \"\${PHP_FPM_USER}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^group = .*/group = \"\${PHP_FPM_GROUP}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^listen = .*/listen = \"\${PHP_FPM_LISTEN}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^pm\.max_children = .*/pm.max_children = \"\${PHP_FPM_PM_MAX_CHILDREN}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^pm\.start_servers = .*/pm.start_servers = \"\${PHP_FPM_PM_START_SERVERS}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^pm\.min_spare_servers = .*/pm.min_spare_servers = \"\${PHP_FPM_PM_MIN_SPARE_SERVERS}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^pm\.max_spare_servers = .*/pm.max_spare_servers = \"\${PHP_FPM_PM_MAX_SPARE_SERVERS}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^;\?request_terminate_timeout = .*/request_terminate_timeout = \"\${PHP_FPM_REQUEST_TERMINATE_TIMEOUT}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^;env\[TEMP\] = .*/env[APP_ENV] = \$PHP_APP_ENV/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf";

ENV APP_ENV 'dev'

ENV PHP_CLI_MEMORY_LIMIT '128M'

ENV PHP_FPM_MEMORY_LIMIT '128M'
ENV PHP_FPM_USER 'www-data'
ENV PHP_FPM_GROUP 'www-data'
ENV PHP_FPM_LISTEN '0.0.0.0:9000'
ENV PHP_FPM_PM_MAX_CHILDREN '5'
ENV PHP_FPM_PM_START_SERVERS '2'
ENV PHP_FPM_PM_MIN_SPARE_SERVERS '1'
ENV PHP_FPM_PM_MAX_SPARE_SERVERS '3'
ENV PHP_FPM_REQUEST_TERMINATE_TIMEOUT '0'
ENV PHP_APP_ENV 'dev'

WORKDIR /data/application

ENTRYPOINT ["/init"]

CMD ["php-fpm7.2", "-F"]

EXPOSE 80
EXPOSE 443