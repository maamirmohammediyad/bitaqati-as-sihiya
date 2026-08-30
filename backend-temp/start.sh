#!/bin/sh

set -e

echo "========================================"
echo "Starting DZ-HEALTH TECH Backend"
echo "========================================"

echo "Running database migrations..."
php artisan migrate --force

echo "Creating/updating Super Admin..."
php artisan db:seed --force

echo "Clearing old configuration cache..."
php artisan config:clear

echo "Caching configuration..."
php artisan config:cache

echo "Caching routes..."
php artisan route:cache

echo "Starting Laravel server..."
php artisan serve --host=0.0.0.0 --port="${PORT}"