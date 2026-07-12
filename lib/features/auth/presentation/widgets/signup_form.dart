import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/features/auth/presentation/widgets/policy_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

import '../../../../core/utils/form_helpers.dart';
import '../../logic/auth_cubit.dart';
import 'signup_button.dart';
import 'oauth_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final logger = UnifiedLogger.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      final username = usernameController.text;
      final email = emailController.text;
      final pw = passwordController.text;
      if (pw.isEmpty || pw.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context)!.passwordMinLength)));
        return;
      }
      context
          .read<AuthCubit>()
          .signUp(username: username, email: email, userId: '', password: pw);
    } else {
      logger.w('Signup form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message.isNotEmpty
                    ? state.message
                    : AppLocalizations.of(context)!.registrationFailed)),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  UserNameField(
                    controller: usernameController,
                    focusNode: usernameFocusNode,
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  EmailField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    enabled: true,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password),
                    validator: (v) => (v == null || v.isEmpty)
                        ? AppLocalizations.of(context)!.enterPassword
                        : null,
                  ),
                  const SizedBox(height: 24),
                  SignUpButton(
                    onPressed: _handleSignUp,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(AppLocalizations.of(context)!.orContinueWith),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // OAuth buttons moved below primary signup
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4),
                    child: OAuthButton.openRouter(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4),
                    child: OAuthButton.google(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.alreadyHaveAccountQuestion,
                          style: Theme.of(context).textTheme.bodyLarge),
                      GestureDetector(
                        onTap: () => GoRouter.of(context).pushNamed('login'),
                        child: Text(AppLocalizations.of(context)!.signIn,
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const PolicyText(),
                  const SizedBox(height: 8),
                  const SizedBox(child: ContinueAsGuestButton()),
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
