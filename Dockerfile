FROM ros:humble-ros-base

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

# Install prerequisites
RUN sudo apt-get update && apt-get install -y git wget \
    g++

# Switch to non-root user
USER $USERNAME

# Create tmp folder for Zivid Core install
RUN mkdir Zivid && cd Zivid && wget \
    https://downloads.zivid.com/sdk/releases/2.15.0+5fcc365b-1/u24/amd64/zivid_2.15.0+5fcc365b-1_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.15.0+5fcc365b-1/u24/amd64/zivid-studio_2.15.0+5fcc365b-1_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.15.0+5fcc365b-1/u24/amd64/zivid-tools_2.15.0+5fcc365b-1_amd64.deb \
    https://downloads.zivid.com/sdk/releases/2.15.0+5fcc365b-1/u24/amd64/zivid-genicam_2.15.0+5fcc365b-1_amd64.deb

RUN cd Zivid && sudo apt update && sudo apt install -y ./*.deb

# Cleanup after install 
RUN rm -r Zivid/

# Switch to non-root user
USER $USERNAME  

# Get ROS1 Driver from github repo and install with dependencies
RUN bash -c "source /opt/ros/humble/setup.bash && \
    mkdir -p ~/ros2_ws/src && \
    cd ~/ros2_ws/src && \
    git clone https://github.com/zivid/zivid-ros.git && \
    cd ~/ros2_ws && \
    sudo apt-get update && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    colcon build --symlink-install"

# Source ROS environment and set up entrypoint
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /home/$USERNAME/ros2_ws/install/setup.bash" >> ~/.bashrc

# Copy volumes into the container
COPY ./config $WORKDIR/.config/Zivid/API
COPY ./capture_settings $WORKDIR/ros2_ws/config/capture_settings/
COPY ./zivid_helper_scripts $WORKDIR/ros2_ws/zivid_helper_scripts/
# Check if vendors directory exists and is not empty before copying
RUN if [ -d /etc/OpenCL/vendors ] && [ "$(ls -A /etc/OpenCL/vendors)" ]; then \
    cp -r /etc/OpenCL/vendors /etc/OpenCL/vendors; \
fi

CMD ["bash"]
