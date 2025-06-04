import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      print('[LOGIN] Iniciando login con backend');
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('[LOGIN] Código de respuesta: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('[LOGIN] Login exitoso');
        return jsonDecode(response.body);
      } else {
        print('[LOGIN] Falló el login. Cuerpo: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[LOGIN] Error en login: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('[GOOGLE] Iniciando signInWithGoogle');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('[GOOGLE] Usuario canceló el inicio de sesión');
        return null;
      }

      print('[GOOGLE] Usuario seleccionado: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('[GOOGLE] Token obtenido correctamente');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('[GOOGLE] Autenticando en Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        print('[GOOGLE] Autenticación exitosa con Firebase: ${user.email}');
        return {
          "name": user.displayName ?? "Usuario Google",
          "token": await user.getIdToken(),
        };
      } else {
        print('[GOOGLE] El usuario es null después de Firebase');
        return null;
      }
    } catch (e) {
      print('[GOOGLE] Error en Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    print('[SIGNOUT] Cerrando sesión de Google y Firebase');
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    print('[SIGNOUT] Sesión cerrada');
  }
}
