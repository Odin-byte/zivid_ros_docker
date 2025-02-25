#!/bin/bash

# Set default image name if not provided
IMAGE_NAME=${1:-zivid2_plus_m130_ros_1}

# Build the Docker image
docker build -t $IMAGE_NAME .

# Notify the user
echo "Docker image '$IMAGE_NAME' built successfully."
