import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/features/profile/logic/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/profile_form.dart';
import '../widgets/authentication_options.dart';
import '../widgets/api_key_section.dart';
import '../widgets/storage_options_card.dart';
import '../widgets/model_routing_priority_card.dart';
import '../../logic/profile_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../chat/logic/chat_cubit.dart';
import '../widgets/profile_bottom_actions.dart';
import '../../../../shared_preferences.dart';
import '../../../../core/widgets/privacy_toggle.dart';
import 'package:flutter_app_itse500/features/auth/presentation/widgets/signup_form.dart';
import 'package:flutter_app_itse500/features/auth/logic/auth_cubit.dart';
import '../../../../core/widgets/otp_pinput.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
// Removed ApiKeySection & AuthenticationOptions in refactored visitor/unverified views
// import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _storageOption = 'mixed';
  final _prefs = SharedPref();
  bool _isAuthenticated = false; // true for ProfileLoaded/ProfileVerified
  String _lastUsername = '';
  Map<String, String> get _providerApiKeys =>
      context.watch<ChatCubit>().providerApiKeys;
  Map<String, List<String>> get _providerLLMs =>
      context.watch<ChatCubit>().providerLLMs;
  Map<String, List<String>> get _selectedProviderLLMs =>
      context.watch<ChatCubit>().selectedProviderLLMs;
  Map<String, bool> get _providerConnected =>
      context.watch<ChatCubit>().providerConnected;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController usernameController;
  late final TextEditingController serverUuidController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController verificationCodeController;
  late final TextEditingController phoneController;
  late final FocusNode usernameFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    serverUuidController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    verificationCodeController = TextEditingController();
    phoneController = TextEditingController();
    usernameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    // Auto-update profile when username loses focus (only for authenticated users)
    usernameFocusNode.addListener(() {
      if (!usernameFocusNode.hasFocus && _isAuthenticated) {
        final current = usernameController.text.trim();
        if (current.isNotEmpty && current != _lastUsername) {
          _lastUsername = current;
          try {
            context.read<ProfileCubit>().updateProfile(
                  current,
                  emailController.text,
                  passwordController.text,
                );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile update requested.')),
              );
            }
          } catch (_) {}
        }
      }
    });
    // Load stored storage mode (default to local) and prefill username with visitor ids
    _prefs.getString('storage_mode').then((v) {
      if (!mounted) return;
      setState(
          () => _storageOption = (v == 'mixed' || v == 'local') ? v! : 'local');
    });
    () async {
      final server = await _prefs.getString('visitor_server_uuid');
      final local = await _prefs.getString('visitor_local_id');
      final shown =
          (server != null && server.isNotEmpty) ? server : (local ?? '');
      if (shown.isNotEmpty) {
        usernameController.text = shown;
        _lastUsername = shown;
      }
      if (server != null && server.isNotEmpty) {
        serverUuidController.text = server;
      }
    }();
    // No need to initialize, values are read from ChatCubit
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    serverUuidController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    verificationCodeController.dispose();
    phoneController.dispose();
    usernameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openVerifyEmailDialog({required bool isReset}) async {
    final profileCubit = context.read<ProfileCubit>();
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter email first')));
      return;
    }
    verificationCodeController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          bool verified =
              isReset; // password fields unlocked immediately for reset
          bool verifying = false; // waiting for server
          final otpController = TextEditingController();
          final otpKey = GlobalKey<OtpPinputState>();
          return StatefulBuilder(builder: (ctx, setStateDialog) {
            Future<void> attemptPasswordSetIfProvided() async {
              final pw = passwordController.text.trim();
              final cpw = confirmPasswordController.text.trim();
              if (pw.isNotEmpty) {
                if (pw != cpw) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')));
                  return;
                }
                final hashed = sha256.convert(utf8.encode(pw)).toString();
                final ok =
                    await profileCubit.setPasswordAfterVerify(email, hashed);
                if (ok) {
                  if (mounted) {
                    profileCubit.loadProfile();
                    Navigator.of(ctx).pop();
                  }
                }
              } else {
                if (mounted) {
                  profileCubit.loadProfile();
                  Navigator.of(ctx).pop();
                }
              }
            }

            void submitCode(String code) async {
              if (code.length != 5 || verifying || verified) return;
              setStateDialog(() => verifying = true);
              await profileCubit.verifyEmail(email: email, pin: code);
            }

            return BlocListener<ProfileCubit, ProfileState>(
              listener: (context, pState) {
                if (!isReset &&
                    pState is ProfileLoaded &&
                    pState.emailVerified &&
                    !verified) {
                  setStateDialog(() {
                    verified = true;
                    verifying = false;
                  });
                  otpKey.currentState?.showSuccess();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email verified')));
                } else if (!isReset && pState is ProfileError && verifying) {
                  setStateDialog(() {
                    verifying = false;
                    verified = false;
                  });
                  otpKey.currentState?.showError();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Verification failed, try again')));
                }
              },
              child: AlertDialog(
                title: Text(isReset ? 'Reset Password' : 'Verify Email'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      // Always show PIN input; disabled when resetting password (bypassed)
                      const Text('Confirmation Code'),
                      const SizedBox(height: 8),
                      OtpPinput(
                        key: otpKey,
                        controller: otpController,
                        length: 5,
                        enabled: !isReset && !verified && !verifying,
                        onCompleted: submitCode,
                      ),
                      if (!isReset && verifying)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      if (isReset)
                        const Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: Text(
                              'PIN entry is disabled for password reset (bypassed).'),
                        ),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: verified ? 1.0 : 0.4,
                        child: IgnorePointer(
                          ignoring: !verified,
                          child: Column(
                            children: [
                              if (!isReset) ...[
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Password (optional)'),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: confirmPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Confirm Password'),
                                ),
                              ] else ...[
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'New Password'),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: confirmPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Confirm New Password'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (!isReset && !verified)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(verifying
                              ? 'Verifying code...'
                              : 'Enter the 5-digit code sent to your email. Password fields unlock after verification.'),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  if (verified)
                    TextButton(
                      onPressed: () async {
                        await attemptPasswordSetIfProvided();
                      },
                      child: Text(isReset ? 'Reset' : 'Save'),
                    ),
                ],
              ),
            );
          });
        });
  }

  // LM Studio handling now occurs inside unified ApiKeySection (ProviderConfigBlock)

  void _showConfigureDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempStorageOption = _storageOption;
        Map<String, String> tempApiKeys = Map.from(_providerApiKeys);
        Map<String, List<String>> tempSelectedLLMs =
            Map.from(_selectedProviderLLMs);
        return AlertDialog(
          title: const Text('Configure Profile'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Storage Option:'),
                const SizedBox(height: 6),
                PrivacyToggle(
                  onChanged: (m) {
                    setState(() => tempStorageOption = m);
                  },
                  labelPadding: const EdgeInsets.only(bottom: 8),
                ),
                if (tempStorageOption == 'local') ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.lock, size: 16, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(
                      'In-Private Mode: Conversations stay on-device and are not synced to the server.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    )),
                  ]),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                    ),
                    child: const Text(
                        'Switch to Mixed storage anytime to enable future sync for new conversations (existing local-only ones remain private).',
                        style: TextStyle(fontSize: 11)),
                  ),
                ],
                const SizedBox(height: 12),
                ...tempApiKeys.keys.map((provider) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$provider API Key:'),
                        TextFormField(
                          initialValue: tempApiKeys[provider],
                          obscureText: true,
                          onChanged: (val) => tempApiKeys[provider] = val,
                        ),
                      ],
                    )),
                const SizedBox(height: 12),
                ...tempSelectedLLMs.keys.map((provider) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select LLMs for $provider:'),
                        Wrap(
                          children: _providerLLMs[provider]!
                              .map((llm) => ChoiceChip(
                                    label: Text(llm),
                                    selected: tempSelectedLLMs[provider]!
                                        .contains(llm),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          tempSelectedLLMs[provider]!.add(llm);
                                        } else {
                                          tempSelectedLLMs[provider]!
                                              .remove(llm);
                                        }
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _storageOption = tempStorageOption;
                });
                await _prefs.saveString('storage_mode', _storageOption);
                context.read<ChatCubit>().providerApiKeys = tempApiKeys;
                context.read<ChatCubit>().selectedProviderLLMs =
                    tempSelectedLLMs;
                // Persist values to secure storage
                const storage = FlutterSecureStorage();
                for (final entry in tempApiKeys.entries) {
                  await storage.write(
                      key: '${entry.key}_key', value: entry.value);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileArchived ||
              state is ProfileDeleted ||
              state is ProfileLoggedOut) {
            // Reset chat state and purge credentials to avoid rehydration
            try {
              final chat = context.read<ChatCubit>();
              chat.resetForLogout(clearSelections: true);
              chat.purgeProviderCredentialsAndSelections();
            } catch (_) {}
            // Ensure auth state resets to initial and navigate to login, clearing back stack
            try {
              context.read<AuthCubit>().logout();
            } catch (_) {}
            try {
              context.go('/login');
            } catch (_) {}
          }
        },
        builder: (context, state) {
          Widget mainProfileSection = const SizedBox();
          bool usernameOk = false;
          _isAuthenticated = state is ProfileLoaded || state is ProfileVerified;
          if (state is ProfileLoaded || state is ProfileLoadedError) {
            final loaded =
                state is ProfileLoadedError ? state : state as ProfileLoaded;
            // Populate controllers if changed to avoid unnecessary rebuild artifacts
            if (usernameController.text != loaded.username) {
              usernameController.text = loaded.username;
              _lastUsername = loaded.username;
            }
            if (serverUuidController.text != loaded.userId) {
              serverUuidController.text = loaded.userId;
            }
            if (emailController.text != loaded.email) {
              emailController.text = loaded.email;
            }
            if (phoneController.text != loaded.phoneNumber) {
              phoneController.text = loaded.phoneNumber;
            }
            usernameOk = true;
            mainProfileSection = ProfileForm(
              formKey: formKey,
              usernameController: usernameController,
              serverUuidController: serverUuidController,
              emailController: emailController,
              passwordController: passwordController,
              usernameFocusNode: usernameFocusNode,
              emailFocusNode: emailFocusNode,
              passwordFocusNode: passwordFocusNode,
              phoneController: phoneController,
              isEditable: true,
              disabled: false,
              usernameOk: usernameOk,
              emailVerified: loaded.emailVerified,
              profileEmailVerified: loaded.profileEmailVerified,
              onVerifyEmailPressed: loaded.emailVerified
                  ? null
                  : () => _openVerifyEmailDialog(isReset: false),
            );
            if (state is ProfileLoadedError) {
              // Show one-time snack bar for error
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage)),
                );
              });
            }
          } else if (state is ProfileLoading) {
            mainProfileSection =
                const Center(child: CircularProgressIndicator());
          } else if (state is ProfileVisitor) {
            // Visitor: limited UI
            mainProfileSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileForm(
                  formKey: formKey,
                  usernameController: usernameController,
                  serverUuidController: serverUuidController,
                  emailController: emailController,
                  passwordController: passwordController,
                  usernameFocusNode: usernameFocusNode,
                  emailFocusNode: emailFocusNode,
                  passwordFocusNode: passwordFocusNode,
                  phoneController: phoneController,
                  isEditable: true,
                  disabled: false,
                  usernameOk: false,
                  emailVerified: false,
                  profileEmailVerified: false,
                  onUsernameSuffixTap: () {},
                  onVerifyEmailPressed: null,
                  onRegisterPressed: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => BlocProvider.value(
                        value: context.read<AuthCubit>(),
                        child: BlocListener<AuthCubit, AuthState>(
                          listener: (ctx, aState) async {
                            if (aState is AuthRegistrationNoEmailVerification) {
                              Navigator.of(ctx).pop();
                              if (mounted)
                                context.read<ProfileCubit>().loadProfile();
                            }
                          },
                          child: Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 480),
                                child: const SignUpForm(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          } else if (state is ProfileUnverified) {
            // Unverified: show data but disable edits
            if (usernameController.text != state.username)
              usernameController.text = state.username;
            if (emailController.text != state.email)
              emailController.text = state.email;
            if (phoneController.text != state.phoneNumber)
              phoneController.text = state.phoneNumber;
            if (serverUuidController.text != state.userId)
              serverUuidController.text = state.userId;
            mainProfileSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Your email isn\'t verified yet. Verify to enable editing.',
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
                ProfileForm(
                  formKey: formKey,
                  usernameController: usernameController,
                  serverUuidController: serverUuidController,
                  emailController: emailController,
                  passwordController: passwordController,
                  usernameFocusNode: usernameFocusNode,
                  emailFocusNode: emailFocusNode,
                  passwordFocusNode: passwordFocusNode,
                  phoneController: phoneController,
                  isEditable: true,
                  disabled: true,
                  usernameOk: true,
                  emailVerified: false,
                  profileEmailVerified: false,
                  onVerifyEmailPressed: () =>
                      _openVerifyEmailDialog(isReset: false),
                ),
              ],
            );
          } else if (state is ProfileError) {
            mainProfileSection = Center(child: Text(state.message));
          } else if (state is ProfileInitial) {
            mainProfileSection =
                const Center(child: CircularProgressIndicator());
          } else if (state is ProfileArchived) {
            mainProfileSection = const Center(
                child: Text('Account archived. Redirecting to login...'));
          } else if (state is ProfileDeleted) {
            mainProfileSection = const Center(
                child: Text('Account deleted. Redirecting to login...'));
          } else if (state is ProfileLoggedOut) {
            mainProfileSection = const Center(
                child: Text('Logged out. Redirecting to login...'));
          } else {
            mainProfileSection = const Center(child: Text('Unknown state'));
          }
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 220),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mainProfileSection,
                      if (state is ProfileLoaded && state.emailVerified ||
                          state is ProfileLoadedError &&
                              state.emailVerified) ...[
                        const SizedBox(height: 8),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _openVerifyEmailDialog(isReset: true),
                                icon: const Icon(Icons.lock_reset),
                                label: const Text('Reset Password'),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (state is! ProfileArchived &&
                          state is! ProfileDeleted &&
                          state is! ProfileLoggedOut) ...[
                        const SizedBox(height: 24),
                        const Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: ApiKeySection(isEditable: true),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24.0),
                      StorageOptionsCard(
                        initialMode: _storageOption,
                        onChanged: (m) async {
                          setState(() => _storageOption = m);
                          await _prefs.saveString('storage_mode', m);
                        },
                      ),
                      const SizedBox(height: 16),
                      const ModelRoutingPriorityCard(),
                      const SizedBox(height: 16),
                      // Authentication provider & biometric toggles (placed last after storage options)
                      // Allow editing even for visitors so OAuth & biometric can be tested pre-registration.
                      const AuthenticationOptions(isEditable: true),
                      // Manual Sync section removed; merged with Username field
                      // LM Studio configuration now unified inside ApiKeySection via ProviderConfigBlock.
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2)),
                      ],
                    ),
                    child: ProfileBottomActions(
                      onLogout: () async {
                        // Execute profile logout to ensure caches/DB are cleared
                        try {
                          await context.read<ProfileCubit>().logout();
                        } catch (_) {}
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
