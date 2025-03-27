import 'package:flutter/material.dart';
import '../models/pump_activity.dart';
import '../services/api_service.dart';

class PumpProvider with ChangeNotifier {
  List<PumpActivity> _pumpActivityTimeline = [];
  String _pumpStatus = 'OFF';
  final ApiService _apiService = ApiService();

  List<PumpActivity> get pumpActivityTimeline => _pumpActivityTimeline;
  String get pumpStatus => _pumpStatus;

  // Fetch current pump status
  Future<void> fetchPumpStatus() async {
    print('Fetching current pump status...');
    try {
      _pumpStatus = await _apiService.fetchPumpStatus();
      print('Pump status fetched successfully: $_pumpStatus');
      notifyListeners();
    } catch (e) {
      print("Error fetching pump status: $e");
    }
  }

  // Fetch pump activity timeline
  Future<void> fetchPumpActivityTimeline() async {
    print('Fetching pump activity timeline...');
    try {
      _pumpActivityTimeline = await _apiService.fetchPumpActivityTimeline();
      print('Pump activity timeline fetched successfully.');
      notifyListeners();
    } catch (e) {
      print("Error fetching pump activity timeline: $e");
    }
  }

  // Control the pump manually(ON/OFF)
  Future<void> manualControl(String status) async {
    print('Controlling pump manually: setting status to $status...');
    try {
      await _apiService.manualControl(status);
      _pumpStatus = status.toUpperCase();
      print('Pump control successful. Status set to $_pumpStatus');
      notifyListeners();
    } catch (e) {
      print("Error controlling pump: $e");
    }
  }

  // Control the pump automatically(ON/OFF)
  Future<void> autoControl() async {
    print('Controlling pump automatically...');
    try {
      await _apiService.autoControl();
      print('Auto Mode SetUp Successfully!');
      notifyListeners();
    } catch (e) {
      print("Error in setting up automatic pump control: $e");
    }
  }
}
