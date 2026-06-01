import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:window_to_front/window_to_front_method_channel.dart';
import 'package:window_to_front/window_to_front_platform_interface.dart';

class MockWindowToFrontPlatform
    with MockPlatformInterfaceMixin
    implements WindowToFrontPlatform {
  bool activated = false;

  @override
  Future<void> activate() async {
    activated = true;
  }
}

void main() {
  final initialPlatform = WindowToFrontPlatform.instance;

  test('$MethodChannelWindowToFront is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWindowToFront>());
  });

  test('activate delegates to platform implementation', () async {
    final fakePlatform = MockWindowToFrontPlatform();
    WindowToFrontPlatform.instance = fakePlatform;

    await WindowToFront.activate();

    expect(fakePlatform.activated, isTrue);
  });
}
