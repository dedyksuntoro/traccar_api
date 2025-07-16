Traccar API
A Flutter plugin for integrating with the Traccar API, providing access to device and position data from a Traccar server.
Features

Authenticate with Traccar server using email/password or token.
Fetch list of devices.
Retrieve position data for specific devices with optional time filters.
Cross-platform support for Android and iOS.

Installation
Add the following to your pubspec.yaml:
dependencies:
  traccar_api: ^1.0.0

Run flutter pub get to install the package.
Usage
Initialize the plugin
import 'package:traccar_api/traccar_api.dart';

void main() async {
  final traccar = TraccarApi(baseUrl: 'http://demo.traccar.org:5055');

  // Authenticate with email and password
  bool success = await traccar.authenticate(
    email: 'your-email@example.com',
    password: 'your-password',
  );

  if (success) {
    print('Authentication successful');
  } else {
    print('Authentication failed');
  }

  // Alternatively, authenticate with a token
  traccar.authenticateWithToken('your-token');

  // Fetch devices
  try {
    final devices = await traccar.getDevices();
    for (var device in devices) {
      print(device);
    }
  } catch (e) {
    print('Error: $e');
  }

  // Fetch positions for a device
  try {
    final positions = await traccar.getPositions(deviceId: 1);
    for (var position in positions) {
      print(position);
    }
  } catch (e) {
    print('Error: $e');
  }

  // Dispose when done
  traccar.dispose();
}

Configuration
Android
Add the following permissions to android/app/src/main/AndroidManifest.xml:
<uses-permission android:name="android.permission.INTERNET" />

iOS
Add the following to ios/Runner/Info.plist to allow HTTP connections (if your server uses HTTP):
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>

Publishing to pub.dev

Ensure you have a CHANGELOG.md file documenting changes.
Update the version in pubspec.yaml for each release.
Run flutter pub publish --dry-run to verify the package.
Run flutter pub publish to upload to pub.dev.

Contributing
Contributions are welcome! Please open an issue or submit a pull request on GitHub.