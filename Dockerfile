# Stage 1: Build semua plugin
FROM golang:1.23 AS builder
WORKDIR /app

# Copy dan build semua plugin secara terpisah
COPY ./plugins /app/plugins

# Build setiap plugin dan letakkan di /tmp
RUN cd /app/plugins/plugin-jwt && go mod tidy && go build -o /tmp/plugin-jwt && \
    cd /app/plugins/plugin-basic-auth && go mod tidy && go build -o /tmp/plugin-basic-auth && \
    cd /app/plugins/plugin-cache && go mod tidy && go build -o /tmp/plugin-cache && \
    cd /app/plugins/plugin-whitelist && go mod tidy && go build -o /tmp/plugin-whitelist && \
    cd /app/plugins/plugin-ratelimit && go mod tidy && go build -o /tmp/plugin-ratelimit

# Stage 2: Final image
FROM nginx:latest

# Copy semua plugin ke container
COPY --from=builder /tmp/plugin-jwt /usr/local/bin/plugin-jwt
COPY --from=builder /tmp/plugin-basic-auth /usr/local/bin/plugin-basic-auth
COPY --from=builder /tmp/plugin-cache /usr/local/bin/plugin-cache
COPY --from=builder /tmp/plugin-whitelist /usr/local/bin/plugin-whitelist
COPY --from=builder /tmp/plugin-ratelimit /usr/local/bin/plugin-ratelimit

# Copy services (sidra-config dan sidra-plugins-hub)
COPY ./sidra-config /usr/local/bin/sidra-config
COPY ./sidra-plugins-hub /usr/local/bin/sidra-plugins-hub

# Set permissions
RUN chmod +x /usr/local/bin/plugin-* \
              /usr/local/bin/sidra-config \
              /usr/local/bin/sidra-plugins-hub

# Expose necessary ports
EXPOSE 8080

# Set default command
CMD ["nginx", "-g", "daemon off;"]
