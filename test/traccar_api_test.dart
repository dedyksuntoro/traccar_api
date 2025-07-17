// import 'package:flutter_test/flutter_test.dart';
// import 'package:traccar_api/traccar_api.dart';
// import 'package:http/http.dart' as http;
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'traccar_api_test.mocks.dart';

// @GenerateMocks([http.Client])
// void main() {
//   late TraccarApi traccar;
//   late MockClient mockClient;

//   setUp(() {
//     mockClient = MockClient();
//     traccar = TraccarApi(baseUrl: 'http://demo.traccar.org:5055', client: mockClient);
//   });

//   test('authenticate returns true on successful login', () async {
//     when(mockClient.post(
//       any,
//       headers: anyNamed('headers'),
//       body: anyNamed('body'),
//     )).thenAnswer((_) async => http.Response('{"token": "mock-token"}', 200));

//     final success = await traccar.authenticate(email: 'test@example.com', password: 'password');
//     expect(success, true);
//     expect(traccar.toString().contains('mock-token'), true);
//   });

//   test('getDevices throws exception when not authenticated', () {
//     expect(
//       () => traccar.getDevices(),
//       throwsA(isA<TraccarException>().having((e) => e.message, 'message', contains('Not authenticated'))),
//     );
//   });

//   test('getDevices returns list of devices', () async {
//     traccar.authenticateWithToken('mock-token');
//     when(mockClient.get(
//       any,
//       headers: anyNamed('headers'),
//     )).thenAnswer((_) async => http.Response('[{"id": 1, "name": "Device1", "uniqueId": "123"}]', 200));

//     final devices = await traccar.getDevices();
//     expect(devices, isA<List<TraccarDevice>>());
//     expect(devices.length, 1);
//     expect(devices[0].name, 'Device1');
//   });
// }
