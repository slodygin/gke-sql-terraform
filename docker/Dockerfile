# ==============================================

#ARG PHP_BASE_IMAGE_VERSION
FROM php:7.4-fpm

# Install system packages for PHP extensions
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get -y install \
        gnupg2 && \
    apt-key update && \
    apt-get update && \
    apt-get -y install \
            sed \
            g++ \
            git \
            lsof \
            default-mysql-client \
            curl \
            ssh \
            clickhouse-client \
            wget \
            imagemagick \
            libcurl3-dev \
            libicu-dev \
            librabbitmq-dev \
            libgeoip-dev geoip-bin geoip-database \
            libfreetype6-dev \
            libwebp-dev \
            libjpeg-dev \
            libjpeg62-turbo-dev \
            libonig-dev \
            libmagickwand-dev \
            libpq-dev \
            p7zip-full \
            libpng-dev libxpm-dev \
            libmcrypt-dev \
            libxml2-dev \
            libc-client-dev \
            libkrb5-dev \
            lame \
            procps \
            systemd \
            libzip-dev \
            zlib1g-dev \
            unzip \
            gzip \
            bzip2 \
            apt-utils \
            libcurl4-openssl-dev \
            libssl-dev \
            supervisor \
            cron \
            openssh-server \
            nginx \
        --no-install-recommends && \
        pecl install redis && docker-php-ext-enable redis && \
        pecl install channel://pecl.php.net/amqp-1.10.2 && docker-php-ext-enable amqp && \
        pecl install geoip-1.1.1 && docker-php-ext-enable geoip && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
        sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf

# Install PHP extensions
ARG X_LEGACY_GD_LIB=0
RUN if [ $X_LEGACY_GD_LIB = 1 ]; then \
        docker-php-ext-configure gd \
                --with-freetype-dir=/usr/include/ \
                --with-png-dir=/usr/include/ \
                --with-jpeg-dir=/usr/include/; \
    else \
        docker-php-ext-configure gd \
                --with-freetype=/usr/include/ \
                --with-jpeg=/usr/include/; \
    fi && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-install \
        soap \
        zip \
        curl \
        bcmath \
        exif \
        gd \
        iconv \
        intl \
        mbstring \
        opcache \
        pdo_mysql \
        mysqli \
        pdo_pgsql

# Environment settings
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    PHP_USER_ID=1000 \
    PHP_ENABLE_XDEBUG=0 \
    PATH=/app/rtb/bidder:/root/.composer/vendor/bin:$PATH \
    TERM=linux \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.7 \
    VERSION_XDEBUG=2.8.1


COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY docker/base.ini /usr/local/etc/php/conf.d/base.ini
COPY docker/php.ini /usr/local/etc/php/php.ini
COPY docker/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY docker/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY docker/composer /usr/local/bin/composer

# Add GITHUB_API_TOKEN support for composer
RUN chmod 700 \
        /usr/local/bin/docker-php-entrypoint /usr/local/bin/composer

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer.phar \
        --install-dir=/usr/local/bin \
        --version=1.10.16 && \
    composer clear-cache

# Install composer plugins
RUN composer global require --optimize-autoloader \
        "hirak/prestissimo:${VERSION_PRESTISSIMO_PLUGIN}" && \
    composer global dumpautoload --optimize && \
    composer clear-cache

COPY ./www/ /var/www/
# Application environment
WORKDIR /var/www

# Install Yii framework bash autocompletion
RUN curl -L https://raw.githubusercontent.com/yiisoft/yii2/master/contrib/completion/bash/yii \
        -o /etc/bash_completion.d/yii

ARG SSH_PORT
RUN sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/.*sftp.*/Subsystem sftp internal-sftp/g' /etc/ssh/sshd_config
RUN sed -i "s/.*Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
RUN mkdir /root/.ssh
COPY docker/authorized_keys /root/.ssh/
RUN chmod 700 /root/.ssh;chmod 600 /root/.ssh/authorized_keys

RUN mkdir /var/run/sshd

#remove default file /etc/nginx/sites-available/default 
RUN sed -i 's/^.*sites-enabled.*$//g' /etc/nginx/nginx.conf

CMD ["/usr/bin/supervisord", "-n"]
