import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go('/forgot-password');
      },
      child: const Text('Forgot Password?',
          style: TextStyle(color: Colors.blue), textAlign: TextAlign.center),
    );
  }
}
