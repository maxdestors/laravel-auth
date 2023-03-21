#!/bin/sh

echo "alias pa='php artisan'
alias pam='php artisan migrate'
alias pamr='php artisan migrate:rollback'
alias pamm='php artisan make:migration'" >> ~/.bashrc

composer install
php artisan migrate --force
php artisan db:seed --force
php artisan optimize:clear
npm install

exec "$@"
