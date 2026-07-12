import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// Visible app-bar / window title
  ///
  /// In en, this message translates to:
  /// **'ITSE500'**
  String get appTitle;

  /// Title shown when navigating to an unknown route
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFoundTitle;

  /// Body text shown on the unknown-route error screen
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find the page you were looking for.'**
  String get pageNotFoundMessage;

  /// Button that navigates back to the home screen
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @exitGuest.
  ///
  /// In en, this message translates to:
  /// **'Exit Guest'**
  String get exitGuest;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Tooltip/accessible label for the chat attachment button
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// Tooltip/accessible label for the password-visibility toggle when the password is currently hidden
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Tooltip/accessible label for the password-visibility toggle when the password is currently visible
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Tooltip/accessible label for a confirm/done icon button (e.g. closing the priority-models picker)
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @models.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get models;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get apiKey;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get emailVerification;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @serverUuid.
  ///
  /// In en, this message translates to:
  /// **'Server UUID'**
  String get serverUuid;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @registerAndKeepData.
  ///
  /// In en, this message translates to:
  /// **'Register & Keep Data'**
  String get registerAndKeepData;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @newUserQuestion.
  ///
  /// In en, this message translates to:
  /// **'New user? '**
  String get newUserQuestion;

  /// No description provided for @alreadyHaveAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountQuestion;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithOpenRouter.
  ///
  /// In en, this message translates to:
  /// **'Continue with OpenRouter'**
  String get continueWithOpenRouter;

  /// No description provided for @connectingOpenRouter.
  ///
  /// In en, this message translates to:
  /// **'Connecting OpenRouter…'**
  String get connectingOpenRouter;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @connectingGoogle.
  ///
  /// In en, this message translates to:
  /// **'Connecting Google…'**
  String get connectingGoogle;

  /// No description provided for @policyText.
  ///
  /// In en, this message translates to:
  /// **'By Continuing you adhere to Privacy Policy and Terms of Service'**
  String get policyText;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @exitGuestModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Guest Mode?'**
  String get exitGuestModeTitle;

  /// No description provided for @exitGuestModeBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all local conversations and data on this device.'**
  String get exitGuestModeBody;

  /// No description provided for @deleteAndExit.
  ///
  /// In en, this message translates to:
  /// **'Delete & Exit'**
  String get deleteAndExit;

  /// No description provided for @modelCatalog.
  ///
  /// In en, this message translates to:
  /// **'Model Catalog'**
  String get modelCatalog;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// No description provided for @configurationAndInference.
  ///
  /// In en, this message translates to:
  /// **'Configuration & Inference'**
  String get configurationAndInference;

  /// No description provided for @serverDownWarning.
  ///
  /// In en, this message translates to:
  /// **'Server is down. Some features may not work.'**
  String get serverDownWarning;

  /// No description provided for @noConversationsFound.
  ///
  /// In en, this message translates to:
  /// **'No conversations found'**
  String get noConversationsFound;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel Selection'**
  String get cancelSelection;

  /// No description provided for @deleteSelectedConversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete selected conversations?'**
  String get deleteSelectedConversationsTitle;

  /// No description provided for @deleteSelectedConversationsBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {count} conversation(s).'**
  String deleteSelectedConversationsBody(int count);

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @privateLabel.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateLabel;

  /// No description provided for @mixedLabel.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixedLabel;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked ({reason})'**
  String locked(String reason);

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get switchLanguage;

  /// No description provided for @providerDisabledWarning.
  ///
  /// In en, this message translates to:
  /// **'Selected provider is disabled or not configured. Enable it in Config/Profile.'**
  String get providerDisabledWarning;

  /// No description provided for @generatingImage.
  ///
  /// In en, this message translates to:
  /// **'Generating image…'**
  String get generatingImage;

  /// No description provided for @imageGenerated.
  ///
  /// In en, this message translates to:
  /// **'Image generated'**
  String get imageGenerated;

  /// No description provided for @generatingEmbedding.
  ///
  /// In en, this message translates to:
  /// **'Generating embedding…'**
  String get generatingEmbedding;

  /// No description provided for @embeddingGenerated.
  ///
  /// In en, this message translates to:
  /// **'Embedding generated ({dims} dims)'**
  String embeddingGenerated(int dims);

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @goToLatest.
  ///
  /// In en, this message translates to:
  /// **'Go to latest'**
  String get goToLatest;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @providersLabel.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providersLabel;

  /// No description provided for @noProvidersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No providers available'**
  String get noProvidersAvailable;

  /// No description provided for @addApiKeyInProfile.
  ///
  /// In en, this message translates to:
  /// **'Add API key for {provider} in Profile screen.'**
  String addApiKeyInProfile(String provider);

  /// No description provided for @limitResponseLength.
  ///
  /// In en, this message translates to:
  /// **'Limit Response Length'**
  String get limitResponseLength;

  /// No description provided for @sampling.
  ///
  /// In en, this message translates to:
  /// **'Sampling'**
  String get sampling;

  /// No description provided for @topK.
  ///
  /// In en, this message translates to:
  /// **'Top K'**
  String get topK;

  /// No description provided for @repeatPenalty.
  ///
  /// In en, this message translates to:
  /// **'Repeat Penalty'**
  String get repeatPenalty;

  /// No description provided for @minP.
  ///
  /// In en, this message translates to:
  /// **'Min P'**
  String get minP;

  /// No description provided for @topP.
  ///
  /// In en, this message translates to:
  /// **'Top P'**
  String get topP;

  /// No description provided for @structuredOutput.
  ///
  /// In en, this message translates to:
  /// **'Structured Output'**
  String get structuredOutput;

  /// No description provided for @structuredOutputJsonSchema.
  ///
  /// In en, this message translates to:
  /// **'Structured Output (JSON Schema)'**
  String get structuredOutputJsonSchema;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @systemPrompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get systemPrompt;

  /// No description provided for @systemPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a persistent system instruction (e.g., You are a helpful assistant...)'**
  String get systemPromptHint;

  /// No description provided for @providerApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'{provider} API Key'**
  String providerApiKeyLabel(String provider);

  /// No description provided for @providerApiTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'{provider} API Token'**
  String providerApiTokenLabel(String provider);

  /// No description provided for @providerBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'{provider} Base URL'**
  String providerBaseUrlLabel(String provider);

  /// No description provided for @storageOptions.
  ///
  /// In en, this message translates to:
  /// **'Storage Options:'**
  String get storageOptions;

  /// No description provided for @modelRoutingPriority.
  ///
  /// In en, this message translates to:
  /// **'Model Routing Priority'**
  String get modelRoutingPriority;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalog;

  /// No description provided for @providerDisabledLabel.
  ///
  /// In en, this message translates to:
  /// **'{provider} disabled'**
  String providerDisabledLabel(String provider);

  /// No description provided for @alphaFeature.
  ///
  /// In en, this message translates to:
  /// **'(Alpha Feature)'**
  String get alphaFeature;

  /// No description provided for @chatEmbeddingsDisabledTooltip.
  ///
  /// In en, this message translates to:
  /// **'Chat & embeddings disabled for now; image generation only'**
  String get chatEmbeddingsDisabledTooltip;

  /// No description provided for @fetchModelsFirst.
  ///
  /// In en, this message translates to:
  /// **'Fetch models first to configure routing'**
  String get fetchModelsFirst;

  /// No description provided for @priorityFailoverExplanation.
  ///
  /// In en, this message translates to:
  /// **'If Priority 1 model fails, the next one is attempted automatically.'**
  String get priorityFailoverExplanation;

  /// No description provided for @invalidModelsClearedExplanation.
  ///
  /// In en, this message translates to:
  /// **'Invalid or removed models are automatically cleared and logged.'**
  String get invalidModelsClearedExplanation;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// No description provided for @oauthProviders.
  ///
  /// In en, this message translates to:
  /// **'OAuth Providers'**
  String get oauthProviders;

  /// No description provided for @enableOpenRouterSignIn.
  ///
  /// In en, this message translates to:
  /// **'Enable to show OpenRouter Sign-In on login screen'**
  String get enableOpenRouterSignIn;

  /// No description provided for @enableGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Enable to show Google Sign-In on login screen'**
  String get enableGoogleSignIn;

  /// No description provided for @enableMicrosoftSignIn.
  ///
  /// In en, this message translates to:
  /// **'Enable to show Microsoft Sign-In on login screen'**
  String get enableMicrosoftSignIn;

  /// No description provided for @deviceSecurity.
  ///
  /// In en, this message translates to:
  /// **'Device Security'**
  String get deviceSecurity;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric not available'**
  String get biometricNotAvailable;

  /// No description provided for @biometricNotSupportedBody.
  ///
  /// In en, this message translates to:
  /// **'Your device does not support biometric authentication'**
  String get biometricNotSupportedBody;

  /// No description provided for @biometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// No description provided for @requireBiometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Require fingerprint/face to unlock after login'**
  String get requireBiometricUnlock;

  /// No description provided for @biometricNotSupportedDevice.
  ///
  /// In en, this message translates to:
  /// **'Biometric not supported on device'**
  String get biometricNotSupportedDevice;

  /// No description provided for @noBiometricsEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No biometrics enrolled. Add fingerprint/face in system settings first.'**
  String get noBiometricsEnrolled;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric auth failed or unavailable'**
  String get biometricAuthFailed;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleSignInFailed;

  /// No description provided for @microsoftSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Microsoft sign-in failed'**
  String get microsoftSignInFailed;

  /// No description provided for @openRouterSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'OpenRouter sign-in failed'**
  String get openRouterSignInFailed;

  /// No description provided for @refreshAll.
  ///
  /// In en, this message translates to:
  /// **'Refresh all'**
  String get refreshAll;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @modelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} models'**
  String modelsCount(int count);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @openDocs.
  ///
  /// In en, this message translates to:
  /// **'Open docs'**
  String get openDocs;

  /// No description provided for @searchModels.
  ///
  /// In en, this message translates to:
  /// **'Search models'**
  String get searchModels;

  /// No description provided for @embeddings.
  ///
  /// In en, this message translates to:
  /// **'Embeddings'**
  String get embeddings;

  /// No description provided for @imageVision.
  ///
  /// In en, this message translates to:
  /// **'Image / Vision'**
  String get imageVision;

  /// No description provided for @billingRequired.
  ///
  /// In en, this message translates to:
  /// **'Billing Required'**
  String get billingRequired;

  /// No description provided for @billing.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billing;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// No description provided for @noModelsData.
  ///
  /// In en, this message translates to:
  /// **'No models data. Fetch models first.'**
  String get noModelsData;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update: {date}'**
  String lastUpdate(String date);

  /// No description provided for @providerModelsTitle.
  ///
  /// In en, this message translates to:
  /// **'{provider} Models'**
  String providerModelsTitle(String provider);

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueLabel;

  /// No description provided for @confirmationCode.
  ///
  /// In en, this message translates to:
  /// **'Confirmation Code'**
  String get confirmationCode;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPasswordButton;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter email first'**
  String get enterEmailFirst;

  /// No description provided for @pinDisabledForReset.
  ///
  /// In en, this message translates to:
  /// **'PIN entry is disabled for password reset (bypassed).'**
  String get pinDisabledForReset;

  /// No description provided for @passwordOptional.
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get passwordOptional;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @enterFiveDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 5-digit code sent to your email. Password fields unlock after verification.'**
  String get enterFiveDigitCode;

  /// No description provided for @verifyingCode.
  ///
  /// In en, this message translates to:
  /// **'Verifying code...'**
  String get verifyingCode;

  /// No description provided for @emailVerifiedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerifiedSnackbar;

  /// No description provided for @verificationFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Verification failed, try again'**
  String get verificationFailedTryAgain;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @profileUpdateRequested.
  ///
  /// In en, this message translates to:
  /// **'Profile update requested.'**
  String get profileUpdateRequested;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Your email isn\'t verified yet. Verify to enable editing.'**
  String get emailNotVerifiedYet;

  /// No description provided for @accountArchivedRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Account archived. Redirecting to login...'**
  String get accountArchivedRedirecting;

  /// No description provided for @accountDeletedRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Account deleted. Redirecting to login...'**
  String get accountDeletedRedirecting;

  /// No description provided for @loggedOutRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Logged out. Redirecting to login...'**
  String get loggedOutRedirecting;

  /// No description provided for @unknownState.
  ///
  /// In en, this message translates to:
  /// **'Unknown state'**
  String get unknownState;

  /// No description provided for @accountArchivedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Account archived.'**
  String get accountArchivedSnackbar;

  /// No description provided for @accountDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeletedSnackbar;

  /// No description provided for @loggedOutSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Logged out.'**
  String get loggedOutSnackbar;

  /// No description provided for @accountActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Account action failed'**
  String get accountActionFailed;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @archiveOrDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Archive or Delete Account'**
  String get archiveOrDeleteAccount;

  /// No description provided for @closeYourAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Close Your Account'**
  String get closeYourAccountTitle;

  /// No description provided for @closeAccountExplanation.
  ///
  /// In en, this message translates to:
  /// **'Choose an option below. Archiving disables access and schedules deletion in ~30 days. Deleting removes your account immediately.\n There is no guarantee your account data will be removed from our past DB Backups!'**
  String get closeAccountExplanation;

  /// No description provided for @reasonFeedbackOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason / Feedback (optional)'**
  String get reasonFeedbackOptional;

  /// No description provided for @tellUsWhyLeaving.
  ///
  /// In en, this message translates to:
  /// **'Tell us why you are leaving...'**
  String get tellUsWhyLeaving;

  /// No description provided for @permanentlyDeleteNow.
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete Now'**
  String get permanentlyDeleteNow;

  /// No description provided for @turnOffToArchive.
  ///
  /// In en, this message translates to:
  /// **'Turn off to archive instead'**
  String get turnOffToArchive;

  /// No description provided for @deleteNow.
  ///
  /// In en, this message translates to:
  /// **'Delete Now'**
  String get deleteNow;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
