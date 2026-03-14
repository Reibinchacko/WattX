import 'package:flutter_test/flutter_test.dart';
import 'package:wattx/services/database_service.dart';

void main() {
  group('DatabaseService', () {
    test('toggleDevice throws FormatException for unsupported keys', () async {
      final service = DatabaseService();
      
      expect(
        () async => await service.toggleDevice('METER001', 'Invalid Device', true),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
