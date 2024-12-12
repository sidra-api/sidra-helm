#!/bin/bash
rm -rf ./services/*
rm -rf ./plugins/*
# Array of repository URLs
repos=(
    "https://github.com/sidra-api/plugin-basic-auth.git"
    "https://github.com/sidra-api/plugin-jwt.git"
    "https://github.com/sidra-api/plugin-rate-limit.git"
    "https://github.com/sidra-api/plugin-whitelist.git"
    "https://github.com/sidra-api/plugin-cache.git"
    "https://github.com/sidra-api/plugin-rsa.git"
)

# Clone sidra-config and sidra-plugins-hub
git clone https://github.com/sidra-api/sidra-data-plane.git ./services/sidra-data-plane
git clone https://github.com/sidra-api/sidra-plugins-hub.git ./services/sidra-plugins-hub

# Clone additional repositories
# Clone additional repositories
for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    git clone "$repo" "./plugins/$repo_name"
done