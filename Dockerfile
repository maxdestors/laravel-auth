FROM php:8.2.3-apache as base

# Arguments defined in docker-compose.yml
ARG user
ARG uid

WORKDIR /app

# Install PHP dependencies
RUN apt-get update && apt-get install -y \
        libpng-dev \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
        zip \
        unzip \
        locales \
    && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
    && docker-php-source delete \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install opcache \
    && docker-php-ext-install bcmath

# Env
ENV LC_ALL fr_FR.UTF-8 
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:en

# Copy project, vhost.conf, config php and install composer
COPY . .
COPY docker/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY docker/custom.ini $PHP_INI_DIR/conf.d/custom.ini
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

# Add permissions
RUN mkdir -p /app/vendor \
    mkdir -p /app/storage/logs \
    && useradd -G www-data,root -u $uid -d /home/$user $user \
    && mkdir -p /home/$user/.composer \
    && chown -R $user:$user /home/$user \
    && chown -R $user:$user /app \
    && a2enmod rewrite \
    && chmod +x docker/startup-dev.sh \
    && chmod +x docker/startup-prod.sh

EXPOSE 8080

FROM base as development
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get update && apt-get install -y \
        nano \
        nodejs
ENTRYPOINT ["docker/startup-dev.sh"]
CMD ["apache2-foreground"]
USER $user

FROM base as production
COPY docker/opcache.ini $PHP_INI_DIR/conf.d/opcache.ini
RUN composer clearcache && composer install --optimize-autoloader --no-dev
ENTRYPOINT ["docker/startup-prod.sh"]
CMD ["apache2-foreground"]
USER $user
