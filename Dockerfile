# Base image menggunakan golang untuk menjalankan custom script
FROM golang:1.23 AS builder

WORKDIR /app

# Instalasi tools dasar
RUN apk add --no-cache git bash docker-cli

# Copy konfigurasi nginx dari direktori lokal ke container
COPY ./config/nginx.conf /etc/nginx/nginx.conf

# # Buat direktori build
# RUN mkdir -p /app/build /app/bin

# # Salin seluruh proyek ke dalam container
# COPY . .

# # Build semua plugin
# RUN for dir in ./plugins/*; do \
#     if [ -d "$dir" ] && [ -f "$dir/Dockerfile" ]; then \
#         echo "Building $(basename $dir) using its Dockerfile..."; \
#         cd "$dir"; \
#         docker build -t $(basename $dir)-image .; \
#         docker create --name temp-container ghcr.io/your-username/$(basename $dir)-image:latest; \
#         docker cp temp-container:/app/build/$(basename $dir) /app/build/$(basename $dir); \
#         docker rm temp-container; \
#         cd /app; \
#     fi; \
# done

# # Debug: List hasil build plugin
# RUN echo "Checking contents of /app/build:" && ls -l /app/build

# # Build aplikasi sidra-config dan sidra-plugins-hub
# RUN cd ./services/sidra-config && go mod tidy && go build -o /app/bin/sidra-config
# RUN cd ./services/sidra-plugins-hub && go mod tidy && go build -o /app/bin/sidra-plugins-hub

# # Stage 2: Menjalankan container dengan nginx dan plugin
# FROM nginx:latest

# WORKDIR /app

# RUN mkdir -p /app/plugins

# # Salin hasil build plugin ke direktori plugin
# COPY --from=builder /app/build/ /app/plugins/

# # Salin hasil build dan konfigurasi ke dalam container
# COPY --from=builder /app/bin/sidra-config /app/sidra-config
# COPY --from=builder /app/bin/sidra-plugins-hub /app/sidra-plugins-hub

# RUN echo "Contents of /app/plugins:" && ls -l /app/plugins

# Install Redis untuk mendukung plugin cache
RUN apt-get update && apt-get install -y redis

# Menyediakan akses ke port 8080
EXPOSE 8080 3033 3080

# Gunakan image minimal untuk hasil akhir
FROM alpine:latest

# Salin skrip run.sh
COPY ./run.sh /app/run.sh
RUN chmod +x /app/run.sh

# # Clone script untuk menarik semua repositori (opsional jika tidak digunakan)
# COPY ./clone.sh /app/clone.sh
# RUN chmod +x /app/clone.sh

# Set default command untuk menjalankan aplikasi
CMD ["bash", "/app/run.sh"]
