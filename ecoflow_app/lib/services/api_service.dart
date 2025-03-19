import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pump_activity.dart';
import '../models/sensor_data.dart';

class ApiService {
  static const String baseUrl = "http://192.168.202.180";

  // Fetch current soil moisture reading
  Future<int> fetchCurrentSoilMoisture() async {
    final url = '$baseUrl/soil-moisture';
    print('Calling API: GET $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Response from $url: ${response.body}');
      return int.parse(response.body);
    } else {
      print('Failed to fetch soil moisture. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch soil moisture');
    }
  }

  // Fetch soil moisture history for graph
  Future<List<SensorData>> fetchSoilMoistureHistory() async {
    final url = '$baseUrl/soil-moisture-history';
    print('Calling API: GET $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Response from $url: ${response.body}');
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => SensorData.fromJson(item)).toList();
    } else {
      print('Failed to fetch soil moisture history. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch soil moisture history');
    }
  }

  // Fetch current threshold value
  Future<int> fetchThreshold() async {
    final url = '$baseUrl/get-threshold';
    print('Calling API: GET $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Response from $url: ${response.body}');
      return int.parse(response.body);
    } else {
      print('Failed to fetch threshold. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch threshold');
    }
  }

  // Fetch pump activity timeline for graph
  Future<List<PumpActivity>> fetchPumpActivityTimeline() async {
    final url = '$baseUrl/pump-activity-timeline';
    print('Calling API: GET $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Response from $url: ${response.body}');
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PumpActivity.fromJson(item)).toList();
    } else {
      print('Failed to fetch pump activity timeline. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch pump activity timeline');
    }
  }

  // Fetch current pump status (ON/OFF)
  Future<String> fetchPumpStatus() async {
    final url = '$baseUrl/pump-status';
    print('Calling API: GET $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Response from $url: ${response.body}');
      return response.body;
    } else {
      print('Failed to fetch pump status. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch pump status');
    }
  }

  // Control pump (ON/OFF)
  Future<void> controlPump(String status) async {
    final url = '$baseUrl/pump-control';
    print('Calling API: POST $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'status': status},
    );

    if (response.statusCode == 200) {
      print('Pump control successful. Status: $status');
    } else {
      print('Failed to control pump. Status code: ${response.statusCode}');
      throw Exception('Failed to control pump');
    }
  }

  // Set soil moisture threshold
  Future<void> setThreshold(int threshold) async {
    final url = '$baseUrl/set-threshold';
    print('Calling API: POST $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'threshold': threshold.toString()},
    );

    if (response.statusCode == 200) {
      print('Threshold set successfully: $threshold');
    } else {
      print('Failed to set threshold. Status code: ${response.statusCode}');
      throw Exception('Failed to set threshold');
    }
  }
}
