class ReadingModel {
  final double power;
  final double voltage;
  final double current;
  final DateTime timestamp;

  ReadingModel({
    required this.power,
    required this.voltage,
    required this.current,
    required this.timestamp,
  });

  factory ReadingModel.fromMap(Map<dynamic, dynamic> map) {
    dynamic rawTimestamp = map['timestamp'];
    DateTime parsedTime;

    if (rawTimestamp == null) {
      parsedTime = DateTime.now();
    } else if (rawTimestamp is int) {
      // IoT devices might send seconds or milliseconds
      // If it's less than 10,000,000,000 it's likely seconds
      if (rawTimestamp < 10000000000) {
        parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTimestamp * 1000);
      } else {
        parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
      }
    } else {
      parsedTime = DateTime.now();
    }

    return ReadingModel(
      power: (map['power'] ?? 0.0).toDouble(),
      voltage: (map['voltage'] ?? 0.0).toDouble(),
      current: (map['current'] ?? 0.0).toDouble(),
      timestamp: parsedTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'power': power,
      'voltage': voltage,
      'current': current,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
