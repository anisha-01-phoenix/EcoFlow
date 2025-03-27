import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';

class SensorProvider with ChangeNotifier {
  List<SensorData> _moistureHistory = [];
  int _currentMoisture = 0;
  int _moistureThreshold = 0;
  final ApiService _apiService = ApiService();

  List<SensorData> get moistureHistory => _moistureHistory;

  int get currentMoisture => _currentMoisture;
  int get moistureThreshold => _moistureThreshold;

  // Fetch current soil moisture
  Future<void> fetchCurrentMoisture() async {
    print('Fetching current soil moisture...');
    try {
      _currentMoisture = await _apiService.fetchCurrentSoilMoisture();
      print('Current soil moisture fetched successfully: $_currentMoisture');
      notifyListeners();
    } catch (e) {
      print("Error fetching current moisture: $e");
    }
  }

  // Fetch soil moisture history
  Future<void> fetchMoistureHistory() async {
    print('Fetching soil moisture history...');
    try {
      _moistureHistory = await _apiService.fetchSoilMoistureHistory();
      print('Soil moisture history fetched successfully.');
      notifyListeners();
    } catch (e) {
      print("Error fetching soil moisture history: $e");
    }
  }

  //Fetch Current Threshold
  Future<void> fetchMoistureThreshold() async {
    print('Fetching moisture threshold...');
    try {
      _moistureThreshold = await _apiService.fetchThreshold();
      print('Moisture threshold fetched successfully: $_moistureThreshold');
      notifyListeners();
    } catch (e) {
      print("Error fetching threshold: $e");
    }
  }

  // Set soil moisture threshold
  Future<void> setMoistureThreshold(int threshold) async {
    print('Setting moisture threshold to $threshold...');
    try {
      await _apiService.setThreshold(threshold);
      print('Moisture threshold set successfully.');
      notifyListeners();
    } catch (e) {
      print("Error setting threshold: $e");
    }
  }
}
