#!/bin/bash

if [[ $APP_ENV == "production" ]]; then
    php artisan optimize;
fi

exec "$@"
