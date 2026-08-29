FROM php:8.3-cli-alpine

WORKDIR /var/www/html

# System dependencies
RUN apk add --no-cache \
    git \
    unzip \
    zip \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    postgresql-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    autoconf \
    dpkg-dev \
    dpkg \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkgconf \
    re2c

# Configure GD
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

# PHP extensions
RUN docker-php-ext-install \
    bcmath \
    exif \
    gd \
    intl \
    mbstring \
    pdo_pgsql \
    zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Composer files
COPY composer.json composer.lock ./

# Install production dependencies
RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --optimize-autoloader \
    --no-scripts

# Copy Laravel application
COPY . .

# Laravel directories
RUN mkdir -p \
    bootstrap/cache \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    && chmod -R 775 storage bootstrap/cache

# Copy startup script
COPY start.sh /usr/local/bin/start.sh

# Make startup script executable
RUN chmod +x /usr/local/bin/start.sh

# Start application
CMD ["/usr/local/bin/start.sh"]