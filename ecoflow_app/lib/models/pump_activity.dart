class PumpActivity {
  final String state;  // "ON" or "OFF"
  final int timestamp;

  PumpActivity({required this.state, required this.timestamp});

  factory PumpActivity.fromJson(Map<String, dynamic> json) {
    return PumpActivity(
      state: json['state'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'timestamp': timestamp,
    };
  }
}