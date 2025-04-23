#!/bin/bash

# Get the current user's UID and GID
USER_UID=$(id -u)
USER_GID=$(id -g)

# Set default image name if not provided
IMAGE_NAME=${1:-zivid_driver:humble}

# Build the Docker image
docker build --build-arg USER_UID=$USER_UID --build-arg USER_GID=$USER_GID\
 -t $IMAGE_NAME .

# Notify the user
echo "Docker image '$IMAGE_NAME' built successfully."
