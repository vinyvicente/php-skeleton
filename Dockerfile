FROM php:7.4-cli-alpine AS base

ENV COMPOSER_ALLOW_SUPERUSER="1"
ENV PATH="/var/www/app/bin:/var/www/app/vendor/bin:${PATH}"

WORKDIR /var/www/app

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

FROM base AS dev

RUN apk add --no-cache --update $PHPIZE_DEPS
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

COPY ./.docker/deps/php.ini /usr/local/etc/php/php.ini

ARG XDEBUG_REMOTE_HOST="localhost"

RUN sed -i "s|xdebug.remote_host = localhost|xdebug.remote_host = $XDEBUG_REMOTE_HOST|g" /usr/local/etc/php/php.ini

FROM base AS ci

COPY ./composer.* /var/www/app/

RUN composer install \
    --optimize-autoloader \
    --no-ansi \
    --no-interaction \
    --no-progress \
    --no-suggest

COPY ./src /var/www/app/src
COPY ./public /var/www/app/public
COPY ./tests /var/www/app/tests
COPY ./phpunit.xml.dist /var/www/app/phpunit.xml
COPY ./.php_cs /var/www/app/.php_cs
COPY ./phpstan.neon.dist /var/www/app/phpstan.neon

RUN composer test
