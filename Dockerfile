# Stage 1: Build semua plugin dan konfigurasi
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Salin file go.mod dan go.sum ke dalam direktori root
# COPY go.mod go.sum ./

# Salin seluruh proyek ke dalam container
COPY . .

# Build semua plugin
RUN for dir in ./plugins/*; do \
    if [ -d "$dir" ]; then \
        echo "Building $(basename $dir)..."; \
        cd $dir && go mod tidy && go build -o /app/build/$(basename $dir); \
        cd -; \
    fi; \
done

# Pastikan direktori yang sesuai memiliki go.mod
RUN cd ./services/sidra-config && go mod tidy && go build -o /app/bin/sidra-config
RUN cd ./services/sidra-plugins-hub && go mod tidy && go build -o /app/bin/sidra-plugins-hub

# Stage 2: Menjalankan container dengan nginx dan plugin
FROM nginx:latest

WORKDIR /app

# Salin hasil build dan konfigurasi ke dalam container
COPY --from=builder /app/build/plugin-basic-auth /app/plugins/plugin-basic-auth
COPY --from=builder /app/build/plugin-jwt /app/plugins/plugin-jwt
COPY --from=builder /app/build/plugin-whitelist /app/plugins/plugin-whitelist
COPY --from=builder /app/build/plugin-cache /app/plugins/plugin-cache
COPY --from=builder /app/build/plugin-rate-limit /app/plugins/plugin-rate-limit
COPY --from=builder /app/bin/sidra-config /app/sidra-config
COPY --from=builder /app/bin/sidra-plugins-hub /app/sidra-plugins-hub

# Install Redis
# RUN apk add --no-cache redis
RUN apt-get update && apt-get install -y redis

# Menyediakan akses ke port 8080
EXPOSE 8080 3033 3080

# Salin skrip run.sh
COPY run.sh /app/run.sh

# Set default command untuk menjalankan aplikasi
CMD ["bash", "/app/run.sh"]