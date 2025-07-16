import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:traccar_api/traccar_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Traccar API Example')),
        body: TraccarExample(),
      ),
    );
  }
}

class TraccarExample extends StatefulWidget {
  @override
  _TraccarExampleState createState() => _TraccarExampleState();
}

class _TraccarExampleState extends State<TraccarExample> {
  final traccar = TraccarApi(baseUrl: 'https://admin.lacakaja.com');
  String status = 'Initializing...';
  List<TraccarDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _testTraccar();
  }

  Future<void> _testTraccar() async {
    try {
      // Authenticate
      bool success = await traccar.authenticate(
        email: 'su@sudo.com', // Ganti dengan kredensial valid
        password: 'IT@mandalaputra78', // Ganti dengan kredensial valid
      );
      setState(() {
        status = success
            ? 'Authentication successful'
            : 'Authentication failed';
      });

      if (!success) return;

      // Fetch devices
      try {
        devices = await traccar.getDevices();
        setState(() {
          status += '\nDevices found: ${devices.length}';
        });
      } catch (e) {
        setState(() {
          status += '\nError fetching devices: $e';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error: $e';
      });
    }
  }

  // Fungsi untuk menampilkan peta posisi saat ini
  Future<void> _showDeviceMap(
    BuildContext context,
    TraccarDevice device,
  ) async {
    try {
      // Ambil posisi untuk perangkat yang dipilih
      final positions = await traccar.getPositions(deviceId: device.id);
      if (positions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No positions found for ${device.name}')),
          );
        }
        return;
      }

      // Tampilkan dialog dengan peta OpenStreetMap
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Location of ${device.name}'),
            content: SizedBox(
              height: 300,
              width: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: latlong.LatLng(
                    positions[0].latitude,
                    positions[0].longitude,
                  ),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.traccar_api_example',
                  ),
                  MarkerLayer(
                    markers: positions
                        .asMap()
                        .entries
                        .map(
                          (entry) => Marker(
                            point: latlong.LatLng(
                              entry.value.latitude,
                              entry.value.longitude,
                            ),
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog peta
                  _showDateRangePicker(device); // Buka dialog pemilih tanggal
                },
                child: Text('History'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error fetching positions: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching positions: $e')));
      }
    }
  }

  // Fungsi untuk menampilkan pemilih rentang tanggal
  Future<void> _showDateRangePicker(TraccarDevice device) async {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Date Range for ${device.name}'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: SfDateRangePicker(
              onSelectionChanged:
                  (DateRangePickerSelectionChangedArgs args) async {
                    if (args.value is PickerDateRange) {
                      final PickerDateRange range = args.value;
                      if (range.startDate != null && range.endDate != null) {
                        Navigator.of(
                          context,
                        ).pop(); // Tutup dialog pemilih tanggal
                        await _showHistoryMap(
                          device,
                          range.startDate!,
                          range.endDate!,
                        );
                      }
                    }
                  },
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  // Fungsi untuk menampilkan peta history perjalanan
  Future<void> _showHistoryMap(
    TraccarDevice device,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Log parameter yang dikirim
      print(
        'Fetching history for device ${device.id} from ${startDate.toUtc().toIso8601String()} to ${endDate.toUtc().toIso8601String()}',
      );

      // Ambil posisi untuk rentang tanggal
      final positions = await traccar.getPositions(
        deviceId: device.id,
        from: startDate,
        to: endDate,
      );

      // Log jumlah posisi yang ditemukan
      print('Found ${positions.length} positions for device ${device.id}');

      if (positions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No history found for ${device.name} in selected range',
              ),
            ),
          );
        }
        return;
      }

      // Tampilkan dialog dengan peta history (hanya polyline, tanpa marker)
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Travel History of ${device.name}'),
            content: SizedBox(
              height: 300,
              width: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: latlong.LatLng(
                    positions[0].latitude,
                    positions[0].longitude,
                  ),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.traccar_api_example',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: positions
                            .map(
                              (pos) =>
                                  latlong.LatLng(pos.latitude, pos.longitude),
                            )
                            .toList(),
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error fetching history: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching history: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            status,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Devices:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...devices.map(
            (device) => ListTile(
              title: Text(device.name),
              subtitle: Text('ID: ${device.id}, Unique ID: ${device.uniqueId}'),
              onTap: () => _showDeviceMap(context, device),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    traccar.dispose();
    super.dispose();
  }
}
