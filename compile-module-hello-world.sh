#! /bin/sh

set -euxo pipefail

NGX_V=1.24.0
NGX_DM=nginx-hello-world-module
NGX_MN=ngx_http_hello_world_module
NGX_DR=hello_world

apk add --no-cache --virtual build-base pcre-dev zlib-dev util-linux-dev gd-dev libxml2-dev openssl-dev

[ -d "nginx-${NGX_V}" ] || wget https://nginx.org/download/nginx-${NGX_V}.tar.gz && \
    tar -zxvf nginx-${NGX_V}.tar.gz && \
    rm nginx-${NGX_V}.tar.gz

cd nginx-${NGX_V}

./configure --with-compat --add-dynamic-module=../${NGX_DM}

make modules 

cp ./objs/${NGX_MN}.so /modules/

cat << EOF > ./conf.d/${NGX_DM}.conf
server {
    listen 80 default_server;

    location / {
        ${NGX_DR};
    }
}
EOF

source ./test-nginx-dev.sh