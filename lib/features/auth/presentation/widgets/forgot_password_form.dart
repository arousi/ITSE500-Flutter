import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'forgot_password_request_form.dart';
import 'forgot_password_enter_code_form.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

enum ForgotPasswordStep { requestCode, enterCode }

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final logger = UnifiedLogger.instance;
  ForgotPasswordStep step = ForgotPasswordStep.requestCode;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final TextEditingController emailOrPhoneController = TextEditingController();
  final FocusNode emailOrPhoneFocusNode = FocusNode();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final FocusNode newPasswordFocusNode = FocusNode();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    usernameController.dispose();
    usernameFocusNode.dispose();
    emailOrPhoneController.dispose();
    emailOrPhoneFocusNode.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordController.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void submitRequestCode() {
    logger.i('Requesting confirmation code');
    // Call API to send confirmation code to email
    // Api: requestEmailPin(email)
    setState(() {
      step = ForgotPasswordStep.enterCode;
    });
  }

  void submitResetPassword() {
    logger.i('Submitting confirmation code and new password');
    // Api: verifyEmailPin(email, code) then setPasswordAfterEmailVerify(email, newPassword)
    // On success, navigate to login or show success message
    context.go('/login');
  }

  Widget buildRequestCodeForm(BuildContext context) {
    return ForgotPasswordRequestForm(
      formKey: _formKey,
      usernameController: usernameController,
      usernameFocusNode: usernameFocusNode,
      emailOrPhoneController: emailOrPhoneController,
      emailOrPhoneFocusNode: emailOrPhoneFocusNode,
      onContinue: () {
        if (_formKey.currentState?.validate() ?? false) {
          submitRequestCode();
        }
      },
    );
  }

  Widget buildEnterCodeForm(BuildContext context) {
    return ForgotPasswordEnterCodeForm(
      formKey: _formKey,
      codeController: codeController,
      newPasswordController: newPasswordController,
      newPasswordFocusNode: newPasswordFocusNode,
      confirmPasswordController: confirmPasswordController,
      confirmPasswordFocusNode: confirmPasswordFocusNode,
      onResetPassword: () {
        if (_formKey.currentState?.validate() ?? false) {
          submitResetPassword();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: step == ForgotPasswordStep.requestCode
            ? buildRequestCodeForm(context)
            : buildEnterCodeForm(context),
      ),
    );
  }
}
