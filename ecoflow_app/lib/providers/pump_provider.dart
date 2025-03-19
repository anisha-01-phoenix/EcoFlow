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

  // Control the pump (ON/OFF)
  Future<void> controlPump(String status) async {
    print('Controlling pump: setting status to $status...');
    try {
      await _apiService.controlPump(status);
      _pumpStatus = status.toUpperCase();
      print('Pump control successful. Status set to $_pumpStatus');
      notifyListeners();
    } catch (e) {
      print("Error controlling pump: $e");
    }
  }
}
