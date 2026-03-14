import 'package:flutter_test/flutter_test.dart';
import 'package:wattx/models/user_model.dart';

void main() {
  group('UserModel.fromMap', () {
    test('builds a complete user model from map data', () {
      final user = UserModel.fromMap('uid-1', {
        'name': 'Rahul Kumar',
        'email': 'rahul@gmail.com',
        'role': 'user',
        'phoneNumber': '9999999999',
        'address': 'Kanjirappally',
        'profileImageUrl': 'https://example.com/profile.png',
        'budgetLimit': 1500.0,
        'isActive': true,
        'createdAt': 1741180320000,
      });

      expect(user.uid, 'uid-1');
      expect(user.name, 'Rahul Kumar');
      expect(user.email, 'rahul@gmail.com');
      expect(user.role, 'user');
      expect(user.phoneNumber, '9999999999');
      expect(user.address, 'Kanjirappally');
      expect(user.profileImageUrl, 'https://example.com/profile.png');
      expect(user.budgetLimit, 1500.0);
      expect(user.isActive, isTrue);
      expect(
        user.createdAt,
        DateTime.fromMillisecondsSinceEpoch(1741180320000),
      );
    });

    test('uses defaults for optional and omitted values', () {
      final user = UserModel.fromMap('uid-2', {
        'name': 'Test',
        'email': 't@t.com',
      });

      expect(user.role, 'user');
      expect(user.phoneNumber, isNull);
      expect(user.address, isNull);
      expect(user.profileImageUrl, isNull);
      expect(user.budgetLimit, 100.0);
      expect(user.isActive, isTrue);
      expect(user.createdAt, isNull);
    });
  });

  test('UserModel.toMap serializes model fields', () {
    final user = UserModel(
      uid: 'uid-3',
      name: 'Anu',
      email: 'anu@gmail.com',
      role: 'admin',
      budgetLimit: 500.0,
      isActive: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1741180320000),
    );

    expect(user.toMap(), {
      'name': 'Anu',
      'email': 'anu@gmail.com',
      'role': 'admin',
      'phoneNumber': null,
      'address': null,
      'profileImageUrl': null,
      'budgetLimit': 500.0,
      'isActive': false,
      'createdAt': 1741180320000,
    });
  });
}