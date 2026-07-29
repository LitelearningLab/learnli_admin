import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:learnli_admin/providers/admin_provider.dart';
import 'package:learnli_admin/models/chapter_content_model.dart';
import 'package:learnli_admin/models/curriculum_models.dart';
import 'package:learnli_admin/views/tabs/chapter_content_editor.dart';

void main() {
  testWidgets('Test ContentTab - All Add Buttons', (WidgetTester tester) async {
    // Set screen size for test to avoid overflow
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockCurriculum = {
      'grade_7': Grade(
        name: 'Grade 7',
        description: 'Grade 7 curriculum',
        emoji: '🎓',
        subjects: [
          Subject(
            id: 'science',
            name: 'Science',
            emoji: '🔬',
            color: '#FF0000',
            chapters: [
              Chapter(number: 1, title: 'Nutrition in Plants'),
            ],
          ),
        ],
      ),
    };

    final mockContent = ChapterContent.empty(7, 'Science', 1, 'Nutrition in Plants');

    final prov = AdminProvider();
    prov.setupMockData(mockCurriculum, mockContent);

    await tester.pumpWidget(
      ChangeNotifierProvider<AdminProvider>.value(
        value: prov,
        child: const MaterialApp(
          home: Scaffold(
            body: ChapterContentEditor(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Simple Overview
    await tester.tap(find.text('Simple Overview'));
    await tester.pumpAndSettle();
    expect(find.text('Simple Overview HTML URL'), findsOneWidget);



    // 2. Pre-requisite Concepts
    final prerequisiteFinder = find.text('Pre-requisite Concepts');
    await tester.ensureVisible(prerequisiteFinder);
    await tester.pumpAndSettle();
    await tester.tap(prerequisiteFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Prerequisite'));
    await tester.pumpAndSettle();
    expect(find.text('Prerequisite #1'), findsOneWidget);

    // 3. Industry Insights
    final industryInsightsFinder = find.text('Industry Insights');
    await tester.ensureVisible(industryInsightsFinder);
    await tester.pumpAndSettle();
    await tester.tap(industryInsightsFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Application'));
    await tester.pumpAndSettle();
    expect(find.text('Application #1'), findsOneWidget);

    // 4. AI Learning Chips
    final aiChipsFinder = find.text('AI Learning Chips');
    await tester.ensureVisible(aiChipsFinder);
    await tester.pumpAndSettle();
    await tester.tap(aiChipsFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Chip'));
    await tester.pumpAndSettle();
    expect(find.text('Chip #1'), findsOneWidget);

    // 5. Plus Points Topics
    final plusPointsFinder = find.text('Plus Points Topics');
    await tester.ensureVisible(plusPointsFinder);
    await tester.pumpAndSettle();
    await tester.tap(plusPointsFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Topic'));
    await tester.pumpAndSettle();
    expect(find.text('Topic #1'), findsOneWidget);

    // 6. Quiz & Questions
    final quizFinder = find.text('Quiz & Questions');
    await tester.ensureVisible(quizFinder);
    await tester.pumpAndSettle();
    await tester.tap(quizFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add MCQ Question'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Question #1'), findsOneWidget);

    // 7. Pronunciation Lab
    final pronunciationFinder = find.text('Pronunciation Lab');
    await tester.ensureVisible(pronunciationFinder);
    await tester.pumpAndSettle();
    await tester.tap(pronunciationFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Vocabulary Word'));
    await tester.pumpAndSettle();
    expect(find.text('Word #1'), findsOneWidget);
  });
}
