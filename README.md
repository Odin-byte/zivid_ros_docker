# zivid_ros_docker
Container used to run the ROS1 driver for the Zivid cameras.

## Installation
Ensure that you have a Nvidia driver installed. You can check this by running
```shell
nvidia-smi
```
If your GPU does not show up, please install a driver either using the apt manager or by using the "Additional Driver" GUI provided by Ubuntu.\
After that you need to install the [Nvidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). Simply follow the instructions provided by Nvidia.\
Now you are ready to clone this repo and use the provided **build.sh** script to build the container.
Next use the provided **run.sh** script to start the container. This script starts the container, mounts the needed directories and ensures the usage of the Nvidia GPU.\
Now from inside the docker start ZividStudio by running
```shell
/usr/bin/ZividStudio
```
This application provided by Zivid should automatically detect your Zivid camera connected over Ethernet. If the camera is found but not accesible due to a missmatch within the IP configuration of the camera you can use the following command to overwrite the current camera configuration:
```shell
/usr/bin/ZividNetworkCameraConfigurator set-config <host> --static --ip <ip> --subnet-mask <mask> --gateway <gateway>
```
*host* being the current IP address of the camera.\
*ip* being the new IP address you want to asign the camera to.\
*mask* and *gateway* need to match the network your PC and Camera are using to communciate with each other.\
\
After theses changes your camera should be able to connect to ZividStudio. Here you might need to install the latest firmware using the GUI. Afterwards you are ready to go. While you are here you might try some of the available presets over live capture mode. If any of these presets fit your needs export them to the `config/capture_settings/`folder located in the base of your `catkin_ws` for later use within the ROS1 driver node.

## Usage
When the docker is running make sure that there is a roscore available. After that run:
```shell
ROS_NAMESPACE=zivid_camera rosrun zivid_camera zivid_camera_node
```
Next call the parameter load service provided by the driver node to load your capture preset.
```shell
rosservice call /zivid_camera/load_settings_from_file "file_path: '<path/to/your/preset.yml>'"
```
Now you are all set to call the trigger service
```shell
rosservice call /zivid_camera/capture
```
This call triggers the zivid camera which then uses the provided preset to publish the image information to the corresponding topics.

### Topics
Available topics:
- /zivid_camera/color/camera_info
- /zivid_camera/color/image_color
- /zivid_camera/depth/camera_info
- /zivid_camera/depth/image
- /zivid_camera/normals/xyz
- /zivid_camera/points/xyz
- /zivid_camera/points/xyzrgba
- /zivid_camera/snr/camera_info
- /zivid_camera/snr/image

### Services
Available services:
- /zivid_camera/camera_info/model_name
- /zivid_camera/camera_info/serial_number
- /zivid_camera/capture
- /zivid_camera/capture_2d
- /zivid_camera/capture_and_save
- /zivid_camera/capture_assistant/suggest_settings
- /zivid_camera/is_connected
- /zivid_camera/load_settings_2d_from_file
- /zivid_camera/load_settings_from_file
- /zivid_camera/zivid_camera/get_loggers
- /zivid_camera/zivid_camera/list
- /zivid_camera/zivid_camera/load_nodelet
- /zivid_camera/zivid_camera/set_logger_level
- /zivid_camera/zivid_camera/unload_nodelet
