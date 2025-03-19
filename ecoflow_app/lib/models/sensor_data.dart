class SensorData {
  final int moisture;
  final int timestamp;

  SensorData({required this.moisture, required this.timestamp});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      moisture: json['moisture'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moisture': moisture,
      'timestamp': timestamp,
    };
  }
}
