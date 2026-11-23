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
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'usitask'**
  String get appName;

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'نظام إدارة المهام والمعلومات الأكاديمية'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'منصتك الأكاديمية الموحدة للمهام والمواعيد والتنبيهات'**
  String get tagline;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get start;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث...'**
  String get search;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @download.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل'**
  String get download;

  /// No description provided for @open.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get open;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ar, this message translates to:
  /// **'تنظيم أكاديمي شامل'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ar, this message translates to:
  /// **'وداعاً للتشتت في مجموعات واتساب وتلغرام، جميع التكاليف والمحاضرات في مكان واحد منظم.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ar, this message translates to:
  /// **'تتبع دقيق للمواعيد النهائية'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت تنازلي لكل تكليف مع تنبيهات ذكية لتسليم واجباتك قبل فوات الأوان.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ar, this message translates to:
  /// **'تواصل فعال وتحديثات فورية'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ar, this message translates to:
  /// **'تلقي الإعلانات وتعديلات المواعيد وتنزيل المرفقات الدراسية بسهولة وأمان.'**
  String get onboardingDesc3;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get register;

  /// No description provided for @emailOrUsername.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو اسم المستخدم'**
  String get emailOrUsername;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @currentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الرباعي'**
  String get fullName;

  /// No description provided for @studentId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الجامعي'**
  String get studentId;

  /// No description provided for @cohortJoiningCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الانضمام للدفعة (مثال: UST-IT2023)'**
  String get cohortJoiningCode;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ سجل الآن'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟ تسجيل الدخول'**
  String get hasAccount;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صالح'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب ألا تقل عن 6 خانات'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get passwordsDoNotMatch;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get dashboard;

  /// No description provided for @assignments.
  ///
  /// In ar, this message translates to:
  /// **'التكاليف'**
  String get assignments;

  /// No description provided for @calendar.
  ///
  /// In ar, this message translates to:
  /// **'التقويم'**
  String get calendar;

  /// No description provided for @courses.
  ///
  /// In ar, this message translates to:
  /// **'المقررات'**
  String get courses;

  /// No description provided for @announcements.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get announcements;

  /// No description provided for @files.
  ///
  /// In ar, this message translates to:
  /// **'الملفات والمرفقات'**
  String get files;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @admin.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الإدارة'**
  String get admin;

  /// No description provided for @repDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المندوب'**
  String get repDashboard;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get welcome;

  /// No description provided for @pendingTasks.
  ///
  /// In ar, this message translates to:
  /// **'تكاليف قيد الإنجاز'**
  String get pendingTasks;

  /// No description provided for @dueSoon.
  ///
  /// In ar, this message translates to:
  /// **'تسليم قريب'**
  String get dueSoon;

  /// No description provided for @overdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get overdue;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completed;

  /// No description provided for @upcomingDeadlines.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد النهائية القادمة'**
  String get upcomingDeadlines;

  /// No description provided for @recentAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'آخر الإعلانات'**
  String get recentAnnouncements;

  /// No description provided for @noUpcomingAssignments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تكاليف قادمة حالياً!'**
  String get noUpcomingAssignments;

  /// No description provided for @noAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات منشورة'**
  String get noAnnouncements;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterNew.
  ///
  /// In ar, this message translates to:
  /// **'جديدة'**
  String get filterNew;

  /// No description provided for @filterInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get filterInProgress;

  /// No description provided for @filterCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get filterCompleted;

  /// No description provided for @filterOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get filterOverdue;

  /// No description provided for @allCourses.
  ///
  /// In ar, this message translates to:
  /// **'جميع المقررات'**
  String get allCourses;

  /// No description provided for @sortByDeadline.
  ///
  /// In ar, this message translates to:
  /// **'حسب موعد التسليم'**
  String get sortByDeadline;

  /// No description provided for @sortByCreated.
  ///
  /// In ar, this message translates to:
  /// **'حسب تاريخ النشر'**
  String get sortByCreated;

  /// No description provided for @assignmentDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل التكليف'**
  String get assignmentDetails;

  /// No description provided for @course.
  ///
  /// In ar, this message translates to:
  /// **'المقرر'**
  String get course;

  /// No description provided for @deadline.
  ///
  /// In ar, this message translates to:
  /// **'موعد التسليم'**
  String get deadline;

  /// No description provided for @publishedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النشر'**
  String get publishedAt;

  /// No description provided for @publishedBy.
  ///
  /// In ar, this message translates to:
  /// **'الناشر'**
  String get publishedBy;

  /// No description provided for @remainingTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي'**
  String get remainingTime;

  /// No description provided for @instructions.
  ///
  /// In ar, this message translates to:
  /// **'التعليمات والمتطلبات'**
  String get instructions;

  /// No description provided for @attachments.
  ///
  /// In ar, this message translates to:
  /// **'المرفقات والملفات'**
  String get attachments;

  /// No description provided for @noAttachments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرفقات لهذا التكليف'**
  String get noAttachments;

  /// No description provided for @externalLinks.
  ///
  /// In ar, this message translates to:
  /// **'روابط ومصادر خارجية'**
  String get externalLinks;

  /// No description provided for @personalStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الإنجاز الشخصية'**
  String get personalStatus;

  /// No description provided for @statusNotStarted.
  ///
  /// In ar, this message translates to:
  /// **'لم أبدأ بعد'**
  String get statusNotStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري العمل عليه'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'أنجزت التكليف'**
  String get statusCompleted;

  /// No description provided for @cancelAssignment.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التكليف'**
  String get cancelAssignment;

  /// No description provided for @cancellationReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء'**
  String get cancellationReason;

  /// No description provided for @assignmentCancelledNotice.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء هذا التكليف الأكاديمي'**
  String get assignmentCancelledNotice;

  /// No description provided for @createAssignment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تكليف جديد'**
  String get createAssignment;

  /// No description provided for @editAssignment.
  ///
  /// In ar, this message translates to:
  /// **'تعديل التكليف'**
  String get editAssignment;

  /// No description provided for @assignmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التكليف'**
  String get assignmentTitle;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف المختصر'**
  String get description;

  /// No description provided for @selectCourse.
  ///
  /// In ar, this message translates to:
  /// **'اختر المقرر الدراسي'**
  String get selectCourse;

  /// No description provided for @selectDeadlineDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسليم'**
  String get selectDeadlineDate;

  /// No description provided for @selectDeadlineTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التسليم'**
  String get selectDeadlineTime;

  /// No description provided for @publishNow.
  ///
  /// In ar, this message translates to:
  /// **'نشر التكليف فوراً'**
  String get publishNow;

  /// No description provided for @changeReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب التعديل (إذا تغير الموعد)'**
  String get changeReason;

  /// No description provided for @createAnnouncement.
  ///
  /// In ar, this message translates to:
  /// **'نشر إعلان جديد'**
  String get createAnnouncement;

  /// No description provided for @announcementTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الإعلان'**
  String get announcementTitle;

  /// No description provided for @announcementContent.
  ///
  /// In ar, this message translates to:
  /// **'نص الإعلان'**
  String get announcementContent;

  /// No description provided for @priority.
  ///
  /// In ar, this message translates to:
  /// **'درجة الأهمية'**
  String get priority;

  /// No description provided for @priorityNormal.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get priorityNormal;

  /// No description provided for @priorityImportant.
  ///
  /// In ar, this message translates to:
  /// **'هام'**
  String get priorityImportant;

  /// No description provided for @priorityUrgent.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get priorityUrgent;

  /// No description provided for @notificationCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز التنبيهات والإشعارات'**
  String get notificationCenter;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تعيين الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات جديدة'**
  String get noNotifications;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة / Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي حسب النظام'**
  String get systemTheme;

  /// No description provided for @notificationPreferences.
  ///
  /// In ar, this message translates to:
  /// **'تفضيلات التذكير الذكي'**
  String get notificationPreferences;

  /// No description provided for @remind3Days.
  ///
  /// In ar, this message translates to:
  /// **'تذكير قبل الموعد بـ 3 أيام'**
  String get remind3Days;

  /// No description provided for @remind1Day.
  ///
  /// In ar, this message translates to:
  /// **'تذكير قبل الموعد بـ 24 ساعة'**
  String get remind1Day;

  /// No description provided for @remind3Hours.
  ///
  /// In ar, this message translates to:
  /// **'تذكير حرج قبل الموعد بـ 3 ساعات'**
  String get remind3Hours;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @aboutAppDesc.
  ///
  /// In ar, this message translates to:
  /// **'usitask تطبيق لإدارة التكاليف والإعلانات والمواعيد الجامعية، صُمم لتسهيل تجربة الطلاب الأكاديمية.'**
  String get aboutAppDesc;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار 1.0.0'**
  String get version;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @userManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين والصلاحيات'**
  String get userManagement;

  /// No description provided for @academicHierarchy.
  ///
  /// In ar, this message translates to:
  /// **'الهيكل الأكاديمي'**
  String get academicHierarchy;

  /// No description provided for @auditLogs.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات والرقابة'**
  String get auditLogs;

  /// No description provided for @role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get role;

  /// No description provided for @statusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get statusInactive;

  /// No description provided for @changeRole.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصلاحية'**
  String get changeRole;

  /// No description provided for @toggleStatus.
  ///
  /// In ar, this message translates to:
  /// **'تبديل حالة التفعيل'**
  String get toggleStatus;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In ar, this message translates to:
  /// **'ثانية'**
  String get seconds;

  /// No description provided for @deadlinePassed.
  ///
  /// In ar, this message translates to:
  /// **'انتهى موعد التسليم'**
  String get deadlinePassed;

  /// No description provided for @downloadSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تنزيل الملف بنجاح'**
  String get downloadSuccess;

  /// No description provided for @downloadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تنزيل الملف'**
  String get downloadFailed;

  /// No description provided for @uploadSubmissionFile.
  ///
  /// In ar, this message translates to:
  /// **'رفع ملف التسليم'**
  String get uploadSubmissionFile;

  /// No description provided for @submitAssignment.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الواجب'**
  String get submitAssignment;

  /// No description provided for @replaceSubmissionFile.
  ///
  /// In ar, this message translates to:
  /// **'استبدال ملف التسليم'**
  String get replaceSubmissionFile;

  /// No description provided for @submissionStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة التسليم'**
  String get submissionStatus;

  /// No description provided for @submittedOnTime.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم في الموعد'**
  String get submittedOnTime;

  /// No description provided for @submittedLate.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم متأخراً'**
  String get submittedLate;

  /// No description provided for @notSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التسليم'**
  String get notSubmitted;

  /// No description provided for @submissionClosed.
  ///
  /// In ar, this message translates to:
  /// **'فترة التسليم منتهية'**
  String get submissionClosed;

  /// No description provided for @allowedExtensions.
  ///
  /// In ar, this message translates to:
  /// **'الامتدادات المسموحة'**
  String get allowedExtensions;

  /// No description provided for @maxFileSize.
  ///
  /// In ar, this message translates to:
  /// **'أقصى حجم للملف'**
  String get maxFileSize;

  /// No description provided for @allowReplacement.
  ///
  /// In ar, this message translates to:
  /// **'السماح باستبدال الملف'**
  String get allowReplacement;

  /// No description provided for @allowLateSubmission.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالتسليم المتأخر'**
  String get allowLateSubmission;

  /// No description provided for @downloadSubmissionsZip.
  ///
  /// In ar, this message translates to:
  /// **'تجميع وتحميل التسليمات (ZIP)'**
  String get downloadSubmissionsZip;

  /// No description provided for @submissionsSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص تسليمات الطلاب'**
  String get submissionsSummary;

  /// No description provided for @studentsSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get studentsSubmitted;

  /// No description provided for @studentsLate.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get studentsLate;

  /// No description provided for @studentsPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التسليم'**
  String get studentsPending;

  /// No description provided for @totalStudents.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي طلاب الدفعة'**
  String get totalStudents;

  /// No description provided for @submissionSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم الواجب بنجاح!'**
  String get submissionSuccess;

  /// No description provided for @selectFile.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف من الجهاز'**
  String get selectFile;

  /// No description provided for @fileSelected.
  ///
  /// In ar, this message translates to:
  /// **'الملف المحدد'**
  String get fileSelected;

  /// No description provided for @noFileSelected.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار ملف أولاً'**
  String get noFileSelected;

  /// No description provided for @fileSizeExceeded.
  ///
  /// In ar, this message translates to:
  /// **'حجم الملف يتجاوز الحد المسموح به'**
  String get fileSizeExceeded;

  /// No description provided for @invalidExtension.
  ///
  /// In ar, this message translates to:
  /// **'امتداد هذا الملف غير مسموح به'**
  String get invalidExtension;

  /// No description provided for @submissionNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات التسليم (اختياري)'**
  String get submissionNotes;

  /// No description provided for @downloadMySubmission.
  ///
  /// In ar, this message translates to:
  /// **'تحميل الملف الذي سلّمته'**
  String get downloadMySubmission;

  /// No description provided for @submissionHistory.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التسليم'**
  String get submissionHistory;

  /// No description provided for @submissionVersion.
  ///
  /// In ar, this message translates to:
  /// **'رقم النسخة'**
  String get submissionVersion;

  /// No description provided for @submissionDate.
  ///
  /// In ar, this message translates to:
  /// **'وقت التسليم'**
  String get submissionDate;

  /// No description provided for @noSubmissionsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أي تسليمات حتى الآن'**
  String get noSubmissionsYet;

  /// No description provided for @submissionsList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة تسليمات الطلاب'**
  String get submissionsList;

  /// No description provided for @exportingZip.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ ضغط وتجهيز الملفات...'**
  String get exportingZip;
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
    'that was used.',
  );
}
