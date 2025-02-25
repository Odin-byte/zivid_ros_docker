#!/bin/bash

# Get the current user's UID and GID
USER_UID=$(id -u)
USER_GID=$(id -g)

# Set default image name if not provided
IMAGE_NAME=${1:-zivid2_plus_m130_ros_1}

# Build the Docker image
docker build --build-arg USER_UID=$USER_UID --build-arg USER_GID=$USER_GID\
 -t $IMAGE_NAME .

# Notify the user
echo "Docker image '$IMAGE_NAME' built successfully."
