import 'package:flutter_test/flutter_test.dart';
import 'package:eshop/services/auth_service.dart';

void main() {
  group('AuthService Test', () {
    final authService = AuthService();

    test('Login should return user data with valid credentials', () async {
      const username = 'testuser';
      const password = 'testpassword';

      final result = await authService.login(username, password);

      expect(result, isA<Map<String, dynamic>>());
      expect(result, contains('token'));
      expect(result, contains('name'));
    });

    test('Login should fail with invalid credentials', () async {
      const wrongUsername = 'wronguser';
      const wrongPassword = 'wrongpassword';

      final result = await authService.login(wrongUsername, wrongPassword);

      expect(result, isNull);
    });
  });
}
