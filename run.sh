trap 'kill 0' SIGTERM

redis-server &
./bin/sidra-data-plane &
./bin/sidra-plugins-hub &
wait