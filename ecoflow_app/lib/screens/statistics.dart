import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/sensor_provider.dart';
import '../providers/pump_provider.dart';
import '../models/sensor_data.dart';
import '../models/pump_activity.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedTimeline = 'Hours'; // Default timeline
  double minX = 0, maxX = 24; // Default x-axis range for Hours
  bool _isRefreshing = false;

  /// Converts a raw timestamp (in milliseconds) into a value in the selected time unit.
  double convertTimestamp(int timestamp) {
    switch (selectedTimeline) {
      case 'Minutes':
        return timestamp / (1000 * 60); // minutes
      case 'Hours':
        return timestamp / (1000 * 60 * 60); // hours
      case 'Days':
        return timestamp / (1000 * 60 * 60 * 24); // days
      case 'Months':
        return timestamp / (1000 * 60 * 60 * 24 * 30); // approximate months
      default:
        return timestamp.toDouble();
    }
  }

  void _changeTimeline(String timeline) {
    setState(() {
      selectedTimeline = timeline;
      // Adjust the x-axis range based on the timeline.
      switch (timeline) {
        case 'Minutes':
          minX = 0;
          maxX = 60;
          break;
        case 'Hours':
          minX = 0;
          maxX = 24;
          break;
        case 'Days':
          minX = 0;
          maxX = 30;
          break;
        case 'Months':
          minX = 0;
          maxX = 12;
          break;
      }
    });
  }

  /// Widget to build the bottom (X) axis title using the selected timeline.
  Widget _buildBottomTitle(double value, TitleMeta meta) {
    String text;
    switch (selectedTimeline) {
      case 'Minutes':
        text = "${value.toInt()} min";
        break;
      case 'Hours':
        text = "${value.toInt()} hr";
        break;
      case 'Days':
        text = "${value.toInt()} d";
        break;
      case 'Months':
        text = "${value.toInt()} mo";
        break;
      default:
        text = value.toString();
    }
    return SideTitleWidget(
      meta: meta,
      space: 6,
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }

  /// Refreshes moisture history, threshold, and pump activity data.
  Future<void> _refreshData() async {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    final pumpProvider = Provider.of<PumpProvider>(context, listen: false);

    setState(() {
      _isRefreshing = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refreshing data...')),
      );
      await Future.wait([
        sensorProvider.fetchMoistureHistory(),
        sensorProvider.fetchMoistureThreshold(),
        pumpProvider.fetchPumpActivityTimeline(),
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed successfully!',
              style: TextStyle(color: Colors.green)),
          backgroundColor: Colors.lime,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to refresh data.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  /// Formats the timestamp (milliseconds) into dd/MM/yyyy HH:mm:ss
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
   final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorProvider>(context);
    final pumpProvider = Provider.of<PumpProvider>(context);

    final moistureHistory = sensorProvider.moistureHistory;
    final pumpActivityList = pumpProvider.pumpActivityTimeline;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Soil Moisture History Chart with threshold line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Soil Moisture Graph',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    PopupMenuButton<String>(
                      onSelected: _changeTimeline,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'Minutes', child: Text('Minutes')),
                        const PopupMenuItem(
                            value: 'Hours', child: Text('Hours')),
                        const PopupMenuItem(value: 'Days', child: Text('Days')),
                        const PopupMenuItem(
                            value: 'Months', child: Text('Months')),
                      ],
                      icon: const Icon(Icons.arrow_drop_down_circle_rounded,
                          color: Colors.white),
                    ),
                    _isRefreshing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : IconButton(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            onPressed: _refreshData,
                            tooltip: 'Refresh Data',
                          ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            moistureHistory.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No sensor data available yet!',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                : _buildSoilMoistureChart(moistureHistory),
            const SizedBox(height: 16),

            // Pump Timeline Title + Table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pump Status Timings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            pumpActivityList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No pump activity data available yet!',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                : _buildPumpTimelineTable(pumpActivityList),
          ],
        ),
      ),
    );
  }

  /// Builds the soil moisture line chart with an overlay threshold line.
  Widget _buildSoilMoistureChart(List<SensorData> moistureData) {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              // Draw the threshold as a horizontal dashed red line with a label.
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: sensorProvider.moistureThreshold.toDouble(),
                    color: Colors.red,
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (_) =>
                          "Threshold: ${sensorProvider.moistureThreshold}",
                      style: const TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: moistureData.map((data) {
                    final double xValue = convertTimestamp(data.timestamp);
                    return FlSpot(xValue, data.moisture.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
              ],
              minX: minX,
              maxX: maxX,
              minY: 0,
              maxY: 1023,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Time --→',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green),
                  ),
                  axisNameSize: 20,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: _buildBottomTitle,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      'Soil Moisture (Sensor Readings) --→',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                  ),
                  axisNameSize: 20,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a professional table (DataTable) for pump timeline, displaying timestamp and pump status.
  Widget _buildPumpTimelineTable(List<PumpActivity> pumpActivityList) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text(
                  'Timestamp',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: pumpActivityList.map((activity) {
              final formattedTime = _formatTimestamp(activity.timestamp);
              return DataRow(
                cells: [
                  DataCell(Text(formattedTime)),
                  DataCell(
                    Text(
                      activity.state == 'ON' ? 'PUMP ON' : 'PUMP OFF',
                      style: TextStyle(
                          color: activity.state == 'ON'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial'),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
