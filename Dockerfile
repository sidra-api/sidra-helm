# Base image menggunakan golang untuk menjalankan custom script
FROM golang:1.23 AS builder

WORKDIR /app

# Instalasi tools dasar
RUN apk add --no-cache git bash docker-cli

FROM nginx:latest

# Copy konfigurasi nginx dari direktori lokal ke container
COPY ./config/nginx.conf /etc/nginx/nginx.conf

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
