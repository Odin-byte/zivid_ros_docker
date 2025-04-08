# zivid_ros_docker
Container used to run the ROS2 driver for the Zivid cameras.

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
ZividStudio
```
This application provided by Zivid should automatically detect your Zivid camera connected over Ethernet. If the camera is found but not accesible due to a missmatch within the IP configuration of the camera you can use the following command to overwrite the current camera configuration:
```shell
ZividNetworkCameraConfigurator set-config <host> --static --ip <ip> --subnet-mask <mask> --gateway <gateway>
```
*host* being the current IP address of the camera.\
*ip* being the new IP address you want to asign the camera to.\
*mask* and *gateway* need to match the network your PC and Camera are using to communciate with each other.\
\
After theses changes your camera should be able to connect to ZividStudio. Here you might need to install the latest firmware using the GUI. Afterwards you are ready to go. While you are here you might try some of the available presets over live capture mode. If any of these presets fit your needs export them to the `config/capture_settings/`folder located in the base of your `ros2_ws` for later use within the ROS2 driver node.

## Usage
When the docker is running start the ros driver using
```shell
ros2 run zivid_camera zivid_camera
```
Due to the nested msgs and services, its best to configure the camera config by writing a ros2 script which calls the corresponding '/zivid_camera/set_parameters' service. For the needed msg structure take a look at this [script](https://github.com/zivid/zivid-ros/blob/master/zivid_samples/scripts/sample_capture_with_settings_from_file.py).

After setting up the capture settings, you are ready to call the '/capture' service which captures a 2D and 3D depth image and publishes the information on the corresponding topics.
