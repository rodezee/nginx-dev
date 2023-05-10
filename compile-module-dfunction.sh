#! /bin/sh

set -euxo pipefail

NGX_V=1.24.0
NGX_DM=nginx-dfunction-module
NGX_MN=ngx_http_dfunction_module
NGX_DR=dfunction

docker compose exec -it nginx sh -c "cd nginx-${NGX_V} && ./configure --with-compat --add-dynamic-module=../${NGX_DM}"

docker compose exec -it nginx sh -c "cd nginx-${NGX_V} && make modules"

docker compose exec -it nginx sh -c "cd nginx-${NGX_V} && cp ./objs/${NGX_MN}.so /etc/nginx/modules/"

cat << EOF > ./conf.d/${NGX_DM}.conf
server {
    listen 80 default_server;

    location / {
        ${NGX_DR};
    }
}
EOF

docker compose cp ./conf.d/${NGX_DR}.conf nginx:/etc/nginx/conf.d/

docker compose exec -it nginx nginx -s reload
