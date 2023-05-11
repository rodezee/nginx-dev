#! /bin/sh

set -euxo pipefail

NGX_V=1.24.0
NGX_DM=nginx-dfunction-module
NGX_MN=ngx_http_dfunction_module
NGX_DR=dfunction

# create the nginx.conf including the load of the .so file (see docker-compose.yml for mount in nignx container)
cat << EOF > ./nginx.conf
load_module modules/ngx_http_${NGX_DR}_module.so;
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
EOF

# create a new default.conf for nginx (see docker-compose.yml for mount in nignx container)
cat << EOF > ./conf.d/default.conf
server {
    listen 80 default_server;
    # listen 443 ssl;

    # ssl_certificate /etc/nginx/certs/default.crt;
    # ssl_certificate_key /etc/nginx/certs/default.key;

    location / {
        ${NGX_DR};
    }
}
EOF

# start the nginx container (see docker-compose.yml for more info.)
docker compose up -d

# copy code of module to the container
docker compose cp ./${NGX_DM} nginx:/root/${NGX_DM}

# configure the module
docker compose exec -it nginx ./configure --with-compat --add-dynamic-module=../${NGX_DM}

# build the module
docker compose exec -it nginx make modules

# copy the compiled module to the current local folder
docker compose cp nginx:/root/nginx-${NGX_V}/objs/${NGX_MN}.so ./

# restart the container (see docker-compose.yml for the mount of the current folder .so file)
docker compose stop && docker compose rm -f && docker compose up -d && docker compose logs -f nginx


# # reload nginx within the container and follow it's logs
# docker compose exec -it nginx nginx -s reload && docker compose logs -f nginx
