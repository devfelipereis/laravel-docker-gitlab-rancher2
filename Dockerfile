FROM nginx:1.14.2-alpine

LABEL maintainer "Felipe Reis - https://github.com/devfelipereis"

ARG UID=1000
ARG GID=1000

ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN echo "@php https://dl.bintray.com/php-alpine/v3.9/php-7.3" >> /etc/apk/repositories
RUN apk add --no-cache --update \
    ca-certificates \
    php@php \
    php-common@php \
    php-ctype@php \
    php-curl@php \
    php-fpm@php \
    php-gd@php \
    php-intl@php \
    php-json@php \
    php-mbstring@php \
    php-openssl@php \
    php-pdo@php \
    php-pdo_mysql@php \
    php-mysqlnd@php \
    php-xml@php \
    php-zip@php \
    php-memcached@php \
    php-phar@php \
    php-pcntl@php \
    php-dom@php \
    php-posix@php \
    bash git grep dcron tzdata su-exec shadow \
    supervisor

# Sync user and group with the host
RUN usermod -u ${UID} nginx && groupmod -g ${GID} nginx

# Configure time
RUN echo "America/Sao_Paulo" > /etc/timezone && \
    cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    apk del --no-cache tzdata && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

# CRON SETUP
COPY docker/cron/crontab /var/spool/cron/crontabs/root
RUN chmod -R 0644 /var/spool/cron/crontabs

RUN mkdir -p /var/www/html && \
    mkdir -p /var/cache/nginx && \
    mkdir -p /var/lib/nginx && \
    mkdir -p /etc/nginx/ssl && \
    chown -R nginx:nginx /var/cache/nginx /var/lib/nginx && \
    chmod -R g+rw /var/cache/nginx /var/lib/nginx /etc/php7/php-fpm.d && \
    ln -s /usr/bin/php7 /usr/bin/php && \
    openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

COPY _SSL/dev.crt /etc/nginx/ssl/dev.crt
COPY _SSL/dev.key /etc/nginx/ssl/dev.key
COPY docker/conf/php-fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY docker/conf/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/conf/nginx.conf /etc/nginx/nginx.conf
COPY docker/conf/nginx-site.conf /etc/nginx/conf.d/default.conf
# COPY docker/conf/php.ini /etc/php7/conf.d/50-settings.ini
COPY docker/entrypoint.sh /sbin/entrypoint.sh

WORKDIR /var/www/html/

COPY --chown=nginx:nginx ./ .

COPY --from=composer:1.8.3 /usr/bin/composer /usr/bin/composer

VOLUME /var/www/html/storage

EXPOSE 8000 443

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["true"]
