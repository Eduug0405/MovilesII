import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService  = AuthService();

  String _error   = '';
  bool   _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    final user = await _authService.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (user != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user['token']);
      await prefs.setString('name',  user['name']);
      Navigator.pushReplacementNamed(context, '/products', arguments: {
        'name': user['name'],
      });
    } else {
      setState(() => _error = 'Usuario o contraseña incorrectos');
    }
    setState(() => _loading = false);
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);

    final user = await _authService.signInWithGoogle();

    if (user != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user['token']);
      await prefs.setString('name',  user['name']);
      Navigator.pushReplacementNamed(context, '/products', arguments: {
        'name': user['name'],
      });
    } else {
      setState(() => _error = 'Falló el inicio con Google');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFDCF1DC)],
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(Icons.spa_outlined, size: 96, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text('E-Shop',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  )),

              const SizedBox(height: 32),


              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 28),

                
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Iniciar sesión'),
                        ),
                      ),

                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(_error, style: const TextStyle(color: Colors.red)),
                      ],

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('ó', style: theme.textTheme.labelMedium),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _loginWithGoogle,
                          icon: const Icon(Icons.g_mobiledata_outlined, size: 28, color: Colors.red),
                          label: const Text('Iniciar sesión con Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text('“Todo en un solo lugar”',
                  style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}
