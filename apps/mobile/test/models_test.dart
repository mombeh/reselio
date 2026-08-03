import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/auth_response.dart';

void main() {
  group('User', () {
    test('creates instance from JSON with _id', () {
      final json = {
        '_id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'customer',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.role, 'customer');
    });

    test('creates instance from JSON with id', () {
      final json = {
        'id': '456',
        'name': 'Jane Doe',
        'email': 'jane@example.com',
        'role': 'client',
      };

      final user = User.fromJson(json);

      expect(user.id, '456');
      expect(user.name, 'Jane Doe');
      expect(user.email, 'jane@example.com');
      expect(user.role, 'client');
    });

    test('converts to JSON', () {
      final user = User(
        id: '789',
        name: 'Test User',
        email: 'test@example.com',
        role: 'admin',
      );

      final json = user.toJson();

      expect(json['id'], '789');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['role'], 'admin');
    });
  });

  group('AuthResponse', () {
    test('creates instance from JSON', () {
      final json = {
        'access_token': 'test-token-123',
        'user': {
          '_id': '123',
          'name': 'John Doe',
          'email': 'john@example.com',
          'role': 'customer',
        },
      };

      final response = AuthResponse.fromJson(json);

      expect(response.accessToken, 'test-token-123');
      expect(response.user.id, '123');
      expect(response.user.name, 'John Doe');
      expect(response.user.email, 'john@example.com');
      expect(response.user.role, 'customer');
    });
  });
}
