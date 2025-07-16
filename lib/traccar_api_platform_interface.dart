// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// import 'traccar_api_method_channel.dart';

// abstract class TraccarApiPlatform extends PlatformInterface {
//   /// Constructs a TraccarApiPlatform.
//   TraccarApiPlatform() : super(token: _token);

//   static final Object _token = Object();

//   static TraccarApiPlatform _instance = MethodChannelTraccarApi();

//   /// The default instance of [TraccarApiPlatform] to use.
//   ///
//   /// Defaults to [MethodChannelTraccarApi].
//   static TraccarApiPlatform get instance => _instance;

//   /// Platform-specific implementations should set this with their own
//   /// platform-specific class that extends [TraccarApiPlatform] when
//   /// they register themselves.
//   static set instance(TraccarApiPlatform instance) {
//     PlatformInterface.verifyToken(instance, _token);
//     _instance = instance;
//   }

//   Future<String?> getPlatformVersion() {
//     throw UnimplementedError('platformVersion() has not been implemented.');
//   }
// }
