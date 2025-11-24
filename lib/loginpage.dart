import 'package:flutter/material.dart';
import 'api/auth_api.dart';
import 'api/auth_state.dart';
import 'admin_dashboard.dart';
import 'dashboard_org.dart';
import 'dashboard_user.dart';
import 'routes.dart';

const Color primaryColor = Color(0xFF1E88E5);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authApi = AuthApi();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Protego Security',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Secure your premises with the best guards and organizations.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                _buildLoginCard(context),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoute.roleSelectRoute),
                    child: const Text(
                      "Don't have an account? Create one",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Login to continue protecting what matters most.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Email or username',
              hintText: 'e.g. admin or you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Password',
              hintText: '••••••••',
              controller: _passwordController,
              isPassword: true,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter password' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: Image.asset('assets/images/googleLogo.png', height: 20),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && _obscurePassword,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // Always go through API to get proper token (including admin)
      final resp = await _authApi.login(email: email, password: password);
      setState(() => _isLoading = false);

      final status = resp['status'] as int? ?? 0;
      final body = (resp['body'] as Map<String, dynamic>? ?? {});
      if (status < 200 || status >= 300) {
        final msg = body['message']?.toString() ?? 'Invalid credentials';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
        return;
      }

      final role = body['role']?.toString() ?? '';
      // Token and email are already stored in AuthState by AuthApi.login

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoute.adminDashboardRoute);
      } else if (role == 'org') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OrganizationDashboardPage(displayName: email.split('@').first),
          ),
        );
      } else {
        // default to seeker / normal user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                UserDashboardPage(displayName: email.split('@').first),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }
}