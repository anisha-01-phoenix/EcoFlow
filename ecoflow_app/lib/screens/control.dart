import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _pumpStatus = false;

  @override
  void initState() {
    super.initState();
    _pumpStatus =
        Provider.of<SensorProvider>(context, listen: false).pumpStatus;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _pumpStatus ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _pumpStatus ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(
                'Manual Pump Control',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Pump is currently ${_pumpStatus ? "ON" : "OFF"}',
                style: const TextStyle(fontSize: 12),
              ),
              secondary: Icon(
                _pumpStatus ? Icons.check_circle : Icons.cancel,
                color: _pumpStatus ? Colors.green : Colors.red,
                size: 32,
              ),
              value: _pumpStatus,
              onChanged: (bool value) {
                setState(() {
                  _pumpStatus = value;
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              'Current Pump Status: ${_pumpStatus ? "ON" : "OFF"}',
              key: ValueKey<bool>(_pumpStatus),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 30),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _pumpStatus
                ? Image.asset(
              'assets/watering_on.gif',
              key: const ValueKey('on'),
              fit: BoxFit.cover,
              width: double.infinity,
            )
                : const SizedBox.shrink(key: ValueKey('off')),
          ),
        ],
      ),
    );
  }
}
