#!/bin/sh

NGX_VERSION=1.24.0
NGX_DYNAMIC_MODULE=nginx-hello-world-module

set -x

apk add --no-cache build-base pcre-dev zlib-dev libssl-dev libgd-dev libxml2-dev uuid-dev

cd ./nginx-$NGX_VERSION

./configure --with-compat --add-dynamic-module=../$NGX_DYNAMIC_MODULE --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module

make

make install

