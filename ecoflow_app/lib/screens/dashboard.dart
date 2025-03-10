import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorProvider>(context);
    final int currentReading = sensorProvider.readings.isNotEmpty
        ? sensorProvider.readings.last.value
        : 1;
    final bool pumpStatus = sensorProvider.pumpStatus;

    String sensorStatusText;
    Widget sensorIcon = const SizedBox.shrink();
    if (currentReading == 1) {
      sensorStatusText = "Dry Soil";
      sensorIcon = const Icon(Icons.wb_sunny, color: Colors.orange, size: 24);
    } else if (currentReading == 0) {
      sensorStatusText = "Wet Soil";
      sensorIcon = const Icon(Icons.water_drop, color: Colors.blue, size: 24);
    } else {
      sensorStatusText = "$currentReading";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.transparent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/dashboard.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero),
            duration: const Duration(milliseconds: 500),
            builder: (context, offset, child) {
              return Transform.translate(
                offset: offset,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading:
                      const Icon(Icons.speed, color: Colors.green, size: 32),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sensor Reading',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (currentReading == 0 || currentReading == 1)
                            sensorIcon,
                          if (currentReading == 0 || currentReading == 1)
                            const SizedBox(width: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                            child: Text(
                              sensorStatusText,
                              key: ValueKey<String>(sensorStatusText),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.green),
                    onPressed: () {
                      sensorProvider.refreshData();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero),
            duration: const Duration(milliseconds: 500),
            builder: (context, offset, child) {
              return Transform.translate(
                offset: offset,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pumpStatus
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: pumpStatus
                        ? const Icon(Icons.check_circle,
                            color: Colors.green, size: 32)
                        : const Icon(Icons.cancel, color: Colors.red, size: 32),
                  ),
                  title: Row(
                    children: [
                      const Text(
                        'Pump Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                        child: Text(
                          pumpStatus ? "ON" : "OFF",
                          key: ValueKey<bool>(pumpStatus),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
