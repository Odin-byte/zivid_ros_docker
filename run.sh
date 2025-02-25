#!/bin/bash

# Set default values if not provided
IMAGE_NAME=${1:-zivid2_plus_m130_ros_1}
CONTAINER_NAME=${2:-zivid_driver}
USER_HOME=${3:-/home/ros}

# Enable X11 for GUI applications
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

# Create Xauthority file if it doesn't exist
if [ ! -f $XAUTH ]; then
    touch $XAUTH
    xauth_list=$(xauth nlist $DISPLAY)
    if [ ! -z "$xauth_list" ]; then
        echo $xauth_list | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    fi
    chmod 777 $XAUTH
fi

# Allow for x forwarding
xhost +local:

# Notify the user
echo "Docker container '$CONTAINER_NAME' starting."

# Run the Docker container
docker run -it --rm \
    --name $CONTAINER_NAME \
    --net=host \
    --env DISPLAY=$DISPLAY \
    --env XAUTHORITY=$XAUTH \
    --volume $XSOCK:$XSOCK:rw \
    --volume $XAUTH:$XAUTH:rw \
    --volume ./config:$USER_HOME/.config/Zivid/API:rw \
    --volume /etc/OpenCL/vendors:/etc/OpenCL/vendors:ro \
    --privileged \
    --gpus all \
    $IMAGE_NAME
