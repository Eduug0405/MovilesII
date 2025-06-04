import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final authService = AuthService();

  String error = '';
  bool isLoading = false;

  void _login() async {
    setState(() => isLoading = true);

    final userData = await authService.login(usernameCtrl.text, passwordCtrl.text);

    if (userData != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userData['token']);
      await prefs.setString('name', userData['name']);
      Navigator.pushReplacementNamed(context, '/products', arguments: {"name": userData['name']});
    } else {
      setState(() => error = 'Usuario o contraseña incorrectos');
    }

    setState(() => isLoading = false);
  }

  void _loginWithGoogle() async {
    setState(() => isLoading = true);

    final userData = await authService.signInWithGoogle();

    if (userData != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userData['token']);
      await prefs.setString('name', userData['name']);
      Navigator.pushReplacementNamed(context, '/products', arguments: {"name": userData['name']});
    } else {
      setState(() => error = 'Falló el inicio con Google');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Usuario')),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading ? const CircularProgressIndicator() : const Text("Iniciar sesión"),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: Image.asset('assets/google_logo.png', height: 20),
              label: const Text("Iniciar con Google"),
              onPressed: isLoading ? null : _loginWithGoogle,
            ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
    );
  }
}
