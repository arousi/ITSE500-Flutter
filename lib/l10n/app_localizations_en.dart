// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ITSE500';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundMessage =>
      'We couldn\'t find the page you were looking for.';

  @override
  String get goHome => 'Go home';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign up';

  @override
  String get logout => 'Logout';

  @override
  String get exitGuest => 'Exit Guest';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get history => 'History';

  @override
  String get chat => 'Chat';

  @override
  String get newChat => 'New chat';

  @override
  String get send => 'Send';

  @override
  String get attachFile => 'Attach file';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get doneAction => 'Done';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get archive => 'Archive';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get confirm => 'Confirm';

  @override
  String get model => 'Model';

  @override
  String get models => 'Models';

  @override
  String get provider => 'Provider';

  @override
  String get temperature => 'Temperature';

  @override
  String get apiKey => 'API key';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get search => 'Search';

  @override
  String get emailVerification => 'Email verification';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get username => 'Username';

  @override
  String get serverUuid => 'Server UUID';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get registerAndKeepData => 'Register & Keep Data';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get newUserQuestion => 'New user? ';

  @override
  String get alreadyHaveAccountQuestion => 'Already have an account? ';

  @override
  String get signIn => 'Sign In';

  @override
  String get signup => 'Signup';

  @override
  String get or => 'or';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithOpenRouter => 'Continue with OpenRouter';

  @override
  String get connectingOpenRouter => 'Connecting OpenRouter…';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get connectingGoogle => 'Connecting Google…';

  @override
  String get policyText =>
      'By Continuing you adhere to Privacy Policy and Terms of Service';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get exitGuestModeTitle => 'Exit Guest Mode?';

  @override
  String get exitGuestModeBody =>
      'This will delete all local conversations and data on this device.';

  @override
  String get deleteAndExit => 'Delete & Exit';

  @override
  String get modelCatalog => 'Model Catalog';

  @override
  String get newConversation => 'New Conversation';

  @override
  String get configurationAndInference => 'Configuration & Inference';

  @override
  String get serverDownWarning => 'Server is down. Some features may not work.';

  @override
  String get noConversationsFound => 'No conversations found';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get cancelSelection => 'Cancel Selection';

  @override
  String get deleteSelectedConversationsTitle =>
      'Delete selected conversations?';

  @override
  String deleteSelectedConversationsBody(int count) {
    return 'This will permanently delete $count conversation(s).';
  }

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get privateLabel => 'Private';

  @override
  String get mixedLabel => 'Mixed';

  @override
  String get unlock => 'Unlock';

  @override
  String locked(String reason) {
    return 'Locked ($reason)';
  }

  @override
  String get switchLanguage => 'Switch language';

  @override
  String get providerDisabledWarning =>
      'Selected provider is disabled or not configured. Enable it in Config/Profile.';

  @override
  String get generatingImage => 'Generating image…';

  @override
  String get imageGenerated => 'Image generated';

  @override
  String get generatingEmbedding => 'Generating embedding…';

  @override
  String embeddingGenerated(int dims) {
    return 'Embedding generated ($dims dims)';
  }

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get goToLatest => 'Go to latest';

  @override
  String get configuration => 'Configuration';

  @override
  String get providersLabel => 'Providers';

  @override
  String get noProvidersAvailable => 'No providers available';

  @override
  String addApiKeyInProfile(String provider) {
    return 'Add API key for $provider in Profile screen.';
  }

  @override
  String get limitResponseLength => 'Limit Response Length';

  @override
  String get sampling => 'Sampling';

  @override
  String get topK => 'Top K';

  @override
  String get repeatPenalty => 'Repeat Penalty';

  @override
  String get minP => 'Min P';

  @override
  String get topP => 'Top P';

  @override
  String get structuredOutput => 'Structured Output';

  @override
  String get structuredOutputJsonSchema => 'Structured Output (JSON Schema)';

  @override
  String get close => 'Close';

  @override
  String get systemPrompt => 'System Prompt';

  @override
  String get systemPromptHint =>
      'Enter a persistent system instruction (e.g., You are a helpful assistant...)';

  @override
  String providerApiKeyLabel(String provider) {
    return '$provider API Key';
  }

  @override
  String providerApiTokenLabel(String provider) {
    return '$provider API Token';
  }

  @override
  String providerBaseUrlLabel(String provider) {
    return '$provider Base URL';
  }

  @override
  String get storageOptions => 'Storage Options:';

  @override
  String get modelRoutingPriority => 'Model Routing Priority';

  @override
  String get catalog => 'Catalog';

  @override
  String providerDisabledLabel(String provider) {
    return '$provider disabled';
  }

  @override
  String get alphaFeature => '(Alpha Feature)';

  @override
  String get chatEmbeddingsDisabledTooltip =>
      'Chat & embeddings disabled for now; image generation only';

  @override
  String get fetchModelsFirst => 'Fetch models first to configure routing';

  @override
  String get priorityFailoverExplanation =>
      'If Priority 1 model fails, the next one is attempted automatically.';

  @override
  String get invalidModelsClearedExplanation =>
      'Invalid or removed models are automatically cleared and logged.';

  @override
  String get authentication => 'Authentication';

  @override
  String get oauthProviders => 'OAuth Providers';

  @override
  String get enableOpenRouterSignIn =>
      'Enable to show OpenRouter Sign-In on login screen';

  @override
  String get enableGoogleSignIn =>
      'Enable to show Google Sign-In on login screen';

  @override
  String get enableMicrosoftSignIn =>
      'Enable to show Microsoft Sign-In on login screen';

  @override
  String get deviceSecurity => 'Device Security';

  @override
  String get biometricNotAvailable => 'Biometric not available';

  @override
  String get biometricNotSupportedBody =>
      'Your device does not support biometric authentication';

  @override
  String get biometricAuthentication => 'Biometric Authentication';

  @override
  String get requireBiometricUnlock =>
      'Require fingerprint/face to unlock after login';

  @override
  String get biometricNotSupportedDevice => 'Biometric not supported on device';

  @override
  String get noBiometricsEnrolled =>
      'No biometrics enrolled. Add fingerprint/face in system settings first.';

  @override
  String get biometricAuthFailed => 'Biometric auth failed or unavailable';

  @override
  String get googleSignInFailed => 'Google sign-in failed';

  @override
  String get microsoftSignInFailed => 'Microsoft sign-in failed';

  @override
  String get openRouterSignInFailed => 'OpenRouter sign-in failed';

  @override
  String get refreshAll => 'Refresh all';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String modelsCount(int count) {
    return '$count models';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get openDocs => 'Open docs';

  @override
  String get searchModels => 'Search models';

  @override
  String get embeddings => 'Embeddings';

  @override
  String get imageVision => 'Image / Vision';

  @override
  String get billingRequired => 'Billing Required';

  @override
  String get billing => 'Billing';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get noModelsData => 'No models data. Fetch models first.';

  @override
  String lastUpdate(String date) {
    return 'Last update: $date';
  }

  @override
  String providerModelsTitle(String provider) {
    return '$provider Models';
  }

  @override
  String get continueLabel => 'CONTINUE';

  @override
  String get confirmationCode => 'Confirmation Code';

  @override
  String get resetPasswordButton => 'RESET PASSWORD';

  @override
  String get enterEmailFirst => 'Enter email first';

  @override
  String get pinDisabledForReset =>
      'PIN entry is disabled for password reset (bypassed).';

  @override
  String get passwordOptional => 'Password (optional)';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get enterFiveDigitCode =>
      'Enter the 5-digit code sent to your email. Password fields unlock after verification.';

  @override
  String get verifyingCode => 'Verifying code...';

  @override
  String get emailVerifiedSnackbar => 'Email verified';

  @override
  String get verificationFailedTryAgain => 'Verification failed, try again';

  @override
  String get resetButton => 'Reset';

  @override
  String get profileUpdateRequested => 'Profile update requested.';

  @override
  String get emailNotVerifiedYet =>
      'Your email isn\'t verified yet. Verify to enable editing.';

  @override
  String get accountArchivedRedirecting =>
      'Account archived. Redirecting to login...';

  @override
  String get accountDeletedRedirecting =>
      'Account deleted. Redirecting to login...';

  @override
  String get loggedOutRedirecting => 'Logged out. Redirecting to login...';

  @override
  String get unknownState => 'Unknown state';

  @override
  String get accountArchivedSnackbar => 'Account archived.';

  @override
  String get accountDeletedSnackbar => 'Account deleted.';

  @override
  String get loggedOutSnackbar => 'Logged out.';

  @override
  String get accountActionFailed => 'Account action failed';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get archiveOrDeleteAccount => 'Archive or Delete Account';

  @override
  String get closeYourAccountTitle => 'Close Your Account';

  @override
  String get closeAccountExplanation =>
      'Choose an option below. Archiving disables access and schedules deletion in ~30 days. Deleting removes your account immediately.\n There is no guarantee your account data will be removed from our past DB Backups!';

  @override
  String get reasonFeedbackOptional => 'Reason / Feedback (optional)';

  @override
  String get tellUsWhyLeaving => 'Tell us why you are leaving...';

  @override
  String get permanentlyDeleteNow => 'Permanently Delete Now';

  @override
  String get turnOffToArchive => 'Turn off to archive instead';

  @override
  String get deleteNow => 'Delete Now';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
}
