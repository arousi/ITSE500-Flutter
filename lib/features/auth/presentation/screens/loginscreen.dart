import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';

import '../widgets/loginform.dart';

class LoginScreen extends StatefulWidget {
  // convert to stateful make it listen to states
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final logger = UnifiedLogger.instance;
  @override
  Widget build(BuildContext context) {
    logger.i('Building LoginScreen'); // No sensitive data
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(
        minimum: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}
