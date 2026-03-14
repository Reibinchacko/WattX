import 'package:flutter_test/flutter_test.dart';
import 'package:wattx/models/alert_model.dart';

void main() {
  group('AlertModel.fromMap', () {
    test('parses alert fields correctly', () {
      final alert = AlertModel.fromMap('alert-1', {
        'title': 'Power Overage',
        'message': 'Usage exceeded threshold.',
        'type': 'critical',
        'timestamp': 1741180320000,
        'isRead': true,
      });

      expect(alert.alertId, 'alert-1');
      expect(alert.title, 'Power Overage');
      expect(alert.message, 'Usage exceeded threshold.');
      expect(alert.type, 'critical');
      expect(alert.isRead, isTrue);
      expect(
        alert.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1741180320000),
      );
    });

    test('falls back to info type and unread state by default', () {
      final alert = AlertModel.fromMap('alert-2', {
        'title': 'Info',
        'message': 'No timestamp provided.',
      });

      expect(alert.type, 'info');
      expect(alert.isRead, isFalse);
    });
  });

  test('AlertModel.toMap serializes alert fields', () {
    final alert = AlertModel(
      alertId: 'alert-3',
      title: 'Bill Milestone',
      message: 'Estimated bill crossed limit.',
      type: 'warning',
      timestamp: DateTime.fromMillisecondsSinceEpoch(1741180320000),
      isRead: false,
    );

    expect(alert.toMap(), {
      'title': 'Bill Milestone',
      'message': 'Estimated bill crossed limit.',
      'type': 'warning',
      'timestamp': 1741180320000,
      'isRead': false,
    });
  });
}