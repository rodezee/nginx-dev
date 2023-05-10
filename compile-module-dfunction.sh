#! /bin/sh

set -euxo pipefail

NGX_V=1.24.0
NGX_DM=nginx-dfunction-module
NGX_MN=ngx_http_dfunction_module
NGX_DR=dfunction

docker compose cp ./${NGX_DM}/${NGX_MN}.c nginx:/root/${NGX_DM}/

docker compose exec -it nginx ./configure --with-compat --add-dynamic-module=../${NGX_DM}

docker compose exec -it nginx make modules

docker compose exec -it nginx cp ./objs/${NGX_MN}.so /etc/nginx/modules/

docker compose cp nginx:/root/objs/${NGX_MN}.so ./

docker compose stop && docker compose rm -f && docker compose up -d && docker compose logs -f nginx

# cat << EOF > ./conf.d/${NGX_DM}.conf
# server {
#     listen 80 default_server;

#     location / {
#         ${NGX_DR};
#     }
# }
# EOF

# docker compose cp ./conf.d/${NGX_DR}.conf nginx:/etc/nginx/conf.d/

# docker compose exec -it nginx sed -i "1s#^#load_module modules/${NGX_MN}.so;#" /etc/nginx/nginx.conf

# docker compose exec -it nginx nginx -s reload
