import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../providers/pump_provider.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _pumpStatus = false;
  int _threshold = 512;
  bool _isPumpUpdating = false;
  bool _isThresholdUpdating = false;

  @override
  void initState() {
    super.initState();
    final pumpProvider = Provider.of<PumpProvider>(context, listen: false);
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _pumpStatus = pumpProvider.pumpStatus == "ON";
        _threshold = sensorProvider.moistureThreshold;
      });
    });
  }

  Future<void> _togglePump(bool newValue) async {
    final pumpProvider = Provider.of<PumpProvider>(context, listen: false);
    setState(() {
      _isPumpUpdating = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending pump command...')),
    );
    try {
      await pumpProvider.controlPump(newValue ? "ON" : "OFF");
      setState(() {
        _pumpStatus = newValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pump turned ${newValue ? "ON" : "OFF"} successfully!',
            style: TextStyle(color: Colors.green.shade700, fontFamily: 'Arial'),
          ),
          backgroundColor: Colors.lime,
        ),
      );
    } catch (e) {
      setState(() {
        _pumpStatus = !newValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update pump status.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPumpUpdating = false;
      });
    }
  }

  Future<void> _updateThreshold(double value) async {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    setState(() {
      _isThresholdUpdating = true;
      _threshold = value.toInt();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating moisture threshold...')),
    );
    try {
      await sensorProvider.setMoistureThreshold(value.toInt());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Threshold set to ${value.toInt()} successfully!',
            style: TextStyle(color: Colors.green.shade700),
          ),
          backgroundColor: Colors.lime,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update threshold.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isThresholdUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AnimatedContainer(
            width: double.infinity,
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
            child: Column(
              children: [
                const Text(
                  'Manual Pump Control',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AnimatedToggleSwitch<bool>.dual(
                  current: _pumpStatus,
                  first: false,
                  second: true,
                  iconBuilder: (value) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        value ? "PUMP ON" : "PUMP OFF",
                        style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: value
                                ? Colors.green.shade50
                                : Colors.red.shade50),
                      ),
                    ),
                  ),
                  borderWidth: 2,
                  indicatorSize: const Size(70, 60),
                  style: ToggleStyle(backgroundColor: Colors.white10),
                  styleBuilder: (value) => ToggleStyle(
                      indicatorColor: value ? Colors.green : Colors.red),
                  onChanged:
                      _isPumpUpdating ? null : (value) => _togglePump(value),
                  animationDuration: const Duration(milliseconds: 500),
                ),
                const SizedBox(height: 10),
                if (_isPumpUpdating)
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.green,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set Moisture Threshold',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Wet (0)',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w700),
                    ),
                    Expanded(
                      child: Slider(
                        value: _threshold.toDouble(),
                        min: 0,
                        max: 1024,
                        divisions: 1024,
                        label: _threshold.toString(),
                        onChanged: _isThresholdUpdating
                            ? null
                            : (double value) {
                                setState(() {
                                  _threshold = value.toInt();
                                });
                              },
                        onChangeEnd: _isThresholdUpdating
                            ? null
                            : (double value) => _updateThreshold(value),
                      ),
                    ),
                    const Text(
                      'Dry (1023)',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Threshold: $_threshold',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Adjust the threshold to balance water usage. ',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      TextSpan(
                        text: 'Lower values',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' indicate wetter soil, while ',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      TextSpan(
                        text: 'higher values',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' indicate drier soil.',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                if (_isThresholdUpdating)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: const [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Updating threshold...',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Use the controls above to manage the pump and adjust moisture settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
