import 'package:flutter/material.dart';
import '../widgets/forgot_password_enter_code_form.dart';

class ConfirmPasswordScreen extends StatelessWidget {
  const ConfirmPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final newPasswordFocusNode = FocusNode();
    final confirmPasswordFocusNode = FocusNode();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ForgotPasswordEnterCodeForm(
            formKey: formKey,
            codeController: codeController,
            newPasswordController: newPasswordController,
            newPasswordFocusNode: newPasswordFocusNode,
            confirmPasswordController: confirmPasswordController,
            confirmPasswordFocusNode: confirmPasswordFocusNode,
            onResetPassword: () {}, // wiring added later
          ),
        ),
      ),
    );
  }
}
