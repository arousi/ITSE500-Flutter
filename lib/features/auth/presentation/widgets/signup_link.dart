import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupLink extends StatelessWidget {
  const SignupLink({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('New user? ', style: Theme.of(context).textTheme.bodyLarge),
        GestureDetector(
          onTap: () => GoRouter.of(context).go('/signup'),
          child: const Text('Signup',
              style:
                  TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
