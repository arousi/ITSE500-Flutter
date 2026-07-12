// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ITSE500';

  @override
  String get pageNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get pageNotFoundMessage => 'تعذّر العثور على الصفحة التي تبحث عنها.';

  @override
  String get goHome => 'العودة للرئيسية';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get exitGuest => 'الخروج من وضع الضيف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get settings => 'الإعدادات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get history => 'السجل';

  @override
  String get chat => 'المحادثة';

  @override
  String get newChat => 'محادثة جديدة';

  @override
  String get send => 'إرسال';

  @override
  String get attachFile => 'إرفاق ملف';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get doneAction => 'تم';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get archive => 'أرشفة';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get confirm => 'تأكيد';

  @override
  String get model => 'النموذج';

  @override
  String get models => 'النماذج';

  @override
  String get provider => 'المزوّد';

  @override
  String get temperature => 'الحرارة';

  @override
  String get apiKey => 'مفتاح API';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get search => 'بحث';

  @override
  String get emailVerification => 'التحقق من البريد الإلكتروني';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get serverUuid => 'معرّف الخادم';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get registerAndKeepData => 'التسجيل والاحتفاظ بالبيانات';

  @override
  String get verifyEmail => 'تحقق من البريد الإلكتروني';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get newUserQuestion => 'مستخدم جديد؟ ';

  @override
  String get alreadyHaveAccountQuestion => 'لديك حساب بالفعل؟ ';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signup => 'إنشاء حساب';

  @override
  String get or => 'أو';

  @override
  String get orContinueWith => 'أو المتابعة باستخدام';

  @override
  String get continueWithOpenRouter => 'المتابعة باستخدام OpenRouter';

  @override
  String get connectingOpenRouter => 'جارٍ الاتصال بـ OpenRouter…';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get connectingGoogle => 'جارٍ الاتصال بـ Google…';

  @override
  String get policyText =>
      'بالمتابعة فإنك توافق على سياسة الخصوصية وشروط الخدمة';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get registrationFailed => 'فشل التسجيل';

  @override
  String get passwordMinLength =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get enterUsername => 'أدخل اسم المستخدم';

  @override
  String get enterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get exitGuestModeTitle => 'الخروج من وضع الضيف؟';

  @override
  String get exitGuestModeBody =>
      'سيؤدي هذا إلى حذف جميع المحادثات والبيانات المحلية على هذا الجهاز.';

  @override
  String get deleteAndExit => 'حذف وخروج';

  @override
  String get modelCatalog => 'كتالوج النماذج';

  @override
  String get newConversation => 'محادثة جديدة';

  @override
  String get configurationAndInference => 'الإعدادات والاستدلال';

  @override
  String get serverDownWarning =>
      'الخادم غير متاح حاليًا. قد لا تعمل بعض الميزات.';

  @override
  String get noConversationsFound => 'لم يتم العثور على محادثات';

  @override
  String selectedCount(int count) {
    return 'تم تحديد $count';
  }

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get deleteSelected => 'حذف المحدد';

  @override
  String get cancelSelection => 'إلغاء التحديد';

  @override
  String get deleteSelectedConversationsTitle => 'حذف المحادثات المحددة؟';

  @override
  String deleteSelectedConversationsBody(int count) {
    return 'سيؤدي هذا إلى حذف $count محادثة (محادثات) نهائيًا.';
  }

  @override
  String get typeAMessage => 'اكتب رسالة...';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get copy => 'نسخ';

  @override
  String get privateLabel => 'خاص';

  @override
  String get mixedLabel => 'مختلط';

  @override
  String get unlock => 'فتح القفل';

  @override
  String locked(String reason) {
    return 'مقفل ($reason)';
  }

  @override
  String get switchLanguage => 'تغيير اللغة';

  @override
  String get providerDisabledWarning =>
      'المزوّد المحدد معطّل أو غير مهيّأ. قم بتفعيله من الإعدادات/الملف الشخصي.';

  @override
  String get generatingImage => 'جارٍ إنشاء الصورة…';

  @override
  String get imageGenerated => 'تم إنشاء الصورة';

  @override
  String get generatingEmbedding => 'جارٍ إنشاء المتجهات…';

  @override
  String embeddingGenerated(int dims) {
    return 'تم إنشاء المتجهات ($dims بُعد)';
  }

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get goToLatest => 'الانتقال إلى الأحدث';

  @override
  String get configuration => 'الإعدادات';

  @override
  String get providersLabel => 'المزوّدون';

  @override
  String get noProvidersAvailable => 'لا يوجد مزوّدون متاحون';

  @override
  String addApiKeyInProfile(String provider) {
    return 'أضف مفتاح API الخاص بـ $provider في شاشة الملف الشخصي.';
  }

  @override
  String get limitResponseLength => 'تحديد طول الاستجابة';

  @override
  String get sampling => 'أخذ العينات';

  @override
  String get topK => 'Top K';

  @override
  String get repeatPenalty => 'عقوبة التكرار';

  @override
  String get minP => 'Min P';

  @override
  String get topP => 'Top P';

  @override
  String get structuredOutput => 'المخرجات المنظّمة';

  @override
  String get structuredOutputJsonSchema => 'المخرجات المنظّمة (مخطط JSON)';

  @override
  String get close => 'إغلاق';

  @override
  String get systemPrompt => 'تعليمات النظام';

  @override
  String get systemPromptHint =>
      'أدخل تعليمة نظام دائمة (مثال: أنت مساعد مفيد...)';

  @override
  String providerApiKeyLabel(String provider) {
    return 'مفتاح API لـ $provider';
  }

  @override
  String providerApiTokenLabel(String provider) {
    return 'رمز API لـ $provider';
  }

  @override
  String providerBaseUrlLabel(String provider) {
    return 'رابط $provider الأساسي';
  }

  @override
  String get storageOptions => 'خيارات التخزين:';

  @override
  String get modelRoutingPriority => 'أولوية توجيه النماذج';

  @override
  String get catalog => 'الكتالوج';

  @override
  String providerDisabledLabel(String provider) {
    return '$provider معطّل';
  }

  @override
  String get alphaFeature => '(ميزة تجريبية)';

  @override
  String get chatEmbeddingsDisabledTooltip =>
      'المحادثة والمتجهات معطّلة حاليًا؛ توليد الصور فقط';

  @override
  String get fetchModelsFirst => 'اجلب النماذج أولاً لتهيئة التوجيه';

  @override
  String get priorityFailoverExplanation =>
      'إذا فشل نموذج الأولوية 1، يتم تجربة النموذج التالي تلقائيًا.';

  @override
  String get invalidModelsClearedExplanation =>
      'يتم مسح النماذج غير الصالحة أو المحذوفة تلقائيًا وتسجيلها.';

  @override
  String get authentication => 'المصادقة';

  @override
  String get oauthProviders => 'مزوّدو OAuth';

  @override
  String get enableOpenRouterSignIn =>
      'فعّل لإظهار تسجيل الدخول عبر OpenRouter في شاشة الدخول';

  @override
  String get enableGoogleSignIn =>
      'فعّل لإظهار تسجيل الدخول عبر Google في شاشة الدخول';

  @override
  String get enableMicrosoftSignIn =>
      'فعّل لإظهار تسجيل الدخول عبر Microsoft في شاشة الدخول';

  @override
  String get deviceSecurity => 'أمان الجهاز';

  @override
  String get biometricNotAvailable => 'المصادقة البيومترية غير متاحة';

  @override
  String get biometricNotSupportedBody => 'جهازك لا يدعم المصادقة البيومترية';

  @override
  String get biometricAuthentication => 'المصادقة البيومترية';

  @override
  String get requireBiometricUnlock =>
      'يتطلب بصمة الإصبع/الوجه لإلغاء القفل بعد تسجيل الدخول';

  @override
  String get biometricNotSupportedDevice =>
      'المصادقة البيومترية غير مدعومة على هذا الجهاز';

  @override
  String get noBiometricsEnrolled =>
      'لا توجد بيانات بيومترية مسجّلة. أضف بصمة الإصبع/الوجه من إعدادات النظام أولاً.';

  @override
  String get biometricAuthFailed => 'فشلت المصادقة البيومترية أو غير متاحة';

  @override
  String get googleSignInFailed => 'فشل تسجيل الدخول عبر Google';

  @override
  String get microsoftSignInFailed => 'فشل تسجيل الدخول عبر Microsoft';

  @override
  String get openRouterSignInFailed => 'فشل تسجيل الدخول عبر OpenRouter';

  @override
  String get refreshAll => 'تحديث الكل';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int minutes) {
    return 'منذ $minutes د';
  }

  @override
  String hoursAgo(int hours) {
    return 'منذ $hours س';
  }

  @override
  String daysAgo(int days) {
    return 'منذ $days يوم';
  }

  @override
  String modelsCount(int count) {
    return '$count نموذج';
  }

  @override
  String get refresh => 'تحديث';

  @override
  String get openDocs => 'فتح التوثيق';

  @override
  String get searchModels => 'بحث في النماذج';

  @override
  String get embeddings => 'المتجهات';

  @override
  String get imageVision => 'صورة / رؤية';

  @override
  String get billingRequired => 'يتطلب فوترة';

  @override
  String get billing => 'فوترة';

  @override
  String errorPrefix(String error) {
    return 'خطأ: $error';
  }

  @override
  String get noModelsData => 'لا توجد بيانات نماذج. اجلب النماذج أولاً.';

  @override
  String lastUpdate(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String providerModelsTitle(String provider) {
    return 'نماذج $provider';
  }

  @override
  String get continueLabel => 'متابعة';

  @override
  String get confirmationCode => 'رمز التأكيد';

  @override
  String get resetPasswordButton => 'إعادة تعيين كلمة المرور';

  @override
  String get enterEmailFirst => 'أدخل البريد الإلكتروني أولاً';

  @override
  String get pinDisabledForReset =>
      'إدخال الرمز معطّل عند إعادة تعيين كلمة المرور (تم تجاوزه).';

  @override
  String get passwordOptional => 'كلمة المرور (اختياري)';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get enterFiveDigitCode =>
      'أدخل الرمز المكوّن من 5 أرقام المُرسل إلى بريدك الإلكتروني. تُفتح حقول كلمة المرور بعد التحقق.';

  @override
  String get verifyingCode => 'جارٍ التحقق من الرمز...';

  @override
  String get emailVerifiedSnackbar => 'تم التحقق من البريد الإلكتروني';

  @override
  String get verificationFailedTryAgain => 'فشل التحقق، حاول مرة أخرى';

  @override
  String get resetButton => 'إعادة تعيين';

  @override
  String get profileUpdateRequested => 'تم طلب تحديث الملف الشخصي.';

  @override
  String get emailNotVerifiedYet =>
      'لم يتم التحقق من بريدك الإلكتروني بعد. تحقق لتفعيل التعديل.';

  @override
  String get accountArchivedRedirecting =>
      'تم أرشفة الحساب. جارٍ التوجيه إلى تسجيل الدخول...';

  @override
  String get accountDeletedRedirecting =>
      'تم حذف الحساب. جارٍ التوجيه إلى تسجيل الدخول...';

  @override
  String get loggedOutRedirecting =>
      'تم تسجيل الخروج. جارٍ التوجيه إلى تسجيل الدخول...';

  @override
  String get unknownState => 'حالة غير معروفة';

  @override
  String get accountArchivedSnackbar => 'تمت أرشفة الحساب.';

  @override
  String get accountDeletedSnackbar => 'تم حذف الحساب.';

  @override
  String get loggedOutSnackbar => 'تم تسجيل الخروج.';

  @override
  String get accountActionFailed => 'فشل إجراء الحساب';

  @override
  String get sendFeedback => 'إرسال ملاحظات';

  @override
  String get archiveOrDeleteAccount => 'أرشفة أو حذف الحساب';

  @override
  String get closeYourAccountTitle => 'إغلاق حسابك';

  @override
  String get closeAccountExplanation =>
      'اختر أحد الخيارات أدناه. الأرشفة تعطّل الوصول وتجدول الحذف خلال ~30 يومًا. الحذف يزيل حسابك فورًا.\n لا يوجد ضمان بإزالة بيانات حسابك من النسخ الاحتياطية السابقة لقاعدة البيانات!';

  @override
  String get reasonFeedbackOptional => 'السبب / الملاحظات (اختياري)';

  @override
  String get tellUsWhyLeaving => 'أخبرنا لماذا تغادر...';

  @override
  String get permanentlyDeleteNow => 'حذف نهائي الآن';

  @override
  String get turnOffToArchive => 'أطفئ للأرشفة بدلاً من ذلك';

  @override
  String get deleteNow => 'حذف الآن';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';
}
