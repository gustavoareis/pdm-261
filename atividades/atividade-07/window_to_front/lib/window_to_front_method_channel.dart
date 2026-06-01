import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'window_to_front_platform_interface.dart';

class MethodChannelWindowToFront extends WindowToFrontPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('window_to_front');

  @override
  Future<void> activate() {
    return methodChannel.invokeMethod<void>('activate');
  }
}
