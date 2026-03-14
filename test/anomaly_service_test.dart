import 'package:flutter_test/flutter_test.dart';
import 'package:wattx/services/anomaly_service.dart';

void main() {
  group('AnomalyService.detectAnomaly', () {
    test('detects critical anomaly for 300% deviation', () {
      final result = AnomalyService.detectAnomaly(4.0, 1.0);
      expect(result, 'critical');
    });

    test('detects efficient anomaly for -50% deviation', () {
      final result = AnomalyService.detectAnomaly(0.5, 1.0);
      expect(result, 'efficient');
    });

    test('returns normal safely when baseline is 0 (division by zero safety)', () {
      final result = AnomalyService.detectAnomaly(1.0, 0.0);
      expect(result, 'normal');
    });
  });
}
