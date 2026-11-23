// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'usitask';

  @override
  String get appTitle => 'نظام إدارة المهام والمعلومات الأكاديمية';

  @override
  String get tagline => 'منصتك الأكاديمية الموحدة للمهام والمواعيد والتنبيهات';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get start => 'ابدأ الآن';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get search => 'بحث...';

  @override
  String get refresh => 'تحديث';

  @override
  String get download => 'تنزيل';

  @override
  String get open => 'فتح';

  @override
  String get close => 'إغلاق';

  @override
  String get onboardingTitle1 => 'تنظيم أكاديمي شامل';

  @override
  String get onboardingDesc1 =>
      'وداعاً للتشتت في مجموعات واتساب وتلغرام، جميع التكاليف والمحاضرات في مكان واحد منظم.';

  @override
  String get onboardingTitle2 => 'تتبع دقيق للمواعيد النهائية';

  @override
  String get onboardingDesc2 =>
      'مؤقت تنازلي لكل تكليف مع تنبيهات ذكية لتسليم واجباتك قبل فوات الأوان.';

  @override
  String get onboardingTitle3 => 'تواصل فعال وتحديثات فورية';

  @override
  String get onboardingDesc3 =>
      'تلقي الإعلانات وتعديلات المواعيد وتنزيل المرفقات الدراسية بسهولة وأمان.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب جديد';

  @override
  String get emailOrUsername => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fullName => 'الاسم الرباعي';

  @override
  String get studentId => 'الرقم الجامعي';

  @override
  String get cohortJoiningCode => 'رمز الانضمام للدفعة (مثال: UST-IT2023)';

  @override
  String get noAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get hasAccount => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'البريد الإلكتروني غير صالح';

  @override
  String get passwordTooShort => 'كلمة المرور يجب ألا تقل عن 6 خانات';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get dashboard => 'الرئيسية';

  @override
  String get assignments => 'التكاليف';

  @override
  String get calendar => 'التقويم';

  @override
  String get courses => 'المقررات';

  @override
  String get announcements => 'الإعلانات';

  @override
  String get files => 'الملفات والمرفقات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get admin => 'لوحة الإدارة';

  @override
  String get repDashboard => 'لوحة المندوب';

  @override
  String get welcome => 'مرحباً بك';

  @override
  String get pendingTasks => 'تكاليف قيد الإنجاز';

  @override
  String get dueSoon => 'تسليم قريب';

  @override
  String get overdue => 'متأخرة';

  @override
  String get completed => 'مكتملة';

  @override
  String get upcomingDeadlines => 'المواعيد النهائية القادمة';

  @override
  String get recentAnnouncements => 'آخر الإعلانات';

  @override
  String get noUpcomingAssignments => 'لا توجد تكاليف قادمة حالياً!';

  @override
  String get noAnnouncements => 'لا توجد إعلانات منشورة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterNew => 'جديدة';

  @override
  String get filterInProgress => 'قيد التنفيذ';

  @override
  String get filterCompleted => 'مكتملة';

  @override
  String get filterOverdue => 'متأخرة';

  @override
  String get allCourses => 'جميع المقررات';

  @override
  String get sortByDeadline => 'حسب موعد التسليم';

  @override
  String get sortByCreated => 'حسب تاريخ النشر';

  @override
  String get assignmentDetails => 'تفاصيل التكليف';

  @override
  String get course => 'المقرر';

  @override
  String get deadline => 'موعد التسليم';

  @override
  String get publishedAt => 'تاريخ النشر';

  @override
  String get publishedBy => 'الناشر';

  @override
  String get remainingTime => 'الوقت المتبقي';

  @override
  String get instructions => 'التعليمات والمتطلبات';

  @override
  String get attachments => 'المرفقات والملفات';

  @override
  String get noAttachments => 'لا توجد مرفقات لهذا التكليف';

  @override
  String get externalLinks => 'روابط ومصادر خارجية';

  @override
  String get personalStatus => 'حالة الإنجاز الشخصية';

  @override
  String get statusNotStarted => 'لم أبدأ بعد';

  @override
  String get statusInProgress => 'جاري العمل عليه';

  @override
  String get statusCompleted => 'أنجزت التكليف';

  @override
  String get cancelAssignment => 'إلغاء التكليف';

  @override
  String get cancellationReason => 'سبب الإلغاء';

  @override
  String get assignmentCancelledNotice => 'تم إلغاء هذا التكليف الأكاديمي';

  @override
  String get createAssignment => 'إضافة تكليف جديد';

  @override
  String get editAssignment => 'تعديل التكليف';

  @override
  String get assignmentTitle => 'عنوان التكليف';

  @override
  String get description => 'الوصف المختصر';

  @override
  String get selectCourse => 'اختر المقرر الدراسي';

  @override
  String get selectDeadlineDate => 'تاريخ التسليم';

  @override
  String get selectDeadlineTime => 'وقت التسليم';

  @override
  String get publishNow => 'نشر التكليف فوراً';

  @override
  String get changeReason => 'سبب التعديل (إذا تغير الموعد)';

  @override
  String get createAnnouncement => 'نشر إعلان جديد';

  @override
  String get announcementTitle => 'عنوان الإعلان';

  @override
  String get announcementContent => 'نص الإعلان';

  @override
  String get priority => 'درجة الأهمية';

  @override
  String get priorityNormal => 'عادي';

  @override
  String get priorityImportant => 'هام';

  @override
  String get priorityUrgent => 'عاجل';

  @override
  String get notificationCenter => 'مركز التنبيهات والإشعارات';

  @override
  String get markAllRead => 'تعيين الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات جديدة';

  @override
  String get language => 'اللغة / Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get theme => 'المظهر';

  @override
  String get lightTheme => 'الوضع الفاتح';

  @override
  String get darkTheme => 'الوضع الليلي';

  @override
  String get systemTheme => 'تلقائي حسب النظام';

  @override
  String get notificationPreferences => 'تفضيلات التذكير الذكي';

  @override
  String get remind3Days => 'تذكير قبل الموعد بـ 3 أيام';

  @override
  String get remind1Day => 'تذكير قبل الموعد بـ 24 ساعة';

  @override
  String get remind3Hours => 'تذكير حرج قبل الموعد بـ 3 ساعات';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get aboutAppDesc =>
      'usitask تطبيق لإدارة التكاليف والإعلانات والمواعيد الجامعية، صُمم لتسهيل تجربة الطلاب الأكاديمية.';

  @override
  String get version => 'الإصدار 1.0.0';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get userManagement => 'إدارة المستخدمين والصلاحيات';

  @override
  String get academicHierarchy => 'الهيكل الأكاديمي';

  @override
  String get auditLogs => 'سجل العمليات والرقابة';

  @override
  String get role => 'الدور';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusInactive => 'معطل';

  @override
  String get changeRole => 'تغيير الصلاحية';

  @override
  String get toggleStatus => 'تبديل حالة التفعيل';

  @override
  String get days => 'يوم';

  @override
  String get hours => 'ساعة';

  @override
  String get minutes => 'دقيقة';

  @override
  String get seconds => 'ثانية';

  @override
  String get deadlinePassed => 'انتهى موعد التسليم';

  @override
  String get downloadSuccess => 'تم تنزيل الملف بنجاح';

  @override
  String get downloadFailed => 'فشل تنزيل الملف';

  @override
  String get uploadSubmissionFile => 'رفع ملف التسليم';

  @override
  String get submitAssignment => 'تسليم الواجب';

  @override
  String get replaceSubmissionFile => 'استبدال ملف التسليم';

  @override
  String get submissionStatus => 'حالة التسليم';

  @override
  String get submittedOnTime => 'تم التسليم في الموعد';

  @override
  String get submittedLate => 'تم التسليم متأخراً';

  @override
  String get notSubmitted => 'لم يتم التسليم';

  @override
  String get submissionClosed => 'فترة التسليم منتهية';

  @override
  String get allowedExtensions => 'الامتدادات المسموحة';

  @override
  String get maxFileSize => 'أقصى حجم للملف';

  @override
  String get allowReplacement => 'السماح باستبدال الملف';

  @override
  String get allowLateSubmission => 'السماح بالتسليم المتأخر';

  @override
  String get downloadSubmissionsZip => 'تجميع وتحميل التسليمات (ZIP)';

  @override
  String get submissionsSummary => 'ملخص تسليمات الطلاب';

  @override
  String get studentsSubmitted => 'تم التسليم';

  @override
  String get studentsLate => 'متأخر';

  @override
  String get studentsPending => 'بانتظار التسليم';

  @override
  String get totalStudents => 'إجمالي طلاب الدفعة';

  @override
  String get submissionSuccess => 'تم تسليم الواجب بنجاح!';

  @override
  String get selectFile => 'اختيار ملف من الجهاز';

  @override
  String get fileSelected => 'الملف المحدد';

  @override
  String get noFileSelected => 'يرجى اختيار ملف أولاً';

  @override
  String get fileSizeExceeded => 'حجم الملف يتجاوز الحد المسموح به';

  @override
  String get invalidExtension => 'امتداد هذا الملف غير مسموح به';

  @override
  String get submissionNotes => 'ملاحظات التسليم (اختياري)';

  @override
  String get downloadMySubmission => 'تحميل الملف الذي سلّمته';

  @override
  String get submissionHistory => 'بيانات التسليم';

  @override
  String get submissionVersion => 'رقم النسخة';

  @override
  String get submissionDate => 'وقت التسليم';

  @override
  String get noSubmissionsYet => 'لا توجد أي تسليمات حتى الآن';

  @override
  String get submissionsList => 'قائمة تسليمات الطلاب';

  @override
  String get exportingZip => 'جارٍ ضغط وتجهيز الملفات...';
}
