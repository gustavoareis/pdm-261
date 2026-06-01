import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'window_to_front_method_channel.dart';

abstract class WindowToFrontPlatform extends PlatformInterface {
  WindowToFrontPlatform() : super(token: _token);

  static final Object _token = Object();

  static WindowToFrontPlatform _instance = MethodChannelWindowToFront();

  static WindowToFrontPlatform get instance => _instance;

  static set instance(WindowToFrontPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> activate() {
    throw UnimplementedError('activate() has not been implemented.');
  }
}
