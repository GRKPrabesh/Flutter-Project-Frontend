import 'package:flutter/material.dart';
import 'routes/routes.dart'; // Assuming the file containing AppRoute is named AppRoute.dart

// Use the same primary color for consistency
const Color primaryColor = Color(0xFF1E88E5);
const Color inputFillColor = Color(0xFFF0F0F0); // Slightly darker gray for better contrast

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Transparent AppBar to allow the background to show, matching modern design
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87), // Style back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            // TODO: Implement navigation back to LoginScreen
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Title
              const Text(
                'Create an Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40.0),

              // Full Name Field
              _buildTextField(
                hintText: 'Full Name',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 18.0),

              // Email Field
              _buildTextField(
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18.0),

              // Phone Number Field
              _buildTextField(
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18.0),

              // Password Field
              _buildTextField(
                hintText: 'Password',
                isPassword: true,
              ),
              const SizedBox(height: 32.0),

              // SIGN UP Button
              _buildSignupButton(),
              const SizedBox(height: 32.0),

              // Google Sign-up (reusing the style)
              _buildGoogleSignInButton(),
              const SizedBox(height: 50.0),

              // Login Prompt
              _buildLoginPrompt(context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for text fields
  Widget _buildTextField({
    required String hintText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputFillColor, // Light grey background
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          // Suffix Icon (Eye icon) for password visibility
          suffixIcon: isPassword
              ? IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.grey),
            onPressed: () {
              // TODO: Implement toggle password visibility state
            },
          )
              : null,
          border: InputBorder.none, // Removes default border
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0, vertical: 18.0),
        ),
      ),
    );
  }

  // Helper function for the main button
  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement user registration logic
        print('Sign Up button pressed');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        elevation: 5,
        shadowColor: primaryColor.withOpacity(0.4),
      ),
      child: const Text(
        'SIGN UP',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Helper function for Google sign-up
  Widget _buildGoogleSignInButton() {
    return OutlinedButton(
      onPressed: () {
        // TODO: Implement Google sign-up logic
        print('Continue with Google pressed (Sign Up)');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Ensure your asset is correctly configured in pubspec.yaml!
          Image.asset(
            'assets/images/googleLogo.png',
            height: 24.0,
            width: 24.0,
          ),
          const SizedBox(width: 12.0),
          const Text(
            'Continue with Google',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Helper function for the login prompt at the bottom
  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Already have an account?",
          style: TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: () {

            Navigator.of(context).pushReplacementNamed(AppRoute.loginPageRoute);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(0, 0),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}