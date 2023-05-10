#! /bin/sh

set -x

NGX_DM=nginx-hello-world-module
NGX_MN=ngx_http_hello_world_module
NGX_DR=hello_world

./configure --with-compat --add-dynamic-module=../${NGX_DM}

make modules && cp ./objs/${NGX_MN}.so /etc/nginx/modules/

cat << EOF > ${NGX_DM}.conf
server {
    listen 80 default_server;

    location / {
        ${NGX_DR};
    }
}
EOF

source test-nginx-dev.sh