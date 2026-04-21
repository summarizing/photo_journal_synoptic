import 'package:flutter/services.dart';

// This uses a platform channel to call native code on both iOS and Android.
// It fetches the device model name directly from the OS rather than using
// a third-party package.
//
// I looked into device_info_plus first but decided doing it manually
// shows the actual channel mechanism better - easier to explain too.

class DeviceInfoService {
  static const _channel = MethodChannel('com.photojournal/device_info');

  // Returns something like "iPhone 14 Pro" or "Samsung Galaxy S21"
  // Falls back to a generic string if the platform call fails for any reason
  static Future<String> getDeviceModel() async {
    try {
      final model = await _channel.invokeMethod<String>('getDeviceModel');
      return model ?? 'Unknown device';
    } on PlatformException catch (e) {
      // This can happen in the emulator sometimes - not a big deal
      print('Platform channel error: ${e.message}');
      return 'Unknown device';
    }
  }
}
