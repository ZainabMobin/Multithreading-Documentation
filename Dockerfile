FROM node:22-bookworm-slim

# Install sudo, git and ca-certificates in custom image (since Github Actions have them by default)
# --no-install-recommends and cleaning up # /var/lib/apt/lists/* keep custom image small
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    ca-certificates \
    python3 \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Configure passwordless sudo for the default node user
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set the default user back to node
USER node

# success message
RUN echo " 🟩 Custom Docker image for Node.js 22 with sudo, git, ca-certificates and python created successfully 👊👊"