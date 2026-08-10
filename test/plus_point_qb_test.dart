import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnli_admin/models/chapter_content_model.dart';

void main() {
  test('PlusPointQuestionBank parse and export json with marks', () {
    const jsonStr = '''{
  "type": "plus_point_question_bank",
  "chapter_number": "7",
  "chapter_name": "Integrals",
  "patterns": [
    {
      "id": "7.2.1",
      "concept_id": "7.2",
      "concept_name": "Integration as an Inverse Process of Differentiation",
      "pattern_number": "01",
      "pattern_name": "Direct Inspection and Standard Formula",
      "questions": [
        {
          "question_number": 1,
          "instruction": "By recognising the corresponding derivative, find an antiderivative of",
          "equation_latex": "\\\\sin 2x",
          "source": "NCERT Textbook – Exercise 7.1, Question 1"
        }
      ],
      "marks": 2
    },
    {
      "id": "7.6.3",
      "concept_id": "7.6",
      "concept_name": "Integration by Parts",
      "pattern_number": "13",
      "pattern_name": "Cyclic or Repeated Integration by Parts",
      "questions": [
        {
          "question_number": 1,
          "instruction": "Apply integration by parts twice",
          "equation_latex": "\\\\int e^{2x}\\\\sin x\\\\,dx",
          "source": "NCERT Textbook"
        }
      ],
      "marks": 10
    }
  ]
}''';

    final decoded = json.decode(jsonStr) as Map<String, dynamic>;
    final qb = PlusPointQuestionBank.fromJson(decoded);

    expect(qb.chapterNumber, '7');
    expect(qb.chapterName, 'Integrals');
    expect(qb.patterns.length, 2);
    expect(qb.patterns[0].marks, 2);
    expect(qb.patterns[1].marks, 10);

    final exported = qb.toJson();
    expect(exported['type'], 'plus_point_question_bank');
    expect(exported['patterns'][0]['marks'], 2);
    expect(exported['patterns'][1]['marks'], 10);
  });
}
