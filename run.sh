trap 'kill 0' SIGTERM

redis-server &
./bin/sidra-config &
for plugin in ./plugins/*; do
    if [ -x "$plugin" ]; then
        "bin/plugins/$plugin" >> /tmp/plugin.log &
    fi
done
./bin/sidra-plugins-hub &
wait