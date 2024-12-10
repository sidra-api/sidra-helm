./sidra-config &
./sidra-plugins-hub &
for plugin in ./plugins/*; do
    if [ -x "$plugin" ]; then
        "$plugin" >> /tmp/plugin.log &
    fi
done
redis-server &
nginx -g 'daemon off;'