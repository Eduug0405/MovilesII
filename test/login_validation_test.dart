import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eshop/screens/login_screen.dart';

void main() {
  testWidgets(
    'Muestra mensaje de error cuando los campos están vacíos',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('Por favor completa todos los campos.'), findsNothing);
      final loginButton = find.text('Iniciar sesión');
      expect(loginButton, findsOneWidget);           
      await tester.tap(loginButton);
      await tester.pump();                           

      expect(find.text('Por favor completa todos los campos.'), findsOneWidget);
    },
  );
}
