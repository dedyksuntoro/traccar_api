// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// import 'traccar_api_platform_interface.dart';

// /// An implementation of [TraccarApiPlatform] that uses method channels.
// class MethodChannelTraccarApi extends TraccarApiPlatform {
//   /// The method channel used to interact with the native platform.
//   @visibleForTesting
//   final methodChannel = const MethodChannel('traccar_api');

//   @override
//   Future<String?> getPlatformVersion() async {
//     final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
//     return version;
//   }
// }
