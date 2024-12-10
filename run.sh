#!/bin/bash

# Jalankan Redis
redis-server --daemonize yes

# # Jalankan sidra-config
# /app/sidra-config &

# # Jalankan sidra-plugins-hub
# /app/sidra-plugins-hub &

# # Jalankan semua binary plugin di direktori /app/plugins
# for plugin_binary in /app/plugins/*; do
#     if [ -x "$plugin_binary" ]; then
#         "$plugin_binary" >> "/tmp/$(basename "$plugin_binary").log" 2>&1 &
#     fi
# done

# Jalankan sidra-config dari image GHCR
docker run --rm -d --name sidra-config ghcr.io/sidra-gateway/sidra-config:latest

# Jalankan sidra-plugins-hub dari image GHCR
docker run --rm -d --name sidra-plugins-hub ghcr.io/sidra-gateway/sidra-plugins-hub:latest

# Jalankan semua plugin dari image GHCR
plugins=("plugin-whitelist" "plugin-rsa" "plugin-rate-limit" "plugin-jwt" "plugin-cache" "plugin-basic-auth")

for plugin in "${plugins[@]}"; do
    docker run --rm -d --name "$plugin-" ghcr.io/sidra-gateway/"$plugin-":latest
done


# Jalankan nginx
nginx -g "daemon off;"
