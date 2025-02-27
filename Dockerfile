FROM ros:noetic-ros-core

# Define user and home directory
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=1000
ARG WORKDIR=/home/$USERNAME

# Create a non-root user with the specified UID/GID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID --create-home --shell /bin/bash $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set working directory and change ownership
WORKDIR $WORKDIR
RUN chown -R $USERNAME:$USERNAME $WORKDIR

# Install prequisites
RUN sudo apt-get update && apt-get install -y python3-catkin-tools python3-osrf-pycommon git wget \
     g++ python3-rosdep build-essential ros-noetic-rqt-reconfigure python3-rospkg ros-noetic-rviz

# Switch to non-root user
USER $USERNAME

# Create tmp folder for Zivid Core install
RUN mkdir Zivid && cd Zivid && wget \
    https://downloads.zivid.com/sdk/releases/2.14.2+1a322f18-1/u20/amd64/zivid_2.14.2+1a322f18-1_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.14.2+1a322f18-1/u20/amd64/zivid-studio_2.14.2+1a322f18-1_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.14.2+1a322f18-1/u20/amd64/zivid-tools_2.14.2+1a322f18-1_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.14.2+1a322f18-1/u20/amd64/zivid-genicam_2.14.2+1a322f18-1_amd64.deb

RUN cd Zivid && sudo apt update && sudo apt install -y ./*.deb

# Cleanup after install 

RUN rm -r Zivid/

# Switch to non-root user
USER $USERNAME  

# Get ROS1 Driver from github repo and install with dependencies
RUN bash -c "source /opt/ros/noetic/setup.bash && \
    mkdir -p ~/catkin_ws/src && \
    cd ~/catkin_ws/src && \
    git clone https://github.com/Odin-byte/zivid-ros.git -b ros1-sdk-2.14.0 && \
    cd ~/catkin_ws && \
    sudo apt-get update && \
    sudo rosdep init && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    catkin build"

# Source ROS environment and set up entrypoint
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /home/$USERNAME/catkin_ws/devel/setup.bash" >> ~/.bashrc

CMD ["bash"]
