#!/usr/bin/env python

import sys

from ament_index_python.packages import get_package_share_directory
from rcl_interfaces.srv import SetParameters
import rclpy
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node
from rclpy.parameter import Parameter
from std_srvs.srv import Trigger


class ParamSetter(Node):

    def __init__(self):
        super().__init__('sample_capture_with_settings_from_file_py')

        self.capture_service = self.create_client(Trigger, 'capture')
        while not self.capture_service.wait_for_service(timeout_sec=3.0):
            self.get_logger().info('capture service not available, waiting again...')

        self.param_client = self.create_client(SetParameters, 'zivid_camera/set_parameters')
        while not self.param_client.wait_for_service(timeout_sec=3):
            self.get_logger().info('Parameter service not available, waiting again...')

    def set_settings(self):
        path_to_settings_yml = (
            get_package_share_directory('zivid_samples')
            + '/settings/camera_settings.yml'
        )
        self.get_logger().info(
            'Setting parameter `settings_file_path` to: ' + path_to_settings_yml
        )

        settings_parameter = Parameter(
            'settings_file_path',
            Parameter.Type.STRING,
            path_to_settings_yml,
        ).to_parameter_msg()

        

        future = self.param_client.call_async(
            SetParameters.Request(parameters=[settings_parameter])
        )
        rclpy.spin_until_future_complete(self, future, timeout_sec=30)
        if not future.result():
            raise RuntimeError('Failed to set parameters')


def main(args=None):
    rclpy.init(args=args)

    try:
        helper = ParamSetter()
        helper.set_settings()

    except KeyboardInterrupt:
        pass
    except ExternalShutdownException:
        sys.exit(1)


if __name__ == '__main__':
    main()