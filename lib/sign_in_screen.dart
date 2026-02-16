// presentation/screens/sign_in_screen.dart
// 
// Purpose: Authentication entry point.
// Responsibility: Allows existing students to log in using their credentials.
// Navigation: Login -> MainScreen | "Sign Up" -> RegistrationScreen

import 'package:flutter/material.dart';
import 'package:hostel_reservation/screens/home_screen.dart';
import 'app_theme.dart';
import 'registration_screen.dart';

/// Primary login interface for the hostel reservation system.
// [LABEL: SIGN IN SCREEN] - Handles user authentication.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450), // max-w-md
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/futo_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Hostel Reservation',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24, // text-3xl usually larger but Flutter scale differs
                      color: isDark ? Colors.white : const Color(0xFF0F172A), // slate-900
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your accommodation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, // slate-500
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Reg Number
                        Text(
                          'Reg Number',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade200 : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'e.g., 2018/123456',
                          ),
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade200 : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Button
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // iOS home indicator simulation
                  Container(
                    width: 100, // w-1/3 roughly
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
