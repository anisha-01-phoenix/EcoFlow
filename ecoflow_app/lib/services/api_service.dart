import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.202.180";

  static Future<int> fetchSensorData() async {
    final url = Uri.parse("$baseUrl/sensor");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String body = response.body;
      List<String> parts = body.split(" ");
      int value = int.parse(parts.last.trim());
      return value;
    } else {
      throw Exception("Failed to fetch sensor data");
    }
  }

  static Future<bool> pumpOn() async {
    final url = Uri.parse("$baseUrl/pumpOn");
    final response = await http.get(url);
    return response.statusCode == 200;
  }

  static Future<bool> pumpOff() async {
    final url = Uri.parse("$baseUrl/pumpOff");
    final response = await http.get(url);
    return response.statusCode == 200;
  }
}
