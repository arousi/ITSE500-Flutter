import 'package:flutter/material.dart';
import '../../../../core/utils/form_helpers.dart';
import '../../../../core/widgets/otp_pinput.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class ForgotPasswordEnterCodeForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final TextEditingController newPasswordController;
  final FocusNode newPasswordFocusNode;
  final TextEditingController confirmPasswordController;
  final FocusNode confirmPasswordFocusNode;
  final VoidCallback onResetPassword;
  const ForgotPasswordEnterCodeForm({
    super.key,
    required this.formKey,
    required this.codeController,
    required this.newPasswordController,
    required this.newPasswordFocusNode,
    required this.confirmPasswordController,
    required this.confirmPasswordFocusNode,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        Text(l10n.confirmationCode,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        OtpPinput(
          controller: codeController,
          length: 5,
        ),
        const SizedBox(height: 24),
        PasswordField(
            controller: newPasswordController,
            focusNode: newPasswordFocusNode,
            required: true,
            enabled: true),
        const SizedBox(height: 16),
        ConfirmPasswordField(
          controller: confirmPasswordController,
          focusNode: confirmPasswordFocusNode,
          passwordController: newPasswordController,
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
          onPressed: onResetPassword,
          child: Text(l10n.resetPasswordButton,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
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
