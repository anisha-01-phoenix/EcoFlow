import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pump_provider.dart';
import '../providers/sensor_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSensorRefreshing = false;
  bool _isPumpRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorProvider>(context);
    final pumpProvider = Provider.of<PumpProvider>(context);
    final int currentReading = sensorProvider.currentMoisture;
    final String pumpStatus = pumpProvider.pumpStatus;

    String sensorStatusText;
    Widget sensorIcon = const SizedBox.shrink();
    Color sensorTextColor;
    if (currentReading >= 1000) {
      sensorStatusText = "Dry Soil (${currentReading})";
      sensorIcon = const Icon(Icons.wb_sunny, color: Colors.orange, size: 20);
      sensorTextColor = Colors.orange.shade900;
    } else if (currentReading >= 400 && currentReading < 1000) {
      sensorStatusText = "Moist Soil (${currentReading})";
      sensorIcon =
          const Icon(Icons.grass_rounded, color: Colors.green, size: 20);
      sensorTextColor = Colors.green.shade900;
    } else {
      sensorStatusText = "Wet Soil (${currentReading})";
      sensorIcon =
          const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 20);
      sensorTextColor = Colors.blue.shade900;
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
                          sensorIcon,
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
                              style: TextStyle(
                                  fontSize: 15, color: sensorTextColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: _isSensorRefreshing
                          ? SizedBox(
                              key: const ValueKey('sensorLoading'),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blueGrey,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              key: ValueKey('sensorRefresh'),
                              color: Colors.blueGrey,
                            ),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isSensorRefreshing = true;
                      });
                      await sensorProvider.fetchCurrentMoisture();
                      setState(() {
                        _isSensorRefreshing = false;
                      });
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
                      color: pumpStatus == "ON"
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: pumpStatus == "ON"
                        ? const Icon(Icons.check_circle,
                            color: Colors.green, size: 32)
                        : const Icon(Icons.cancel, color: Colors.red, size: 32),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          pumpStatus,
                          key: ValueKey<String>(pumpStatus),
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Arial',
                              color: pumpStatus == "ON"
                                  ? Colors.green.shade700
                                  : Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: _isPumpRefreshing
                          ? SizedBox(
                              key: const ValueKey('pumpLoading'),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blueGrey,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              key: ValueKey('pumpRefresh'),
                              color: Colors.blueGrey,
                            ),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isPumpRefreshing = true;
                      });
                      await pumpProvider.fetchPumpStatus();
                      setState(() {
                        _isPumpRefreshing = false;
                      });
                    },
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
