import 'package:flutter/material.dart';
import 'dart:async';
import '../models/sensor_data.dart';
import '../services/api_service.dart';

class SensorProvider with ChangeNotifier {
  List<SensorData> _readings = [];
  bool _pumpStatus = false;
  Timer? _timer;

  List<SensorData> get readings => _readings;
  bool get pumpStatus => _pumpStatus;

  SensorProvider() {
    // Start fetching sensor data every 10 seconds
    _fetchSensorData();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchSensorData();
    });
  }

  Future<void> _fetchSensorData() async {
    try {
      final sensorValue = await ApiService.fetchSensorData();
      final reading = SensorData(value: sensorValue, timestamp: DateTime.now());
      _readings.add(reading);
      // Limit to the latest 50 readings for the chart
      if (_readings.length > 50) {
        _readings.removeAt(0);
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching sensor data: $e");
    }
  }

  Future<void> refreshData() async {
    await _fetchSensorData();
  }

  Future<void> turnPumpOn() async {
    try {
      bool result = await ApiService.pumpOn();
      if (result) {
        _pumpStatus = true;
        notifyListeners();
      }
    } catch (e) {
      print("Error turning pump on: $e");
    }
  }

  Future<void> turnPumpOff() async {
    try {
      bool result = await ApiService.pumpOff();
      if (result) {
        _pumpStatus = false;
        notifyListeners();
      }
    } catch (e) {
      print("Error turning pump off: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
