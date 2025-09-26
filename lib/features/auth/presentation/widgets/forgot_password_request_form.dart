import 'package:flutter/material.dart';
import '../../../../core/utils/form_helpers.dart';

class ForgotPasswordRequestForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final FocusNode usernameFocusNode;
  final TextEditingController emailOrPhoneController;
  final FocusNode emailOrPhoneFocusNode;
  final VoidCallback onContinue;
  const ForgotPasswordRequestForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.usernameFocusNode,
    required this.emailOrPhoneController,
    required this.emailOrPhoneFocusNode,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 48, color: Colors.white70),
        ),
        const SizedBox(height: 32),
        UserNameField(
          controller: usernameController,
          focusNode: usernameFocusNode,
          enabled: true,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        EmailField(
          controller: emailOrPhoneController,
          focusNode: emailOrPhoneFocusNode,
          enabled: true,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onContinue,
          child: const Text('CONTINUE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 24),
        const PrivacyPolicyText(),
        const SizedBox(height: 16),
        const ContinueAsGuestButton(),
        const SizedBox(height: 24),
      ],
    );
  }
}
