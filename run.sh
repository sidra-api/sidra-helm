#!/bin/bash

# Jalankan Redis
redis-server --daemonize yes

# Jalankan sidra-config
/app/sidra-config &

# Jalankan sidra-plugins-hub
/app/sidra-plugins-hub &

# Jalankan semua binary plugin di direktori /app/plugins
for plugin_binary in /app/plugins/*; do
    if [ -x "$plugin_binary" ]; then
        "$plugin_binary" >> "/tmp/$(basename "$plugin_binary").log" 2>&1 &
    fi
done

# Jalankan nginx
nginx -g "daemon off;"
