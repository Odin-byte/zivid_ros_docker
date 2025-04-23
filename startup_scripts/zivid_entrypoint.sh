#!/bin/bash

# Source the ROS2 environment
source /opt/ros/humble/setup.bash
source /home/ros_ws/install/setup.bash

# Start the zivid hardware driver
echo "Starting the zivid ros driver..."
ros2 launch zivid_camera iiwa.launch.py

# Optionally wait for it to initialize (naive wait or use topic/service check)
sleep 10

# Call the configure setting before capturing
echo "Setting the capture config..."
ros2 service call 

# Keep the container alive
wait
