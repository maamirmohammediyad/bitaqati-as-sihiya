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
    $PHPIZE_DEPS

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

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Composer files from backend-temp
COPY backend-temp/composer.json backend-temp/composer.lock ./

# Install Laravel dependencies
# --no-scripts مهم حتى لا يتم تشغيل Laravel أثناء build
RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --optimize-autoloader \
    --no-scripts

# Copy the Laravel application
COPY backend-temp/ .

# Laravel writable directories
RUN mkdir -p \
    bootstrap/cache \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    && chmod -R 775 storage bootstrap/cache

# Render provides PORT automatically
ENV PORT=10000

# Start Laravel
CMD sh -c "php artisan config:cache && php artisan route:cache && php artisan serve --host=0.0.0.0 --port=${PORT}"