# # Stage 1: Build semua plugin dan konfigurasi
# FROM golang:1.23-alpine AS builder

# WORKDIR /app

# # Instalasi tools dasar
# RUN apk add --no-cache git bash docker-cli

# # Buat direktori build
# RUN mkdir -p /app/build app/bin

# # Salin seluruh proyek ke dalam container
# COPY . .

# # Build semua plugin
# RUN for dir in ./plugins/*; do \
#     if [ -d "$dir" ] && [ -f "$dir/Dockerfile" ]; then \
#         echo "Building $(basename $dir) using its Dockerfile..."; \
#         cd "$dir"; \
#         docker build -t $(basename $dir)-image .; \
#         docker create --name temp-container $(basename $dir)-image; \
#         docker cp temp-container:/app/build/$(basename $dir) /app/build/$(basename $dir); \
#         docker rm temp-container; \
#         cd /app; \
#     fi; \
# done

# # Debug: List hasil build plugin
# RUN echo "Checking contents of /app/build:" && ls -l /app/build

# #Build aplikasi sidra-config dan sidra-plugins-hub
# RUN cd ./services/sidra-config && go mod tidy && go build -o /app/bin/sidra-config
# RUN cd ./services/sidra-plugins-hub && go mod tidy && go build -o /app/bin/sidra-plugins-hub

# Stage 2: Menjalankan container dengan nginx dan plugin
FROM nginx:latest

WORKDIR /app

RUN mkdir -p /app/plugins

# # Salin hasil build plugin ke direktori plugin
# COPY --from=builder /app/build/ /app/plugins/

# Salin hasil build dan konfigurasi ke dalam container
# COPY --from=builder /app/build/plugin-basic-auth /app/plugins/plugin-basic-auth
# COPY --from=builder /app/build/plugin-jwt /app/plugins/plugin-jwt
# COPY --from=builder /app/build/plugin-whitelist /app/plugins/plugin-whitelist
# COPY --from=builder /app/build/plugin-cache /app/plugins/plugin-cache
# COPY --from=builder /app/build/plugin-rate-limit /app/plugins/plugin-rate-limit

# COPY --from=builder /app/bin/sidra-config /app/sidra-config
# COPY --from=builder /app/bin/sidra-plugins-hub /app/sidra-plugins-hub

# Salin plugin yang sudah ada file binary-nya ke direktori /app/plugins
COPY ./plugins/plugin-basic-auth/plugin-basic-auth /app/plugins/
COPY ./plugins/plugin-cache/plugin-cache /app/plugins/
COPY ./plugins/plugin-jwt/plugin-jwt /app/plugins/
COPY ./plugins/plugin-rate-limit/plugin-rate-limit /app/plugins/
COPY ./plugins/plugin-rsa/plugin-rsa /app/plugins/
COPY ./plugins/plugin-whitelist/plugin-whitelist /app/plugins/

# Salin hasil build aplikasi sidra-config dan sidra-plugins-hub yang sudah jadi
COPY ./services/sidra-config/sidra-config /app/
COPY ./services/sidra-plugins-hub/sidra-plugins-hub /app/

RUN echo "Contents of /app/plugins:" && ls -l /app/plugins

# Install Redis untuk mendukung plugin cache
RUN apt-get update && apt-get install -y redis

# Menyediakan akses ke port 8080
EXPOSE 8080 3033 3080

# Salin skrip run.sh
COPY run.sh /app/run.sh

RUN chmod +x /app/run.sh

# Set default command untuk menjalankan aplikasi
CMD ["bash", "/app/run.sh"]