import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/logic/auth_cubit.dart';

// Controllers for form fields.

final TextEditingController usernameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();
final FocusNode usernameFocusNode = FocusNode();
final FocusNode emailFocusNode = FocusNode();
final FocusNode passwordFocusNode = FocusNode();
final FocusNode confirmPasswordFocusNode = FocusNode();

void disposeFormHelpers() {
  usernameController.dispose();
  emailController.dispose();
  passwordController.dispose();
  confirmPasswordController.dispose();
  usernameFocusNode.dispose();
  emailFocusNode.dispose();
  passwordFocusNode.dispose();
  confirmPasswordFocusNode.dispose(); // No sensitive data
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your email';
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your password';
  if (value.length < 6) return 'Password must be at least 6 characters long';
  return null;
}

String? validateConfirmPassword(
    String? value, TextEditingController passwordController) {
  if (value == null || value.isEmpty) return 'Please confirm your password';
  if (value != passwordController.text) return 'Passwords do not match';
  return null;
}

// Clean reusable form fields for login/signup

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration? decoration;

  const EmailField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.decoration,
    required bool enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration ??
          const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
      validator: validateEmail,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool required;
  const PasswordField(
      {super.key,
      required this.controller,
      required this.focusNode,
      this.required = true,
      required bool enabled});
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        // borders/fill from theme
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      obscureText: _obscureText,
      validator: widget.required ? validatePassword : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

class ConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextEditingController passwordController;
  const ConfirmPasswordField(
      {super.key,
      required this.controller,
      required this.focusNode,
      required this.passwordController});
  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outline),
        // borders/fill from theme
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      obscureText: _obscureText,
      validator: (value) =>
          validateConfirmPassword(value, widget.passwordController),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

class UserNameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration? decoration;

  const UserNameField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.decoration,
    required bool enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration ??
          const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
          ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        if (value.length < 3) {
          return 'Username must be at least 3 characters';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
    );
  }
}

/// Reusable button widget for guest login
class ContinueAsGuestButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final IconData icon;
  const ContinueAsGuestButton({
    super.key,
    this.label = 'CONTINUE AS GUEST',
    this.backgroundColor = const Color(0xFF616161),
    this.icon = Icons.mic,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        onPressed: () async {
          context.read<AuthCubit>().continueAsGuest(context);
        },
      ),
    );
  }
}

/// Reusable privacy policy text widget
class PrivacyPolicyText extends StatelessWidget {
  const PrivacyPolicyText({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'By Continuing you adhere to Privacy Policy and Terms of Service',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

/// Reusable confirmation code row widget
// ConfirmationCodeRow replaced by OtpPinput widget in core/widgets/otp_pinput.dart
