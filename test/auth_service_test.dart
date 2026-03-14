import 'package:flutter_test/flutter_test.dart';
import 'package:wattx/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('signIn rejects invalid email format before calling Firebase', () async {
      final service = AuthService();

      expect(
        () async => await service.signIn(email: 'invalid-email', password: 'password123'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
