library traccar_api;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TraccarApi {
  final String _baseUrl;
  String? _sessionToken;
  final http.Client _client;

  TraccarApi({required String baseUrl, http.Client? client})
      : _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _client = client ?? http.Client();

  Future<bool> authenticate(
      {required String email, required String password}) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/session'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        _sessionToken = response.headers['set-cookie']?.split(';').first;
        print('Authentication successful, session token: $_sessionToken');
        return true;
      } else {
        print(
            'Authentication response: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      throw TraccarException('Authentication failed: $e');
    }
  }

  bool authenticateWithToken(String token) {
    _sessionToken = token;
    return true;
  }

  Future<List<TraccarDevice>> getDevices() async {
    if (_sessionToken == null) {
      throw TraccarException('Not authenticated. Call authenticate() first.');
    }

    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/devices'),
        headers: {
          'Cookie': _sessionToken!,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TraccarDevice.fromJson(json)).toList();
      } else {
        print(
            'Get devices response: ${response.statusCode} - ${response.body}');
        throw TraccarException(
            'Failed to fetch devices: ${response.statusCode}');
      }
    } catch (e) {
      throw TraccarException('Error fetching devices: $e');
    }
  }

  Future<List<TraccarPosition>> getPositions({
    required int deviceId,
    DateTime? from,
    DateTime? to,
  }) async {
    if (_sessionToken == null) {
      throw TraccarException('Not authenticated. Call authenticate() first.');
    }

    try {
      final queryParameters = {
        'deviceId': deviceId.toString(),
        if (from != null)
          'from': from
              .toUtc()
              .toIso8601String()
              .replaceAll(RegExp(r'\.\d{3}Z$'), 'Z'),
        if (to != null)
          'to': to
              .toUtc()
              .toIso8601String()
              .replaceAll(RegExp(r'\.\d{3}Z$'), 'Z'),
      };
      final uri = Uri.parse('$_baseUrl/api/positions')
          .replace(queryParameters: queryParameters);
      print('Requesting positions: $uri');
      final response = await _client.get(
        uri,
        headers: {'Cookie': _sessionToken!, 'Accept': 'application/json'},
      );
      print(
          'Get positions response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TraccarPosition.fromJson(json)).toList();
      } else {
        throw TraccarException(
            'Failed to fetch positions: ${response.statusCode}');
      }
    } catch (e) {
      throw TraccarException('Error fetching positions: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class TraccarDevice {
  final int id;
  final String name;
  final String uniqueId;

  TraccarDevice({required this.id, required this.name, required this.uniqueId});

  factory TraccarDevice.fromJson(Map<String, dynamic> json) {
    return TraccarDevice(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      uniqueId: json['uniqueId'] ?? '',
    );
  }

  @override
  String toString() =>
      'TraccarDevice(id: $id, name: $name, uniqueId: $uniqueId)';
}

class TraccarPosition {
  final int deviceId;
  final double latitude;
  final double longitude;
  final DateTime serverTime;

  TraccarPosition({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.serverTime,
  });

  factory TraccarPosition.fromJson(Map<String, dynamic> json) {
    return TraccarPosition(
      deviceId: json['deviceId'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      serverTime: DateTime.parse(
          json['serverTime'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() =>
      'TraccarPosition(deviceId: $deviceId, lat: $latitude, lon: $longitude)';
}

class TraccarException implements Exception {
  final String message;

  TraccarException(this.message);

  @override
  String toString() => 'TraccarException: $message';
}
