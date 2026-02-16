// presentation/screens/registration_screen.dart
// 
// Purpose: New user onboarding.
// Responsibility: Collects student details (Reg No, Dept, etc.) for account creation.
// Navigation: Success -> Back to SignInScreen

import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Detailed registration form for new students.
// [LABEL: REGISTRATION SCREEN] - For new student signup.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480), // max-w-[480px]
              child: Column(
                children: [
                   // Header
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
                   const SizedBox(height: 8),
                   Text(
                     'Student Registration',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       fontSize: 22,
                     ),
                   ),
                   const SizedBox(height: 4),
                   const Text(
                     'Book your hostel accommodation securely.',
                     style: TextStyle(
                       color: Color(0xFF45A1A1), // text-[#45a1a1]
                     ),
                   ),
                   const SizedBox(height: 32),

                   Form(
                     key: _formKey,
                     child: Column(
                       children: [
                         // Name Row
                         Row(
                           children: [
                             Expanded(child: _buildInput('First Name')),
                             const SizedBox(width: 16),
                             Expanded(child: _buildInput('Last Name')),
                           ],
                         ),
                         const SizedBox(height: 16),
                         _buildInput('Reg Number', hint: 'e.g. 2021/12345'),
                         const SizedBox(height: 16),
                         _buildInput('Department', hint: 'e.g. Software Engineering'),
                         const SizedBox(height: 16),
                         _buildInput('Email Address', hint: 'student@futo.edu.ng', icon: Icons.mail_outline),
                         const SizedBox(height: 16),
                         _buildInput('Phone Number', hint: '080 1234 5678', icon: Icons.phone_outlined),
                         const SizedBox(height: 16),
                         
                         // Gender Dropdown
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
                             const SizedBox(height: 8),
                             DropdownButtonFormField<String>(
                               decoration: const InputDecoration(
                                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                               ),
                               items: ['Male', 'Female', 'Other'].map((e) => 
                                 DropdownMenuItem(value: e, child: Text(e))
                               ).toList(),
                               onChanged: (v) {},
                               hint: const Text('Select Gender', style: TextStyle(color: Color(0xFF45A1A1))),
                             ),
                           ],
                         ),
                         const SizedBox(height: 16),
                         
                         // Password
                         _buildPasswordInput('Password', _obscurePassword, () {
                           setState(() => _obscurePassword = !_obscurePassword);
                         }),
                         const SizedBox(height: 16),
                         _buildPasswordInput('Confirm Password', _obscureConfirm, () {
                           setState(() => _obscureConfirm = !_obscureConfirm);
                         }),
                         
                         const SizedBox(height: 32),
                         SizedBox(
                           width: double.infinity,
                           child: ElevatedButton(
                             onPressed: () {
                               if (_formKey.currentState!.validate()) {
                                 Navigator.of(context).pop(); // Go back to Sign In
                               }
                             },
                             child: const Text('Register'),
                           ),
                         ),
                       ],
                     ),
                   ),
                   
                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Text('Already have an account? ', style: TextStyle(color: Color(0xFF45A1A1))),
                       GestureDetector(
                         onTap: () => Navigator.of(context).pop(),
                         child: const Text('Sign In', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                       ),
                     ],
                   ),
                   const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, {String? hint, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: const TextStyle(color: Color(0xFF45A1A1)),
            suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF45A1A1)) : null,
          ),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildPasswordInput(String label, bool obscure, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: label.contains('Confirm') ? 'Confirm password' : 'Create password',
            hintStyle: const TextStyle(color: Color(0xFF45A1A1)),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF45A1A1),
              ),
              onPressed: toggle,
            ),
          ),
           validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
