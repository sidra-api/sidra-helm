#!/bin/bash

# GitHub organization and personal access token
source .env
ORG="sidra-gateway"
TOKEN=$TOKEN
# Configure git to use the personal access token for authentication
git config --global credential.helper store
cp ~/.git-credentials ~/.git-credentials.bak || true
echo "https://$TOKEN:@github.com" > ~/.git-credentials

# Get list of repositories in the organization
repos=$(curl -s -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/orgs/$ORG/repos | jq -r '.[].ssh_url')

rm -Rf ./plugins || true
rm -Rf ./services || true
mkdir -p ./plugins || true
mkdir -p ./services || true

# Build the plugins
for repo in $repos; do
    repo_name=$(basename -s .git $repo)
    if [[ $repo_name == plugin-* ]]; then        
        echo "Cloning $repo_name"
        git clone "$repo" "./plugins/$repo_name"
        # Build plugin binary
        # cd "./plugins/$repo_name" || exit
        # go build -o main
        # cd - || exit
    fi    
done

# Clone sidra-config and sidra-plugins-hub
git clone git@github.com:sidra-gateway/sidra-config.git ./services/sidra-config
git clone git@github.com:sidra-gateway/sidra-plugins-hub.git ./services/sidra-plugins-hub

cp ~/.git-credentials.bak ~/.git-credentials || true