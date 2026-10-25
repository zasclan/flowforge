import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = _isLogin
        ? await auth.login(_email.text.trim(), _password.text)
        : await auth.register(
            _email.text.trim(), _password.text, _name.text.trim());
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? 'Authentication failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              color: const Color(0xff2563eb),
                              borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.account_tree_rounded,
                              color: Colors.white, size: 34),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('FlowForge',
                          style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Color(0xff0f172a))),
                      Text(
                          _isLogin
                              ? 'Sign in to continue your execution plan.'
                              : 'Create a private, synchronized workspace.',
                          style: const TextStyle(
                              color: Color(0xff64748b), fontSize: 15)),
                      const SizedBox(height: 28),
                      if (!_isLogin) ...[
                        TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.person_outline_rounded)),
                            validator: (value) =>
                                value == null || value.trim().length < 2
                                    ? 'Enter your name.'
                                    : null),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded)),
                          validator: (value) =>
                              value != null && value.contains('@')
                                  ? null
                                  : 'Enter a valid email.'),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline_rounded)),
                          validator: (value) =>
                              value != null && value.length >= 6
                                  ? null
                                  : 'Use at least 6 characters.'),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : Text(_isLogin ? 'Sign in' : 'Create account'),
                        ),
                      ),
                      TextButton(
                          onPressed: auth.isLoading
                              ? null
                              : () => setState(() => _isLogin = !_isLogin),
                          child: Text(_isLogin
                              ? 'New here? Create an account'
                              : 'Already have an account? Sign in')),
                      const SizedBox(height: 14),
                      const Text(
                          'Per-user access is enforced by Firestore security rules.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: Color(0xff94a3b8))),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
