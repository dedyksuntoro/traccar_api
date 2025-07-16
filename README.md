# traccar_api

A Flutter plugin for interacting with the Traccar API. This plugin allows you to authenticate with a Traccar server, fetch device information, and retrieve current and historical position data. It supports visualizing device locations and travel paths on a map using `flutter_map`.

## Features
- Authenticate with a Traccar server using email and password.
- Retrieve a list of registered devices.
- Fetch current positions for a specific device.
- Fetch historical positions within a specified date range.
- Display current positions on a map with markers.
- Visualize historical travel paths as polylines.

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  traccar_api: ^1.0.0
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
  syncfusion_flutter_datepicker: ^20.0.0
```

Then, run:

```bash
flutter pub get
```

## Usage

### 1. Initialize the Traccar API Client
Create an instance of `TraccarApi` with your Traccar server URL:

```dart
import 'package:traccar_api/traccar_api.dart';

final traccar = TraccarApi(baseUrl: 'http://demo.traccar.org:5055');
```

### 2. Authenticate with the Server
Use your Traccar credentials to authenticate:

```dart
bool success = await traccar.authenticate(
  email: 'admin@traccar.org',
  password: 'admin',
);
if (success) {
  print('Authentication successful');
} else {
  print('Authentication failed');
}
```

### 3. Fetch Devices
Retrieve a list of devices registered on the server:

```dart
List<TraccarDevice> devices = await traccar.getDevices();
print('Found ${devices.length} devices');
```

### 4. Fetch Current Positions
Get the latest positions for a specific device:

```dart
final positions = await traccar.getPositions(deviceId: devices[0].id);
if (positions.isNotEmpty) {
  print('Latest position: ${positions[0].latitude}, ${positions[0].longitude}');
}
```

### 5. Fetch Historical Positions
Retrieve positions for a device within a date range:

```dart
final positions = await traccar.getPositions(
  deviceId: devices[0].id,
  from: DateTime(2025, 7, 1),
  to: DateTime(2025, 7, 16),
);
print('Found ${positions.length} historical positions');
```

## Example

The `example/` directory contains a complete Flutter app demonstrating how to:
- Authenticate with a Traccar server.
- Display a list of devices.
- Show current device positions on a map with markers.
- Visualize historical travel paths as polylines using a date range picker.

To run the example:

```bash
cd example
flutter run
```

## Dependencies
This plugin requires the following dependencies:
- `flutter_map`: For rendering maps.
- `latlong2`: For handling latitude and longitude coordinates.
- `syncfusion_flutter_datepicker`: For selecting date ranges in the example app.

Ensure these are included in your `pubspec.yaml` if you use the example or similar functionality.

## Notes
- Replace `http://demo.traccar.org:5055` with your Traccar server URL if you are using a private instance.
- Ensure a stable internet connection to fetch data from the Traccar server and load OpenStreetMap tiles.
- For private servers, verify that your server supports the Traccar API and that your credentials are valid.

## Contributing
Contributions are welcome! Please submit issues or pull requests to the [GitHub repository](https://github.com/dedyksuntoro/traccar_api).

## License
This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.
