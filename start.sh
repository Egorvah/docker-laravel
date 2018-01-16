#!/bin/bash

# Add environment domain to nginx config
eval "sed -- \"s/{domain}/$DOMAIN/g\" /opt/laravel.conf > /etc/nginx/sites-enabled/laravel.conf && service nginx start"