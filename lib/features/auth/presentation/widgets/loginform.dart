import 'package:flutter_app_itse500/features/auth/logic/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/form_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';
import 'forgot_password_link.dart';
import 'identifier_field.dart';
import 'oauth_button.dart';
import 'login_button.dart';
import 'policy_text.dart';
import 'signup_link.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final logger = UnifiedLogger.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController identifierController = TextEditingController();
  final FocusNode identifierFocusNode = FocusNode();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
  }

  void _handleLogin() async {
    logger.i('Login button pressed');
    if (_formKey.currentState!.validate()) {
      final identifier = identifierController.text;
      final password = passwordController.text;
      try {
        // Call AuthCubit login
        context.read<AuthCubit>().login(context, identifier, password);
      } catch (e) {
        logger.e('Login failed', error: e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${AppLocalizations.of(context)!.loginFailed}: $e')),
        );
      }
    } else {
      logger.w('Login form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i('Building #LoginForm');
    // Ensure deep link listener started once when login form builds
    context.read<AuthCubit>().initDeepLinks();
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message.isNotEmpty
                    ? state.message
                    : AppLocalizations.of(context)!.loginFailed)),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          logger.i('Tapped outside input fields');
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 48, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  IdentifierField(
                      controller: identifierController,
                      focusNode: identifierFocusNode),
                  const SizedBox(height: 16),
                  PasswordField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      required:
                          false, // change later when the email verification works
                      enabled: true),
                  const SizedBox(height: 24),
                  LoginButton(
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 12),
                  // Biometric status intentionally hidden here (managed from profile only)
                  const SignupLink(),
                  const SizedBox(height: 4),
                  const ForgotPasswordLink(),
                  const SizedBox(height: 8),
                  const PolicyText(),
                  const SizedBox(height: 12),
                  // Inline divider row formatting
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(AppLocalizations.of(context)!.or),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(child: ContinueAsGuestButton()),
                  const SizedBox(height: 12),
                  OAuthButton.openRouter(),
                  const SizedBox(height: 12),
                  OAuthButton.google(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
