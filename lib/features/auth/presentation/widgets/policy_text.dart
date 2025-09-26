import 'package:flutter/material.dart';

class PolicyText extends StatelessWidget {
  const PolicyText({super.key});
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
