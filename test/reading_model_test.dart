import 'package:flutter_test/flutter_test.dart';
import 'package:wattx/models/reading_model.dart';

void main() {
  group('ReadingModel.fromMap', () {
    test('parses millisecond timestamps correctly', () {
      final reading = ReadingModel.fromMap({
        'power': 1.42,
        'voltage': 231.5,
        'current': 6.14,
        'timestamp': 1741180320000,
      });

      expect(reading.power, 1.42);
      expect(reading.voltage, 231.5);
      expect(reading.current, 6.14);
      expect(
        reading.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1741180320000),
      );
    });

    test('treats small integer timestamps as seconds', () {
      final reading = ReadingModel.fromMap({
        'power': 1.0,
        'voltage': 230.0,
        'current': 4.3,
        'timestamp': 1741180320,
      });

      expect(
        reading.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1741180320 * 1000),
      );
    });

    test('uses defaults when values are missing', () {
      final reading = ReadingModel.fromMap({
        'timestamp': 1741180320000,
      });

      expect(reading.power, 0.0);
      expect(reading.voltage, 0.0);
      expect(reading.current, 0.0);
    });
  });

  test('ReadingModel.toMap serializes values back to a map', () {
    final reading = ReadingModel(
      power: 0.75,
      voltage: 229.0,
      current: 3.2,
      timestamp: DateTime.fromMillisecondsSinceEpoch(1741180320000),
    );

    expect(reading.toMap(), {
      'power': 0.75,
      'voltage': 229.0,
      'current': 3.2,
      'timestamp': 1741180320000,
    });
  });
}