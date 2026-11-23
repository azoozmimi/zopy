import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usitask/core/theme/app_theme.dart';
import 'package:usitask/l10n/app_localizations.dart';
import 'package:usitask/models/assignment.dart';
import 'package:usitask/models/course.dart';
import 'package:usitask/models/user.dart';
import 'package:usitask/widgets/assignment_card.dart';
import 'package:usitask/widgets/countdown_timer_widget.dart';
import 'package:usitask/widgets/empty_state_widget.dart';

void main() {
  group('1. Business Logic and Model Unit Tests', () {
    test('User role getters work correctly', () {
      final student = User(id: 1, fullName: 'Student', email: 's@u.edu', username: 's', role: 'Student');
      final rep = User(id: 2, fullName: 'Rep', email: 'r@u.edu', username: 'r', role: 'Representative');
      final admin = User(id: 3, fullName: 'Admin', email: 'a@u.edu', username: 'a', role: 'Admin');

      expect(student.isStudent, true);
      expect(student.isRepresentative, false);
      expect(student.isAdmin, false);

      expect(rep.isRepresentative, true);
      expect(rep.isAdmin, false);

      expect(admin.isAdmin, true);
      expect(admin.isRepresentative, true); // Admin has representative capabilities
    });

    test('Assignment Status Enum mapping works both ways', () {
      expect(AssignmentStatusType.fromInt(0), AssignmentStatusType.notStarted);
      expect(AssignmentStatusType.fromInt(1), AssignmentStatusType.inProgress);
      expect(AssignmentStatusType.fromInt(2), AssignmentStatusType.completed);

      expect(AssignmentStatusType.notStarted.toInt(), 0);
      expect(AssignmentStatusType.inProgress.toInt(), 1);
      expect(AssignmentStatusType.completed.toInt(), 2);
    });

    test('Assignment deadline countdown calculations', () {
      final futureDeadline = DateTime.now().toUtc().add(const Duration(days: 3, hours: 2));
      final assignment = Assignment(
        id: 1,
        courseId: 10,
        courseNameAr: 'هندسة برمجيات',
        courseNameEn: 'Software Engineering',
        courseCode: 'CS401',
        doctorName: 'د. عبد الرزاق',
        cohortId: 1,
        cohortName: 'IT23',
        title: 'واجب UML',
        description: 'رسم مخططات',
        instructions: 'PDF فقط',
        publicationDateUtc: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        deadlineUtc: futureDeadline,
        createdByUserId: 1,
        createdByUserName: 'أحمد',
        isPublished: true,
        isCancelled: false,
        createdAtUtc: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        userStatus: AssignmentStatusType.notStarted,
        attachments: [],
      );

      expect(assignment.isOverdue, false);
      expect(assignment.remainingTime.inDays >= 2, true);
    });

    test('Overdue assignment logic', () {
      final pastDeadline = DateTime.now().toUtc().subtract(const Duration(days: 2));
      final overdueAssignment = Assignment(
        id: 2,
        courseId: 10,
        courseNameAr: 'أمن معلومات',
        courseNameEn: 'Security',
        courseCode: 'CS403',
        doctorName: 'د. سمير',
        cohortId: 1,
        cohortName: 'IT23',
        title: 'واجب تشفير',
        description: 'AES',
        instructions: 'تشفير',
        publicationDateUtc: DateTime.now().toUtc().subtract(const Duration(days: 5)),
        deadlineUtc: pastDeadline,
        createdByUserId: 1,
        createdByUserName: 'أحمد',
        isPublished: true,
        isCancelled: false,
        createdAtUtc: DateTime.now().toUtc().subtract(const Duration(days: 5)),
        userStatus: AssignmentStatusType.notStarted,
        attachments: [],
      );

      expect(overdueAssignment.isOverdue, true);

      // If marked completed, should not be considered overdue
      final completedAssignment = Assignment(
        id: 3,
        courseId: 10,
        courseNameAr: 'أمن معلومات',
        courseNameEn: 'Security',
        courseCode: 'CS403',
        doctorName: 'د. سمير',
        cohortId: 1,
        cohortName: 'IT23',
        title: 'واجب تشفير',
        description: 'AES',
        instructions: 'تشفير',
        publicationDateUtc: DateTime.now().toUtc().subtract(const Duration(days: 5)),
        deadlineUtc: pastDeadline,
        createdByUserId: 1,
        createdByUserName: 'أحمد',
        isPublished: true,
        isCancelled: false,
        createdAtUtc: DateTime.now().toUtc().subtract(const Duration(days: 5)),
        userStatus: AssignmentStatusType.completed,
        attachments: [],
      );

      expect(completedAssignment.isOverdue, false);
    });

    test('Course localization method returns correct language', () {
      final course = Course(
        id: 1,
        cohortId: 1,
        nameAr: 'برمجة متقدمة',
        nameEn: 'Advanced Programming',
        code: 'CS201',
        doctorName: 'د. خالد',
      );

      expect(course.localizedName('ar'), 'برمجة متقدمة');
      expect(course.localizedName('en'), 'Advanced Programming');
    });
  });

  group('2. Widget and Localization Tests', () {
    Widget createLocalizedWidget({required Widget child, Locale locale = const Locale('ar')}) {
      return MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
      );
    }

    testWidgets('EmptyStateWidget renders title, icon, and button', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        createLocalizedWidget(
          child: EmptyStateWidget(
            icon: Icons.assignment_outlined,
            title: 'لا توجد مهام',
            subtitle: 'جميع المهام مكتملة',
            buttonText: 'تحديث',
            onButtonPressed: () => buttonPressed = true,
          ),
        ),
      );

      expect(find.text('لا توجد مهام'), findsOneWidget);
      expect(find.text('جميع المهام مكتملة'), findsOneWidget);
      expect(find.text('تحديث'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);

      await tester.tap(find.text('تحديث'));
      expect(buttonPressed, true);
    });

    testWidgets('CountdownTimerWidget displays completed status correctly in Arabic', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(
          child: CountdownTimerWidget(
            deadlineUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
            isCompleted: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('أنجزت التكليف'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('CountdownTimerWidget displays completed status correctly in English', (tester) async {
      await tester.pumpWidget(
        createLocalizedWidget(
          locale: const Locale('en'),
          child: CountdownTimerWidget(
            deadlineUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
            isCompleted: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('AssignmentCard renders course code, title, and responds to tap', (tester) async {
      bool cardTapped = false;
      final assignment = Assignment(
        id: 10,
        courseId: 1,
        courseNameAr: 'هندسة البرمجيات',
        courseNameEn: 'Software Engineering',
        courseCode: 'CS401',
        doctorName: 'د. عبد الرزاق',
        cohortId: 1,
        cohortName: 'IT23',
        title: 'مشروع التخرج المرحلة الأولى',
        description: 'إعداد وثيقة المشروع والمخططات الأساسية',
        instructions: 'تسليم PDF',
        publicationDateUtc: DateTime.now().toUtc(),
        deadlineUtc: DateTime.now().toUtc().add(const Duration(days: 5)),
        createdByUserId: 1,
        createdByUserName: 'أحمد',
        isPublished: true,
        isCancelled: false,
        createdAtUtc: DateTime.now().toUtc(),
        userStatus: AssignmentStatusType.inProgress,
        attachments: [],
      );

      await tester.pumpWidget(
        createLocalizedWidget(
          child: AssignmentCard(
            assignment: assignment,
            onTap: () => cardTapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('مشروع التخرج المرحلة الأولى'), findsOneWidget);
      expect(find.textContaining('CS401'), findsOneWidget);
      expect(find.text('جاري العمل عليه'), findsOneWidget);

      await tester.tap(find.text('مشروع التخرج المرحلة الأولى'));
      expect(cardTapped, true);
    });

    test('StudentSubmission model parses and Assignment evaluates submission status', () {
      final sub = StudentSubmission(
        id: 1,
        assignmentId: 10,
        userId: 2,
        studentName: 'محمد أحمد',
        studentId: '44101',
        originalFileName: 'report.pdf',
        formattedFileName: '44101_محمد_أحمد_تقرير.pdf',
        extension: '.pdf',
        fileSize: 1024 * 500,
        contentType: 'application/pdf',
        status: 1,
        isLate: false,
        version: 1,
        submittedAtUtc: DateTime.now().toUtc(),
        downloadUrl: 'http://localhost/download',
      );

      final assignment = Assignment(
        id: 10,
        courseId: 1,
        courseNameAr: 'هندسة',
        courseNameEn: 'Eng',
        courseCode: 'CS401',
        doctorName: 'د. عبد الرزاق',
        cohortId: 1,
        cohortName: 'IT23',
        title: 'واجب',
        description: 'وصف',
        instructions: 'تعليمات',
        publicationDateUtc: DateTime.now().toUtc(),
        deadlineUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
        createdByUserId: 1,
        createdByUserName: 'مندوب',
        isPublished: true,
        isCancelled: false,
        createdAtUtc: DateTime.now().toUtc(),
        userStatus: AssignmentStatusType.notStarted,
        attachments: [],
        allowedExtensions: '.pdf,.cs',
        maxFileSizeMB: 15,
        allowReplacement: true,
        allowLateSubmission: true,
        mySubmission: sub,
      );

      expect(assignment.isSubmitted, true);
      expect(assignment.isSubmissionLate, false);
      expect(assignment.isOverdue, false);
    });

    testWidgets('AssignmentCard displays submitted badge when submission is present', (tester) async {
      final sub = StudentSubmission(
        id: 1,
        assignmentId: 11,
        userId: 2,
        studentName: 'محمد',
        studentId: '44101',
        originalFileName: 'report.pdf',
        formattedFileName: '44101_محمد_تقرير.pdf',
        extension: '.pdf',
        fileSize: 1024,
        contentType: 'application/pdf',
        status: 1,
        isLate: false,
        version: 1,
        submittedAtUtc: DateTime.now().toUtc(),
        downloadUrl: 'http://localhost/download',
      );

      final assignment = Assignment(
        id: 11,
        courseId: 1,
        courseNameAr: 'شبكات',
        courseNameEn: 'Networks',
        courseCode: 'NET101',
        doctorName: 'د. سمير',
        cohortId: 1,
        cohortName: 'IT23',
        title: 'واجب بروتوكول TCP',
        description: 'دراسة',
        instructions: 'ملف',
        publicationDateUtc: DateTime.now().toUtc(),
        deadlineUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
        createdByUserId: 1,
        createdByUserName: 'مندوب',
        isPublished: true,
        isCancelled: false,
        createdAtUtc: DateTime.now().toUtc(),
        userStatus: AssignmentStatusType.completed,
        attachments: [],
        mySubmission: sub,
      );

      await tester.pumpWidget(
        createLocalizedWidget(
          child: AssignmentCard(
            assignment: assignment,
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('تم التسليم في الموعد'), findsOneWidget);
    });
  });
}
