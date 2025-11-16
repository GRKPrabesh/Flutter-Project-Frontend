import 'package:flutter/material.dart';
import 'routes.dart';
import 'dashboard_org.dart';

const Color primaryColor = Color(0xFF1E88E5);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Welcome to Protego',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 48.0),
              _buildTextField(
                hintText: 'Email',
                icon: Icons.email_outlined,
                controller: emailController,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                hintText: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: passwordController,
              ),
              const SizedBox(height: 24.0),
              _buildLoginButton(context, emailController),
              const SizedBox(height: 12.0),
              Center(
                child: TextButton(
                  onPressed: () {
                    print('Forgot password tapped');
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              _buildGoogleSignInButton(),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoute.roleSelectRoute);
                    },
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: isPassword
              ? IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.grey),
            onPressed: () {
              // TODO: Implement toggle password visibility
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 16.0),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, TextEditingController emailController) {
    return ElevatedButton(
      onPressed: () {
        // Derive organization/name from login credential (email before '@' as a simple stand-in)
        final email = emailController.text.trim();
        final displayName = email.isEmpty ? 'there' : (email.contains('@') ? email.split('@').first : email);
        // Navigate to Organization Dashboard with welcome name
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrganizationDashboardPage(displayName: displayName),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        elevation: 5,
      ),
      child: const Text(
        'LOGIN',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return OutlinedButton(
      onPressed: () {
        print('Continue with Google pressed');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/googleLogo.png', // Path to your Google logo image
            height: 24.0, // Adjust height as needed
            width: 24.0,  // Adjust width as needed
          ),
          const SizedBox(width: 8.0),
          const Text(
            'Continue with Google',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}