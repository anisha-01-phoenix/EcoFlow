import 'package:ecoflow_app/providers/pump_provider.dart';
import 'package:ecoflow_app/providers/sensor_provider.dart';
import 'package:ecoflow_app/screens/control.dart';
import 'package:ecoflow_app/screens/dashboard.dart';
import 'package:ecoflow_app/screens/statistics.dart';
import 'package:ecoflow_app/widgets/error_screen.dart';
import 'package:ecoflow_app/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => PumpProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  late Future<void> _initialization;

  // Titles for the app bar.
  static const List<String> _titles = <String>[
    'Dashboard',
    'Pump Operations',
    'Performance Analytics'
  ];

  // Screens for the bottom navigation bar.
  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    ControlScreen(),
    StatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initialization = _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    final pumpProvider = Provider.of<PumpProvider>(context, listen: false);
    print('Fetching all initial data...');
    await Future.wait([
      sensorProvider.fetchCurrentMoisture(),
      sensorProvider.fetchMoistureThreshold(),
      sensorProvider.fetchMoistureHistory(),
      pumpProvider.fetchPumpStatus(),
      pumpProvider.fetchPumpActivityTimeline(),
    ]);
    print('All initial data fetched.');
  }

  Future<void> _refreshData() async {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    final pumpProvider = Provider.of<PumpProvider>(context, listen: false);
    print('Refreshing all data...');
    await Future.wait([
      sensorProvider.fetchCurrentMoisture(),
      sensorProvider.fetchMoistureThreshold(),
      sensorProvider.fetchMoistureHistory(),
      pumpProvider.fetchPumpStatus(),
      pumpProvider.fetchPumpActivityTimeline(),
    ]);
    print('Data refreshed.');
  }

  // Change the current screen index.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoFlow',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Montserrat',
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          } else if (snapshot.hasError) {
            return ErrorScreen(
              onRetry: () {
                setState(() {
                  _initialization = _fetchInitialData();
                });
              },
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.green,
                centerTitle: true,
                title: Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              body: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green,
                      Colors.green.shade50,
                      Colors.green,
                    ],
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: _screens.elementAt(_selectedIndex),
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.green,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.opacity_rounded),
                    label: 'Pump Control',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart_rounded),
                    label: 'Analytics',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                onTap: _onItemTapped,
              ),
            );
          }
        },
      ),
    );
  }
}
