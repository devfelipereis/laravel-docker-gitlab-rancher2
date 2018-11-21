FROM sickp/alpine-nginx:1.14.0

LABEL maintainer "Felipe Reis - https://github.com/devfelipereis"

ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN echo "@php https://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories
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
    php-xml@php \
    php-zip@php \
    php-pdo_mysql@php \
    php-memcached@php \
    php-phar@php \
    php-pcntl@php \
    php-dom@php \
    php-posix@php \
    bash git grep dcron tzdata su-exec \
    supervisor

# Configure time
RUN echo "America/Sao_Paulo" > /etc/timezone && \
    cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    apk del tzdata && \
    rm /var/cache/apk/*

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
COPY docker/entrypoint.sh /sbin/entrypoint.sh

WORKDIR /var/www/html/

COPY --chown=nginx:nginx ./ .

COPY --from=composer:1.7.2 /usr/bin/composer /usr/bin/composer

RUN chmod -R ug+rwx storage bootstrap/cache

VOLUME /var/www/html/storage

EXPOSE 8000 443

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["true"]
