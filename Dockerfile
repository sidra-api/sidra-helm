# Stage 1: Build semua plugin dan konfigurasi
FROM golang:1.23-alpine

WORKDIR /app

# Salin file go.mod dan go.sum ke dalam direktori root
# COPY go.mod go.sum ./

# Salin seluruh proyek ke dalam container
COPY . .

# # Build semua plugin
# RUN for dir in ./plugins/*; do \
#     if [ -d "$dir" ]; then \
#         echo "Building $(basename $dir)..."; \
#         cd $dir && go mod tidy && go build -o /app/bin/plugins/$(basename $dir); \
#         cd -; \
#     fi; \
# done

# # Pastikan direktori yang sesuai memiliki go.mod
# RUN cd ./services/sidra-data-plane && go mod tidy && go build -o /app/bin/sidra-data-plane
# RUN cd ./services/sidra-plugins-hub && go mod tidy && go build -o /app/bin/sidra-plugins-hub

# RUN rm -rf ./plugins
# RUN rm -rf ./services

RUN apk add --no-cache redis

# Stage 2: Menjalankan container dengan nginx dan plugin

# Menyediakan akses ke port 8080
EXPOSE 8080 3033 3080

# Salin skrip run.sh
COPY run.sh /app/run.sh

# Set default command untuk menjalankan aplikasi
CMD ["sh", "/app/run.sh"]